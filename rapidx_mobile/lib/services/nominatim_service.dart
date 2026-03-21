import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A place result from Nominatim search.
class NominatimPlace {
  final String displayName;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String city;
  final String state;
  final String pincode;
  final String address;

  NominatimPlace({
    required this.displayName,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.city,
    required this.state,
    required this.pincode,
    required this.address,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    final addressObj = json['address'] as Map<String, dynamic>? ?? {};
    
    final street = addressObj['road'] ?? '';
    final houseNumber = addressObj['house_number'] ?? '';
    final neighbourhood = addressObj['neighbourhood'] ?? addressObj['suburb'] ?? '';
    final streetAddress = [houseNumber, street, neighbourhood]
        .where((s) => s.toString().isNotEmpty)
        .join(', ');

    return NominatimPlace(
      displayName: json['display_name'] ?? '',
      name: json['name'] ?? json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0,
      lng: double.tryParse(json['lon']?.toString() ?? '') ?? 0,
      type: json['type'] ?? '',
      city: addressObj['city'] ?? addressObj['town'] ?? addressObj['village'] ?? addressObj['county'] ?? '',
      state: addressObj['state'] ?? '',
      pincode: addressObj['postcode'] ?? '',
      address: streetAddress.isNotEmpty ? streetAddress : (json['name'] ?? ''),
    );
  }
}

/// Service for place search & autocomplete using the free Nominatim API.
/// Nominatim usage policy: max 1 request/second, include User-Agent.
class NominatimService {
  static Timer? _debounceTimer;

  /// Search for places matching [query].
  /// Debounced: waits 300ms after last keystroke before calling the API.
  /// Returns a list of [NominatimPlace] results.
  static Future<List<NominatimPlace>> searchPlaces(String query) async {
    if (query.trim().length < 3) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json'
      '&addressdetails=1'
      '&limit=8'
      '&countrycodes=in'
      '&viewbox=68.1,6.5,97.4,35.7'
      '&bounded=1', // Strictly limit results to India viewbox
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'RapidX-Flutter-App'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Nominatim search failed: ${response.statusCode}');
    }

    final List<dynamic> results = json.decode(response.body);
    return results.map((r) => NominatimPlace.fromJson(r)).toList();
  }

  /// Debounced search — call this from a TextField onChanged.
  /// [onResults] is invoked with the list of places after the debounce delay.
  static void debouncedSearch(
    String query,
    void Function(List<NominatimPlace>) onResults, {
    Duration delay = const Duration(milliseconds: 400),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () async {
      try {
        final results = await searchPlaces(query);
        onResults(results);
      } catch (_) {
        onResults([]);
      }
    });
  }

  /// Cancel any pending debounced search.
  static void cancelSearch() {
    _debounceTimer?.cancel();
  }
}
