/**
 * PostgreSQL Database Configuration
 * 
 * Update these values to match your PostgreSQL server settings.
 * You can also use environment variables for sensitive data.
 */

const config = {
    // Database connection settings
    db: {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT) || 5433,
        database: process.env.DB_NAME || 'ServiceCenterDb',
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || 'momo',

        ssl: {
            rejectUnauthorized: false
        },

        // Connection pool settings
        max: 5,                    // Maximum number of clients in the pool
        idleTimeoutMillis: 30000,  // Close idle clients after 30 seconds
        connectionTimeoutMillis: 10000, // Return an error after 10 seconds if connection could not be established
    },

    // Migration settings
    migration: {
        // Table to track migration history
        historyTable: '_migration_history',

        // Schema for the migration history table (use 'public' if unsure)
        historySchema: 'public',

        // Directory containing migration scripts (relative to project root)
        scriptsDir: './scripts',
    }
};

module.exports = config;