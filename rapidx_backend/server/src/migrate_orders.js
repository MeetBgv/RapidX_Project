const pool = require('./config/db');

async function migrate() {
  try {
    console.log('Running orders table migration...');
    await pool.query(`
      ALTER TABLE orders
        ADD COLUMN IF NOT EXISTS delivery_partner_id INTEGER,
        ADD COLUMN IF NOT EXISTS sender_lat  NUMERIC,
        ADD COLUMN IF NOT EXISTS sender_lng  NUMERIC,
        ADD COLUMN IF NOT EXISTS receiver_lat NUMERIC,
        ADD COLUMN IF NOT EXISTS receiver_lng NUMERIC;
    `);
    console.log('Migration complete.');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrate();
