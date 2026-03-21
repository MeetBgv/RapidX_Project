const pool = require('./src/config/db');
pool.query('SELECT * FROM roles_master').then(res => {
  console.log(JSON.stringify(res.rows, null, 2));
  process.exit(0);
}).catch(err => {
  console.error(err);
  process.exit(1);
});
