

require('dotenv').config();

const config = {
    
    db: {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT) || 5433,
        database: process.env.DB_NAME || 'ServiceCentreDb',
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || 'momo',

        ssl: {
            rejectUnauthorized: false
        },

        max: 5,                    
        idleTimeoutMillis: 30000,  
        connectionTimeoutMillis: 10000, 
    },

    migration: {
        
        historyTable: '_migration_history',

        historySchema: 'public',

        scriptsDir: './scripts',
    }
};

module.exports = config;