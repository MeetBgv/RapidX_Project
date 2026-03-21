# Data Flow using Providers for Customer & Delivery Partners

This guide explains how **RapidX Mobile** manages application data like user details, order information, and delivery partner status using the **Provider** pattern.

We use `Provider` to avoid passing data manually through every widget (drilling). Instead, we store data in a central place (the Provider) and any widget can listen to changes.

Whether it is a **Customer** (using `UserDataProvider`) or a **Delivery Partner** (using `DeliveryPartnerProvider`), the data flow pattern is exactly the same.

---

## 🚀 The Core Concept: 3 Easy Steps

1.  **The State (Data Source)**: A class that holds your variables (e.g., `userName`, `phoneNumber`).
2.  **The Trigger**: A function that updates the variable and tells the app "Hey! Data changed!" (`notifyListeners()`).
3.  **The Listener (UI)**: The widget that shows the data and rebuilds automatically when it changes.

---

## 📂 1. File Structure

All data logic lives in the `lib/providers/` folder.

```
lib/
├── main.dart                  <-- Where we "switch on" the providers
└── providers/
    ├── userDataProvider.dart          <-- Logic for Customers
    └── deliveryPartnerProvider.dart   <-- Logic for Delivery Partners
```

---

## 🛠️ 2. The Provider Class (Syntax Explained)

Let's look at a common example: storing a **User's Name**. This code works exactly the same for both Customers and Delivery Partners.

**File:** `lib/providers/userDataProvider.dart`

```dart
import 'package:flutter/material.dart';

// 1. Extend 'ChangeNotifier' so Flutter knows this class can alert the UI of changes.
class UserDataProvider with ChangeNotifier {

  // ==================== A. THE DATA (Private) ====================
  // We make it private (_variable) so only this class can change it directly.
  String _userName = ''; 

  // ==================== B. THE GETTER (Read-only) ====================
  // This allows the UI to READ the data, but not change it directly.
  // We can also add logic here, like returning a default value if empty.
  String get userName => _userName.isEmpty ? 'Guest User' : _userName;

  // ==================== C. THE SETTER (The Trigger) ====================
  // This is the function called by the UI to UPDATE the data.
  void setUserName(String name) {
    _userName = name;          // 1. Update the private variable
    notifyListeners();         // 2. IMPORTANT! This tells all listening widgets to rebuild.
  }
}
```

### Why do we do this?
*   **Encapsulation**: We protect `_userName` so random parts of the app can't break it.
*   **Reactivity**: `notifyListeners()` is the magic implementation that makes the screen update automatically.

---

## 🔌 3. Registering the Provider (Wiring it up)

Before any widget can use the provider, we must initialize it at the very top of our app.

**File:** `lib/main.dart`

```dart
import 'package:provider/provider.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:newrapidx/providers/deliveryPartnerProvider.dart';

void main() {
  runApp(
    // MultiProvider allows us to list ALL our data stores in one place.
    MultiProvider(
      providers: [
        // Create the instance of the providers here
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryPartnerProvider()),
      ],
      child: const newRapidX(),
    ),
  );
}
```

---

## 📱 4. Using the Data in the UI (The Listener)

Now, let's see how a **Profile Page** or **Registration Form** reads and writes this data.

### 📖 Reading Data (Displaying it)

To show the `userName` on the screen, we use `context.watch` or `Consumer`.

```dart
// Inside a build method (e.g., in profilePage.dart)
@override 
Widget build(BuildContext context) {
  // context.watch<UserDataProvider>() keeps listening. 
  // Whenever 'notifyListeners()' is called, this widget causes a rebuild.
  final userData = context.watch<UserDataProvider>();

  return Text(
    "Hello, ${userData.userName}", // Accessing the Getter
    style: TextStyle(fontSize: 20),
  );
}
```

### ✍️ Writing Data (Updating it)

To save the user's input (like when typing in a TextField), we use `context.read` because we just need to execute a function, we don't need to rebuild the widget while typing.

```dart
// Inside a TextField's onChanged or a Button's onPressed
TextField(
  onChanged: (newValue) {
    // context.read<UserDataProvider>() fetches the class once to call the function.
    // It does NOT listen for changes (prevents unnecessary rebuilds while typing).
    context.read<UserDataProvider>().setUserName(newValue); 
  },
  decoration: InputDecoration(labelText: "Enter your name"),
);
```

---

## 🔄 Summary of the Flow

1.  **User Types 'Alice'**: The `TextField` calls `context.read<UserDataProvider>().setUserName('Alice')`.
2.  **Provider Updates**: The `setUserName` function updates `_userName` to 'Alice'.
3.  **App Notified**: The function calls `notifyListeners()`.
4.  **UI Rebuilds**: Any widget using `context.watch<UserDataProvider>()` (like the Profile Page) detects the signal, re-runs its `build` method, and displays "Hello, Alice".

Attributes like `_userAddress`, `_phoneNumber`, `_vehicleType` (for Delivery Partners) all follow this **exact same pattern**.
