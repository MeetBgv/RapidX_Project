const pool = require('./src/config/db');

async function test() {
    try {
        const { rows } = await pool.query(`
            SELECT 
                COALESCE(SUM(CASE WHEN status = 'cash_pending' THEN cash_collected ELSE 0 END), 0) as cash_in_hand,
                COALESCE(SUM(CASE WHEN status = 'awaiting_payout' THEN dp_share ELSE 0 END), 0) as unpaid_online_earnings,
                COALESCE(SUM(CASE WHEN status = 'paid' THEN dp_share ELSE 0 END), 0) as lifetime_earnings
            FROM delivery_partner_payout_orders
            WHERE delivery_partner_id = 10574138
        `);
        console.log(rows);
        process.exit(0);
    } catch (e) {
        console.error(e.message);
        process.exit(1);
    }
}
test();
