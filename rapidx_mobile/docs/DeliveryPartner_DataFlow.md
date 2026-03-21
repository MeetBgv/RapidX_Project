# Delivery Partner Data Flow: Sign Up to Database to Profile

This document explains the technical flow of data for the Delivery Partner module, tracing how information moves from the mobile app (Sign Up/Input) to the backend database and then back to the mobile app (Profile/Display).

---

## 🏗️ Part 1: Sign Up (Data Input -> Database)

This phase covers how the user's data is collected, processed, and stored.

### 1. User Interface (Data Collection)
*   **File:** `rapidx_mobile/lib/deliveyPartner/deliveryPartnerSignUp.dart`
*   **Role:** Collects raw input from the user.
*   **Mechanism:**
    *   Uses `TextEditingController`s (e.g., `nameController`, `phoneController`) to capture text.
    *   Uses `ImagePicker` to capture file paths for documents.
    *   **Action:** When the user clicks "Submit" (Step 3), the app calls methods on the `DeliveryPartnerProvider` to save this state locally.
    *   *Note:* The final API call trigger resides here (or in the OTP sheet) to send this collected data to the server.

### 2. State Management (Data Staging)
*   **File:** `rapidx_mobile/lib/providers/deliveryPartnerProvider.dart`
*   **Role:** Acts as a temporary holding area for the data before it is sent to the API.
*   **Mechanism:**
    *   Methods like `updatePersonalDetails(...)` update class properties (`name`, `phone`, etc.).
    *   `notifyListeners()` updates any UI components listening to this data (e.g., a review screen).

### 3. API Call (Transmission)
*   **File:** (Logic should be in `rapidx_mobile/lib/api/api_services.dart` or directly in the UI)
*   **Role:** Sends the HTTP POST request to the backend.
*   **Endpoint:** `http://10.0.2.2:3000/api/users/register/delivery-partner`
*   **Payload:** a JSON object containing all registration fields (`rider_first_name`, `phone`, `license_number`, etc.).

### 4. Backend Controller (Request Handling)
*   **File:** `rapidx_backend/server/src/controllers/userController.js`
*   **Function:** `registerDeliveryPartner`
*   **Role:** Receives the HTTP request and validates the body.
*   **Mechanism:**
    *   Extracts variables from `req.body`.
    *   Calls `userService.registerDeliveryPartner(...)`.
    *   Sends a response (status 201 + Token) back to the mobile app upon success.

### 5. Database Service (Data Persistence)
*   **File:** `rapidx_backend/server/src/services/userService.js`
*   **Function:** `registerDeliveryPartner`
*   **Role:** Executes SQL queries to permanently save data.
*   **Mechanism:**
    *   Hashes the password using `bcrypt`.
    *   Generates unique IDs (`generateId`).
    *   **Transactions:**
        1.  **Users Table:** Inserts login credentials (email, password hash, phone).
        2.  **Addresses Table:** Inserts the partner's address.
        3.  **Delivery_Partner Table:** Inserts specific profile details (license info, vehicle details, bank account).
    *   Returns a JWT (JSON Web Token) to authenticate the user immediately.

---

## 🔄 Part 2: Profile (Database -> Data Display)

This phase covers how the stored data is retrieved and shown to the user.

### 1. Login (Authentication & Fetching)
*   **File:** `rapidx_mobile/lib/Common/CommonLogin.dart`
*   **Role:** Authenticates the user and retrieves their active profile data.
*   **Mechanism:**
    *   User submits Email/Password.
    *   App calls `POST /api/users/login`.
    *   **Backend (`userController.js`):** Checks credentials and returns a JSON object with:
        *   `token`: For future authorized requests.
        *   `user`: Basic user details (First Name, Last Name, Phone, Email).
    *   **Action:** The app parses this response and updates the `DeliveryPartnerProvider` with the fetched data (e.g., `provider.setName(...)`).

### 2. State Management (UI State Update)
*   **File:** `rapidx_mobile/lib/providers/deliveryPartnerProvider.dart`
*   **Role:** Stores the fetched data so it can be used across the app.
*   **Mechanism:**
    *   Setter methods (e.g., `setName(String name)`) update the state variables.
    *   `notifyListeners()` triggers the Profile Page to rebuild with the new data.

### 3. Profile UI (Data Rendering)
*   **File:** `rapidx_mobile/lib/deliveyPartner/mainApp/Profile/profilePageDP.dart`
*   **Role:** Displays the data to the user.
*   **Mechanism:**
    *   **Listener:** `final provider = Provider.of<DeliveryPartnerProvider>(context);`
    *   **Display:** Widgets read directly from the provider properties.
        ```dart
        Text(
          provider.name, // "John Doe"
          style: ...
        )
        ```
    *   **Result:** The user sees the name and details that were originally saved in the database.
