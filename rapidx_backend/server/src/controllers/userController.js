const userService = require("../services/userService");
const pricingService = require("../services/pricingService");

const registerCustomer = async (req, res) => {
    try {
        const { first_name, last_name, email, phone, password, address, state, city, pincode, address_type } = req.body;
        const response = await userService.registerCustomer(first_name, last_name, email, phone, password, address, state, city, pincode, address_type);
        res.status(201).json(response);
    } catch (error) {
        console.log(error);
        if (!res.headersSent)
            res.status(500).json({ error: error.message });
    }
};

const registerBusiness = async (req, res) => {
    try {
        const { company_name, business_type_id, reg_no, business_email, business_phone, address, city, state, pincode, billing_cycle_id, payment_method_id, business_password, admin_first_name, admin_last_name, admin_phone, admin_email, admin_password } = req.body;
        const response = await userService.registerBusiness(company_name, business_type_id, reg_no, business_email, business_phone, address, city, state, pincode, billing_cycle_id, payment_method_id, business_password, admin_first_name, admin_last_name, admin_phone, admin_email, admin_password);
        res.status(201).json(response);
    } catch (error) {
        console.log("Error in registering business: ", error);
    }
};

const registerBusinessMasterValues = async (req, res) => {
    try {
        const data = await userService.registerBusinessMasterValues();

        if (data) {
            res.status(200).json(data);
        } else {
            res.status(400).json("Error in registering business master values");
        }
    } catch (error) {
        console.log("Error in registering business master values: ", error);
        res.status(500).json("Error in registering business master values");
    }
};

const registerEmployee = async (req, res) => {
    try {
        const { email, phone, password, first_name, last_name } = req.body;
        const authToken = req.headers.authorization.split(" ")[1];
        const response = await userService.registerEmployee(email, phone, password, first_name, last_name, authToken);

        if (response == true) {
            res.status(201).json("Employee registered successfully");
        } else {
            res.status(400).json("Error in registering employee");
        }
    } catch (error) {
        console.log("Error in registering employee: ", error);
    }
};

const registerDeliveryPartner = async (req, res) => {
    try {
        const { rider_first_name, rider_last_name, phone, email, password, birth_date, profile_picture, license_number, expiry_date, license_photo, document_type_id, document_number, document_photo, address, state, city, pincode, vehicle_type_id, vehicle_number, rc_book_picture, bank_name, branch_name, account_number, account_holder_name, account_type, ifsc_code, working_type_id, working_state, working_city, time_slot } = req.body
        const response = await userService.registerDeliveryPartner(rider_first_name, rider_last_name, phone, email, password, birth_date, profile_picture, license_number, expiry_date, license_photo, document_type_id, document_number, document_photo, address, state, city, pincode, vehicle_type_id, vehicle_number, rc_book_picture, bank_name, branch_name, account_number, account_holder_name, account_type, ifsc_code, working_type_id, working_state, working_city, time_slot);

        if (response !== false) {
            res.status(201).json({ token: response });
        } else {
            res.status(400).json("Error in registering delivery partner");
        }
    } catch (error) {

    }
};

const login = async (req, res) => {
    const { email, password } = req.body;
    try {
        const response = await userService.login(email, password);

        res.status(200).json({ token: response.token, role: response.role, user: response.user });
    } catch (error) {
        console.log("Error in login: ", error);
        res.status(401).json({ error: error.message || "Invalid credentials" });
    }
};

const getPayoutsByPartnerHandler = async (req, res) => {
    try {
        const result = await userService.getPayoutsByPartner();
        res.status(200).json(result);
    } catch (error) {
        console.error('Error getting payouts by partner:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const confirmPartnerBulkCashHandler = async (req, res) => {
    try {
        const { id } = req.params; // delivery_partner_id
        const result = await userService.confirmPartnerCash(id);
        res.status(200).json({ message: 'All pending cash payments confirmed', count: result.length });
    } catch (error) {
        console.error('Error confirming partner bulk cash:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const processPartnerBulkPayoutHandler = async (req, res) => {
    try {
        const { id } = req.params; 
        const { transaction_id, notes } = req.body;
        console.log(`[PAYOUT] Processing bulk payout for partner ${id}. Txn: ${transaction_id}`);
        const result = await userService.processPartnerBulkPayout(id, transaction_id, notes);
        console.log(`[PAYOUT] Success! Updated ${result.length} orders.`);
        res.status(200).json({ message: 'All partner payouts processed successfully', count: result.length });
    } catch (error) {
        console.error('Error processing bulk partner payout:', error);
        res.status(500).json({ error: 'Server error: ' + error.message });
    }
};

const toggleBanHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const { is_banned } = req.body;
        const result = await userService.toggleUserBan(id, is_banned);
        if (result) res.status(200).json({ message: `User ${is_banned ? 'banned' : 'unbanned'} successfully` });
        else res.status(400).json({ error: "Failed to update user status" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const deleteUserHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await userService.deleteUser(id);
        if (result) res.status(200).json({ message: "User deleted successfully" });
        else res.status(400).json({ error: "Failed to delete user" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const adminCreateUserHandler = async (req, res) => {
    try {
        const result = await userService.adminCreateUser(req.body);
        if (result) res.status(201).json(result);
        else res.status(400).json({ error: "Failed to create user" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const createMasterCategoryHandler = async (req, res) => {
    try {
        const { type_name } = req.body;
        const result = await userService.createMasterCategory(type_name);
        if (result) res.status(201).json(result);
        else res.status(400).json({ error: "Failed to create category" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const createMasterValueHandler = async (req, res) => {
    try {
        const { master_id, value_name } = req.body;
        const result = await userService.createMasterValue(master_id, value_name);
        if (result) res.status(201).json(result);
        else res.status(400).json({ error: "Failed to create value" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const createComplaintHandler = async (req, res) => {
    try {
        const { order_id, complaint_type_id, description } = req.body;
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const userId = payload?.userId;
        if (!userId) return res.status(401).json('Invalid token');

        const result = await userService.createComplaint(order_id, userId, complaint_type_id, description);
        if (result) res.status(201).json(result);
        else res.status(400).json({ error: "Failed to create complaint" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getMyComplaintsHandler = async (req, res) => {
    try {
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const userId = payload?.userId;
        if (!userId) return res.status(401).json('Invalid token');

        const result = await userService.getMyComplaints(userId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const resolveComplaintHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const { admin_note } = req.body;
        const result = await userService.resolveComplaint(id, admin_note);
        if (result) res.status(200).json({ message: "Complaint marked as resolved" });
        else res.status(400).json({ error: "Failed to resolve complaint" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const generateBillsHandler = async (req, res) => {
    try {
        const result = await userService.generateBilling();
        res.status(200).json({ message: `Successfully generated ${result} billing records` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const createOrder = async (req, res) => {
    try {
        const bearerToken = req.headers.authorization;
        let authToken;

        if (bearerToken && bearerToken.startsWith("Bearer ")) {
            authToken = bearerToken.split(" ")[1];
        } else {
            return res.status(401).json("Unauthorized");
        }

        console.log('--- DEBUG: NEW ORDER BODY ---');
        console.log(JSON.stringify(req.body, null, 2));

        const {
            sender_name,
            sender_phone,
            sender_address,
            sender_state,
            sender_city,
            sender_pincode,
            receiver_name,
            receiver_phone,
            receiver_address,
            receiver_state,
            receiver_city,
            receiver_pincode,
            special_instruction,
            order_amount,
            parcels,
            urgency,
            fare_breakdown,
            sender_lat,
            sender_lng,
            receiver_lat,
            receiver_lng,
            payment_method
        } = req.body;

        // Robust payment method extraction (handle camelCase and case sensitivity)
        let resolvedPaymentMethod = payment_method || req.body.paymentMethod || 'cash';
        if (typeof resolvedPaymentMethod === 'string') {
            resolvedPaymentMethod = resolvedPaymentMethod.toLowerCase();
        }

        const orderOptions = {
            authToken,
            sender_name,
            sender_phone,
            sender_address,
            sender_state,
            sender_city,
            sender_pincode,
            receiver_name,
            receiver_phone,
            receiver_address,
            receiver_state,
            receiver_city,
            receiver_pincode,
            special_instruction,
            order_amount,
            parcels,
            urgency,
            fare_breakdown,
            sender_lat,
            sender_lng,
            receiver_lat,
            receiver_lng,
            payment_method: resolvedPaymentMethod
        };

        const response = await userService.createOrder(authToken, orderOptions);

        if (response) {
            console.log('Order created successfully. Confirmed Method:', orderOptions.payment_method);
            res.status(201).json({ 
                message: "Order placed successfully", 
                order: response,
                payment_method_confirmed: orderOptions.payment_method
            });
        } else {
            console.error('Order creation failed in userService');
            res.status(400).json({ message: "Order placement failed" });
        }
    } catch (error) {
        console.log("Error in Creating Order: ", error);
        if (!res.headersSent)
            res.status(500).json({ error: "Internal server error" });
    }
};

const updateUserRole = async (req, res) => {
    try {
        const { phone, role_id } = req.body;
        const response = await userService.updateUserRole(phone, role_id);
        if (response) {
            res.status(200).json({ message: "Role updated successfully" });
        } else {
            res.status(400).json({ error: "Failed to update role" });
        }
    } catch (error) {
        console.log("Error updating user role:", error);
        res.status(500).json({ error: "Server error" });
    }
};

const calculatePriceHandler = async (req, res) => {
    try {
        const { distance, weight, vehicle_id, urgency, is_in_city } = req.body;
        if (distance == null || weight == null || vehicle_id == null) {
            return res.status(400).json({ error: "Missing required parameters: distance, weight, vehicle_id" });
        }

        const breakdown = await pricingService.calculatePrice(distance, weight, vehicle_id, urgency, is_in_city);
        res.status(200).json(breakdown);
    } catch (error) {
        console.error("Error calculating price:", error);
        res.status(500).json({ error: "Internal server error during price calculation" });
    }
};

const updateUserLocationHandler = async (req, res) => {
    try {
        const { lat, lng } = req.body;
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const userId = payload?.userId;
        if (!userId) return res.status(401).json('Invalid token');

        const success = await userService.updateUserLocation(userId, lat, lng);
        if (success) {
            res.status(200).json({ message: "Location updated" });
        } else {
            res.status(400).json({ error: "Failed to update location" });
        }
    } catch (error) {
        console.error("Error in updateUserLocationHandler:", error);
        res.status(500).json({ error: "Server error" });
    }
};

const getAllUsers = async (req, res) => {
    try {
        const users = await userService.getAllUsers();
        if (users) {
            res.status(200).json(users);
        } else {
            res.status(400).json({ error: "Failed to fetch users" });
        }
    } catch (error) {
        console.error("Error in getAllUsers:", error);
        res.status(500).json({ error: "Server error" });
    }
};

const getAllDeliveryPartners = async (req, res) => {
    try {
        const dps = await userService.getAllDeliveryPartners();
        if (dps) {
            res.status(200).json(dps);
        } else {
            res.status(400).json({ error: "Failed to fetch delivery partners" });
        }
    } catch (error) {
        console.error("Error in getAllDeliveryPartners:", error);
        res.status(500).json({ error: "Server error" });
    }
};

const verifyDeliveryPartner = async (req, res) => {
    try {
        const { id } = req.params;
        const verified = await userService.verifyDeliveryPartner(id);
        if (verified) {
            res.status(200).json({ message: "Partner verified successfully" });
        } else {
            res.status(400).json({ error: "Failed to verify partner. They may not have submitted their verification documents yet." });
        }
    } catch (error) {
        console.error("Error in verifyDeliveryPartner:", error);
        res.status(500).json({ error: "Server error" });
    }
};

const createDeliveryPartnerProfileHandler = async (req, res) => {
    try {
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const result = await userService.createDeliveryPartnerProfile(authToken, req.body);
        if (result !== false) {
            res.status(201).json({ message: 'Delivery partner profile created successfully', delivery_partner_id: result });
        } else {
            res.status(400).json({ error: 'Failed to create delivery partner profile' });
        }
    } catch (error) {
        console.error('Error in createDeliveryPartnerProfile:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

// ─── Delivery Partner Order Dispatch ──────────────────────────────────────

const getPendingOrdersHandler = async (req, res) => {
    try {
        const orders = await userService.getPendingOrders();
        res.status(200).json(orders);
    } catch (error) {
        console.error('Error in getPendingOrders:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const acceptOrderHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const dpId = payload?.userId;
        if (!dpId) return res.status(401).json('Invalid token');

        const order = await userService.acceptOrder(id, dpId);
        if (!order) return res.status(409).json({ error: 'Order already taken or not found' });
        res.status(200).json(order);
    } catch (error) {
        console.error('Error in acceptOrder:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getDPActiveOrderHandler = async (req, res) => {
    try {
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const dpId = payload?.userId;
        if (!dpId) return res.status(401).json('Invalid token');

        const order = await userService.getDPActiveOrder(dpId);
        res.status(200).json(order ?? null);
    } catch (error) {
        console.error('Error in getDPActiveOrder:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const updateOrderStatusHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const bearerToken = req.headers.authorization;
        
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        
        const authToken = bearerToken.split(' ')[1];
        
        // Check for admin_token special case or standard JWT with Admin role
        if (authToken === 'admin_token') {
            const order = await userService.adminUpdateOrderStatus(id, status);
            if (!order) return res.status(404).json({ error: 'Order not found' });
            return res.status(200).json(order);
        }

        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const userId = payload?.userId;
        const role = payload?.role; // Ensure role is available if using standard JWTs for admin

        if (role === 'Admin' || !userId) {
             const order = await userService.adminUpdateOrderStatus(id, status);
             if (!order) return res.status(404).json({ error: 'Order not found' });
             return res.status(200).json(order);
        }

        const dpId = userId;
        const order = await userService.updateOrderStatus(id, dpId, status);
        if (!order) return res.status(404).json({ error: 'Order not found or not assigned to you' });
        res.status(200).json(order);
    } catch (error) {
        console.error('Error in updateOrderStatusHandler:', error);
        res.status(500).json({ error: 'Server error' });
    }
};



const getDeliveryPartnerProfileHandler = async (req, res) => {
    try {
        const bearerToken = req.headers['authorization'];
        if (!bearerToken) return res.status(401).json('Unauthorized');

        const authToken = bearerToken.split(' ')[1];
        const profile = await userService.getDeliveryPartnerProfile(authToken);
        
        if (!profile) return res.status(404).json({ error: 'Profile not found' });
        
        res.status(200).json(profile);
    } catch (error) {
        console.error('Error in getDeliveryPartnerProfileHandler:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllOrdersHandler = async (req, res) => {
    try {
        const orders = await userService.getAllOrders();
        res.status(200).json(orders);
    } catch (error) {
        console.error('Error fetching all orders:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getCustomerOrdersHandler = async (req, res) => {
    try {
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const userId = payload?.userId;
        if (!userId) return res.status(401).json('Invalid token');

        const orders = await userService.getCustomerOrders(userId);
        res.status(200).json(orders);
    } catch (error) {
        console.error('Error fetching customer orders:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getDeliveryPartnerOrdersHandler = async (req, res) => {
    try {
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const userId = payload?.userId;
        const timeframe = req.query.timeframe || 'all';

        if (!userId) return res.status(401).json('Invalid token');

        const orders = await userService.getDeliveryPartnerOrders(userId, timeframe);
        res.status(200).json(orders);
    } catch (error) {
        console.error('Error fetching delivery partner orders:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getDashboardStatsHandler = async (req, res) => {
    try {
        const timeframe = req.query.timeframe || 'all';
        const stats = await userService.getDashboardStats(timeframe);
        res.status(200).json(stats);
    } catch (error) {
        console.error('Error in getDashboardStatsHandler:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllBusinessesHandler = async (req, res) => {
    try {
        const businesses = await userService.getAllBusinesses();
        res.status(200).json(businesses);
    } catch (error) {
        console.error('Error in getAllBusinessesHandler:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllParcelsHandler = async (req, res) => {
    try {
        const parcels = await userService.getAllParcels();
        res.status(200).json(parcels);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllPaymentsHandler = async (req, res) => {
    try {
        const payments = await userService.getAllPayments();
        res.status(200).json(payments);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllPayoutsHandler = async (req, res) => {
    try {
        const payouts = await userService.getAllPayouts();
        res.status(200).json(payouts);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllComplaintsHandler = async (req, res) => {
    try {
        const complaints = await userService.getAllComplaints();
        res.status(200).json(complaints);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllBillingHandler = async (req, res) => {
    try {
        const billing = await userService.getAllBilling();
        res.status(200).json(billing);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllRolesHandler = async (req, res) => {
    try {
        const roles = await userService.getAllRoles();
        res.status(200).json(roles);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

const getAllMasterDataHandler = async (req, res) => {
    try {
        const masterdata = await userService.getAllMasterData();
        res.status(200).json(masterdata);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

// ── PAYOUT MANAGEMENT HANDLERS ──────────────────────────────
const getPayoutStatsHandler = async (req, res) => {
    try {
        const stats = await userService.getPayoutStats();
        res.status(200).json(stats);
    } catch (error) {
        console.error('Error fetching payout stats:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const confirmCashDepositHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await userService.confirmCashDeposit(id);
        if (!result) return res.status(404).json({ error: 'Payout not found or not in cash_pending status' });
        res.status(200).json(result);
    } catch (error) {
        console.error('Error confirming cash deposit:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const processPayoutHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const { transaction_id, notes } = req.body;
        const result = await userService.processPayoutToDp(id, transaction_id, notes);
        if (!result) return res.status(404).json({ error: 'Payout not found or not in awaiting_payout status' });
        res.status(200).json(result);
    } catch (error) {
        console.error('Error processing payout:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

const getDeliveryPartnerWalletHandler = async (req, res) => {
    try {
        const bearerToken = req.headers.authorization;
        if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
            return res.status(401).json('Unauthorized');
        }
        const authToken = bearerToken.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const payload = jwt.decode(authToken);
        const dpId = payload?.userId;
        if (!dpId) return res.status(401).json('Invalid token');

        const timeframe = req.query.timeframe || 'all';
        const wallet = await userService.getDeliveryPartnerWalletDetails(dpId, timeframe);
        res.status(200).json(wallet);
    } catch (error) {
        console.error('Error fetching DP wallet:', error);
        res.status(500).json({ error: 'Server error' });
    }
};

module.exports = {
    registerCustomer,
    registerBusiness,
    registerBusinessMasterValues,
    registerEmployee,
    registerDeliveryPartner,
    login,
    createOrder,
    updateUserRole,
    calculatePriceHandler,
    updateUserLocationHandler,
    getAllUsers,
    getAllDeliveryPartners,
    verifyDeliveryPartner,
    createDeliveryPartnerProfileHandler,
    getDeliveryPartnerProfileHandler,
    getPendingOrdersHandler,
    acceptOrderHandler,
    getDPActiveOrderHandler,
    updateOrderStatusHandler,
    getAllOrdersHandler,
    getCustomerOrdersHandler,
    getDeliveryPartnerOrdersHandler,
    getDashboardStatsHandler,
    getAllBusinessesHandler,
    getAllParcelsHandler,
    getAllPaymentsHandler,
    getAllPayoutsHandler,
    getAllComplaintsHandler,
    getAllBillingHandler,
    getAllRolesHandler,
    getAllMasterDataHandler,
    toggleBanHandler,
    deleteUserHandler,
    adminCreateUserHandler,
    createMasterCategoryHandler,
    createMasterValueHandler,
    createComplaintHandler,
    getMyComplaintsHandler,
    resolveComplaintHandler,
    generateBillsHandler,
    getPayoutStatsHandler,
    confirmCashDepositHandler,
    processPayoutHandler,
    getPayoutsByPartnerHandler,
    confirmPartnerBulkCashHandler,
    processPartnerBulkPayoutHandler,
    getDeliveryPartnerWalletHandler
};
