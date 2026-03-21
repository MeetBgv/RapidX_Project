const pool = require('./config/db');

async function testOrder() {
  try {
    const result = await pool.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'orders'
      ORDER BY ordinal_position
    `);
    console.log('Orders table columns:');
    result.rows.forEach(r => {
      console.log(`  ${r.column_name} (${r.data_type}) nullable=${r.is_nullable}`);
    });
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

testOrder();
