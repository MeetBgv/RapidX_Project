const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.post("/register/customer", userController.registerCustomer);

router.post("/register/business", userController.registerBusiness);

router.get("/register/business/master-values", userController.registerBusinessMasterValues)

router.post("/register/employee", userController.registerEmployee);

router.post("/register/delivery-partner", userController.registerDeliveryPartner);

router.post("/login", userController.login);

router.post("/create/order", userController.createOrder);

router.post("/update-role", userController.updateUserRole);

router.post("/calculate-price", userController.calculatePriceHandler);
router.post("/location", userController.updateUserLocationHandler);

router.get("/all", userController.getAllUsers);

router.get("/orders", userController.getAllOrdersHandler);
router.get("/customer-orders", userController.getCustomerOrdersHandler);

router.get("/delivery-partners", userController.getAllDeliveryPartners);

router.post("/delivery-partners/profile", userController.createDeliveryPartnerProfileHandler);
router.get("/delivery-partners/profile", userController.getDeliveryPartnerProfileHandler);

router.post("/delivery-partners/:id/verify", userController.verifyDeliveryPartner);

// ── Delivery Partner Order Dispatch ───────────────────────────────────────────────
router.get("/orders/pending", userController.getPendingOrdersHandler);
router.post("/orders/:id/accept", userController.acceptOrderHandler);
router.get("/orders/active", userController.getDPActiveOrderHandler);
router.post("/orders/:id/status", userController.updateOrderStatusHandler);

router.get("/delivery-partner-orders", userController.getDeliveryPartnerOrdersHandler);

module.exports = router;