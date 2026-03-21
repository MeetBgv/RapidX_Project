import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:newrapidx/services/location_service.dart';
import 'package:newrapidx/services/osrm_service.dart';
import '../../theme/dp_theme.dart';

/// Full-screen navigation map for the delivery partner.
/// Shows a dual-route flow:
/// 1. Current -> Sender (Pickup)
/// 2. Sender -> Receiver (Drop)
class DpNavigationPage extends StatefulWidget {
  final LatLng partnerLocation;
  final LatLng senderLocation;
  final LatLng receiverLocation;
  final String senderLabel;
  final String receiverLabel;
  final bool isPickupMode;

  const DpNavigationPage({
    super.key,
    required this.partnerLocation,
    required this.senderLocation,
    required this.receiverLocation,
    this.senderLabel = 'Pickup',
    this.receiverLabel = 'Drop-off',
    required this.isPickupMode,
  });

  @override
  State<DpNavigationPage> createState() => _DpNavigationPageState();
}

class _DpNavigationPageState extends State<DpNavigationPage> {
  late final MapController _mapController;
  
  // Route 1: Partner -> Pickup
  List<LatLng> _route1Points = [];
  double _dist1 = 0;
  double _time1 = 0;

  // Route 2: Pickup -> Drop
  List<LatLng> _route2Points = [];
  double _dist2 = 0;
  double _time2 = 0;

  LatLng? _myLocation;
  bool _isLoading = true;
  bool _isMapReady = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _myLocation = widget.partnerLocation;
    _loadRoutes();
    _startLocationUpdates();
  }

  Future<void> _loadRoutes() async {
    try {
      // Fetch Route 1 (Partner to Sender)
      final r1 = await OsrmService.getRoute(widget.partnerLocation, widget.senderLocation);
      
      // Fetch Route 2 (Sender to Receiver)
      final r2 = await OsrmService.getRoute(widget.senderLocation, widget.receiverLocation);

      if (mounted) {
        setState(() {
          // Validate points from OSRM (must be finite)
          _route1Points = r1.routePoints.where((p) => p.latitude.isFinite && p.longitude.isFinite).toList();
          _dist1 = r1.distanceKm.isFinite ? r1.distanceKm : 0;
          _time1 = r1.durationMinutes.isFinite ? r1.durationMinutes : 0;

          _route2Points = r2.routePoints.where((p) => p.latitude.isFinite && p.longitude.isFinite).toList();
          _dist2 = r2.distanceKm.isFinite ? r2.distanceKm : 0;
          _time2 = r2.durationMinutes.isFinite ? r2.durationMinutes : 0;

          _isLoading = false;
        });
        if (_isMapReady) _fitMap();
      }
    } catch (e) {
      debugPrint('Navigation routes error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fitMap() {
    if (!_isMapReady || !mounted) return;
    
    try {
      final points = [
        if (widget.isPickupMode) ...[
          widget.partnerLocation,
          widget.senderLocation,
        ] else ...[
          widget.senderLocation,
          widget.receiverLocation,
        ],
        if (_myLocation != null) _myLocation!,
      ].where((l) => l.latitude.isFinite && l.longitude.isFinite).toList();

      if (points.isEmpty) return;

      // Standardized behavior: Center on the start point of the active leg
      if (widget.isPickupMode) {
        // Pickup leg: Start is current location
        final centerPoint = _myLocation ?? widget.partnerLocation;
        _mapController.move(centerPoint, 16.0);
      } else {
        // Drop-off leg: Start is the pickup location (Sender)
        _mapController.move(widget.senderLocation, 16.0);
      }
    } catch (e) {
      debugPrint('Map fit error: $e');
      if (widget.partnerLocation.latitude.isFinite) {
        _mapController.move(widget.partnerLocation, 15.0);
      }
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await LocationService.getCurrentLocation();
        if (mounted) {
          setState(() {
            _myLocation = LatLng(pos.latitude, pos.longitude);
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ──────────────── MAP ────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: (widget.partnerLocation.latitude.isFinite && widget.partnerLocation.longitude.isFinite)
                    ? widget.partnerLocation
                    : const LatLng(0, 0),
                initialZoom: 13,
                minZoom: 3,
                maxZoom: 18,
                onMapReady: () {
                  _isMapReady = true;
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted && !_isLoading) _fitMap();
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rapidx.app',
                ),

                // Route 1: Blue (Pickup)
                if (widget.isPickupMode && _route1Points.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route1Points,
                        strokeWidth: 6,
                        color: DPColors.deepBlue.withOpacity(0.8),
                      ),
                    ],
                  ),

                // Route 2: Orange (Delivery)
                if (!widget.isPickupMode && _route2Points.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route2Points,
                        strokeWidth: 5,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    ],
                  ),

                // Markers
                MarkerLayer(
                  markers: [
                    if (widget.isPickupMode)
                      Marker(
                        point: widget.senderLocation,
                        width: 45.w,
                        height: 60.w,
                        child: _markerWidget(
                          color: DPColors.PickUpGreen,
                          icon: Icons.store,
                          label: "PICKUP",
                        ),
                      ),
                    if (!widget.isPickupMode)
                      Marker(
                        point: widget.receiverLocation,
                        width: 45.w,
                        height: 60.w,
                        child: _markerWidget(
                          color: DPColors.DropRed,
                          icon: Icons.flag,
                          label: "DROP",
                        ),
                      ),
                    if (!_isLoading && !widget.isPickupMode)
                       Marker(
                        point: widget.senderLocation,
                        width: 40.w,
                        height: 40.w,
                        child: Icon(Icons.location_on, color: DPColors.PickUpGreen, size: 24.sp),
                      ),
                    if (_myLocation != null)
                      Marker(
                        point: _myLocation!,
                        width: 55.w,
                        height: 55.w,
                        child: _partnerMarker(),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ──────────────── TOP INFO ────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  _iconButton(
                  //   Icons.arrow_back,
                  //   () => Navigator.pop(context),
                  // ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Opacity(
                        opacity: 1.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isPickupMode)
                              _topInfoRow(
                                icon: Icons.my_location,
                                color: DPColors.deepBlue,
                                title: "Heading to Pickup",
                                subtitle: widget.senderLabel,
                              ),
                            if (!widget.isPickupMode)
                              _topInfoRow(
                                icon: Icons.location_on,
                                color: DPColors.DropRed,
                                title: "Heading to Drop-off",
                                subtitle: widget.receiverLabel,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ──────────────── BOTTOM STATUS CARD ────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 35.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _bottomInfoTile(
                          title: "Distance",
                          value: "${(widget.isPickupMode ? _dist1 : _dist2).toStringAsFixed(1)} km",
                          icon: Icons.directions_bike,
                          color: DPColors.deepBlue,
                        ),
                      ),
                      Container(width: 1, height: 35.h, color: Colors.grey.shade200),
                      Expanded(
                        child: _bottomInfoTile(
                          title: "Estimated Time",
                          value: "${(widget.isPickupMode ? _time1 : _time2).toStringAsFixed(0)} min",
                          icon: Icons.timer_outlined,
                          color: DPColors.deepBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DPColors.deepBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Start Delivery ",
                        style: GoogleFonts.baloo2(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: CircularProgressIndicator(color: DPColors.deepBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topInfoRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.baloo2(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.baloo2(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: DPColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withOpacity(0.6), size: 16.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: GoogleFonts.baloo2(
                fontSize: 11.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: DPColors.black,
          ),
        ),
      ],
    );
  }

  Widget _markerWidget({required Color color, required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 10),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16.sp),
        ),
      ],
    );
  }

  Widget _partnerMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: DPColors.deepBlue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 35.w,
          height: 35.w,
          decoration: BoxDecoration(
            color: DPColors.deepBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: DPColors.deepBlue.withOpacity(0.4), blurRadius: 15),
            ],
          ),
          child: Icon(Icons.delivery_dining, color: Colors.white, size: 20.sp),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 22.sp, color: DPColors.deepBlue),
      ),
    );
  }
}
