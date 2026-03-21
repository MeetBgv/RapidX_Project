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
                blurRadius: 10,
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
              onPressed: () async {
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

                int getParcelSizeId(String size) {
                  if (size.toLowerCase().contains("small")) return 1;
                  if (size.toLowerCase().contains("medium")) return 2;
                  if (size.toLowerCase().contains("large")) return 3;
                  if (size.toLowerCase().contains("extra large")) return 4;
                  return 1;
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
                  if (provider.senderLat != null) "sender_lat": provider.senderLat,
                  if (provider.senderLng != null) "sender_lng": provider.senderLng,
                  if (provider.receiverLat != null) "receiver_lat": provider.receiverLat,
                  if (provider.receiverLng != null) "receiver_lng": provider.receiverLng,
                  "parcels": [
                    {
                      "parcel_type_id": getVehicleTypeId(provider.vehicleType),
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

                  debugPrint('Order API - Token present: ${token.isNotEmpty}');
                  debugPrint('Order API - Request body: ${jsonEncode(body)}');

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

                  debugPrint('Order API - Status: ${response.statusCode}');
                  debugPrint('Order API - Response: ${response.body}');

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
                }
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
                       blurRadius: 15,
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
                           height: 1.5,
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
}
