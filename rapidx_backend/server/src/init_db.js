const pool = require('./config/db');

async function createPricingTables() {
    try {
        console.log("Starting table creation...");

        // 1. Create distance_rates for Local Delivery
        await pool.query(`DROP TABLE IF EXISTS distance_rates CASCADE;`);
        await pool.query(`
            CREATE TABLE distance_rates (
                id SERIAL PRIMARY KEY,
                vehicle_type_id INTEGER NOT NULL,
                min_km DECIMAL NOT NULL,
                max_km DECIMAL NOT NULL,
                price_per_km DECIMAL NOT NULL,
                base_price DECIMAL NOT NULL
            );
        `);

        // Insert defaults for distance_rates (Local Delivery)
        // Bike (id=1): base 40, per km chunks
        // Mini Tempo (id=3): base 120, per km chunks
        // Tempo (id=4): base 250, per km chunks
        // Example simplification: one rate for 0-40km
        await pool.query(`
            INSERT INTO distance_rates (vehicle_type_id, min_km, max_km, price_per_km, base_price)
            VALUES 
                (1, 0, 40, 8, 40),
                (3, 0, 40, 15, 120),
                (4, 0, 40, 25, 250);
        `);

        // 2. Create distance_zones for Intercity Delivery
        await pool.query(`DROP TABLE IF EXISTS distance_zones CASCADE;`);
        await pool.query(`
            CREATE TABLE distance_zones (
                zone_id SERIAL PRIMARY KEY,
                min_km DECIMAL NOT NULL,
                max_km DECIMAL NOT NULL
            );
        `);

        await pool.query(`
            INSERT INTO distance_zones (zone_id, min_km, max_km)
            VALUES 
                (1, 40, 50),
                (2, 50, 150),
                (3, 150, 300),
                (4, 300, 600),
                (5, 600, 1200),
                (6, 1200, 2000),
                (7, 2000, 5000);
        `);

        // 3. Create zone_pricing inside distance_zones
        await pool.query(`DROP TABLE IF EXISTS zone_pricing CASCADE;`);
        await pool.query(`
            CREATE TABLE zone_pricing (
                id SERIAL PRIMARY KEY,
                zone_id INTEGER NOT NULL,
                vehicle_type_id INTEGER NOT NULL,
                base_price DECIMAL NOT NULL
            );
        `);

        // Default prices for varying zones and vehicles
        await pool.query(`
            INSERT INTO zone_pricing (zone_id, vehicle_type_id, base_price)
            VALUES 
                (1, 1, 80), (1, 3, 200), (1, 4, 400),
                (2, 1, 100), (2, 3, 300), (2, 4, 600),
                (3, 1, 120), (3, 3, 400), (3, 4, 800),
                (4, 1, 180), (4, 3, 500), (4, 4, 1000),
                (5, 1, 250), (5, 3, 500), (5, 4, 900),
                (6, 1, 400), (6, 3, 800), (6, 4, 1400),
                (7, 1, 600), (7, 3, 1200), (7, 4, 2000);
        `);

        // 4. Create weight_slabs
        await pool.query(`DROP TABLE IF EXISTS weight_slabs CASCADE;`);
        await pool.query(`
            CREATE TABLE weight_slabs (
                id SERIAL PRIMARY KEY,
                min_weight DECIMAL NOT NULL,
                max_weight DECIMAL NOT NULL,
                price DECIMAL NOT NULL
            );
        `);

        // Weight pricing slabs
        await pool.query(`
            INSERT INTO weight_slabs (min_weight, max_weight, price)
            VALUES 
                (0, 5, 100),
                (5.01, 10, 250),
                (10.01, 20, 420),
                (20.01, 50, 800),
                (50.01, 1000, 1500);
        `);

        console.log("Successfully created and seeded pricing tables.");
        process.exit(0);

    } catch (error) {
        console.error("Error creating tables: ", error);
        process.exit(1);
    }
}

createPricingTables();
