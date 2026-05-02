const { Pool } = require('pg');
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'rapidx',
  password: 'Meet@98985544',
  port: 5432
});

pool.query(`ALTER TABLE orders ADD COLUMN payment_method VARCHAR(50) DEFAULT 'cash'`)
  .then(res => {
    console.log('Successfully added payment_method column to orders table.');
    process.exit(0);
  })
  .catch(err => {
    console.log('Error adding column:', err);
    process.exit(1);
  });
