import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/Customer/mainApp/ordersApp/UI/parcelOrderPage.dart';
import 'package:newrapidx/Customer/mainApp/ordersApp/UI/pickupLocationPage.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:newrapidx/Common/savedAddressesPage.dart';
import 'package:newrapidx/Common/placeSearchPage.dart';
import 'package:newrapidx/Common/mapPickerPage.dart';

/// Bottom Sheet content for placing a new order.
/// Allows user to specify Pickup and Drop locations.
class PlaceOrderContent extends StatefulWidget {
  const PlaceOrderContent({super.key});

  @override
  State<PlaceOrderContent> createState() => _PlaceOrderContentState();
}

class _PlaceOrderContentState extends State<PlaceOrderContent> {
  // Controller for the drop location input field
  final TextEditingController _dropLocationController = TextEditingController();

  // Delivery type state
  bool _isInCity = true;

  /// Maximum delivery distance in kilometers
  static const double _maxDeliveryDistanceKm = 5000.0;

  @override
  void dispose() {
    // Dipose controller to free resources
    _dropLocationController.dispose();
    super.dispose();
  }

  /// Calculate straight-line distance between two coordinates using Haversine formula.
  double _haversineDistance(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  /// Check if drop location is within delivery range.
  /// Returns true if within range, false otherwise (and shows popup).
  bool _isWithinDeliveryRange(double dropLat, double dropLng) {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    final senderLat = provider.senderLat;
    final senderLng = provider.senderLng;

    if (senderLat == null || senderLng == null) {
      // No sender coordinates available yet, allow selection
      return true;
    }

    final distance = _haversineDistance(senderLat, senderLng, dropLat, dropLng);

    if (distance > _maxDeliveryDistanceKm) {
      _showOutOfRangeDialog(distance);
      return false;
    }
    return true;
  }

  /// Show a styled popup informing the user the address is out of delivery range.
  void _showOutOfRangeDialog(double distanceKm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  color: Colors.red.shade400,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Out of Delivery Range",
                style: GoogleFonts.baloo2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff234C6A),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "The selected location is ${distanceKm.toStringAsFixed(0)} km away. We currently deliver within ${_maxDeliveryDistanceKm.toInt()} km only.",
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.4.h,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Please choose a closer drop location.",
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff234C6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Got it",
                    style: GoogleFonts.baloo2(
                      fontSize: 15.sp,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fixed height to ensure Expanded works inside ListView
      height: MediaQuery.of(context).size.height * 0.52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        // Shadow for the bottom sheet
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 15.h),

          // ================= DELIVERY TYPE TOGGLE =================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 45.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: _isInCity ? Alignment.centerLeft : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        margin: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xff234C6A),
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isInCity = true;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              "In-City",
                              style: GoogleFonts.baloo2(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: _isInCity ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isInCity = false;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              "Out of City",
                              style: GoogleFonts.baloo2(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: !_isInCity ? Colors.white : Colors.grey.shade600,
                              ),
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
          SizedBox(height: 20.h),

          // ================= PICKUP & DROP SECTION =================
          // Combined section to show the route line connecting dots
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // PICKUP ROW
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PickupLocationPage(),
                      ),
                    );

                    if (result != null) {
                      final provider = Provider.of<UserDataProvider>(
                        context,
                        listen: false,
                      );
                      setState(() {
                        if (result is Map) {
                          provider.setSenderLocation(
                            lat: (result['lat'] as num?)?.toDouble() ?? 0,
                            lng: (result['lng'] as num?)?.toDouble() ?? 0,
                            address: result['address'] ?? result['displayName'] ?? '',
                            city: result['city'] ?? '',
                            state: result['state'] ?? '',
                            pincode: result['pincode'] ?? '',
                          );
                          provider.setPickupAddress(result['displayName'] ?? result['address'] ?? '');
                        } else if (result is String) {
                          provider.setPickupAddress(result);
                        }
                      });
                    }
                  },
                  behavior: HitTestBehavior
                      .opaque, // Ensures the whole row is clickable
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          // Red Dot (Pickup usually green but matching user's existing logic/design with subtle tweak)
                          Container(
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: const Color(0xff56A3A6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.w),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff56A3A6).withOpacity(0.3),
                                  blurRadius: 4.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          // Vertical Line
                          Container(
                            width: 1.5.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xff56A3A6).withOpacity(0.5),
                                  Colors.grey.shade300,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: CustomPaint(
                              painter: DashedLinePainter(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<UserDataProvider>(
                              builder: (context, provider, child) {
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: provider.userName.isNotEmpty
                                            ? provider.userName
                                            : "User",
                                        style: GoogleFonts.baloo2(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            " • ${provider.phoneNumber.isNotEmpty ? provider.phoneNumber : "Mobile"}",
                                        style: GoogleFonts.baloo2(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 2.h),
                            Consumer<UserDataProvider>(
                              builder: (context, provider, child) {
                                return Text(
                                  provider.pickupAddress.isNotEmpty
                                      ? provider.pickupAddress
                                      : "Current Location",
                                  style: GoogleFonts.baloo2(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),

                // DROP ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Red Dot (Drop)
                    Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffDE9325),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffDE9325).withOpacity(0.3),
                            blurRadius: 4.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Input
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlaceSearchPage(),
                            ),
                          );
                          if (result != null && result is Map) {
                            final dropLat = (result['lat'] as num?)?.toDouble() ?? 0;
                            final dropLng = (result['lng'] as num?)?.toDouble() ?? 0;

                            if (!_isWithinDeliveryRange(dropLat, dropLng)) {
                              return; // Address rejected — out of range
                            }

                            final provider = Provider.of<UserDataProvider>(
                              context,
                              listen: false,
                            );
                            provider.setReceiverLocation(
                              lat: dropLat,
                              lng: dropLng,
                              address: result['address'] ?? result['displayName'] ?? '',
                              city: result['city'] ?? '',
                              state: result['state'] ?? '',
                              pincode: result['pincode'] ?? '',
                            );
                            setState(() {
                              _dropLocationController.text =
                                  result['displayName'] ?? result['address'] ?? '';
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dropLocationController,
                            readOnly: true,
                            style: GoogleFonts.baloo2(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter Drop Location",
                              hintStyle: GoogleFonts.baloo2(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Mic Icon
                    Icon(
                      Icons.mic_none_rounded,
                      color: const Color(0xff234C6A),
                      size: 22.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          SizedBox(height: 25.h),

          // ================= ACTION BUTTONS =================
          // Map Selection and Saved Addresses buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapPickerPage(
                        title: "Drop Location",
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    final dropLat = (result['lat'] as num?)?.toDouble() ?? 0;
                    final dropLng = (result['lng'] as num?)?.toDouble() ?? 0;

                    if (!_isWithinDeliveryRange(dropLat, dropLng)) {
                      return; // Address rejected — out of range
                    }

                    final provider = Provider.of<UserDataProvider>(
                      context,
                      listen: false,
                    );
                    provider.setReceiverLocation(
                      lat: dropLat,
                      lng: dropLng,
                      address: result['address'] ?? '',
                      city: result['city'] ?? '',
                      state: result['state'] ?? '',
                      pincode: result['pincode'] ?? '',
                    );
                    setState(() {
                      _dropLocationController.text = result['address'] ?? '';
                    });
                  }
                },
                icon: Icon(
                  Icons.location_on,
                  size: 20.sp,
                  color: const Color(0xff234C6A),
                ),
                label: Text(
                  "Select on map",
                  style: GoogleFonts.baloo2(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff234C6A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xff234C6A), width: 1.5.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 0.h),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // ================= PROCEED BUTTON =================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff234C6A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xff234C6A).withOpacity(0.3),
                ),
                onPressed: () {
                  final provider = Provider.of<UserDataProvider>(
                    context,
                    listen: false,
                  );

                  // Validation: Check if Pickup and Drop addresses are filled
                  if (provider.pickupAddress.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please select a Pickup Address",
                          style: GoogleFonts.baloo2(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (_dropLocationController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please enter a Drop Address",
                          style: GoogleFonts.baloo2(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Save Data to Provider
                  provider.setDropAddress(_dropLocationController.text);
                  provider.setIsInCity(_isInCity);

                  // Navigate to Parcel Details Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParcelOrderPage(),
                    ),
                  );
                },
                child: Text(
                  "Proceed Order",
                  style: GoogleFonts.baloo2(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
