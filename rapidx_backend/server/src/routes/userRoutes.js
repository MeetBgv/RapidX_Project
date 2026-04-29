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
router.get("/delivery-partner/wallet", userController.getDeliveryPartnerWalletHandler);
router.get("/dashboard-stats", userController.getDashboardStatsHandler);
router.get("/businesses", userController.getAllBusinessesHandler);

router.get("/parcels", userController.getAllParcelsHandler);
router.get("/payments", userController.getAllPaymentsHandler);
router.get("/payouts", userController.getAllPayoutsHandler);
router.get("/payouts/stats", userController.getPayoutStatsHandler);
router.get("/payouts/partner", userController.getPayoutsByPartnerHandler);
router.post("/payouts/partner/:id/confirm-bulk-cash", userController.confirmPartnerBulkCashHandler);
router.post("/payouts/partner/:id/pay-bulk", userController.processPartnerBulkPayoutHandler);
router.post("/payouts/:id/confirm-cash", userController.confirmCashDepositHandler);
router.post("/payouts/:id/pay", userController.processPayoutHandler);
router.get("/complaints", userController.getAllComplaintsHandler);
router.get("/my-complaints", userController.getMyComplaintsHandler);
router.get("/billing", userController.getAllBillingHandler);
router.get("/roles", userController.getAllRolesHandler);
router.get("/masterdata", userController.getAllMasterDataHandler);

// ── Admin Actions ─────────────────────────────────────────────────────────────
router.post("/:id/toggle-ban", userController.toggleBanHandler);
router.delete("/:id", userController.deleteUserHandler);
router.post("/admin-create", userController.adminCreateUserHandler);
router.post("/masterdata/category", userController.createMasterCategoryHandler);
router.post("/masterdata/value", userController.createMasterValueHandler);
router.post("/complaints/:id/resolve", userController.resolveComplaintHandler);
router.post("/complaints", userController.createComplaintHandler);
router.post("/billing/generate", userController.generateBillsHandler);

module.exports = router;