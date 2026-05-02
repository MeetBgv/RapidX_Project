const pool = require('./src/config/db');

async function test() {
    try {
        const { rows } = await pool.query('SELECT order_id, delivery_partner_id, is_complete FROM orders ORDER BY created_at DESC LIMIT 5');
        console.log(rows);
        process.exit(0);
    } catch (e) {
        console.error(e.message);
        process.exit(1);
    }
}
test();
