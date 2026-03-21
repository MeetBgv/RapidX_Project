import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:newrapidx/services/location_service.dart';
import 'package:newrapidx/Common/placeSearchPage.dart';

/// Fullscreen map picker page — used for selecting sender or receiver location.
///
/// Returns a [Map<String, dynamic>] with keys:
///   lat, lng, address, area, city, state, pincode, displayName
///
/// Usage:
/// ```dart
/// final result = await Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const MapPickerPage(title: "Pickup Location")),
/// );
/// if (result != null) { /* use result['lat'], result['address'], etc. */ }
/// ```
class MapPickerPage extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;

  const MapPickerPage({
    super.key,
    this.title = "Select Location",
    this.initialLocation,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late LatLng _currentCenter;
  bool _isLoading = true;
  bool _isGeocoding = false;
  bool _isMapReady = false;
  String _currentAddress = "Move the map to select a location";
  String _currentCity = "";
  String _currentState = "";
  String _currentPincode = "";
  String _currentArea = "";

  // Pin bounce animation
  late AnimationController _pinAnimController;
  late Animation<double> _pinBounce;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.initialLocation ?? const LatLng(20.5937, 78.9629);

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pinBounce = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOut),
    );

    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      if (widget.initialLocation == null) {
        final pos = await LocationService.getCurrentLocation();
        _currentCenter = LatLng(pos.latitude, pos.longitude);
        if (_isMapReady) {
            _mapController.move(_currentCenter, 16);
        }
      }
      await _reverseGeocode(_currentCenter);
    } catch (e) {
      debugPrint('Location init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.baloo2(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isGeocoding = true);
    try {
      final result = await LocationService.reverseGeocode(
        point.latitude,
        point.longitude,
      );
      if (mounted) {
        setState(() {
          _currentAddress = result['displayName'] ?? '';
          _currentArea = result['area'] ?? '';
          _currentCity = result['city'] ?? '';
          _currentState = result['state'] ?? '';
          _currentPincode = result['pincode'] ?? '';
          _isGeocoding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = "Unable to get address";
          _isGeocoding = false;
        });
      }
    }
  }

  void _goToMyLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final loc = LatLng(pos.latitude, pos.longitude);
      _mapController.move(loc, 16);
      setState(() => _currentCenter = loc);
      await _reverseGeocode(loc);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.baloo2()),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': _currentCenter.latitude,
      'lng': _currentCenter.longitude,
      'address': _currentAddress,
      'area': _currentArea,
      'city': _currentCity,
      'state': _currentState,
      'pincode': _currentPincode,
    });
  }

  @override
  void dispose() {
    _pinAnimController.dispose();
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
              initialCenter: _currentCenter,
              initialZoom: widget.initialLocation != null ? 16 : 5,
              minZoom: 4,
              // Restrict map panning to India bounds
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(6.5, 68.1),   // South-West India
                  const LatLng(35.7, 97.4),  // North-East India
                ),
              ),
              onMapReady: () {
                _isMapReady = true;
                if (!_isLoading) {
                  _mapController.move(_currentCenter, 16);
                }
              },
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  _currentCenter = pos.center;
                  if (!_isDragging) {
                    _isDragging = true;
                    _pinAnimController.forward();
                  }
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd && _isDragging) {
                  _isDragging = false;
                  _pinAnimController.reverse();
                  _reverseGeocode(_currentCenter);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rapidx.app',
              ),
            ],
            ),
          ),

          // ================ CENTER PIN ================
          Center(
            child: AnimatedBuilder(
              animation: _pinBounce,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _pinBounce.value - 40),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xff234C6A),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff234C6A).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  // Pin shadow / point
                  CustomPaint(
                    size: Size(12.w, 8.h),
                    painter: _PinPointPainter(),
                  ),
                ],
              ),
            ),
          ),

          // ================ TOP: SEARCH BAR + BACK ================
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Back Button
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
                      SizedBox(width: 12.w),

                      // Search Bar
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlaceSearchPage(),
                              ),
                            );
                            if (result != null && result is Map) {
                              final lat = result['lat'] as double;
                              final lng = result['lng'] as double;
                              final loc = LatLng(lat, lng);
                              _mapController.move(loc, 16);
                              setState(() => _currentCenter = loc);
                              await _reverseGeocode(loc);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
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
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.grey.shade400,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    "Search for a place...",
                                    style: GoogleFonts.baloo2(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ================ MY LOCATION FAB ================
          Positioned(
            right: 16.w,
            bottom: 220.h,
            child: GestureDetector(
              onTap: _goToMyLocation,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location,
                  size: 24.sp,
                  color: const Color(0xff56A3A6),
                ),
              ),
            ),
          ),

          // ================ BOTTOM: ADDRESS CARD + CONFIRM ================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // Title row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xff56A3A6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: const Color(0xff56A3A6),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.baloo2(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff234C6A),
                              ),
                            ),
                            if (_currentCity.isNotEmpty)
                              Text(
                                "$_currentCity${_currentState.isNotEmpty ? ', $_currentState' : ''}",
                                style: GoogleFonts.baloo2(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Address display
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xffF2F2F2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: _isGeocoding
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xff56A3A6),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "Getting address...",
                                style: GoogleFonts.baloo2(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _currentAddress,
                            style: GoogleFonts.baloo2(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  SizedBox(height: 16.h),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isGeocoding ? null : _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff234C6A),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xff234C6A).withValues(alpha: 0.3),
                      ),
                      child: Text(
                        "Confirm Location",
                        style: GoogleFonts.baloo2(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================ LOADING OVERLAY ================
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xff234C6A),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Getting your location...",
                      style: GoogleFonts.baloo2(
                        fontSize: 14.sp,
                        color: const Color(0xff234C6A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter for the small triangle under the pin icon.
class _PinPointPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint()..color = const Color(0xff234C6A);
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
