/**
 * PostgreSQL Database Migration Runner
 * =====================================
 * 
 * Reads SQL scripts from the ./scripts directory and executes them
 * in the correct order against the configured PostgreSQL database.
 * 
 * Folder Structure:
 *   scripts/
 *     01 SCHEMA/
 *       0001_app.schema.sql
 *     02 EXTENSIONS/
 *       0001_uuid_ossp.sql
 *     03 TYPES/
 *       0001_app.enum_status.sql
 *     04 TABLE/
 *       0001_app.tbl_user.sql
 *       0002_app.tbl_role.sql
 *     05 ALTER/
 *       0001_app.tbl_user_add_email.sql
 *     06 VIEWS/
 *       0001_app.vw_active_users.sql
 *     07 FUNCTIONS/
 *       0001_app.fn_get_user.sql
 *     08 PROCEDURES/
 *       0001_app.sp_create_user.sql
 *     09 TRIGGERS/
 *       0001_app.trg_user_audit.sql
 *     10 SEED/
 *       0001_app.seed_roles.sql
 * 
 * Usage:
 *   node migrate.js            - Run all pending migrations
 *   node migrate.js --status   - Show migration status
 *   node migrate.js --reset    - Reset migration history (WARNING: does not undo migrations)
 * 
 * Folders are executed in numeric prefix order (01, 02, 03...).
 * Scripts within each folder are executed in numeric prefix order (0001, 0002...).
 * Already-executed scripts are tracked and skipped on subsequent runs.
 */

const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const config = require('./config');

// ─── ANSI Color Helpers ─────────────────────────────────────────────────────

const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
  bgRed: '\x1b[41m',
  bgGreen: '\x1b[42m',
  bgYellow: '\x1b[43m',
};

function log(color, symbol, message) {
  console.log(`${color}${symbol}${colors.reset} ${message}`);
}

function logSuccess(msg) { log(colors.green, '  ✔', msg); }
function logError(msg) { log(colors.red, '  ✖', msg); }
function logInfo(msg) { log(colors.cyan, '  ℹ', msg); }
function logWarn(msg) { log(colors.yellow, '  ⚠', msg); }
function logSkip(msg) { log(colors.dim, '  ↷', msg); }
function logHeader(msg) {
  console.log();
  console.log(`${colors.bright}${colors.blue}${'═'.repeat(60)}${colors.reset}`);
  console.log(`${colors.bright}${colors.blue}  ${msg}${colors.reset}`);
  console.log(`${colors.bright}${colors.blue}${'═'.repeat(60)}${colors.reset}`);
  console.log();
}
function logSection(msg) {
  console.log();
  console.log(`${colors.bright}${colors.magenta}  ── ${msg} ${'─'.repeat(Math.max(0, 50 - msg.length))}${colors.reset}`);
}

// ─── Migration History Table ────────────────────────────────────────────────

const HISTORY_TABLE = `${config.migration.historySchema}.${config.migration.historyTable}`;

async function ensureHistoryTable(pool) {
  const createTableSQL = `
    CREATE TABLE IF NOT EXISTS ${HISTORY_TABLE} (
      id              SERIAL PRIMARY KEY,
      folder_name     VARCHAR(255) NOT NULL,
      script_name     VARCHAR(255) NOT NULL,
      script_hash     VARCHAR(64) NOT NULL,
      executed_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      execution_ms    INTEGER,
      success         BOOLEAN DEFAULT TRUE,
      UNIQUE(folder_name, script_name)
    );
  `;
  await pool.query(createTableSQL);
}

async function getExecutedScripts(pool) {
  const result = await pool.query(
    `SELECT folder_name, script_name, script_hash, executed_at 
     FROM ${HISTORY_TABLE} 
     WHERE success = TRUE
     ORDER BY id`
  );
  // Build a Set for fast lookups: "folderName/scriptName"
  const executed = new Map();
  for (const row of result.rows) {
    executed.set(`${row.folder_name}/${row.script_name}`, row);
  }
  return executed;
}

async function recordMigration(pool, folderName, scriptName, hash, executionMs, success) {
  await pool.query(
    `INSERT INTO ${HISTORY_TABLE} (folder_name, script_name, script_hash, execution_ms, success)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (folder_name, script_name) DO UPDATE 
     SET script_hash = $3, execution_ms = $4, success = $5, executed_at = NOW()`,
    [folderName, scriptName, hash, executionMs, success]
  );
}

async function resetHistory(pool) {
  await pool.query(`DROP TABLE IF EXISTS ${HISTORY_TABLE}`);
  logSuccess(`Migration history table "${HISTORY_TABLE}" has been dropped.`);
}

// ─── File System Helpers ────────────────────────────────────────────────────

/**
 * Get sorted migration folders from the scripts directory.
 * Folders must start with a numeric prefix (e.g., "01 SCHEMA", "02 TYPES").
 */
function getMigrationFolders(scriptsDir) {
  if (!fs.existsSync(scriptsDir)) {
    throw new Error(`Scripts directory not found: ${scriptsDir}`);
  }

  const entries = fs.readdirSync(scriptsDir, { withFileTypes: true });
  const folders = entries
    .filter(e => e.isDirectory() && /^\d+/.test(e.name))
    .map(e => ({
      name: e.name,
      order: parseInt(e.name.match(/^(\d+)/)[1], 10),
      fullPath: path.join(scriptsDir, e.name),
    }))
    .sort((a, b) => a.order - b.order);

  return folders;
}

/**
 * Get sorted SQL scripts from a folder.
 * Scripts must end with .sql and start with a numeric prefix (e.g., "0001_app.tbl_user.sql").
 */
function getScriptsInFolder(folderPath) {
  const entries = fs.readdirSync(folderPath, { withFileTypes: true });
  const scripts = entries
    .filter(e => e.isFile() && e.name.toLowerCase().endsWith('.sql') && /^\d+/.test(e.name))
    .map(e => ({
      name: e.name,
      order: parseInt(e.name.match(/^(\d+)/)[1], 10),
      fullPath: path.join(folderPath, e.name),
    }))
    .sort((a, b) => a.order - b.order);

  return scripts;
}

/**
 * Simple hash of file contents to detect changes.
 */
function hashContent(content) {
  const crypto = require('crypto');
  return crypto.createHash('sha256').update(content).digest('hex').substring(0, 16);
}

// ─── Migration Runner ───────────────────────────────────────────────────────

async function runMigrations() {
  const scriptsDir = path.resolve(config.migration.scriptsDir);
  const pool = new Pool(config.db);

  try {
    // Test connection
    logHeader('Service Center System OCR - Database Migration');
    logInfo(`Connecting to PostgreSQL at ${config.db.host}:${config.db.port}/${config.db.database}...`);

    const client = await pool.connect();
    const versionResult = await client.query('SELECT version()');
    logSuccess(`Connected! ${versionResult.rows[0].version.split(',')[0]}`);
    client.release();

    // Ensure migration history table
    await ensureHistoryTable(pool);
    logSuccess(`Migration history table "${HISTORY_TABLE}" is ready.`);

    // Get already-executed scripts
    const executedScripts = await getExecutedScripts(pool);

    // Get migration folders
    const folders = getMigrationFolders(scriptsDir);
    if (folders.length === 0) {
      logWarn(`No migration folders found in: ${scriptsDir}`);
      logInfo('Create folders like "01 SCHEMA", "02 TYPES", "03 TABLE", etc.');
      return;
    }

    logInfo(`Found ${folders.length} migration folder(s).`);

    let totalExecuted = 0;
    let totalSkipped = 0;
    let totalFailed = 0;

    // Process each folder in order
    for (const folder of folders) {
      const scripts = getScriptsInFolder(folder.fullPath);
      if (scripts.length === 0) {
        logSection(`${folder.name} (empty)`);
        continue;
      }

      logSection(`${folder.name} (${scripts.length} script${scripts.length > 1 ? 's' : ''})`);

      // Process each script in order
      for (const script of scripts) {
        const key = `${folder.name}/${script.name}`;
        const sqlContent = fs.readFileSync(script.fullPath, 'utf8').trim();
        const hash = hashContent(sqlContent);

        // Check if already executed
        if (executedScripts.has(key)) {
          const prev = executedScripts.get(key);
          if (prev.script_hash === hash) {
            logSkip(`${script.name} (already executed)`);
            totalSkipped++;
            continue;
          } else {
            logWarn(`${script.name} has CHANGED since last execution! Hash mismatch.`);
            logWarn(`  Previous: ${prev.script_hash} | Current: ${hash}`);
            logWarn(`  Skipping changed file. To re-run, use --reset or manually update history.`);
            totalSkipped++;
            continue;
          }
        }

        // Skip empty files
        if (!sqlContent) {
          logSkip(`${script.name} (empty file)`);
          totalSkipped++;
          continue;
        }

        // Execute the script within a transaction
        const client = await pool.connect();
        const startTime = Date.now();

        try {
          await client.query('BEGIN');
          await client.query(sqlContent);
          await client.query('COMMIT');

          const elapsed = Date.now() - startTime;
          await recordMigration(pool, folder.name, script.name, hash, elapsed, true);
          logSuccess(`${script.name} (${elapsed}ms)`);
          totalExecuted++;
        } catch (err) {
          await client.query('ROLLBACK');
          const elapsed = Date.now() - startTime;
          await recordMigration(pool, folder.name, script.name, hash, elapsed, false);
          logError(`${script.name} - FAILED!`);
          console.error(`${colors.red}    Error: ${err.message}${colors.reset}`);

          if (err.position) {
            console.error(`${colors.red}    Position: ${err.position}${colors.reset}`);
          }
          if (err.detail) {
            console.error(`${colors.red}    Detail: ${err.detail}${colors.reset}`);
          }

          totalFailed++;

          // Stop execution on error
          console.log();
          logError('Migration stopped due to error. Fix the script and re-run.');
          logInfo(`File: ${script.fullPath}`);

          // Print summary before exit
          printSummary(totalExecuted, totalSkipped, totalFailed);
          process.exit(1);
        } finally {
          client.release();
        }
      }
    }

    // Final summary
    printSummary(totalExecuted, totalSkipped, totalFailed);

  } catch (err) {
    logError(`Migration failed: ${err.message}`);
    console.error(err);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

function printSummary(executed, skipped, failed) {
  console.log();
  console.log(`${colors.bright}${'─'.repeat(60)}${colors.reset}`);
  console.log(`${colors.bright}  Migration Summary${colors.reset}`);
  console.log(`${colors.bright}${'─'.repeat(60)}${colors.reset}`);
  console.log(`${colors.green}    Executed:  ${executed}${colors.reset}`);
  console.log(`${colors.dim}    Skipped:   ${skipped}${colors.reset}`);
  if (failed > 0) {
    console.log(`${colors.red}    Failed:    ${failed}${colors.reset}`);
  }
  console.log(`${colors.bright}${'─'.repeat(60)}${colors.reset}`);
  console.log();
}

// ─── Status Command ─────────────────────────────────────────────────────────

async function showStatus() {
  const scriptsDir = path.resolve(config.migration.scriptsDir);
  const pool = new Pool(config.db);

  try {
    logHeader('Migration Status');
    logInfo(`Connecting to ${config.db.host}:${config.db.port}/${config.db.database}...`);

    await ensureHistoryTable(pool);
    const executedScripts = await getExecutedScripts(pool);

    logSuccess(`${executedScripts.size} script(s) previously executed.`);

    const folders = getMigrationFolders(scriptsDir);
    let pendingCount = 0;

    for (const folder of folders) {
      const scripts = getScriptsInFolder(folder.fullPath);
      if (scripts.length === 0) continue;

      logSection(folder.name);

      for (const script of scripts) {
        const key = `${folder.name}/${script.name}`;
        if (executedScripts.has(key)) {
          const info = executedScripts.get(key);
          const date = new Date(info.executed_at).toLocaleString();
          logSuccess(`${script.name} (ran: ${date})`);
        } else {
          logWarn(`${script.name} (PENDING)`);
          pendingCount++;
        }
      }
    }

    console.log();
    if (pendingCount > 0) {
      logWarn(`${pendingCount} pending migration(s). Run "npm run migrate" to execute.`);
    } else {
      logSuccess('All migrations are up to date!');
    }

  } catch (err) {
    logError(`Status check failed: ${err.message}`);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// ─── CLI Entry Point ────────────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--status')) {
    await showStatus();
  } else if (args.includes('--reset')) {
    const pool = new Pool(config.db);
    try {
      logHeader('Reset Migration History');
      logWarn('This will DROP the migration history table.');
      logWarn('It will NOT undo any executed SQL scripts.');
      await resetHistory(pool);
    } finally {
      await pool.end();
    }
  } else {
    await runMigrations();
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
