const pool = require('./src/config/db');

async function fixSchemaAgain() {
    try {
        const query = `
            ALTER TABLE delivery_partner_payout_orders
            ADD COLUMN IF NOT EXISTS cash_deposited BOOLEAN DEFAULT false,
            ADD COLUMN IF NOT EXISTS cash_deposit_confirmed BOOLEAN DEFAULT false,
            ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP;
        `;
        await pool.query(query);
        console.log("Schema updated successfully again!");
        process.exit(0);
    } catch (e) {
        console.error("Error updating schema:", e.message);
        process.exit(1);
    }
}
fixSchemaAgain();
