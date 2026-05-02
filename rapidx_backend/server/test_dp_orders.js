const { getDeliveryPartnerOrders } = require('./src/services/userService');

async function test() {
    try {
        const orders = await getDeliveryPartnerOrders(10574138);
        console.log(JSON.stringify(orders, null, 2));
    } catch (e) {
        console.error(e);
    }
    process.exit(0);
}
test();
