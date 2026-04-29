const pool = require('./config/db');

async function migratePaymentPayout() {
    try {
        console.log("Starting payment & payout migration...");

        // 1. Add payment_method column to orders table
        await pool.query(`
            ALTER TABLE orders 
            ADD COLUMN IF NOT EXISTS payment_method VARCHAR(20) DEFAULT 'cash'
        `);
        console.log("✅ Added payment_method column to orders table");

        // 2. Create delivery_partner_payout_orders table 
        //    (Drop if exists so we can rebuild with proper schema)
        await pool.query(`
            CREATE TABLE IF NOT EXISTS delivery_partner_payout_orders (
                payout_order_id SERIAL PRIMARY KEY,
                order_id BIGINT NOT NULL,
                delivery_partner_id BIGINT NOT NULL,
                order_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
                dp_share DECIMAL(10,2) NOT NULL DEFAULT 0,
                admin_share DECIMAL(10,2) NOT NULL DEFAULT 0,
                payment_method VARCHAR(20) NOT NULL DEFAULT 'cash',
                cash_collected DECIMAL(10,2) DEFAULT 0,
                cash_deposited BOOLEAN DEFAULT false,
                cash_deposit_confirmed BOOLEAN DEFAULT false,
                is_paid BOOLEAN DEFAULT false,
                status VARCHAR(30) DEFAULT 'pending',
                partner_transaction_id VARCHAR(100),
                notes TEXT,
                created_at TIMESTAMP DEFAULT NOW(),
                paid_at TIMESTAMP,
                confirmed_at TIMESTAMP
            )
        `);
        console.log("✅ Created delivery_partner_payout_orders table");

        // 3. Add amount, dp_share, admin_share columns if they don't exist
        //    (for backward compat if table existed with different schema)
        const colChecks = [
            { col: 'order_amount', type: 'DECIMAL(10,2) DEFAULT 0' },
            { col: 'dp_share', type: 'DECIMAL(10,2) DEFAULT 0' },
            { col: 'admin_share', type: 'DECIMAL(10,2) DEFAULT 0' },
            { col: 'payment_method', type: "VARCHAR(20) DEFAULT 'cash'" },
            { col: 'cash_collected', type: 'DECIMAL(10,2) DEFAULT 0' },
            { col: 'cash_deposited', type: 'BOOLEAN DEFAULT false' },
            { col: 'cash_deposit_confirmed', type: 'BOOLEAN DEFAULT false' },
            { col: 'status', type: "VARCHAR(30) DEFAULT 'pending'" },
            { col: 'notes', type: 'TEXT' },
            { col: 'partner_transaction_id', type: 'VARCHAR(100)' },
            { col: 'paid_at', type: 'TIMESTAMP' },
            { col: 'confirmed_at', type: 'TIMESTAMP' },
        ];

        for (const { col, type } of colChecks) {
            try {
                await pool.query(`ALTER TABLE delivery_partner_payout_orders ADD COLUMN IF NOT EXISTS ${col} ${type}`);
            } catch (e) {
                // Column might already exist
            }
        }
        console.log("✅ Ensured all payout columns exist");

        console.log("\n🎉 Payment & payout migration complete!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Migration error:", error);
        process.exit(1);
    }
}

migratePaymentPayout();
