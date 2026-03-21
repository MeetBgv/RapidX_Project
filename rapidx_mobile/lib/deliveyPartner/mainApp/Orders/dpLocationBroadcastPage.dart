import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:newrapidx/services/location_service.dart';
import 'package:newrapidx/services/osrm_service.dart';

/// Delivery partner's view — shows route, own location, and status controls.
class DPLocationBroadcastPage extends StatefulWidget {
  final LatLng pickupLocation;
  final LatLng dropLocation;
  final String orderId;
  final String customerName;

  const DPLocationBroadcastPage({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    this.orderId = "",
    this.customerName = "Customer",
  });

  @override
  State<DPLocationBroadcastPage> createState() =>
      _DPLocationBroadcastPageState();
}

class _DPLocationBroadcastPageState extends State<DPLocationBroadcastPage> {
  late final MapController _mapController;
  List<LatLng> _routePoints = [];
  LatLng? _myLocation;
  double _distanceKm = 0;
  double _durationMinutes = 0;
  String _status = "En Route to Pickup";
  bool _isLoadingRoute = true;
  bool _isMapReady = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadRoute();
    _startLocationUpdates();
  }

  Future<void> _loadRoute() async {
    try {
      final route = await OsrmService.getRoute(
        widget.pickupLocation,
        widget.dropLocation,
      );
      if (mounted) {
        setState(() {
          _routePoints = route.routePoints;
          _distanceKm = route.distanceKm;
          _durationMinutes = route.durationMinutes;
          _isLoadingRoute = false;
        });
        if (_isMapReady) _fitMapToRoute();
      }
    } catch (e) {
      debugPrint('Route error: $e');
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  void _fitMapToRoute() {
    // Guard against degenerate bounds (same/nearby points) which cause Infinity zoom
    final lat1 = widget.pickupLocation.latitude;
    final lng1 = widget.pickupLocation.longitude;
    final lat2 = widget.dropLocation.latitude;
    final lng2 = widget.dropLocation.longitude;
    final isSamePoint = (lat1 - lat2).abs() < 0.0001 && (lng1 - lng2).abs() < 0.0001;
    if (isSamePoint) {
      _mapController.move(widget.pickupLocation, 15);
      return;
    }
    final points = [
      widget.pickupLocation,
      widget.dropLocation,
      if (_myLocation != null) _myLocation!,
    ];
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(60.w),
      ),
    );
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await LocationService.getCurrentLocation();
        if (mounted) {
          setState(() {
            _myLocation = LatLng(pos.latitude, pos.longitude);
          });
          // In production: send _myLocation to backend via HTTP POST or WebSocket
        }
      } catch (e) {
        debugPrint('Location update error: $e');
      }
    });
  }

  void _updateStatus(String newStatus) {
    setState(() => _status = newStatus);
    // In production: POST status update to backend
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
          // ================ MAP ================
          Positioned.fill(
            child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.pickupLocation,
              initialZoom: 13,
              onMapReady: () {
                _isMapReady = true;
                if (!_isLoadingRoute) _fitMapToRoute();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rapidx.app',
              ),

              // Route polyline
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: const Color(0xff234C6A),
                    ),
                  ],
                ),

              // Markers
              MarkerLayer(
                markers: [
                  // Pickup marker
                  Marker(
                    point: widget.pickupLocation,
                    width: 40.w,
                    height: 40.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(Icons.store, color: Colors.white, size: 18.sp),
                    ),
                  ),

                  // Drop marker
                  Marker(
                    point: widget.dropLocation,
                    width: 40.w,
                    height: 40.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(Icons.flag, color: Colors.white, size: 18.sp),
                    ),
                  ),

                  // My location marker
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 48.w,
                      height: 48.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff234C6A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff234C6A).withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.delivery_dining,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            ),
          ),

          // ================ BACK BUTTON ================
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 22.sp,
                        color: const Color(0xff234C6A),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10.sp,
                            color: _status == "Delivered"
                                ? Colors.green
                                : const Color(0xffDE9325),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _status,
                            style: GoogleFonts.baloo2(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff234C6A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================ BOTTOM PANEL ================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Order info
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xff234C6A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: const Color(0xff234C6A),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.customerName,
                              style: GoogleFonts.baloo2(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff234C6A),
                              ),
                            ),
                            Text(
                              "${_distanceKm.toStringAsFixed(1)} km • ${_durationMinutes.toStringAsFixed(0)} min",
                              style: GoogleFonts.baloo2(
                                fontSize: 13.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Status Buttons
                  if (_status != "Delivered")
                    Row(
                      children: [
                        if (_status == "En Route to Pickup")
                          Expanded(
                            child: _buildStatusButton(
                              "Picked Up",
                              Icons.inventory_2,
                              const Color(0xffDE9325),
                              () => _updateStatus("Picked Up"),
                            ),
                          ),
                        if (_status == "Picked Up") ...[
                          Expanded(
                            child: _buildStatusButton(
                              "Delivered",
                              Icons.check_circle,
                              Colors.green,
                              () => _updateStatus("Delivered"),
                            ),
                          ),
                        ],
                      ],
                    ),

                  if (_status == "Delivered")
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "Order Delivered Successfully!",
                            style: GoogleFonts.baloo2(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ================ LOADING ================
          if (_isLoadingRoute)
            Container(
              color: Colors.white.withValues(alpha: 0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xff234C6A)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
