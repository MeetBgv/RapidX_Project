const pool = require('./src/config/db');

async function test() {
    try {
        const { rows } = await pool.query(`
            SELECT column_name, data_type, column_default, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'order_status_history';
        `);
        console.log(rows);
        process.exit(0);
    } catch (e) {
        console.error(e.message);
        process.exit(1);
    }
}
test();
