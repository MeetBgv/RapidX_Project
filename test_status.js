const axios = require('axios');

async function testStatusUpdate() {
    try {
        const orderId = '50352554'; // A known order ID (I'll check one from stats)
        const newStatus = 'In Transit';
        
        const response = await axios.post(`https://rapid-x-project.vercel.app/api/users/orders/${orderId}/status`, {
            status: newStatus
        }, {
            headers: {
                'Authorization': 'Bearer admin_token'
            }
        });
        
        console.log('Success:', response.status);
        console.log('Data:', response.data);
    } catch (error) {
        console.log('Error:', error.response ? error.response.status : error.message);
        console.log('Error Data:', error.response ? error.response.data : 'N/A');
    }
}

testStatusUpdate();
