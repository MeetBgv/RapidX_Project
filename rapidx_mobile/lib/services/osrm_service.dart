import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Route result from OSRM.
class OsrmRoute {
  final double distanceKm;
  final double durationMinutes;
  final List<LatLng> routePoints;

  OsrmRoute({
    required this.distanceKm,
    required this.durationMinutes,
    required this.routePoints,
  });
}

/// Service for distance & routing using the free OSRM public API.
/// Docs: https://project-osrm.org/docs/v5.24.0/api/
class OsrmService {
  /// Get route between [origin] and [destination].
  /// Returns an [OsrmRoute] with distance, duration, and polyline points.
  static Future<OsrmRoute> getRoute(LatLng origin, LatLng destination) async {
    // OSRM expects lon,lat (not lat,lon)
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('OSRM routing failed: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
      throw Exception('No route found between these locations.');
    }

    final route = data['routes'][0];
    final distanceMeters = (route['distance'] as num).toDouble();
    final durationSeconds = (route['duration'] as num).toDouble();

    // Parse GeoJSON coordinates → List<LatLng>
    final geometry = route['geometry'];
    final List<dynamic> coords = geometry['coordinates'];
    final routePoints = coords.map<LatLng>((coord) {
      // GeoJSON is [lng, lat]
      return LatLng(coord[1].toDouble(), coord[0].toDouble());
    }).toList();

    return OsrmRoute(
      distanceKm: distanceMeters / 1000,
      durationMinutes: durationSeconds / 60,
      routePoints: routePoints,
    );
  }

  /// Get just the distance (km) between two points — lighter call.
  static Future<double> getDistanceKm(
    LatLng origin,
    LatLng destination,
  ) async {
    final route = await getRoute(origin, destination);
    return route.distanceKm;
  }
}
