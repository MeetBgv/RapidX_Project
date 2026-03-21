const http = require('http');

// First login to get a token
const loginData = JSON.stringify({
  phone: '9999999999',  // replace with a real test user phone
  password: 'test123',
  role: 'customer'
});

const loginOptions = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/users/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(loginData)
  }
};

const loginReq = http.request(loginOptions, (res) => {
  let body = '';
  res.on('data', chunk => body += chunk);
  res.on('end', () => {
    console.log('Login response:', res.statusCode, body);
    try {
      const parsed = JSON.parse(body);
      const token = parsed.token;
      if (token) {
        testCreateOrder(token);
      }
    } catch(e) {
      console.error('Login parse error:', e.message);
    }
  });
});

loginReq.on('error', (e) => console.error('Login error:', e.message));
loginReq.write(loginData);
loginReq.end();

function testCreateOrder(token) {
  const orderData = JSON.stringify({
    sender_name: 'Test Sender',
    sender_phone: '9876543210',
    sender_address: '123 Sender St',
    sender_state: 'Gujarat',
    sender_city: 'Surat',
    sender_pincode: '395001',
    receiver_name: 'Test Receiver',
    receiver_phone: '8765432109',
    receiver_address: '456 Receiver St',
    receiver_state: 'Gujarat',
    receiver_city: 'Surat',
    receiver_pincode: '395002',
    special_instruction: 'Handle with care',
    order_amount: 250,
    urgency: 'Normal',
    fare_breakdown: { base: 100, distance: 100, platform: 50 },
    sender_lat: 21.17,
    sender_lng: 72.83,
    receiver_lat: 21.20,
    receiver_lng: 72.85,
    parcels: [{ parcel_type_id: 1, parcel_size_id: 1, weight: 0.5 }]
  });

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/users/create/order',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      'Content-Length': Buffer.byteLength(orderData)
    }
  };

  const req = http.request(options, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
      console.log('\nCreate Order response:', res.statusCode);
      console.log('Body:', body);
    });
  });

  req.on('error', (e) => console.error('Order error:', e.message));
  req.write(orderData);
  req.end();
}
