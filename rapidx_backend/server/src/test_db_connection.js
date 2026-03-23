const pool = require('./config/db');
const dotenv = require('dotenv');
dotenv.config({ path: '../.env' });

async function testConnection() {
    try {
        console.log("Trying to connect with DB_URL:", process.env.DB_URL);
        const res = await pool.query('SELECT NOW()');
        console.log("SUCCESS! Database returned:", res.rows[0]);
    } catch (err) {
        console.error("CONNECTION FAILED:", err.message);
        if (err.stack) console.error(err.stack);
    } finally {
        await pool.end();
        process.exit();
    }
}

testConnection();
