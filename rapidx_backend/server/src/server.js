const dotenv = require('dotenv');
const app = require('./app');
const pool = require('./config/db');
dotenv.config();

const port = process.env.PORT || 3000;

app.listen(port, async () => {
    console.log(`Your backend server is running in http://localhost:${port}`);
    try {
        await pool.query('SELECT NOW()');
    } catch (err) {
        console.error("Failed to connect to database:", err.message);
    }
});