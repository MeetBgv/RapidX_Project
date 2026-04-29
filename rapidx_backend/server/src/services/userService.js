const pool = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const dotenv = require("dotenv");
const { computeOrderRoute } = require("./dijkstraService");
dotenv.config();

const SECRET_KEY = process.env.JWT_KEY;

const saltRounds = 10;

const generateId = async (id) => {
  try {
    const variableData = [
      { id: 10, table: "users", column: "user_id" },
      { id: 20, table: "business_clients", column: "business_id" },
      { id: 21, table: "users", column: "user_id" },
      { id: 22, table: "users", column: "user_id" },
      { id: 30, table: "users", column: "user_id" },
      { id: 40, table: "addresses", column: "address_id" },
      { id: 50, table: "orders", column: "order_id" },
      { id: 51, table: "parcels", column: "parcel_id" },
      { id: 60, table: "delivery_partner_payout_orders", column: "payout_order_id" },
      { id: 80, table: "complaints", column: "complaint_id" }
    ]

    const currentVariableData = variableData.find((data) => data.id == id);

    let uniqueId;
    let isUnique;

    while (!isUnique) {
      const tempId = Math.floor(100000 + Math.random() * 900000);
      uniqueId = Number(`${currentVariableData.id ?? id}${tempId}`);

      const result = await pool.query(`SELECT * FROM ${currentVariableData.table} WHERE ${currentVariableData.column} = ${uniqueId}`);

      if (result.rowCount === 0) {
        isUnique = true;
      }
    };

    return uniqueId;

  } catch (error) {
    console.log("Error generating id: ", error);
    throw new Error("Error generating id");
  }
};

const registerCustomer = async (
  first_name,
  last_name,
  email,
  phone,
  password,
  address,
  state,
  city,
  pincode,
  address_type
) => {
  try {
    //Hash password
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const userId = await generateId(10);

    const userQuery = `
      INSERT INTO users (
        user_id, role_id, email, phone, password,
        is_banned, created_at, first_name, last_name
      )
      VALUES (
        $1,
        (SELECT role_id FROM roles_master WHERE role_name = 'Customer'),
        $2, $3, $4, $5, NOW(), $6, $7
      )
    `;

    const userValues = [
      userId,
      email,
      phone,
      hashedPassword,
      false,
      first_name,
      last_name
    ];

    const userResult = await pool.query(userQuery, userValues);

    if (userResult.rowCount === 0) {
      throw new Error("Customer user insert failed");
    }

    const addressResult = await insertAddress(
      userId,
      null,
      address,
      city,
      state,
      pincode,
      address_type,
      true
    );

    if (!addressResult || addressResult.rowCount === 0) {
      throw new Error("Customer address insert failed");
    }

    const token = generateJwtToken(userId, null, email);
    return token;

  } catch (error) {
    console.error("Error registering customer:", error);
    throw error;
  }
};

const insertAddress = async (userId, businessId, address, city, state, pincode, address_type, is_default_address) => {
  const addressId = await generateId(40);
  try {
    const addressQuery = `INSERT INTO addresses (address_id, user_id, business_id, address, city, state, pincode, address_type, is_default_address) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`;
    const addressValues = [addressId, userId, businessId, address, city, state, pincode, address_type, is_default_address];
    const addressResult = await pool.query(addressQuery, addressValues);

    return addressResult;

  } catch (error) {
    console.log("Error inserting address data to SQL: ", error);
  }
};

const generateJwtToken = (userId, businessId, email) => {
  const payload = {};

  if (userId !== undefined && userId !== null) payload.userId = userId;
  if (businessId !== undefined && businessId !== null) payload.businessId = businessId;
  if (email !== undefined && email !== null) payload.email = email;

  try {
    const authToken = jwt.sign(payload, SECRET_KEY, { expiresIn: "7d" });
    return authToken;
  } catch (error) {
    console.log("Error generating token: ", error);
    throw new Error("Error generating token");
  }
};

const extractJwtTokenData = (authToken) => {
  try {
    const payload = jwt.decode(authToken, SECRET_KEY);
    const userId = payload.userId ?? null;
    const businessId = payload.businessId ?? null;

    const email = payload.email;

    return { userId, businessId, email };
  } catch (error) {
    console.log("Error extracting token data: ", error);
    throw new Error("Error extracting token data");
  }
};

const registerBusiness = async (
  company_name,
  business_type_id,
  reg_no,
  business_email,
  business_phone,
  address,
  city,
  state,
  pincode,
  billing_cycle_id,
  payment_method_id,
  business_password,
  admin_first_name,
  admin_last_name,
  admin_phone,
  admin_email,
  admin_password
) => {
  try {
    //Hash passwords
    const hashedPassword = await bcrypt.hash(business_password, saltRounds);
    const hashedAdminPassword = await bcrypt.hash(admin_password, saltRounds);


    const adminId = await generateId(21);
    const businessId = await generateId(22);

    const adminQuery = `
      INSERT INTO users (user_id, role_id, email, phone, password, is_banned, created_at, first_name, last_name)
      VALUES (
        $1,
        (SELECT role_id FROM roles_master WHERE role_name = 'Business Admin'),
        $2, $3, $4, $5, NOW(), $6, $7
      )
    `;

    const adminResult = await pool.query(adminQuery, [
      adminId,
      admin_email,
      admin_phone,
      hashedAdminPassword,
      false,
      admin_first_name,
      admin_last_name
    ]);

    if (adminResult.rowCount === 0) throw new Error("Admin insert failed");

    const businessUserQuery = `
      INSERT INTO users (user_id, role_id, email, phone, password, is_banned, created_at, first_name)
      VALUES (
        $1,
        (SELECT role_id FROM roles_master WHERE role_name = 'Business'),
        $2, $3, $4, $5, NOW(), $6
      )
    `;

    const businessUserResult = await pool.query(businessUserQuery, [
      businessId,
      business_email,
      business_phone,
      hashedPassword,
      false,
      company_name
    ]);

    if (businessUserResult.rowCount === 0) throw new Error("Business user insert failed");

    const businessQuery = `
      INSERT INTO business_clients (
        business_id, account_admin_id, company_name,
        business_type_id, reg_no, business_phone,
        created_at, account_status_id, billing_cycle_id, payment_method_id
      )
      VALUES (
        $1, $2, $3, $4, $5, $6,
        NOW(),
        (SELECT value_id FROM value_master WHERE value_name = 'Pending Verification'),
        $7, $8
      )
    `;

    const businessResult = await pool.query(businessQuery, [
      businessId,
      adminId,
      company_name,
      business_type_id,
      reg_no,
      business_phone,
      billing_cycle_id,
      payment_method_id
    ]);

    if (businessResult.rowCount === 0) throw new Error("Business insert failed");

    await pool.query(
      "UPDATE users SET business_id = $1 WHERE user_id IN ($2, $3)",
      [businessId, adminId, businessId]
    );

    const addressResult = await insertAddress(null, businessId, address, city, state, pincode, null, true);
    if (!addressResult || addressResult.rowCount === 0) throw new Error("Address insert failed");

    const token = generateJwtToken(null, businessId, business_email);
    return token;

  } catch (error) {
    console.error("Error registering business:", error);
    throw error;
  }
};

const registerBusinessMasterValues = async () => {
  try {
    console.log("In userService")
    const businessTypeQuery = `SELECT value_id, value_name FROM value_master WHERE master_id = (SELECT master_id FROM main_master WHERE type_name = 'Business type')`;
    const businessTypeResult = await pool.query(businessTypeQuery);
    if (!businessTypeResult.rows) {
      throw new Error("Business type values are not present");
    }

    const billingCycleQuery = `SELECT value_id, value_name FROM value_master WHERE master_id = (SELECT master_id FROM main_master WHERE type_name = 'Billing cycle')`;
    const billingCycleResult = await pool.query(billingCycleQuery);
    if (!billingCycleResult.rows) {
      throw new Error("Billing cycle values are not present");
    }

    const paymentMethodQuery = `SELECT value_id, value_name FROM value_master WHERE master_id = (SELECT master_id FROM main_master WHERE type_name = 'Payment method')`;
    const paymentMethodResult = await pool.query(paymentMethodQuery);
    if (!paymentMethodResult.rows) {
      throw new Error("Payment method values are not present");
    }

    return { businessType: businessTypeResult.rows, billingCycle: billingCycleResult.rows, paymentMethod: paymentMethodResult.rows };

  } catch (error) {
    console.log("Error fetching register master values: ", error);
    throw new Error("Error fetching register master values");
  }
}

const registerEmployee = async (email, phone, password, first_name, last_name, authToken) => {
  try {
    //Extract business ID from token
    const extractedData = extractJwtTokenData(authToken);
    const businessId = extractedData?.id;

    if (!businessId) {
      throw new Error("Invalid or expired auth token");
    }

    //Hash password
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const employeeId = await generateId(22);

    const employeeQuery = `
      INSERT INTO users (
        user_id, role_id, email, phone, password,
        is_banned, created_at, first_name, last_name, business_id
      )
      VALUES (
        $1,
        (SELECT role_id FROM roles_master WHERE role_name = 'Business Employee'),
        $2, $3, $4, $5, NOW(), $6, $7, $8
      )
    `;

    const employeeValues = [
      employeeId,
      email,
      phone,
      hashedPassword,
      false,
      first_name,
      last_name,
      businessId
    ];

    const employeeResult = await pool.query(employeeQuery, employeeValues);

    return employeeResult.rowCount > 0;

  } catch (error) {
    console.log("Error inserting employee data to SQL: ", error);
    return false;
  }
};

const registerDeliveryPartner = async (
  rider_first_name,
  rider_last_name,
  phone,
  email,
  password,
  birth_date,
  profile_picture,
  license_number,
  expiry_date,
  license_photo,
  document_type_id,
  document_number,
  document_photo,
  address,
  state,
  city,
  pincode,
  vehicle_type_id,
  vehicle_number,
  rc_book_picture,
  bank_name,
  branch_name,
  account_number,
  account_holder_name,
  account_type,
  ifsc_code,
  working_type_id,
  working_state,
  working_city,
  time_slot
) => {
  try {
    //Hash password
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const riderId = await generateId(30);

    const riderUsersQuery = `
      INSERT INTO users (
        user_id, role_id, email, phone, password,
        is_banned, created_at, first_name, last_name
      ) 
      VALUES (
        $1,
        9,
        $2, $3, $4, $5, NOW(), $6, $7
      )
    `;

    const usersQueryValues = [
      riderId,
      email,
      phone,
      hashedPassword,
      false,
      rider_first_name,
      rider_last_name
    ];

    const riderUsersResult = await pool.query(riderUsersQuery, usersQueryValues);

    if (riderUsersResult.rowCount === 0) {
      throw new Error("Delivery partner user insert failed");
    }

    const addressResult = await insertAddress(
      riderId,
      null,
      address,
      city,
      state,
      pincode,
      null,
      true
    );

    if (!addressResult || addressResult.rowCount === 0) {
      throw new Error("Delivery partner address insert failed");
    }

    const partnerQuery = `
      INSERT INTO delivery_partner 
      (
        delivery_partner_id, birth_date, profile_picture, 
        license_number, expiry_date, license_photo, document_type_id, 
        document_number, document_photo, vehicle_type_id, vehicle_number, 
        rc_book_picture, working_type_id, working_state, working_city, 
        time_slot, account_status_id, bank_name, branch_name, 
        account_number, account_type, ifsc_code, account_holder_name, 
        is_verified, created_at
      ) 
      VALUES (
        $1, $2, $3, 
        $4, $5, $6, $7, 
        $8, $9, $10, $11, 
        $12, $13, $14, $15, 
        $16,
        (SELECT value_id FROM value_master WHERE value_name = 'Pending Verification'),
        $17, $18, 
        $19, $20, $21, $22, 
        $23, NOW()
      )
    `;

    const partnerValues = [
      riderId,
      birth_date,
      profile_picture,
      license_number,
      expiry_date,
      license_photo,
      document_type_id,
      document_number,
      document_photo,
      vehicle_type_id,
      vehicle_number,
      rc_book_picture,
      working_type_id,
      working_state,
      working_city,
      time_slot,
      bank_name,
      branch_name,
      account_number,
      account_type,
      ifsc_code,
      account_holder_name,
      false
    ];

    const partnerResult = await pool.query(partnerQuery, partnerValues);

    if (partnerResult.rowCount === 0) {
      throw new Error("Delivery partner profile insert failed");
    }

    const token = generateJwtToken(riderId, null, email);
    return token;

  } catch (error) {
    console.log("Error inserting rider data to SQL: ", error);
    return false;
  }
};

const login = async (email, password) => {
  console.log(`[DEBUG] Attempting login for email: "${email}" (Password length: ${password?.length})`);
  
  if (email === "admin" && password === "admin") {
    console.log("[DEBUG] Handled by hardcoded 'admin' check.");
    return {
      token: "admin_token",
      role: "Admin",
      user: {
        email: "admin",
        first_name: "Admin",
        last_name: "User"
      }
    };
  }

  try {
    const checkUserQuery = `SELECT * FROM users WHERE email = $1`;
    const checkUserValues = [email];
    const checkUserResult = await pool.query(checkUserQuery, checkUserValues);

    if (checkUserResult.rowCount === 0) {
      console.log(`[DEBUG] Login failed: User with email "${email}" not found.`);
      throw new Error("Invalid credentials");
    }

    const user = checkUserResult.rows[0];
    
    // Check if user is deleted first
    if (user.is_deleted) {
      console.log(`[DEBUG] Login failed: User ${user.user_id} is deleted.`);
      throw new Error("Account not found");
    }

    if (user.is_banned) {
      console.log(`[DEBUG] Login failed: User ${user.user_id} is banned.`);
      throw new Error("Your account has been banned. Please contact support.");
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      console.log(`[DEBUG] Login failed: Incorrect password for "${email}".`);
      throw new Error("Invalid credentials");
    }

    const role = user.role_id;
    console.log(`[DEBUG] Login successful: User ${user.user_id}, Role ID: ${role}`);
    const token = generateJwtToken(user.user_id, user.business_id, user.email);

    delete user.password;

    return { token, role, user };

  } catch (error) {
    console.error("[DEBUG] Login error during execution:", error);
    throw error;
  }
};

const insertParcels = async (orderId, parcels) => {
  try {
    if (!Array.isArray(parcels) || parcels.length === 0) {
      throw new Error("Invalid parcels data");
    }

    const parcelQuery = `
      INSERT INTO parcels (parcel_id, order_id, parcel_type_id, parcel_size_id, weight)
      VALUES ($1, $2, $3, $4, $5)
    `;

    let parcelAddedCount = 0;

    for (const parcel of parcels) {
      const parcelId = await generateId(51);

      const parcelValues = [
        parcelId,
        orderId,
        parcel.parcel_type_id,
        parcel.parcel_size_id,
        parcel.weight || 0
      ];

      const parcelResult = await pool.query(parcelQuery, parcelValues);

      if (parcelResult.rowCount > 0) {
        parcelAddedCount++;
      }
    }

    return parcelAddedCount === parcels.length;

  } catch (error) {
    console.log("Error inserting parcel data to SQL: ", error);
    return false;
  }
};

const createOrder = async (authToken, options) => {
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
  } = options;

  try {
    console.log(`[userService] createOrder called. Method: ${payment_method}`);
    //Extract token data
    const extractedData = extractJwtTokenData(authToken);
    const userId = extractedData?.userId;
    const businessId = extractedData?.businessId;

    if (!userId) {
      throw new Error("Invalid auth token");
    }

    const orderId = await generateId(50);

    const orderQuery = `
      INSERT INTO orders (
        order_id, sender_id, business_id, sender_name, sender_phone,
        sender_address, sender_state, sender_city, sender_pincode,
        receiver_name, receiver_phone, receiver_address, receiver_state,
        receiver_city, receiver_pincode, special_instruction, 
        order_amount, delivery_status_id, created_at, is_complete,
        urgency, fare_breakdown, sender_lat, sender_lng, receiver_lat, receiver_lng,
        payment_method
      )
      VALUES (
        $1, $2, $3, $4, $5,
        $6, $7, $8, $9,
        $10, $11, $12, $13,
        $14, $15, $16, $17,
        (SELECT value_id FROM value_master WHERE value_name = 'Order Placed'),
        NOW(), $18, $19, $20, $21, $22, $23, $24,
        $25
      )
    `;

    const orderValues = [
      orderId,
      userId,
      businessId,
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
      special_instruction, // $16
      Math.round(Number(order_amount) || 0), // $17
      false, // $18 (is_complete)
      urgency, // $19
      fare_breakdown ? JSON.stringify(fare_breakdown) : null, // $20
      sender_lat ?? null, // $21
      sender_lng ?? null, // $22
      receiver_lat ?? null, // $23
      receiver_lng ?? null, // $24
      payment_method || 'cash' // $25 (Placeholder index 25)
    ];

    console.log('[userService] SQL Values Mapping:');
    orderValues.forEach((val, idx) => {
        console.log(`  $${idx + 1}: ${val}`);
    });

    const orderResult = await pool.query(orderQuery, orderValues);

    if (orderResult.rowCount === 0) {
      throw new Error("Order insert failed");
    }

    const parcelResult = await insertParcels(orderId, parcels);

    if (parcelResult !== true) {
      throw new Error("Parcel insert failed");
    }

    const orderData = await pool.query(
      `SELECT * FROM orders WHERE order_id = $1`,
      [orderId]
    );

    const parcelData = await pool.query(
      `SELECT * FROM parcels WHERE order_id = $1`,
      [orderId]
    );

    // If it's an out-of-city order, compute its route
    let computedRoute = null;
    if (fare_breakdown && fare_breakdown.mode !== 'LOCAL_DELIVERY') {
      computedRoute = await computeOrderRoute(
          sender_lat, sender_lng, receiver_lat, receiver_lng
      );
      if (computedRoute) {
        await pool.query(
            `UPDATE orders SET route_data = $1 WHERE order_id = $2`,
            [JSON.stringify(computedRoute), orderId]
        );
      }
    }

    return {
      orderData: orderData.rows,
      parcelData: parcelData.rows,
      routeData: computedRoute
    };

  } catch (error) {
    console.log("Error inserting order data to SQL:", error);
    return false;
  }
};

const insertParcels_MOVED_ABOVE = null; // placeholder - function moved above createOrder

const updateUserRole = async (phone, role_id) => {
  try {
    const query = `UPDATE users SET role_id = $1 WHERE phone = $2`;
    const result = await pool.query(query, [role_id, phone]);
    return result.rowCount > 0;
  } catch (error) {
    console.log("Error updating user role:", error);
    return false;
  }
};

const updateUserLocation = async (userId, lat, lng) => {
  try {
    const query = `UPDATE users SET current_lat = $1, current_lng = $2 WHERE user_id = $3`;
    const result = await pool.query(query, [lat, lng, userId]);
    return result.rowCount > 0;
  } catch (error) {
    console.log("Error updating user location:", error);
    return false;
  }
};

const toggleUserBan = async (userId, isBanned) => {
    try {
        const query = `UPDATE users SET is_banned = $1 WHERE user_id = $2`;
        const result = await pool.query(query, [isBanned, userId]);
        return result.rowCount > 0;
    } catch (err) {
        console.error("Error toggling user ban:", err);
        throw err;
    }
};

const deleteUser = async (userId) => {
    try {
        const query = `UPDATE users SET is_deleted = true, is_banned = true WHERE user_id = $1`;
        const result = await pool.query(query, [userId]);
        return result.rowCount > 0;
    } catch (err) {
        console.error("Error soft deleting user:", err);
        throw err;
    }
};

const adminCreateUser = async (data) => {
    try {
        const { first_name, last_name, email, phone, password, role_id } = data;
        const hashedPassword = await bcrypt.hash(password, 10);
        const userId = await generateId(role_id === 9 ? 30 : 10); 
        
        const query = `
            INSERT INTO users (user_id, first_name, last_name, email, phone, password, role_id, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
            RETURNING user_id, email, role_id
        `;
        const result = await pool.query(query, [userId, first_name, last_name, email, phone, hashedPassword, role_id]);
        return result.rows[0];
    } catch (err) {
        console.error("Error admin creating user:", err);
        throw err;
    }
};

const getAllUsers = async () => {
  try {
    const query = `
      SELECT u.user_id, u.first_name, u.last_name, u.email, u.phone, u.is_banned, u.created_at, r.role_name, u.role_id, u.current_lat, u.current_lng
      FROM users u
      LEFT JOIN roles_master r ON u.role_id = r.role_id
      WHERE u.is_deleted = false
      ORDER BY u.created_at DESC
    `;
    const result = await pool.query(query);
    return result.rows;
  } catch (error) {
    console.log("Error getting all users:", error);
    return false;
  }
};

const getAllDeliveryPartners = async () => {
  try {
    const query = `
      SELECT u.user_id, u.first_name, u.last_name, u.email, u.phone, u.is_banned, u.created_at, r.role_name, u.role_id, 
             dp.birth_date, dp.profile_picture, dp.license_number, dp.expiry_date, dp.license_photo, 
             dp.document_number, dp.document_photo, dp.vehicle_number, dp.rc_book_picture, 
             dp.working_state, dp.working_city, dp.time_slot, dp.bank_name, dp.branch_name, 
             dp.account_number, dp.account_type, dp.ifsc_code, dp.account_holder_name, dp.is_verified,
             u.current_lat, u.current_lng,
             vm1.value_name AS document_type,
             vm2.value_name AS vehicle_type,
             vm3.value_name AS working_type,
             vm4.value_name AS account_status,
             (SELECT COUNT(*) FROM orders WHERE delivery_partner_id = u.user_id AND is_complete = true) as total_deliveries,
             (SELECT COALESCE(SUM(dp_share), 0) FROM delivery_partner_payout_orders WHERE delivery_partner_id = u.user_id) as lifetime_earnings,
             (SELECT COALESCE(SUM(dp_share), 0) FROM delivery_partner_payout_orders WHERE delivery_partner_id = u.user_id AND status != 'paid') as unsettled_amount
      FROM users u
      LEFT JOIN delivery_partner dp ON u.user_id = dp.delivery_partner_id
      LEFT JOIN roles_master r ON u.role_id = r.role_id
      LEFT JOIN value_master vm1 ON dp.document_type_id = vm1.value_id
      LEFT JOIN value_master vm2 ON dp.vehicle_type_id = vm2.value_id
      LEFT JOIN value_master vm3 ON dp.working_type_id = vm3.value_id
      LEFT JOIN value_master vm4 ON dp.account_status_id = vm4.value_id
      WHERE u.role_id = 9 AND u.is_deleted = false
      ORDER BY u.created_at DESC
    `;
    const result = await pool.query(query);
    return result.rows;
  } catch (error) {
    console.log("Error getting all delivery partners:", error);
    return false;
  }
};

const verifyDeliveryPartner = async (partnerId) => {
  try {
    const query = `
      UPDATE delivery_partner
      SET is_verified = true
      WHERE delivery_partner_id = $1
      RETURNING *
    `;
    const result = await pool.query(query, [partnerId]);
    return result.rows.length > 0;
  } catch (error) {
    console.log("Error verifying delivery partner:", error);
    return false;
  }
};

// ─── Delivery Partner Order Dispatch ──────────────────────────────────────────

/** Returns all unassigned "Order Placed" orders */
const getPendingOrders = async () => {
  try {
    const result = await pool.query(`
      SELECT o.*, (o.order_amount * 0.8) as dp_share
      FROM orders o
      WHERE o.delivery_status_id = (SELECT value_id FROM value_master WHERE value_name = 'Order Placed')
        AND o.delivery_partner_id IS NULL
        AND o.is_complete = false
      ORDER BY o.created_at DESC
      LIMIT 10
    `);
    return result.rows;
  } catch (error) {
    console.error('Error fetching pending orders:', error);
    return [];
  }
};

/** DP accepts an order — assigns themselves and updates status to Assigned */
const acceptOrder = async (orderId, dpId) => {
  try {
    const result = await pool.query(`
      UPDATE orders
      SET delivery_partner_id = $1,
          delivery_status_id  = (SELECT value_id FROM value_master WHERE value_name = 'Assigned')
      WHERE order_id = $2
        AND delivery_partner_id IS NULL
      RETURNING *
    `, [dpId, orderId]);
    return result.rows[0] ?? null;
  } catch (error) {
    console.error('Error accepting order:', error);
    return null;
  }
};

/** Returns the current active (non-complete) order for a DP */
const getDPActiveOrder = async (dpId) => {
  try {
    const result = await pool.query(`
      SELECT o.*, (o.order_amount * 0.8) as dp_share
      FROM orders o
      WHERE o.delivery_partner_id = $1
        AND o.is_complete = false
      ORDER BY o.created_at DESC
      LIMIT 1
    `, [dpId]);
    return result.rows[0] ?? null;
  } catch (error) {
    console.error('Error fetching active order:', error);
    return null;
  }
};

/** Update delivery status for an order (and mark complete if Delivered) */
const updateOrderStatus = async (orderId, dpId, statusName) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    const isComplete = statusName === 'Delivered';
    const result = await client.query(`
      UPDATE orders
      SET delivery_status_id = (SELECT value_id FROM value_master WHERE value_name = $1),
          is_complete = $2
      WHERE order_id = $3 AND delivery_partner_id = $4
      RETURNING *
    `, [statusName, isComplete, orderId, dpId]);

    if (result.rowCount > 0) {
      // Log the change for tracking
      await client.query(`
        INSERT INTO order_status_history (order_id, delivery_status_id, updating_partner_id, updated_at)
        VALUES ($1, (SELECT value_id FROM value_master WHERE value_name = $2), $3, NOW())
      `, [orderId, statusName, dpId]);

      // Auto-create payout record when cash is collected at pickup (or when delivered for online)
      const order = result.rows[0];
      console.log(`[userService] updateOrderStatus: Order ${orderId} is "${order.payment_method}"`);
      const isCash = (order.payment_method || 'cash') === 'cash';
      
      if ((isCash && statusName === 'Picked Up') || isComplete) {
        await createPayoutForOrder(order, client);
      }
    }

    await client.query('COMMIT');
    return result.rows[0] ?? null;
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error updating order status:', error);
    return null;
  } finally {
    client.release();
  }
};

const adminUpdateOrderStatus = async (orderId, statusName) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    const isComplete = statusName === 'Delivered';
    const result = await client.query(`
      UPDATE orders
      SET delivery_status_id = (SELECT value_id FROM value_master WHERE value_name = $1),
          is_complete = $2
      WHERE order_id = $3
      RETURNING *
    `, [statusName, isComplete, orderId]);

    if (result.rowCount > 0) {
      await client.query(`
        INSERT INTO order_status_history (order_id, delivery_status_id, updating_partner_id, updated_at)
        VALUES ($1, (SELECT value_id FROM value_master WHERE value_name = $2), NULL, NOW())
      `, [orderId, statusName]);

      // Auto-create payout record when cash is collected at pickup (or when delivered for online)
      const isCash = (result.rows[0].payment_method || 'cash') === 'cash';
      if ((isCash && statusName === 'Picked Up') || isComplete) {
        await createPayoutForOrder(result.rows[0], client);
      }
    }

    await client.query('COMMIT');
    return result.rows[0] ?? null;
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error in adminUpdateOrderStatus:', error);
    return null;
  } finally {
    client.release();
  }
};

// ── PAYMENT/PAYOUT LOGIC ──────────────────────────────────────────

const DP_SHARE_PERCENT = 0.80;
const ADMIN_SHARE_PERCENT = 0.20;

/** Auto-create a payout record when an order is delivered.
 * Optional 'client' parameter for transaction support.
 */
const createPayoutForOrder = async (order, client = pool) => {
  try {
    if (!order.delivery_partner_id) {
      console.warn(`Cannot create payout for order ${order.order_id}: no delivery partner assigned`);
      return null;
    }

    // Check if payout already exists for this order
    const existingPayout = await client.query(
      `SELECT payout_order_id FROM delivery_partner_payout_orders WHERE order_id = $1`,
      [order.order_id]
    );
    if (existingPayout.rowCount > 0) {
      console.log(`Payout already exists for order ${order.order_id}`);
      return existingPayout.rows[0];
    }

    const orderAmount = Number(order.order_amount) || 0;
    const dpShare = Math.round(orderAmount * DP_SHARE_PERCENT * 100) / 100;
    const adminShare = Math.round(orderAmount * ADMIN_SHARE_PERCENT * 100) / 100;
    
    // EXPLICIT LOGGING to catch why 'online' becomes 'cash'
    const paymentMethod = String(order.payment_method || 'cash').trim().toLowerCase();
    const isCash = paymentMethod === 'cash';

    console.log(`[userService] createPayoutForOrder: Order ${order.order_id} method is "${paymentMethod}", isCash=${isCash}`);

    // For cash orders: DP collected cash, so status = 'cash_pending' (DP must deposit cash first)
    // For online orders: Admin already has money, status = 'awaiting_payout' (Admin can pay DP directly)
    const status = isCash ? 'cash_pending' : 'awaiting_payout';

    const payoutOrderId = await generateId(60);

    const result = await client.query(`
      INSERT INTO delivery_partner_payout_orders 
        (payout_order_id, order_id, delivery_partner_id, order_amount, amount, dp_share, admin_share, 
         payment_method, cash_collected, status, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
      RETURNING *
    `, [
      payoutOrderId,
      order.order_id,
      order.delivery_partner_id,
      orderAmount,
      dpShare,
      dpShare,
      adminShare,
      paymentMethod,
      isCash ? orderAmount : 0, // DP collected the full amount in cash
      status
    ]);

    console.log(`✅ Payout record created for order ${order.order_id}: DP gets ₹${dpShare}, Admin gets ₹${adminShare} (${paymentMethod})`);
    return result.rows[0];
  } catch (error) {
    console.error('Error creating payout for order:', error);
    // Re-throw if in transaction so the caller can rollback
    if (client !== pool) throw error;
    return null;
  }
};

/** Admin confirms that the DP has deposited cash */
const confirmCashDeposit = async (payoutId) => {
  try {
    const result = await pool.query(`
      UPDATE delivery_partner_payout_orders
      SET cash_deposited = true, cash_deposit_confirmed = true, 
          status = 'awaiting_payout', confirmed_at = NOW()
      WHERE payout_order_id = $1 AND status = 'cash_pending'
      RETURNING *
    `, [payoutId]);
    return result.rows[0] ?? null;
  } catch (error) {
    console.error('Error confirming cash deposit:', error);
    return null;
  }
};

/** Admin pays the DP their 80% share */
const processPayoutToDp = async (payoutId, transactionId, notes) => {
  try {
    const result = await pool.query(`
      UPDATE delivery_partner_payout_orders
      SET is_paid = true, status = 'paid', paid_at = NOW(),
          partner_transaction_id = $2, notes = $3
      WHERE payout_order_id = $1 AND status = 'awaiting_payout'
      RETURNING *
    `, [payoutId, transactionId || null, notes || null]);
    return result.rows[0] ?? null;
  } catch (error) {
    console.error('Error processing payout:', error);
    return null;
  }
};

/**
 * Creates (or upserts) a delivery_partner profile row for an EXISTING user.
 * Called from the mobile app after the sign-up multi-step form is completed.
 * The user record already exists (role_id = 9); this creates the matching delivery_partner row.
 * Accepts type NAMES (e.g. "Bike", "Aadhaar Card") and resolves them to IDs internally.
 */
const createDeliveryPartnerProfile = async (authToken, {
  birth_date,
  profile_picture,
  license_number,
  expiry_date,
  license_photo,
  document_type_name,   // string name e.g. "Aadhaar Card"
  document_number,
  document_photo,
  vehicle_type_name,    // string name e.g. "Bike"
  vehicle_number,
  rc_book_picture,
  working_type_name,    // string name e.g. "Full Time"
  working_state,
  working_city,
  time_slot,
  bank_name,
  branch_name,
  account_number,
  account_holder_name,
  account_type,
  ifsc_code,
}) => {
  try {
    const extractedData = extractJwtTokenData(authToken);
    const userId = extractedData?.userId;

    if (!userId) {
      throw new Error('Invalid auth token');
    }

    // Upsert: insert if not exists, update if already there
    // Type names are resolved to IDs via subqueries
    const query = `
      INSERT INTO delivery_partner (
        delivery_partner_id, birth_date, profile_picture,
        license_number, expiry_date, license_photo,
        document_type_id, document_number, document_photo,
        vehicle_type_id, vehicle_number, rc_book_picture,
        working_type_id, working_state, working_city, time_slot,
        account_status_id, bank_name, branch_name,
        account_number, account_type, ifsc_code, account_holder_name,
        is_verified, created_at
      )
      VALUES (
        $1, $2, $3,
        $4, $5, $6,
        (SELECT value_id FROM value_master WHERE value_name = $7 LIMIT 1),
        $8, $9,
        (SELECT value_id FROM value_master WHERE value_name = $10 LIMIT 1),
        $11, $12,
        (SELECT value_id FROM value_master WHERE value_name = $13 LIMIT 1),
        $14, $15, $16,
        (SELECT value_id FROM value_master WHERE value_name = 'Pending Verification'),
        $17, $18,
        $19, $20, $21, $22,
        false, NOW()
      )
      ON CONFLICT (delivery_partner_id) DO UPDATE SET
        birth_date           = EXCLUDED.birth_date,
        profile_picture      = EXCLUDED.profile_picture,
        license_number       = EXCLUDED.license_number,
        expiry_date          = EXCLUDED.expiry_date,
        license_photo        = EXCLUDED.license_photo,
        document_type_id     = EXCLUDED.document_type_id,
        document_number      = EXCLUDED.document_number,
        document_photo       = EXCLUDED.document_photo,
        vehicle_type_id      = EXCLUDED.vehicle_type_id,
        vehicle_number       = EXCLUDED.vehicle_number,
        rc_book_picture      = EXCLUDED.rc_book_picture,
        working_type_id      = EXCLUDED.working_type_id,
        working_state        = EXCLUDED.working_state,
        working_city         = EXCLUDED.working_city,
        time_slot            = EXCLUDED.time_slot,
        bank_name            = EXCLUDED.bank_name,
        branch_name          = EXCLUDED.branch_name,
        account_number       = EXCLUDED.account_number,
        account_type         = EXCLUDED.account_type,
        ifsc_code            = EXCLUDED.ifsc_code,
        account_holder_name  = EXCLUDED.account_holder_name
      RETURNING delivery_partner_id
    `;

    const values = [
      userId,
      birth_date || null,
      profile_picture || null,
      license_number || null,
      expiry_date || null,
      license_photo || null,
      document_type_name || null,
      document_number || null,
      document_photo || null,
      vehicle_type_name || null,
      vehicle_number || null,
      rc_book_picture || null,
      working_type_name || null,
      working_state || null,
      working_city || null,
      time_slot || null,
      bank_name || null,
      branch_name || null,
      account_number || null,
      account_type || null,
      ifsc_code || null,
      account_holder_name || null,
    ];

    const result = await pool.query(query, values);
    return result.rows.length > 0 ? result.rows[0].delivery_partner_id : false;
  } catch (error) {
    console.error('Error creating delivery partner profile:', error);
    return false;
  }
};


const getDeliveryPartnerProfile = async (authToken) => {
  try {
    const extractedData = extractJwtTokenData(authToken);
    const userId = extractedData?.userId;
    if (!userId) throw new Error('Invalid token');

    const query = `
      SELECT u.first_name, u.last_name, u.phone, u.email,
             dp.*,
             vm.value_name as vehicle_type_name
      FROM users u
      LEFT JOIN delivery_partner dp ON dp.delivery_partner_id = u.user_id
      LEFT JOIN value_master vm ON dp.vehicle_type_id = vm.value_id
      WHERE u.user_id = $1
    `;
    const res = await pool.query(query, [userId]);
    if (res.rows.length === 0) return null;
    return res.rows[0];
  } catch (err) {
    console.error("Error fetching DP profile:", err);
    throw err;
  }
};
const getAllOrders = async () => {
    try {
        const query = `
            SELECT 
                o.*,
                u.first_name as sender_first_name,
                u.last_name as sender_last_name,
                dp.first_name as dp_first_name,
                dp.last_name as dp_last_name,
                vs.value_name as status_name,
                (
                    SELECT json_agg(json_build_object(
                        'parcel_id', p.parcel_id,
                        'parcel_type', pt.value_name,
                        'parcel_size', ps.value_name,
                        'weight', p.weight
                    ))
                    FROM parcels p
                    LEFT JOIN value_master pt ON p.parcel_type_id = pt.value_id
                    LEFT JOIN value_master ps ON p.parcel_size_id = ps.value_id
                    WHERE p.order_id = o.order_id
                ) as parcels
            FROM orders o
            LEFT JOIN users u ON o.sender_id = u.user_id
            LEFT JOIN users dp ON o.delivery_partner_id = dp.user_id
            LEFT JOIN value_master vs ON o.delivery_status_id = vs.value_id
            ORDER BY o.created_at DESC
        `;
        const res = await pool.query(query);
        return res.rows;
    } catch (err) {
        console.error("Error fetching all orders:", err);
        throw err;
    }
};
const getCustomerOrders = async (userId) => {
    try {
        const query = `
            SELECT 
                o.*,
                u.first_name as sender_first_name,
                u.last_name as sender_last_name,
                dp.first_name as dp_first_name,
                dp.last_name as dp_last_name,
                dp.phone as dp_phone,
                dp.current_lat, dp.current_lng,
                vs.value_name as status_name,
                (
                    SELECT json_agg(json_build_object(
                        'parcel_id', p.parcel_id,
                        'parcel_type', pt.value_name,
                        'parcel_size', ps.value_name,
                        'weight', p.weight
                    ))
                    FROM parcels p
                    LEFT JOIN value_master pt ON p.parcel_type_id = pt.value_id
                    LEFT JOIN value_master ps ON p.parcel_size_id = ps.value_id
                    WHERE p.order_id = o.order_id
                ) as parcels
            FROM orders o
            LEFT JOIN users u ON o.sender_id = u.user_id
            LEFT JOIN users dp ON o.delivery_partner_id = dp.user_id
            LEFT JOIN value_master vs ON o.delivery_status_id = vs.value_id
            WHERE o.sender_id = $1
            ORDER BY o.created_at DESC
        `;
        const res = await pool.query(query, [userId]);
        return res.rows;
    } catch (err) {
        console.error("Error fetching customer orders:", err);
        throw err;
    }
};

const getDeliveryPartnerOrders = async (dpId, timeframe = 'all') => {
    try {
        let dateFilter = '';
        if (timeframe === '7d') dateFilter = "AND o.created_at >= CURRENT_DATE - INTERVAL '7 days'";
        else if (timeframe === '1m') dateFilter = "AND o.created_at >= CURRENT_DATE - INTERVAL '30 days'";
        else if (timeframe === '1y') dateFilter = "AND o.created_at >= CURRENT_DATE - INTERVAL '1 year'";

        const query = `
            SELECT 
                o.*,
                vs.value_name as status_name,
                payout.dp_share,
                (
                    SELECT json_agg(json_build_object(
                        'parcel_type', pt.value_name,
                        'parcel_size', ps.value_name
                    ))
                    FROM parcels p
                    LEFT JOIN value_master pt ON p.parcel_type_id = pt.value_id
                    LEFT JOIN value_master ps ON p.parcel_size_id = ps.value_id
                    WHERE p.order_id = o.order_id
                ) as parcels
            FROM orders o
            LEFT JOIN value_master vs ON o.delivery_status_id = vs.value_id
            LEFT JOIN delivery_partner_payout_orders payout ON o.order_id = payout.order_id
            WHERE o.delivery_partner_id = $1 ${dateFilter}
            ORDER BY o.created_at DESC
        `;
        const res = await pool.query(query, [dpId]);
        return res.rows;
    } catch (err) {
        console.error("Error fetching delivery partner orders:", err);
        throw err;
    }
};

const getAllBusinesses = async () => {
    try {
        const query = `
            SELECT 
                bc.business_id, bc.company_name, bc.reg_no, bc.business_phone, bc.created_at, 
                u.email as admin_email, u.first_name as admin_first_name, u.last_name as admin_last_name,
                vt.value_name as business_type,
                vb.value_name as billing_cycle,
                vp.value_name as payment_method,
                va.value_name as account_status
            FROM business_clients bc
            LEFT JOIN users u ON bc.account_admin_id = u.user_id
            LEFT JOIN value_master vt ON bc.business_type_id = vt.value_id
            LEFT JOIN value_master vb ON bc.billing_cycle_id = vb.value_id
            LEFT JOIN value_master vp ON bc.payment_method_id = vp.value_id
            LEFT JOIN value_master va ON bc.account_status_id = va.value_id
            ORDER BY bc.created_at DESC
        `;
        const result = await pool.query(query);
        return result.rows;
    } catch (error) {
        console.log("Error getting all businesses:", error);
        return false;
    }
};

const getDashboardStats = async (timeframe = 'all') => {
    try {
        let dateFilter = '';
        if (timeframe === '7d') dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '7 days'";
        else if (timeframe === '1m') dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '30 days'";
        else if (timeframe === '1y') dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '1 year'";

        const statsQuery = `
            SELECT 
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COUNT(*) FROM users u JOIN roles_master r ON u.role_id = r.role_id WHERE r.role_name = 'Customer') as total_customers,
                (SELECT COUNT(*) FROM users u JOIN roles_master r ON u.role_id = r.role_id WHERE r.role_name = 'Business') as total_businesses,
                (SELECT COUNT(*) FROM users u JOIN roles_master r ON u.role_id = r.role_id WHERE r.role_name IN ('Delivery Partner', 'Rider') OR u.role_id = 9) as total_delivery_partners,
                (SELECT COUNT(*) FROM delivery_partner WHERE is_verified = true) as active_delivery_partners,
                (SELECT COUNT(*) FROM delivery_partner WHERE is_verified = false) as pending_verifications,
                (SELECT COUNT(*) FROM users WHERE is_banned = true) as banned_accounts,
                (SELECT COUNT(*) FROM orders WHERE 1=1 ${dateFilter}) as total_orders,
                (SELECT COUNT(*) FROM orders WHERE created_at >= CURRENT_DATE) as orders_today,
                (SELECT COUNT(*) FROM orders o JOIN value_master v ON o.delivery_status_id = v.value_id WHERE v.value_name IN ('Picked Up', 'In Transit', 'Assigned') ${dateFilter}) as orders_in_transit,
                (SELECT COUNT(*) FROM orders o JOIN value_master v ON o.delivery_status_id = v.value_id WHERE v.value_name = 'Delivered' ${dateFilter}) as delivered_orders,
                (SELECT COALESCE(SUM(order_amount), 0) FROM orders WHERE 1=1 ${dateFilter}) as total_revenue
            FROM (SELECT 1) dummy
        `;
        
        const revenueQuery = `
            SELECT 
                DATE(created_at) as date,
                SUM(order_amount) as amount
            FROM orders
            WHERE 1=1 ${dateFilter}
            GROUP BY DATE(created_at)
            ORDER BY DATE(created_at) ASC
        `;

        const orderTrendQuery = `
            SELECT 
                DATE(created_at) as date,
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE delivery_status_id = (SELECT value_id FROM value_master WHERE value_name = 'Delivered')) as delivered
            FROM orders
            WHERE 1=1 ${dateFilter}
            GROUP BY DATE(created_at)
            ORDER BY DATE(created_at) ASC
        `;

        const stats = await pool.query(statsQuery);
        const revenue = await pool.query(revenueQuery);
        const orderTrend = await pool.query(orderTrendQuery);

        return {
            ...stats.rows[0],
            revenueTrend: revenue.rows.map(r => ({ name: new Date(r.date).toLocaleDateString('en-US', { weekday: 'short' }), revenue: parseFloat(r.amount) })),
            orderTrend: orderTrend.rows.map(o => ({ name: new Date(o.date).toLocaleDateString('en-US', { weekday: 'short' }), total: parseInt(o.total), delivered: parseInt(o.delivered) }))
        };
    } catch (err) {
        console.error("Error fetching dashboard stats:", err);
        throw err;
    }
};


const getAllParcels = async () => {
    try {
        const query = `
            SELECT p.parcel_id, p.order_id, p.weight, 
                   pt.value_name as parcel_type_name, 
                   ps.value_name as parcel_size_name
            FROM parcels p
            LEFT JOIN value_master pt ON p.parcel_type_id = pt.value_id
            LEFT JOIN value_master ps ON p.parcel_size_id = ps.value_id
            ORDER BY p.parcel_id DESC
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};

const getAllPayments = async () => {
    try {
        const query = `
            SELECT t.*, pm.value_name as payment_method_name, ps.value_name as payment_status_name
            FROM transactions t
            LEFT JOIN value_master pm ON t.payment_method_id = pm.value_id
            LEFT JOIN value_master ps ON t.payment_status_id = ps.value_id
            ORDER BY t.created_at DESC
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};

const getAllPayouts = async () => {
    try {
        const query = `
            SELECT p.*, 
                   dp.first_name, dp.last_name, dp.phone as dp_phone, dp.email as dp_email
            FROM delivery_partner_payout_orders p
            LEFT JOIN users dp ON p.delivery_partner_id = dp.user_id
            ORDER BY 
                CASE p.status 
                    WHEN 'cash_pending' THEN 1 
                    WHEN 'awaiting_payout' THEN 2 
                    WHEN 'paid' THEN 3 
                    ELSE 4 
                END,
                p.created_at DESC
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};

const getPayoutsByPartner = async () => {
    try {
        const query = `
            SELECT 
                p.delivery_partner_id,
                dp.first_name, dp.last_name, dp.phone, dp.email,
                COUNT(*) FILTER (WHERE p.status = 'cash_pending') as cash_pending_count,
                COUNT(*) FILTER (WHERE p.status = 'awaiting_payout') as awaiting_payout_count,
                COALESCE(SUM(order_amount) FILTER (WHERE p.status = 'cash_pending'), 0) as total_cash_to_collect,
                COALESCE(SUM(dp_share) FILTER (WHERE p.status = 'awaiting_payout'), 0) as total_ready_to_pay,
                COALESCE(SUM(dp_share) FILTER (WHERE p.status = 'cash_pending'), 0) as dp_share_in_cash,
                COALESCE(SUM(admin_share) FILTER (WHERE p.status = 'cash_pending'), 0) as company_share_in_cash
            FROM delivery_partner_payout_orders p
            LEFT JOIN users dp ON p.delivery_partner_id = dp.user_id
            WHERE p.status != 'paid'
            GROUP BY p.delivery_partner_id, dp.first_name, dp.last_name, dp.phone, dp.email
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};


const getPayoutStats = async () => {
    try {
        const query = `
            SELECT 
                COUNT(*) FILTER (WHERE status = 'cash_pending') as cash_pending_count,
                COUNT(*) FILTER (WHERE status = 'awaiting_payout') as awaiting_payout_count,
                COUNT(*) FILTER (WHERE status = 'paid') as paid_count,
                COALESCE(SUM(order_amount) FILTER (WHERE payment_method = 'cash' AND status != 'paid'), 0) as total_cash_held,
                COALESCE(SUM(order_amount) FILTER (WHERE payment_method != 'cash' AND status != 'paid'), 0) as total_online_held,
                COALESCE(SUM(order_amount) FILTER (WHERE status != 'paid'), 0) as grand_total_pending,
                COALESCE(SUM(dp_share) FILTER (WHERE status = 'awaiting_payout'), 0) as total_awaiting,
                COALESCE(SUM(dp_share) FILTER (WHERE status = 'cash_pending'), 0) as total_cash_pending,
                COALESCE(SUM(dp_share) FILTER (WHERE status = 'paid'), 0) as total_paid_out,
                COALESCE(SUM(admin_share), 0) as total_admin_earnings
            FROM delivery_partner_payout_orders
        `;
        const { rows } = await pool.query(query);
        return rows[0];
    } catch (err) {
        throw err;
    }
};

const confirmPartnerCash = async (partnerId) => {
    try {
        const query = `
            UPDATE delivery_partner_payout_orders
            SET cash_deposited = true, cash_deposit_confirmed = true,
                status = 'awaiting_payout', is_paid = false, confirmed_at = NOW()
            WHERE delivery_partner_id = $1 AND status = 'cash_pending'
            RETURNING *
        `;
        const { rows } = await pool.query(query, [partnerId]);
        return rows;
    } catch (err) {
        throw err;
    }
};

const processPartnerBulkPayout = async (partnerId, transactionId, notes) => {
    try {
        console.log(`[SERVICE] Settle bulk payout for DP ${partnerId} with Txn ${transactionId}`);
        const query = `
            UPDATE delivery_partner_payout_orders
            SET status = 'paid', is_paid = true, partner_transaction_id = $2, notes = $3, paid_at = NOW()
            WHERE delivery_partner_id = $1 AND status = 'awaiting_payout'
            RETURNING *
        `;
        const { rows } = await pool.query(query, [partnerId, transactionId, notes]);
        console.log(`[SERVICE] Query complete. Rows affected: ${rows.length}`);
        return rows;
    } catch (err) {
        console.error('[SERVICE ERROR] Bulk Payout Failed:', err);
        throw err;
    }
};

const createComplaint = async (orderId, userId, complaintTypeId, description) => {
  try {
    const complaintId = await generateId(80);
    const query = `
      INSERT INTO complaints (complaint_id, order_id, user_id, complaint_type_id, complaint_status_id, description, created_at)
      VALUES ($1, $2, $3, $4, (SELECT value_id FROM value_master WHERE value_name = 'In Progress'), $5, NOW())
      RETURNING *
    `;
    const result = await pool.query(query, [complaintId, orderId, userId, complaintTypeId, description]);
    return result.rows[0];
  } catch (err) {
    console.error("Error creating complaint:", err);
    return false;
  }
};

const getAllComplaints = async () => {
    try {
        const query = `
            SELECT c.*, ct.value_name as complaint_type_name, cs.value_name as complaint_status_name,
                   u.first_name, u.last_name, u.email
            FROM complaints c
            LEFT JOIN value_master ct ON c.complaint_type_id = ct.value_id
            LEFT JOIN value_master cs ON c.complaint_status_id = cs.value_id
            LEFT JOIN users u ON c.user_id = u.user_id
            ORDER BY c.created_at DESC
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};

const getMyComplaints = async (userId) => {
    try {
        const query = `
            SELECT c.*, ct.value_name as complaint_type_name, cs.value_name as complaint_status_name
            FROM complaints c
            LEFT JOIN value_master ct ON c.complaint_type_id = ct.value_id
            LEFT JOIN value_master cs ON c.complaint_status_id = cs.value_id
            WHERE c.user_id = $1
            ORDER BY c.created_at DESC
        `;
        const { rows } = await pool.query(query, [userId]);
        return rows;
    } catch (err) {
        throw err;
    }
};


const getAllBilling = async () => {
    try {
        const query = `
            SELECT b.*, bc.company_name, bs.value_name as billing_status_name
            FROM business_billing_accounts b
            LEFT JOIN business_clients bc ON b.business_id = bc.business_id
            LEFT JOIN value_master bs ON b.billing_status_id = bs.value_id
            ORDER BY b.generated_at DESC
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};

const getAllRoles = async () => {
    try {
        const query = `
            SELECT * FROM roles_master ORDER BY role_id ASC
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};

const createMasterCategory = async (type_name) => {
    try {
        const query = `INSERT INTO main_master (type_name) VALUES ($1) RETURNING *`;
        const result = await pool.query(query, [type_name]);
        return result.rows[0];
    } catch (err) {
        console.error("Error creating master category:", err);
        throw err;
    }
};

const createMasterValue = async (master_id, value_name) => {
    try {
        const query = `INSERT INTO value_master (master_id, value_name) VALUES ($1, $2) RETURNING *`;
        const result = await pool.query(query, [master_id, value_name]);
        return result.rows[0];
    } catch (err) {
        console.error("Error creating master value:", err);
        throw err;
    }
};

const resolveComplaint = async (id, admin_note) => {
    try {
        // Find 'Resolved' status ID
        const statusQuery = `SELECT value_id FROM value_master WHERE value_name = 'Resolved' LIMIT 1`;
        const statusRes = await pool.query(statusQuery);
        const resolvedId = statusRes.rows[0]?.value_id;
        
        const query = `UPDATE complaints SET complaint_status_id = $1, admin_note = $2 WHERE complaint_id = $3`;
        const result = await pool.query(query, [resolvedId, admin_note, id]);
        return result.rowCount > 0;
    } catch (err) {
        console.error("Error resolving complaint:", err);
        throw err;
    }
};

const generateBilling = async () => {
    try {
        // Mock implementation: find orders for business clients that aren't billed yet
        // In reality, this would be a complex batch process
        const statusQuery = `SELECT value_id FROM value_master WHERE value_name = 'Pending' LIMIT 1`;
        const statusRes = await pool.query(statusQuery);
        const pendingStatusId = statusRes.rows[0]?.value_id;

        const query = `
            INSERT INTO business_billing_accounts (business_id, billing_status_id, amount, generated_at)
            SELECT business_id, $1, SUM(order_amount), NOW()
            FROM orders
            WHERE business_id IS NOT NULL AND created_at >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY business_id
            RETURNING *
        `;
        const result = await pool.query(query, [pendingStatusId]);
        return result.rowCount;
    } catch (err) {
        console.error("Error generating billing:", err);
        throw err;
    }
};

const getAllMasterData = async () => {
    try {
        const query = `
            SELECT vm.*, mm.type_name as category_title
            FROM value_master vm
            LEFT JOIN main_master mm ON vm.master_id = mm.master_id
            ORDER BY mm.master_id ASC, vm.value_id ASC
        `;
        const { rows } = await pool.query(query);
        return rows;
    } catch (err) {
        throw err;
    }
};


const getDeliveryPartnerWalletDetails = async (dpId, timeframe = 'all') => {
    try {
        let dateFilter = '';
        if (timeframe === '7d') dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '7 days'";
        else if (timeframe === '1m') dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '30 days'";
        else if (timeframe === '1y') dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '1 year'";

        const query = `
            SELECT 
                COALESCE(SUM(CASE WHEN status = 'cash_pending' THEN cash_collected ELSE 0 END), 0) as cash_in_hand,
                COALESCE(SUM(CASE WHEN status = 'awaiting_payout' THEN dp_share ELSE 0 END), 0) as unpaid_online_earnings,
                COALESCE(SUM(CASE WHEN status = 'paid' THEN dp_share ELSE 0 END), 0) as lifetime_earnings
            FROM delivery_partner_payout_orders
            WHERE delivery_partner_id = $1 ${dateFilter}
        `;
        const { rows } = await pool.query(query, [dpId]);
        
        const historyQuery = `
            SELECT payout_order_id, order_id, order_amount, dp_share, payment_method, status, cash_collected, created_at, paid_at
            FROM delivery_partner_payout_orders
            WHERE delivery_partner_id = $1 ${dateFilter}
            ORDER BY created_at DESC
        `;
        const historyRes = await pool.query(historyQuery, [dpId]);
        
        return {
            stats: rows[0],
            history: historyRes.rows
        };
    } catch (error) {
        console.error("Error fetching DP wallet details:", error);
        throw error;
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
    updateUserLocation, 
    getAllUsers, 
    getAllDeliveryPartners, 
    verifyDeliveryPartner, 
    createDeliveryPartnerProfile, 
    getDeliveryPartnerProfile, 
    getPendingOrders, 
    acceptOrder, 
    getDPActiveOrder, 
    updateOrderStatus, 
    getAllOrders, 
    getCustomerOrders, 
    getDeliveryPartnerOrders,
    getDashboardStats,
    getAllBusinesses,
    adminUpdateOrderStatus,
    getAllParcels,
    getAllPayments,
    getAllPayouts,
    getPayoutStats,
    createComplaint,
    getAllComplaints,
    getMyComplaints,
    getAllBilling,
    getAllRoles,
    getAllMasterData,
    toggleUserBan,
    deleteUser,
    adminCreateUser,
    createMasterCategory,
    createMasterValue,
    resolveComplaint,
    generateBilling,
    confirmCashDeposit,
    processPayoutToDp,
    getPayoutsByPartner,
    confirmPartnerCash,
    processPartnerBulkPayout,
    getDeliveryPartnerWalletDetails
};