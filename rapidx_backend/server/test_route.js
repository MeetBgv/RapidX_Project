const { computeOrderRoute } = require('./src/services/dijkstraService');
const fs = require('fs');

async function test() {
    console.log("Testing dijkstra routing...");
    const route = await computeOrderRoute(19.0760, 72.8777, 28.7041, 77.1025);
    fs.writeFileSync('route_test_clean.json', JSON.stringify(route, null, 2), 'utf-8');
    process.exit();
}
test();
