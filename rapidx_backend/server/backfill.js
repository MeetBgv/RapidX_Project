const pool = require('./src/config/db');


async function backfillPayouts() {
    try {
        // Find orders that are completed or picked up (cash) but have no payout
        const query = `
            SELECT o.* 
            FROM orders o
            LEFT JOIN delivery_partner_payout_orders p ON o.order_id = p.order_id
            WHERE p.payout_order_id IS NULL
              AND o.delivery_partner_id IS NOT NULL
              AND (
                  o.is_complete = true 
                  OR (o.payment_method = 'cash' AND o.delivery_status_id IN (
                      SELECT value_id FROM value_master WHERE value_name IN ('Picked Up', 'In Transit', 'Delivered')
                  ))
              )
              AND EXISTS (SELECT 1 FROM delivery_partner dp WHERE dp.delivery_partner_id = o.delivery_partner_id)
        `;
        const { rows: missingOrders } = await pool.query(query);
        console.log(`Found ${missingOrders.length} orders missing payouts.`);

        let insertedCount = 0;
        for (const order of missingOrders) {
            const DP_SHARE_PERCENT = 0.80;
            const ADMIN_SHARE_PERCENT = 0.20;
            
            const orderAmount = Number(order.order_amount) || 0;
            const dpShare = Math.round(orderAmount * DP_SHARE_PERCENT * 100) / 100;
            const adminShare = Math.round(orderAmount * ADMIN_SHARE_PERCENT * 100) / 100;
            
            const paymentMethod = String(order.payment_method || 'cash').trim().toLowerCase();
            const isCash = paymentMethod === 'cash';
            const status = isCash ? 'cash_pending' : 'awaiting_payout';
            
            // Just use a random integer if generateId is not available
            const payoutOrderId = Math.floor(100000 + Math.random() * 900000);

            await pool.query(`
              INSERT INTO delivery_partner_payout_orders 
                (payout_order_id, order_id, delivery_partner_id, order_amount, amount, dp_share, admin_share, 
                 payment_method, cash_collected, status, created_at)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
            `, [
              payoutOrderId,
              order.order_id,
              order.delivery_partner_id,
              orderAmount,
              dpShare,
              dpShare,
              adminShare,
              paymentMethod,
              isCash ? orderAmount : 0,
              status
            ]);
            insertedCount++;
        }
        console.log(`Backfilled ${insertedCount} payouts successfully.`);
        process.exit(0);
    } catch (e) {
        console.error("Error backfilling payouts:", e);
        process.exit(1);
    }
}

backfillPayouts();
