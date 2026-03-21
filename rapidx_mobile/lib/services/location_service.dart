import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// Service for handling device GPS location and reverse geocoding
/// using the free Nominatim API (OpenStreetMap).
/// All services are restricted to India.
class LocationService {
  // ==================== INDIA BOUNDS ====================
  // Bounding box: southWest(6.5, 68.1) → northEast(35.7, 97.4)
  static const double indiaMinLat = 6.5;
  static const double indiaMaxLat = 35.7;
  static const double indiaMinLng = 68.1;
  static const double indiaMaxLng = 97.4;

  /// Check if coordinates fall within India's geographic bounds.
  static bool isWithinIndia(double lat, double lng) {
    return lat >= indiaMinLat &&
        lat <= indiaMaxLat &&
        lng >= indiaMinLng &&
        lng <= indiaMaxLng;
  }

  /// Check and request location permission, then get current position.
  /// Returns a [Position] with lat/lng, or throws if permission denied.
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Please enable it in Settings.',
      );
    }

    try {
      // Small delay to allow GPS to get a satellite lock
      await Future.delayed(const Duration(seconds: 3));

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      // Fallback: try getting the last known position.
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        return lastPos;
      }
      throw Exception('Unable to fetch live location. Please check your signal and permissions.');
    }
  }

  // ==================== REVERSE GEOCODING ====================

  /// Convert lat/lng → human-readable address using Nominatim.
  /// Returns a map with keys: address, city, state, pincode, displayName.
  static Future<Map<String, String>> reverseGeocode(
    double lat,
    double lng,
  ) async {
    // Validate India bounds
    if (!isWithinIndia(lat, lng)) {
      throw Exception('Location is outside India. RapidX only operates within India.');
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lng&format=json&addressdetails=1&countrycodes=in',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'RapidX-Flutter-App'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Reverse geocoding failed: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final address = data['address'] ?? {};

    // Build exact location-level address
    final amenity = address['amenity']?.toString() ?? '';
    final building = address['building']?.toString() ?? '';
    final street = address['road']?.toString() ?? '';
    final houseNumber = address['house_number']?.toString() ?? '';
    final neighbourhood = address['neighbourhood']?.toString() ?? address['suburb']?.toString() ?? '';
    
    final streetAddressList = [amenity, building, houseNumber, street, neighbourhood]
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Deduplicate items in case of overlaps
    final uniquestreetAddressList = streetAddressList.toSet().toList();
    
    final streetAddress = uniquestreetAddressList.join(', ');

    return {
      'displayName': data['display_name'] ?? '',
      'address': streetAddress,
      'area': address['suburb'] ?? address['neighbourhood'] ?? '',
      'city': address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'] ??
          '',
      'state': address['state'] ?? '',
      'pincode': address['postcode'] ?? '',
      'country': address['country'] ?? '',
    };
  }
}
