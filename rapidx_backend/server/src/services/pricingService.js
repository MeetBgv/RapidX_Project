const pool = require('../config/db');

// Multipliers based on User rules
const getUrgencyMultiplier = (urgency) => {
    switch (urgency?.toLowerCase()) {
        case 'express': return 1.35;
        case 'priority': return 1.6;
        case 'normal':
        default: return 1.0;
    }
};

const calculatePrice = async (distance, weight, vehicle_id, urgency, is_in_city) => {
    try {
        let final_price = 0;
        let base_price = 0;
        let distance_cost = 0;
        let zone = null;
        let zone_price = 0;
        let weight_price = 0;
        let rate_per_km = 0;

        // Ensure numerics
        distance = parseFloat(distance);
        weight = parseFloat(weight);

        // Step 1: Detect Mode
        let mode;
        if (is_in_city === true) {
            mode = 'LOCAL_DELIVERY';
        } else if (distance <= 40 && is_in_city !== false) {
            mode = 'LOCAL_DELIVERY';
        } else if (distance <= 300) {
            mode = 'INTERCITY_DIRECT';
        } else {
            mode = 'COURIER_NETWORK';
        }

        if (mode === 'LOCAL_DELIVERY') {
            if (is_in_city === true) {
                // In-city fixed rates based on user's business rules
                if (vehicle_id == 1 || vehicle_id == 2) {
                    base_price = 50;
                    rate_per_km = 10;
                } else if (vehicle_id == 3) {
                    base_price = 150;
                    rate_per_km = 20;
                } else {
                    base_price = 200;
                    rate_per_km = 25;
                }

                let extra_km = Math.max(0, distance - 3);
                distance_cost = extra_km * rate_per_km;
                final_price = base_price + distance_cost;
                zone_price = 0;
                weight_price = 0;
            } else {
                // Local Delivery Pricing fallback (if not explicity in-city or backward compat)
                // Query distance rate
                const rateQuery = await pool.query(
                    `SELECT price_per_km, base_price 
                     FROM distance_rates 
                     WHERE vehicle_type_id = $1 
                     AND $2 BETWEEN min_km AND max_km
                     LIMIT 1;`,
                    [vehicle_id, distance]
                );

                if (rateQuery.rows.length > 0) {
                    rate_per_km = parseFloat(rateQuery.rows[0].price_per_km);
                    base_price = parseFloat(rateQuery.rows[0].base_price);
                } else {
                    // Fallback constraints if DB not seeded
                    base_price = vehicle_id === 1 ? 40 : (vehicle_id === 3 ? 120 : 250);
                    rate_per_km = 8;
                }

                distance_cost = distance * rate_per_km;
                final_price = base_price + distance_cost;
                zone_price = 0;
                weight_price = 0;
            }
        } else {
            // Intercity Delivery Pricing
            // 5.1 Find Distance Zone
            const zoneQuery = await pool.query(
                `SELECT zone_id 
                 FROM distance_zones 
                 WHERE $1 BETWEEN min_km AND max_km
                 LIMIT 1;`,
                [distance]
            );

            zone = zoneQuery.rows.length > 0 ? zoneQuery.rows[0].zone_id : 3;

            // 5.2 Get Zone Base Price
            const zonePriceQuery = await pool.query(
                `SELECT base_price 
                 FROM zone_pricing 
                 WHERE zone_id = $1 AND vehicle_type_id = $2
                 LIMIT 1;`,
                [zone, vehicle_id]
            );

            zone_price = zonePriceQuery.rows.length > 0 ? parseFloat(zonePriceQuery.rows[0].base_price) : 120;

            // 5.3 Get Weight Price
            const weightQuery = await pool.query(
                `SELECT price 
                 FROM weight_slabs 
                 WHERE $1 BETWEEN min_weight AND max_weight
                 LIMIT 1;`,
                [weight]
            );

            weight_price = weightQuery.rows.length > 0 ? parseFloat(weightQuery.rows[0].price) : (weight * 18);

            // 5.4 Calculate Base Price for Intercity
            base_price = zone_price + weight_price;
            final_price = base_price;
        }

        // Apply Urgency Multiplier
        let multiplier = getUrgencyMultiplier(urgency);
        final_price = final_price * multiplier;

        // Construct fare breakdown
        const fare_breakdown = {
            distance_km: distance,
            mode: mode,
            vehicle_id: vehicle_id,
            urgency: urgency || "Normal",
            multiplier: multiplier,
            final_price: parseFloat(final_price.toFixed(2))
        };

        // Append mode specific details to breakdown
        if (mode === 'LOCAL_DELIVERY') {
            fare_breakdown.base_price = base_price;
            fare_breakdown.rate_per_km = rate_per_km;
            fare_breakdown.distance_cost = parseFloat(distance_cost.toFixed(2));
        } else {
            fare_breakdown.zone = zone;
            fare_breakdown.zone_price = zone_price;
            fare_breakdown.weight_price = weight_price;
            fare_breakdown.base_price = base_price; // Which is zone_price + weight_price here
        }

        return fare_breakdown;

    } catch (error) {
        console.error("Pricing Engine Error:", error);
        throw error;
    }
};

module.exports = {
    calculatePrice
};
