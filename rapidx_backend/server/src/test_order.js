const http = require('http');

// Use the actual token from Flutter logs (or we test login + order)
// First, we'll simulate by checking if the backend starts correctly with our changes

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/users/orders/pending',
  method: 'GET',
  headers: { 'Content-Type': 'application/json' }
};

const req = http.request(options, (res) => {
  let body = '';
  res.on('data', chunk => body += chunk);
  res.on('end', () => {
    console.log('Pending orders status:', res.statusCode);
    console.log('Response:', body.substring(0, 200));
    process.exit(0);
  });
});
req.on('error', (e) => { console.error('ERROR:', e.message); process.exit(1); });
req.end();
