const pool = require('./src/config/db');
async function query() {
  const o = await pool.query("SELECT * FROM orders LIMIT 1");
  console.log("Orders:", Object.keys(o.rows[0] || {}));
  const p = await pool.query("SELECT * FROM parcels LIMIT 1");
  console.log("Parcels:", Object.keys(p.rows[0] || {}));
  process.exit(0);
}
query();
