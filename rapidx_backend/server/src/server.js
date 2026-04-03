const dotenv = require('dotenv');
const app = require('./app');
const pool = require('./config/db');
dotenv.config();

const port = process.env.PORT || 3000;

const startServer = async () => {
    let retries = 5;
    while (retries > 0) {
        try {
            await pool.query('SELECT NOW()');
            console.log("Database connected successfully");
            break; // Exit the loop if successful
        } catch (err) {
            console.error(`Failed to connect to database. Retries left: ${retries - 1}. Error: ${err.message}`);
            retries -= 1;
            if (retries === 0) {
                console.error("Could not connect to database after maximum retries. Starting server anyway, but requests may fail.");
                break;
            }
            // Wait 3 seconds before retrying
            await new Promise(res => setTimeout(res, 3000));
        }
    }

    app.listen(port, () => {
        console.log(`Your backend server is running in http://localhost:${port}`);
    });
};

startServer();

module.exports = app;