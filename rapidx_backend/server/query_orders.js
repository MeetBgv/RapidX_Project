const pool = require('./src/config/db');
const fs = require('fs');

async function testQuery() {
  const query = `
    SELECT * from orders LIMIT 2
  `;
  try {
    const res = await pool.query(query);
    fs.writeFileSync('orders_result.txt', JSON.stringify(res.rows, null, 2), 'utf-8');
    const p = await pool.query("SELECT * FROM parcels LIMIT 2");
    fs.appendFileSync('orders_result.txt', '\n' + JSON.stringify(p.rows, null, 2), 'utf-8');
  } catch (err) {
    fs.writeFileSync('orders_result.txt', err.toString(), 'utf-8');
  }
  process.exit(0);
}
testQuery();
