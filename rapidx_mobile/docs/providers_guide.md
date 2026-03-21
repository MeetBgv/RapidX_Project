# Working with Providers

This project uses the `provider` package for state management. This guide explains how to define, use, and update application state in a clean, maintainable way.

## Overview
The `Provider` pattern uses:
1.  **State Class (`ChangeNotifier`)**: Holds the data and logic.
2.  **Provider Registration (`ChangeNotifierProvider`)**: Makes the state accessible.
3.  **Dependency Injection (`Provider.of` or `Consumer`)**: Accesses the state in widgets.

---

## 1. Creating a Provider
Providers extend `ChangeNotifier`. When data changes, call `notifyListeners()` to update the UI.
### Example: `UserDataProvider` (`lib/providers/userDataProvider.dart`)

```dart
// 1. Define the class extending ChangeNotifier
class UserDataProvider with ChangeNotifier {
  // 2. Define private data (encapsulation)
  String _userName = '';
  List<Map<String, String>> _savedAddresses = [];

  // 3. Create public getters
  String get userName => _userName;
  List<Map<String, String>> get savedAddresses => _savedAddresses;

  // 4. Create methods to modify state
  void setUserName(String name) {
    _userName = name;
    // 5. Notify listeners to trigger rebuilds
    notifyListeners();
  }

  void addAddress(Map<String, String> address) {
    _savedAddresses.add(address);
    notifyListeners();
  }
}
```

---

## 2. Registering the Provider
Wrap the root widget (or the part of the app that needs access) with `MultiProvider` or `ChangeNotifierProvider`.
This is typically done in `lib/main.dart` or `lib/splashPage.dart`.

### Example: `lib/main.dart`

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Register the provider here
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## 3. Consuming Provider Data

### Option A: Using `Consumer<T>` (Recommended for UI Builds)
The `Consumer` widget automatically listens for changes and rebuilds only its children.

```dart
// Example widget that displays the user name
class UserNameDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        // Access data directly
        return Text("Hello, ${userDataProvider.userName}");
      },
    );
  }
}
```

### Option B: Using `Provider.of<T>(context)`
Use this inside methods (like `onPressed`) or when you need data once without rebuilding.

```dart
// Example button that updates the user name
ElevatedButton(
  onPressed: () {
    // Access the provider without listening (listen: false)
    Provider.of<UserDataProvider>(context, listen: false).setUserName("John Doe");
  },
  child: Text("Update Name"),
);
```

---

## Best Practices
1.  **Keep Logic in Providers**: Avoid complex business logic inside UI widgets.
2.  **Use `listen: false`**: When reading data inside event handlers (like button clicks) to prevent unnecessary rebuilds.
3.  **Minimize Rebuilds**: Use `Consumer` or `Selector` to scope rebuilds to specific parts of the UI.
