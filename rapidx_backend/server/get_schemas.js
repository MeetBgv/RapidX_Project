const pool = require('./src/config/db');

async function getSchemas() {
  const t1 = await pool.query("SELECT * FROM information_schema.columns WHERE table_name = 'orders'");
  const t2 = await pool.query("SELECT * FROM information_schema.columns WHERE table_name = 'parcels'");
  console.log('Orders columns:', t1.rows.map(r => r.column_name));
  console.log('Parcels columns:', t2.rows.map(r => r.column_name));
  process.exit(0);
}
getSchemas();
