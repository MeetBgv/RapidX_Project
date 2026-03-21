const pool = require('./src/config/db');

async function dbChanges() {
  try {
    await pool.query(`ALTER TABLE users ADD COLUMN current_lat DOUBLE PRECISION, ADD COLUMN current_lng DOUBLE PRECISION;`);
    console.log("Columns added to users.");
  } catch(e) { console.log(e.message); }
  
  try {
    // 18.5204, 73.8567 is Pune, let's make it slightly different for customers
    // 18.5210, 73.8570
    await pool.query(`UPDATE users SET current_lat = 18.5210, current_lng = 73.8570 WHERE current_lat IS NULL;`);
    console.log("Mock data set for users.");
  } catch(e) { console.log(e.message); }
  
  process.exit(0);
}

dbChanges();
