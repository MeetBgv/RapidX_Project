/// Pricing result with full fare breakdown.
class PricingResult {
  final String vehicleType;
  final double distanceKm;
  final double baseFare;
  final double extraKmCharge;
  final double totalFare;
  final double adminShare;
  final double partnerShare;
  final double adminPercent;
  final double partnerPercent;

  PricingResult({
    required this.vehicleType,
    required this.distanceKm,
    required this.baseFare,
    required this.extraKmCharge,
    required this.totalFare,
    required this.adminShare,
    required this.partnerShare,
    required this.adminPercent,
    required this.partnerPercent,
  });
}

/// Vehicle pricing configuration.
class _VehicleConfig {
  final double baseFare;
  final double perKmRate;
  final double adminPercent;
  final double partnerPercent;

  const _VehicleConfig({
    required this.baseFare,
    required this.perKmRate,
    required this.adminPercent,
    required this.partnerPercent,
  });
}

/// Pure Dart pricing engine — no API calls, all logic local.
///
/// Pricing Formula:
/// ┌──────────────────┬──────────────────┬────────────┬───────┬─────────┐
/// │ Vehicle          │ Base (0–3 km)    │ Per km +3  │ Admin │ Partner │
/// ├──────────────────┼──────────────────┼────────────┼───────┼─────────┤
/// │ Bike             │ ₹50              │ ₹10/km     │ 20%   │ 80%     │
/// │ Mini Tempo       │ ₹150             │ ₹20/km     │ 20%   │ 80%     │
/// │ Tempo (Largest)  │ ₹400             │ ₹25/km     │ 25%   │ 75%     │
/// └──────────────────┴──────────────────┴────────────┴───────┴─────────┘
class PricingService {
  static const double _baseDistanceKm = 3.0;

  static const Map<String, _VehicleConfig> _config = {
    'Bike': _VehicleConfig(
      baseFare: 50,
      perKmRate: 10,
      adminPercent: 0.20,
      partnerPercent: 0.80,
    ),
    'Mini Tempo': _VehicleConfig(
      baseFare: 150,
      perKmRate: 20,
      adminPercent: 0.20,
      partnerPercent: 0.80,
    ),
    'Tempo': _VehicleConfig(
      baseFare: 400,
      perKmRate: 25,
      adminPercent: 0.25,
      partnerPercent: 0.75,
    ),
  };

  /// Calculate full pricing breakdown for a given [vehicleType] and [distanceKm].
  ///
  /// [vehicleType] must be one of: 'Bike', 'Mini Tempo', 'Tempo'.
  /// [distanceKm] is the OSRM-calculated road distance.
  static PricingResult calculate({
    required String vehicleType,
    required double distanceKm,
  }) {
    final config = _config[vehicleType];
    if (config == null) {
      throw ArgumentError(
        'Unknown vehicle type: "$vehicleType". '
        'Expected one of: ${_config.keys.join(", ")}',
      );
    }

    final extraKm = (distanceKm - _baseDistanceKm).clamp(0, double.infinity);
    final extraKmCharge = extraKm * config.perKmRate;
    final totalFare = config.baseFare + extraKmCharge;
    final adminShare = totalFare * config.adminPercent;
    final partnerShare = totalFare * config.partnerPercent;

    return PricingResult(
      vehicleType: vehicleType,
      distanceKm: distanceKm,
      baseFare: config.baseFare,
      extraKmCharge: extraKmCharge,
      totalFare: totalFare,
      adminShare: adminShare,
      partnerShare: partnerShare,
      adminPercent: config.adminPercent * 100,
      partnerPercent: config.partnerPercent * 100,
    );
  }

  /// Get all supported vehicle types.
  static List<String> get vehicleTypes => _config.keys.toList();

  /// Quick price estimate for display (e.g. "₹50" or "₹130").
  static String quickEstimate({
    required String vehicleType,
    required double distanceKm,
  }) {
    final result = calculate(vehicleType: vehicleType, distanceKm: distanceKm);
    return '₹${result.totalFare.toStringAsFixed(0)}';
  }
}
