import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:newrapidx/services/osrm_service.dart';

/// Live tracking page for customers to track their delivery partner in real-time.
///
/// Shows:
///  - Map with sender, receiver, and delivery partner markers
///  - Route polyline
///  - Bottom card with partner info, ETA, and status
///
/// Currently uses a polling placeholder. Replace with WebSocket for production.
class LiveTrackingPage extends StatefulWidget {
  final LatLng senderLocation;
  final LatLng receiverLocation;
  final String partnerName;
  final String partnerPhone;
  final String orderId;
  final String status;
  final LatLng? initialPartnerLocation;

  const LiveTrackingPage({
    super.key,
    required this.senderLocation,
    required this.receiverLocation,
    this.partnerName = "Delivery Partner",
    this.partnerPhone = "",
    this.orderId = "",
    this.status = "Assigned",
    this.initialPartnerLocation,
  });

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  late final MapController _mapController;
  List<LatLng> _routePoints = [];
  LatLng? _partnerLocation;
  double _distanceKm = 0;
  double _durationMinutes = 0;
  String _orderStatus = "Picked Up";
  bool _isLoadingRoute = true;
  bool _isMapReady = false;
  bool _followPartner = true; // 👉 New: Track whether to follow partner
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Start at initial location or sender
    _partnerLocation = widget.initialPartnerLocation ?? widget.senderLocation;
    _orderStatus = widget.status;
    _loadRoute();
    _startPolling();
  }

  Future<void> _loadRoute() async {
    try {
      final route = await OsrmService.getRoute(
        widget.senderLocation,
        widget.receiverLocation,
      );
      if (mounted) {
        setState(() {
          _routePoints = route.routePoints;
          _distanceKm = route.distanceKm;
          _durationMinutes = route.durationMinutes;
          _isLoadingRoute = false;
        });
        // Fit map to show entire route
        if (_isMapReady) _fitMapToRoute();
      }
    } catch (e) {
      debugPrint('Route loading error: $e');
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isEmpty) return;
    // Guard against degenerate bounds (same/nearby points) which cause Infinity zoom
    final lat1 = widget.senderLocation.latitude;
    final lng1 = widget.senderLocation.longitude;
    final lat2 = widget.receiverLocation.latitude;
    final lng2 = widget.receiverLocation.longitude;
    final isSamePoint = (lat1 - lat2).abs() < 0.0001 && (lng1 - lng2).abs() < 0.0001;
    if (isSamePoint) {
      _mapController.move(widget.senderLocation, 15);
      return;
    }
    final bounds = LatLngBounds.fromPoints([
      widget.senderLocation,
      widget.receiverLocation,
      if (_partnerLocation != null) _partnerLocation!,
    ]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(60.w),
      ),
    );
  }

  /// Real polling to fetch partner location and order status from the backend.
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) return;
      await _fetchLiveUpdates();
    });
  }

  Future<void> _fetchLiveUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/customer-orders?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        final order = data.firstWhere(
          (o) => o['order_id'].toString() == widget.orderId,
          orElse: () => null,
        );

        if (order != null && mounted) {
          final lat = double.tryParse(order['current_lat']?.toString() ?? '');
          final lng = double.tryParse(order['current_lng']?.toString() ?? '');
          final status = order['status_name']?.toString() ?? _orderStatus;

          setState(() {
            if (lat != null && lng != null) {
              _partnerLocation = LatLng(lat, lng);
            }
            _orderStatus = status;
          });

          if (_followPartner && _isMapReady && _partnerLocation != null) {
            _mapController.move(_partnerLocation!, _mapController.camera.zoom);
          }

          if (_orderStatus == "Delivered") {
            _pollingTimer?.cancel();
          }
        }
      }
    } catch (e) {
      debugPrint("Live update fetch error: $e");
    }
  }

  void _recenterOnPartner() {
    if (_partnerLocation != null) {
      _mapController.move(_partnerLocation!, 15);
      setState(() => _followPartner = true);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
              initialCenter: widget.senderLocation,
              initialZoom: 13,
              // 👉 New: Disable auto-follow when user manually moves map
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _followPartner) {
                  setState(() => _followPartner = false);
                }
              },
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
                  // Sender marker (green)
                  Marker(
                    point: widget.senderLocation,
                    width: 40.w,
                    height: 40.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(Icons.store, color: Colors.white, size: 18.sp),
                    ),
                  ),

                  // Receiver marker (red)
                  Marker(
                    point: widget.receiverLocation,
                    width: 40.w,
                    height: 40.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(Icons.flag, color: Colors.white, size: 18.sp),
                    ),
                  ),

                  // Delivery Partner marker (blue, animated)
                  if (_partnerLocation != null)
                    Marker(
                      point: _partnerLocation!,
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
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: GestureDetector(
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
                          offset: const Offset(0, 2),
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
            ),
          ),
        ), // 👈 CLEANED UP COMMA SEPARATION
          // ================ RECENTER BUTTON ================
          if (!_followPartner && _partnerLocation != null)
            Positioned(
              right: 16.w,
              bottom: 300.h, // Adjusted to be above the bottom card
              child: FloatingActionButton(
                onPressed: _recenterOnPartner,
                backgroundColor: const Color(0xff234C6A),
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),

          // ================ BOTTOM INFO CARD ================
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

                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _orderStatus == "Delivered"
                          ? Colors.green.shade50
                          : const Color(0xff56A3A6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _orderStatus == "Delivered"
                              ? Icons.check_circle
                              : Icons.delivery_dining,
                          size: 16.sp,
                          color: _orderStatus == "Delivered"
                              ? Colors.green
                              : const Color(0xff56A3A6),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _orderStatus,
                          style: GoogleFonts.baloo2(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: _orderStatus == "Delivered"
                                ? Colors.green
                                : const Color(0xff56A3A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Partner info row
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: const Color(0xff234C6A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: const Color(0xff234C6A),
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Name & phone
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.partnerName,
                              style: GoogleFonts.baloo2(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff234C6A),
                              ),
                            ),
                            if (widget.partnerPhone.isNotEmpty)
                              Text(
                                widget.partnerPhone,
                                style: GoogleFonts.baloo2(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Call button
                      if (widget.partnerPhone.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.phone,
                            color: Colors.green,
                            size: 20.sp,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Distance & ETA row
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xffF2F2F2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip(
                          Icons.route,
                          "${_distanceKm.toStringAsFixed(1)} km",
                          "Distance",
                        ),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: Colors.grey.shade300,
                        ),
                        _buildInfoChip(
                          Icons.access_time,
                          "${_durationMinutes.toStringAsFixed(0)} min",
                          "ETA",
                        ),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: Colors.grey.shade300,
                        ),
                        _buildInfoChip(
                          Icons.receipt_long,
                          widget.orderId.isNotEmpty
                              ? "#${widget.orderId.substring(0, 6)}"
                              : "—",
                          "Order",
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
                child: CircularProgressIndicator(
                  color: Color(0xff234C6A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xff234C6A)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff234C6A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 11.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
