import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {

  bool _isLoading = true;
  bool _isPlacingOrder = false;
  double _distanceKm = 0.0;
  
  String deliveryMode = "LOCAL_DELIVERY";
  double baseFare = 0.0;
  double distanceCharge = 0.0;
  double weightCharge = 0.0;
  double zonePrice = 0.0;
  double urgencyMultiplier = 1.0;
  double calculatedTotalPrice = 0.0;
  
  final double platformFee = 25.0;

  double get subTotal => calculatedTotalPrice + platformFee;
  double get gst => subTotal * 0.05;
  double get totalAmount => subTotal + gst;

  @override
  void initState() {
    super.initState();
    // Schedule calculation after first build to safely access Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePricing();
    });
  }

  Future<void> _calculatePricing() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);

    double distance = 0.0;
    final lat1 = provider.senderLat;
    final lon1 = provider.senderLng;
    final lat2 = provider.receiverLat;
    final lon2 = provider.receiverLng;

    if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
      try {
        final url = Uri.parse(
          "https://router.project-osrm.org/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=false",
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final meters = (data['routes'][0]['distance'] as num?)?.toDouble();
            if (meters != null) {
              distance = meters / 1000.0;
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching OSRM distance: $e");
      }
    } else {
      debugPrint("Coordinates missing for distance calculation.");
    }

    int getVehicleTypeId(String type) {
      switch (type.toLowerCase()) {
        case "bike": return 1;
        case "two wheeler": return 1;
        case "three wheeler": return 2;
        case "mini tempo": return 3;
        case "pickup 8ft": return 3;
        case "tempo": return 4;
        case "pickup 9ft": return 4;
        default: return 1;
      }
    }

    if (mounted) {
      try {
        final backendUrl = Uri.parse("${ApiConstants.baseUrl}/users/calculate-price");
        final priceResponse = await http.post(
          backendUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "distance": distance,
            "weight": provider.weight,
            "vehicle_id": getVehicleTypeId(provider.vehicleType),
            "urgency": provider.urgency,
            "is_in_city": provider.isInCity
          }),
        );
        
        if (priceResponse.statusCode == 200) {
          final data = json.decode(priceResponse.body);
          
          setState(() {
            _distanceKm = distance;
            deliveryMode = data["mode"] ?? "LOCAL_DELIVERY";
            calculatedTotalPrice = (data["final_price"] as num?)?.toDouble() ?? 0.0;
            urgencyMultiplier = (data["multiplier"] as num?)?.toDouble() ?? 1.0;
            
            if (deliveryMode == "LOCAL_DELIVERY") {
              baseFare = (data["base_price"] as num?)?.toDouble() ?? 0.0;
              distanceCharge = (data["distance_cost"] as num?)?.toDouble() ?? 0.0;
            } else {
              zonePrice = (data["zone_price"] as num?)?.toDouble() ?? 0.0;
              weightCharge = (data["weight_price"] as num?)?.toDouble() ?? 0.0;
            }
            
            provider.setFareBreakdown(data);
            _isLoading = false;
          });
        } else {
            debugPrint("Backend Pricing Error: ${priceResponse.body}");
            setState(() { _isLoading = false; });
        }
      } catch (e) {
          debugPrint("Error calling backend pricing: $e");
          setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        appBar: AppBar(
          title: Text(
            "Billing Details",
            style: GoogleFonts.baloo2(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        
        // ================= BOTTOM PROCEED TO PAY BUTTON =================
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: const Offset(0, -5),
              ),
            ],
          ),
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
              onPressed: _isLoading ? null : () {
                _showPaymentMethodSheet();
              },
              child: Text(
                "Proceed to Pay",
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        body: _isLoading 
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xff56A3A6)),
              )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildSectionTitle("Payment Summary"),
               SizedBox(height: 12.h),
               
               Container(
                 width: double.infinity,
                 padding: EdgeInsets.all(24.w),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(24.r),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.04),
                       blurRadius: 15.r,
                       offset: const Offset(0, 5),
                     ),
                   ],
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Header
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               "RapidX Delivery",
                               style: GoogleFonts.baloo2(
                                 fontSize: 18.sp,
                                 fontWeight: FontWeight.w700,
                                 color: const Color(0xff234C6A),
                               ),
                             ),
                             Text(
                               "Receipt",
                               style: GoogleFonts.baloo2(
                                 fontSize: 14.sp,
                                 fontWeight: FontWeight.w500,
                                 color: Colors.grey.shade500,
                               ),
                             ),
                           ],
                         ),
                         Container(
                           padding: EdgeInsets.all(10.w),
                           decoration: BoxDecoration(
                             color: const Color(0xff56A3A6).withOpacity(0.1),
                             shape: BoxShape.circle,
                           ),
                           child: Icon(
                             Icons.receipt_long_rounded,
                             color: const Color(0xff56A3A6),
                             size: 24.sp,
                           ),
                         ),
                       ],
                     ),
                     
                     SizedBox(height: 30.h),
                     
                     // Itemized List
                     if (deliveryMode == "LOCAL_DELIVERY") ...[
                       _buildBillRow("Base Fare", "₹ ${baseFare.toStringAsFixed(2)}"),
                       SizedBox(height: 14.h),
                       _buildBillRow("Distance Cost (${_distanceKm.toStringAsFixed(1)}km)", "₹ ${distanceCharge.toStringAsFixed(2)}"),
                       SizedBox(height: 14.h),
                     ] else ...[
                       _buildBillRow("Zone Base Price", "₹ ${zonePrice.toStringAsFixed(2)}"),
                       SizedBox(height: 14.h),
                       _buildBillRow("Weight Price", "₹ ${weightCharge.toStringAsFixed(2)}"),
                       SizedBox(height: 14.h),
                     ],
                     
                     if (urgencyMultiplier > 1.0) ...[
                       _buildBillRow("Urgency Multiplier", "x ${urgencyMultiplier.toStringAsFixed(1)}"),
                       SizedBox(height: 14.h),
                     ],
                     
                     _buildBillRow("Delivery Price", "₹ ${calculatedTotalPrice.toStringAsFixed(2)}"),
                     SizedBox(height: 14.h),
                     _buildBillRow("Platform Fee", "₹ ${platformFee.toStringAsFixed(2)}"),
                     SizedBox(height: 14.h),
                     _buildBillRow("GST (5%)", "₹ ${gst.toStringAsFixed(2)}"),
                     
                     SizedBox(height: 24.h),
                     
                     // Dashed Divider
                     Row(
                       children: List.generate(40, (index) => Expanded(
                         child: Container(
                           color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
                           height: 1.5.h,
                         ),
                       )),
                     ),
                     
                     SizedBox(height: 24.h),
                     
                     // Total Amount
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           "Total Amount",
                           style: GoogleFonts.baloo2(
                             fontSize: 18.sp,
                             fontWeight: FontWeight.w700,
                             color: const Color(0xff234C6A),
                           ),
                         ),
                         Text(
                           "₹ ${totalAmount.toStringAsFixed(2)}",
                           style: GoogleFonts.baloo2(
                             fontSize: 24.sp,
                             fontWeight: FontWeight.w800,
                             color: const Color(0xff56A3A6),
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
               
               SizedBox(height: 30.h),

               // Info Alert
               Container(
                 padding: EdgeInsets.all(16.w),
                 decoration: BoxDecoration(
                   color: const Color(0xff234C6A).withOpacity(0.05),
                   borderRadius: BorderRadius.circular(12.r),
                   border: Border.all(color: const Color(0xff234C6A).withOpacity(0.1)),
                 ),
                 child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Icon(
                       Icons.info_outline_rounded,
                       color: const Color(0xff234C6A),
                       size: 20.sp,
                     ),
                     SizedBox(width: 12.w),
                     Expanded(
                       child: Text(
                         "Prices may vary slightly based on traffic and weather conditions during delivery.",
                         style: GoogleFonts.baloo2(
                           fontSize: 13.sp,
                           fontWeight: FontWeight.w500,
                           color: const Color(0xff234C6A).withOpacity(0.8),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.baloo2(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }
  
  Widget _buildBillRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.baloo2(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showPaymentMethodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Payment Method",
                  style: GoogleFonts.baloo2(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff234C6A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 24.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildPaymentOption(
              title: "Online Payment (UPI)",
              subtitle: "Fast and secure online payment via Gateway",
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xff56A3A6),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _processOnlinePayment(); // Open fake payment gateway
              },
            ),
            SizedBox(height: 16.h),
            _buildPaymentOption(
              title: "Cash on Delivery",
              subtitle: "Pay to delivery partner on delivery",
              icon: Icons.payments_rounded,
              color: const Color(0xff234C6A),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _placeOrder('cash'); // Process directly
              },
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  void _processOnlinePayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xff56A3A6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.qr_code_scanner_rounded, size: 48.sp, color: const Color(0xff56A3A6)),
              ),
              SizedBox(height: 20.h),
              Text(
                "Secure Payment Gateway",
                style: GoogleFonts.baloo2(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff234C6A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                "Amount to Pay:",
                style: GoogleFonts.baloo2(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "₹${totalAmount.toStringAsFixed(2)}",
                style: GoogleFonts.baloo2(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff56A3A6),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff56A3A6),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close gateway modal
                    _placeOrder('online'); // Process the order after fake payment
                  },
                  child: Text(
                    "Simulate Payment & Place Order",
                    style: GoogleFonts.baloo2(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel Payment",
                  style: GoogleFonts.baloo2(
                    fontSize: 14.sp,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16.r),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.baloo2(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff234C6A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.baloo2(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(String paymentMethod) async {
    if (_isPlacingOrder) return;
    setState(() { _isPlacingOrder = true; });
    
    final provider = Provider.of<UserDataProvider>(context, listen: false);

    // Helper mapping based on backend value_master
    int getVehicleTypeId(String type) {
      switch (type.toLowerCase()) {
        case "bike": return 1;
        case "two wheeler": return 1;
        case "three wheeler": return 2;
        case "mini tempo": return 3;
        case "pickup 8ft": return 3;
        case "tempo": return 4;
        case "pickup 9ft": return 4;
        default: return 1;
      }
    }

    int getParcelTypeId(String category) {
      switch (category.toLowerCase()) {
        case "document": return 21;
        case "electronics": return 22;
        case "food": return 23;
        case "grocery": return 24;
        case "clothing": return 25;
        case "fragile": return 26;
        default: return 27; // Other
      }
    }

    int getParcelSizeId(String size) {
      final s = size.toLowerCase();
      if (s.contains("small")) return 28;
      if (s.contains("medium")) return 29;
      if (s.contains("large") && !s.contains("very")) return 30;
      if (s.contains("very large") || s.contains("extra")) return 31;
      return 28;
    }

    // Construct request body
    final body = {
      "sender_name": provider.senderName.isNotEmpty ? provider.senderName : "N/A",
      "sender_phone": provider.senderMobile.isNotEmpty ? provider.senderMobile : "0000000000",
      "sender_address": provider.senderAddress.isNotEmpty ? provider.senderAddress : "N/A",
      "sender_state": provider.senderState.isNotEmpty ? provider.senderState : "N/A",
      "sender_city": provider.senderCity.isNotEmpty ? provider.senderCity : "N/A",
      "sender_pincode": provider.senderPincode.isNotEmpty ? provider.senderPincode : "000000",
      "receiver_name": provider.receiverName.isNotEmpty ? provider.receiverName : "N/A",
      "receiver_phone": provider.receiverMobile.isNotEmpty ? provider.receiverMobile : "0000000000",
      "receiver_address": provider.receiverAddress.isNotEmpty ? provider.receiverAddress : "N/A",
      "receiver_state": provider.receiverState.isNotEmpty ? provider.receiverState : "N/A",
      "receiver_city": provider.receiverCity.isNotEmpty ? provider.receiverCity : "N/A",
      "receiver_pincode": provider.receiverPincode.isNotEmpty ? provider.receiverPincode : "000000",
      "special_instruction": provider.specialInstructions,
      "order_amount": totalAmount,
      "urgency": provider.urgency,
      "fare_breakdown": provider.fareBreakdown,
      "payment_method": paymentMethod, // NEW: Include payment method
      if (provider.senderLat != null) "sender_lat": provider.senderLat,
      if (provider.senderLng != null) "sender_lng": provider.senderLng,
      if (provider.receiverLat != null) "receiver_lat": provider.receiverLat,
      if (provider.receiverLng != null) "receiver_lng": provider.receiverLng,
      "parcels": [
        {
          "parcel_type_id": getParcelTypeId(provider.parcelCategory),
          "parcel_size_id": getParcelSizeId(provider.parcelSize),
          "weight": provider.weight
        }
      ]
    };

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xff234C6A))),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      if (token.isEmpty) {
        Navigator.pop(context); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login again to place an order.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/create/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(body),
      );

      Navigator.pop(context); // Close loading indicator

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order Created Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to success page or home
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed (${response.statusCode}): ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isPlacingOrder = false; });
      }
    }
  }
}
