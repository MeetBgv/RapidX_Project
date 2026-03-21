# Riverpod Migration Guide — Delivery Partner

## Overview

The **Delivery Partner** section of the app has been migrated from `provider` (ChangeNotifier) to `flutter_riverpod` (StateNotifier). The **Customer** section still uses the old `provider` package — both coexist in the same app.

---

## Architecture

### Before (Provider)
```
DeliveryPartnerProvider extends ChangeNotifier
├── Mutable fields (name, phone, etc.)
├── Methods call notifyListeners()
└── Widgets use Provider.of<DeliveryPartnerProvider>(context)
```

### After (Riverpod)
```
DeliveryPartnerState (immutable data class with copyWith)
├── All fields are final
└── copyWith() returns a new instance

DeliveryPartnerNotifier extends StateNotifier<DeliveryPartnerState>
├── Methods update state = state.copyWith(...)
└── No manual notifyListeners() needed

deliveryPartnerProvider (global StateNotifierProvider)
└── Widgets use ref.watch() / ref.read()
```

---

## Key Files

| File | Role |
|------|------|
| `lib/providers/delivery_partner_riverpod.dart` | **NEW** — State class, Notifier, and Provider definition |
| `lib/providers/deliveryPartnerProvider.dart` | **OLD** — Can be deleted once no one imports it |

---

## How to Read State (in widgets)

### Old Provider Way
```dart
// Reactive (rebuilds on change)
final provider = Provider.of<DeliveryPartnerProvider>(context);
Text(provider.name);

// Non-reactive (one-time read)
final provider = Provider.of<DeliveryPartnerProvider>(context, listen: false);
```

### New Riverpod Way
```dart
// Reactive (rebuilds on change) — use in build()
final dpState = ref.watch(deliveryPartnerProvider);
Text(dpState.name);

// Non-reactive (one-time read) — use in callbacks/initState
final dpState = ref.read(deliveryPartnerProvider);
```

---

## How to Update State (mutations)

### Old Provider Way
```dart
final provider = Provider.of<DeliveryPartnerProvider>(context, listen: false);
provider.setName("New Name");
provider.updateBankAccount(bank: "SBI", ...);
```

### New Riverpod Way
```dart
ref.read(deliveryPartnerProvider.notifier).setName("New Name");
ref.read(deliveryPartnerProvider.notifier).updateBankAccount(bank: "SBI", ...);
```

> **Key difference**: `.notifier` gives you the `DeliveryPartnerNotifier` (the mutator).  
> Without `.notifier`, you get the `DeliveryPartnerState` (read-only data).

---

## Widget Migration Pattern

### StatelessWidget → ConsumerWidget
```dart
// BEFORE
class ProfilePageDP extends StatelessWidget {
  Widget build(BuildContext context) {
    final provider = Provider.of<DeliveryPartnerProvider>(context);
    ...
  }
}

// AFTER
class ProfilePageDP extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final dpState = ref.watch(deliveryPartnerProvider);
    ...
  }
}
```

### StatefulWidget → ConsumerStatefulWidget
```dart
// BEFORE
class HomePageDP extends StatefulWidget { ... }
class _HomePageDPState extends State<HomePageDP> {
  Widget build(BuildContext context) {
    final provider = Provider.of<DeliveryPartnerProvider>(context);
    ...
  }
}

// AFTER
class HomePageDP extends ConsumerStatefulWidget { ... }
class _HomePageDPState extends ConsumerState<HomePageDP> {
  Widget build(BuildContext context) {
    final dpState = ref.watch(deliveryPartnerProvider);
    // ref is available directly — no need to pass it
    ...
  }
}
```

---

## Import Conflict Resolution

Since both `provider` and `flutter_riverpod` export classes with the same name (`Provider`, `ChangeNotifierProvider`, `Consumer`), you must use `hide` when importing both:

```dart
// When you need BOTH packages in the same file:
import 'package:provider/provider.dart' hide Consumer;
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
```

---

## Files Modified

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `flutter_riverpod: ^2.6.1` |
| `lib/main.dart` | Added `ProviderScope`, removed DP from `MultiProvider` |
| `lib/Common/CommonLogin.dart` | `ConsumerStatefulWidget`, `ref.read(...)` |
| `lib/deliveyPartner/deliveryPartnerSignUp.dart` | `ConsumerStatefulWidget`, `ref.read(...)` |
| `lib/deliveyPartner/mainApp/Home/homepageDP.dart` | `ConsumerStatefulWidget`, `ref.watch(...)` |
| `lib/deliveyPartner/mainApp/Profile/profilePageDP.dart` | `ConsumerWidget`, `ref.watch(...)` |
| `lib/deliveyPartner/mainApp/Profile/bankAccountBottomSheet.dart` | `ConsumerStatefulWidget` |
| `lib/deliveyPartner/mainApp/Profile/documentsBottomSheet.dart` | `ConsumerStatefulWidget` |
| `lib/deliveyPartner/mainApp/Profile/workPreferenceBottomSheet.dart` | `ConsumerStatefulWidget` |
