# Location Features Guide

This document explains the location-related features and how they work.

---

## 1. Architecture Overview

### Free API Stack (No API Keys Required)

| Service | API Used | Purpose |
|---|---|---|
| **Map Display** | OpenStreetMap + `flutter_map` | Display interactive maps |
| **Place Search** | Nominatim API | Autocomplete search for places |
| **GPS Location** | `geolocator` package | Get device's current location |
| **Reverse Geocoding** | Nominatim API | Convert lat/lng → address |
| **Routing & Distance** | OSRM API | Get distance, duration, route polyline |
| **Pricing** | Local Dart engine | Calculate fare based on distance + vehicle |

### File Structure

```
lib/
├── services/
│   ├── location_service.dart     → GPS + reverse geocoding
│   ├── nominatim_service.dart    → Place search/autocomplete
│   ├── osrm_service.dart         → Distance & routing
│   └── pricing_service.dart      → Fare calculation engine
│
├── Common/
│   ├── mapPickerPage.dart        → Fullscreen map picker (reusable)
│   ├── placeSearchPage.dart      → Autocomplete search page
│   └── liveTrackingPage.dart     → Customer tracking screen
│
└── deliveyPartner/mainApp/Orders/
    └── dpLocationBroadcastPage.dart → Partner navigation screen
```

---

## 2. Services

### LocationService (`location_service.dart`)

```dart
// Get current GPS position
final position = await LocationService.getCurrentLocation();
print('${position.latitude}, ${position.longitude}');

// Reverse geocode coordinates to address
final address = await LocationService.reverseGeocode(28.6139, 77.2090);
print(address['city']);    // "New Delhi"
print(address['state']);   // "Delhi"
print(address['pincode']); // "110001"
```

### NominatimService (`nominatim_service.dart`)

```dart
// Direct search
final results = await NominatimService.searchPlaces("Connaught Place");
for (final place in results) {
  print('${place.name} - ${place.lat}, ${place.lng}');
}

// Debounced search (for TextField onChanged)
NominatimService.debouncedSearch("Connaught", (results) {
  setState(() => _places = results);
});
```

### OsrmService (`osrm_service.dart`)

```dart
final route = await OsrmService.getRoute(
  LatLng(28.6139, 77.2090),  // Sender
  LatLng(28.5355, 77.3910),  // Receiver
);
print('Distance: ${route.distanceKm} km');
print('Duration: ${route.durationMinutes} min');
print('Route points: ${route.routePoints.length}');
```

### PricingService (`pricing_service.dart`)

```dart
final result = PricingService.calculate(
  vehicleType: 'Bike',
  distanceKm: 7.5,
);
print('Total: ₹${result.totalFare}');       // ₹95
print('Admin: ₹${result.adminShare}');       // ₹19
print('Partner: ₹${result.partnerShare}');   // ₹76
```

**Pricing Table:**

| Vehicle | Base (0–3 km) | Per km after | Admin | Partner |
|---|---|---|---|---|
| Bike | ₹50 | ₹10/km | 20% | 80% |
| Mini Tempo | ₹150 | ₹20/km | 20% | 80% |
| Tempo | ₹400 | ₹25/km | 25% | 75% |

---

## 3. UI Pages

### MapPickerPage

Reusable fullscreen map for selecting any location (sender or receiver).

**Usage:**
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const MapPickerPage(title: "Pickup Location"),
  ),
);
if (result != null) {
  print(result['lat']);      // 28.6139
  print(result['lng']);      // 77.2090
  print(result['address']);  // Full display name
  print(result['city']);     // "New Delhi"
}
```

### PlaceSearchPage

Autocomplete search that returns coordinates.

### LiveTrackingPage

Customer view — shows delivery partner moving along the route.

### DPLocationBroadcastPage

Delivery partner view — shows route and status controls.

---

## 4. UserDataProvider — Coordinates

New fields added to `UserDataProvider`:

```dart
// Getters
provider.senderLat;    // double?
provider.senderLng;    // double?
provider.receiverLat;  // double?
provider.receiverLng;  // double?

// Set from map picker
provider.setSenderLocation(
  lat: 28.6139,
  lng: 77.2090,
  address: "Full address",
  city: "New Delhi",
  state: "Delhi",
  pincode: "110001",
);
```
