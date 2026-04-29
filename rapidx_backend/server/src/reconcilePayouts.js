const pool = require("./config/db");
const { createPayoutForOrder } = require("./services/userService");

async function reconcilePayouts() {
    try {
        console.log("Starting payout reconciliation...");
        
        // Find delivered orders without a payout record
        const query = `
            SELECT o.*, vm.value_name as status_name
            FROM orders o
            LEFT JOIN value_master vm ON o.delivery_status_id = vm.value_id
            LEFT JOIN delivery_partner_payout_orders ppo ON o.order_id = ppo.order_id
            WHERE vm.value_name = 'Delivered' 
              AND ppo.payout_order_id IS NULL
              AND o.delivery_partner_id IS NOT NULL;
        `;
        
        const { rows: missingOrders } = await pool.query(query);
        console.log(`Found ${missingOrders.length} delivered orders without payout records.`);
        
        for (const order of missingOrders) {
            console.log(`Processing Order ${order.order_id} (Amount: ${order.order_amount})...`);
            try {
                const payout = await createPayoutForOrder(order);
                if (payout) {
                    console.log(`Successfully created payout record ${payout.payout_order_id} for Order ${order.order_id}`);
                } else {
                    console.error(`Failed to create payout record for Order ${order.order_id}`);
                }
            } catch (err) {
                console.error(`Error processing Order ${order.order_id}:`, err);
            }
        }
        
        console.log("Reconciliation finished.");
    } catch (error) {
        console.error("Reconciliation script failed:", error);
    } finally {
        // We don't close the pool if we're in the same process, but here we might want to if running as standalone
        // However, I can't run it as standalone easily.
    }
}

// reconcilePayouts();
module.exports = reconcilePayouts;
