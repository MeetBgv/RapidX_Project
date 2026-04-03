const pool = require('./src/config/db');
const { computeOrderRoute } = require('./src/services/dijkstraService');

async function backfill() {
    console.log("Fetching orders without route_data...");
    const result = await pool.query(
        `SELECT order_id, sender_lat, sender_lng, receiver_lat, receiver_lng, fare_breakdown 
         FROM orders 
         WHERE route_data IS NULL AND sender_lat IS NOT NULL`
    );

    console.log(`Found ${result.rows.length} orders.`);

    let updated = 0;
    for (const order of result.rows) {
        // If mode is local delivery, skip
        let isIntercity = true;
        try {
            const fare = order.fare_breakdown;
            if (fare && fare.mode === 'LOCAL_DELIVERY') {
                isIntercity = false;
            }
        } catch (e) {}

        if (isIntercity) {
            const route = await computeOrderRoute(
                order.sender_lat, order.sender_lng, 
                order.receiver_lat, order.receiver_lng
            );
            if (route) {
                await pool.query(
                    `UPDATE orders SET route_data = $1 WHERE order_id = $2`,
                    [JSON.stringify(route), order.order_id]
                );
                updated++;
            }
        }
    }
    
    console.log(`Successfully backfilled ${updated} orders.`);
    process.exit();
}
backfill();
