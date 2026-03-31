/**
 * Hub Migration Runner
 * Run: node src/run_hub_migration.js
 * This creates the hubs table and seeds all hub data into your PostgreSQL database.
 */
const pool = require('./config/db');
const fs = require('fs');
const path = require('path');

async function runHubMigration() {
    const client = await pool.connect();
    try {
        console.log('🚀 Starting hub migration...');
        const sql = fs.readFileSync(path.join(__dirname, 'migrate_hubs.sql'), 'utf8');
        await client.query(sql);
        console.log('✅ Hub migration completed successfully!');

        const result = await client.query('SELECT hub_type, COUNT(*) FROM hubs GROUP BY hub_type ORDER BY hub_type');
        console.log('\n📊 Hub Summary:');
        result.rows.forEach(row => {
            console.log(`   ${row.hub_type.padEnd(10)}: ${row.count} hubs`);
        });
    } catch (err) {
        console.error('❌ Hub migration failed:', err.message);
        throw err;
    } finally {
        client.release();
        pool.end();
    }
}

runHubMigration();
