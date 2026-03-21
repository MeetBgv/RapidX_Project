# State Management in RapidX

This guide explains how we manage data (state) across the application. We use a hybrid approach recommended by Flutter: **Ephemeral State** (local) and **App State** (global).

## 1. Types of State

### A. Ephemeral State (Local UI State)
Used when state is contained within a single widget and doesn't need to be shared.
**Example**: Controlling a text input field, animation controllers, or the current index of a BottomNavigationBar.

**How we do it**:
We use `StatefulWidget` and `setState()`.

**Code Example (`lib/Customer/customerLogin.dart`)**:
```dart
class _customerLoginState extends State<customerLogin> {
  // 1. Define local variable
  bool _obscurePassword = true;

  void togglePassword() {
    // 2. Wrap change in setState to trigger a rebuild
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscurePassword, // UI reflects the variable
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: togglePassword, // Call the function
        ),
      ),
    );
  }
}
```

---

### B. App State (Global State)
Used when state needs to be shared across many parts of the app or preserved between screens.
**Example**: User profile data, list of saved addresses, or current order status.

**How we do it**:
We use the **Provider** package.

**Code Example (`lib/providers/userDataProvider.dart`)**:
```dart
// 1. Define the model
class UserDataProvider with ChangeNotifier {
  String _userName = '';

  String get userName => _userName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners(); // Alert widgets to rebuild
  }
}
```

---

## 2. Decision Guide: Which to use?

| Scenario | Recommended Approach |
| :--- | :--- |
| **Animation controllers** | `StatefulWidget` (Local) |
| **Tab selection (BottomNavBar)** | `StatefulWidget` (Local) |
| **Form input validation** | `StatefulWidget` (Local) |
| **User Login Data (Name, Email)** | `Provider` (Global) |
| **Shopping Cart / Order List** | `Provider` (Global) |
| **Theme / Settings** | `Provider` (Global) |

---

## 3. Best Practices in This App

1.  **Don't Overuse Provider**: If a variable is only used in *one* widget (like `_obscurePassword` in login), keep it local with `setState`. Putting everything in Provider makes the code harder to follow.
2.  **Private Variables**: In your Provider classes, keep variables private (`_variableName`) and expose them via getters (`get variableName`). This prevents accidental modification from outside without notifying listeners.
3.  **Notify Listeners**: Always remember to call `notifyListeners()` after changing data in a Provider, or the UI will not update.

## 4. Common workflow
1.  **Define**: Create a class in `lib/providers/` that extends `ChangeNotifier`.
2.  **Register**: Add it to the `MultiProvider` list in `lib/main.dart`.
3.  **Read/Write**: Use `Consumer<T>` to read data in the UI, or `Provider.of<T>(context, listen: false)` to update data in functions.
