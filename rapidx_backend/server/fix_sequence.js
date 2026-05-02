const pool = require('./src/config/db');

async function fixSequence() {
    try {
        await pool.query(`
            CREATE SEQUENCE IF NOT EXISTS order_status_history_order_status_id_seq;
            ALTER TABLE order_status_history 
            ALTER COLUMN order_status_id SET DEFAULT nextval('order_status_history_order_status_id_seq');
            ALTER SEQUENCE order_status_history_order_status_id_seq OWNED BY order_status_history.order_status_id;
            
            -- Also set current sequence value just in case there are existing rows
            SELECT setval('order_status_history_order_status_id_seq', COALESCE((SELECT MAX(order_status_id) FROM order_status_history), 1));
            
            -- Same for updating_partner_id, if updating_partner_id is currently NOT NULL, we should probably allow it to be NULL because the code inserts NULL sometimes
            ALTER TABLE order_status_history ALTER COLUMN updating_partner_id DROP NOT NULL;
        `);
        console.log("Schema sequence fixed successfully.");
        process.exit(0);
    } catch (e) {
        console.error("Error updating schema:", e.message);
        process.exit(1);
    }
}
fixSequence();
