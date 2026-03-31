const { Pool } = require('pg');

const pool = new Pool({
    connectionString: "postgresql://postgres:Meet%4098985544@db.vhvyypwbobeutfhyadot.supabase.co:5432/postgres?sslmode=no-verify",
});

async function check() {
    try {
        const users = await pool.query('SELECT user_id, email, role_id FROM users');
        console.log('--- Users ---');
        console.table(users.rows);

        const orders = await pool.query('SELECT order_id, delivery_partner_id, delivery_status_id FROM orders');
        console.log('--- Orders ---');
        console.table(orders.rows);

        const dps = await pool.query('SELECT delivery_partner_id, is_verified FROM delivery_partner');
        console.log('--- Delivery Partners ---');
        console.table(dps.rows);

    } catch (err) {
        console.error(err);
    } finally {
        await pool.end();
    }
}

check();
