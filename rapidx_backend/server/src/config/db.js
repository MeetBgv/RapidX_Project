const pg = require('pg');
const dotenv = require('dotenv');
const { Pool } = pg;
dotenv.config();

const poolConfig = process.env.DB_URL 
    ? {
        connectionString: process.env.DB_URL,
        ssl: {
            rejectUnauthorized: false
        }
    }
    : {
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        password: process.env.DB_PASSWORD,
        port: process.env.DB_PORT,
        ssl: {
            rejectUnauthorized: false
        }
    };

const pool = new Pool(poolConfig);

pool.on("connect", () => {
    console.log("Connection pool established with Database");
});

module.exports = pool;