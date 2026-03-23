import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:newrapidx/Common/liveTrackingPage.dart';

import '../homeApp/homeApp.dart';

class ordersApp extends StatefulWidget {
  final int initialIndex;
  const ordersApp({super.key, this.initialIndex = 0});

  @override
  State<ordersApp> createState() => ordersAppState();
}

class ordersAppState extends State<ordersApp> {
  // 👉 Controls which tab is selected (0,1,2)
  late int selectedIndex;

  void setTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // 👉 Names of the tabs
  final List<String> tabs = ["Current Orders", "Order History"];

  // Real data arrays
  List<Map<String, dynamic>> _liveOrders = [];
  List<Map<String, dynamic>> _pastOrders = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _fetchOrders();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchOrders(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ordersApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      selectedIndex = widget.initialIndex;
    }
  }

  Future<void> _fetchOrders({bool showLoading = true}) async {
    try {
      if (showLoading && mounted) {
        setState(() => _isLoading = true);
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/customer-orders?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("Orders API Response code: ${res.statusCode}");
      // debugPrint("Orders API Response body: ${res.body}");

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);

        final List<Map<String, dynamic>> live = [];
        final List<Map<String, dynamic>> past = [];

        for (var item in data) {
          final isComplete = item['is_complete'] == true;

          final lat1 = double.tryParse(item['sender_lat']?.toString() ?? '0') ?? 0;
          final lng1 = double.tryParse(item['sender_lng']?.toString() ?? '0') ?? 0;
          final lat2 = double.tryParse(item['receiver_lat']?.toString() ?? '0') ?? 0;
          final lng2 = double.tryParse(item['receiver_lng']?.toString() ?? '0') ?? 0;

          String dateStr = 'Unknown date';
          if (item['created_at'] != null) {
            final dt = DateTime.tryParse(item['created_at'].toString())?.toLocal();
            if (dt != null) {
              dateStr = "${dt.day}/${dt.month}/${dt.year} ${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
            }
          }

          final latP = double.tryParse(item['current_lat']?.toString() ?? '0') ?? 0;
          final lngP = double.tryParse(item['current_lng']?.toString() ?? '0') ?? 0;

          final orderObj = {
            "orderId": item['order_id']?.toString() ?? "",
            "status": item['status_name'] ?? "Pending",
            "date": dateStr,
            "partnerName": item['dp_first_name'] != null ? "${item['dp_first_name']} ${item['dp_last_name'] ?? ''}".trim() : "Pending Assignment",
            "partnerPhone": item['dp_phone']?.toString() ?? "",
            "senderLocation": LatLng(lat1 != 0 ? lat1 : 28.7041, lng1 != 0 ? lng1 : 77.1025),
            "receiverLocation": LatLng(lat2 != 0 ? lat2 : 28.5355, lng2 != 0 ? lng2 : 77.3910),
            "partnerLocation": latP != 0 ? LatLng(latP, lngP) : null,
            // 👉 Expanded details for bottom sheet
            "senderName": item['sender_name'] ?? "N/A",
            "receiverName": item['receiver_name'] ?? "N/A",
            "senderAddress": item['sender_address'] ?? "N/A",
            "receiverAddress": item['receiver_address'] ?? "N/A",
            "amount": item['order_amount']?.toString() ?? "0",
            "urgency": item['urgency'] ?? "N/A",
            "parcels": item['parcels'] as List? ?? [],
          };

          if (isComplete) {
            past.add(orderObj);
          } else {
            live.add(orderObj);
          }
        }

        if (mounted) {
          setState(() {
            _liveOrders = live;
            _pastOrders = past;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // ================= BACKGROUND IMAGE =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,

            // 👉 Change opacity (0.0 = invisible, 1.0 = fully visible)
            child: Opacity(
              opacity: 0.1,

              // 👉 Change image here
              child: Image.asset(
                "assets/images/buildingDoodle.png",

                // 👉 Change how image fits
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // ================= MAIN SCROLL VIEW =================
          RefreshIndicator(
            onRefresh: () => _fetchOrders(showLoading: false),
            color: const Color(0xff234C6A),
            child: ListView(
              // 👉 Change screen padding here
              padding: EdgeInsets.only(
                top: 65.h, // Space below AppBar
                left: 10.w, // Left margin
                right: 10.w, // Right margin
                bottom: 10.h, // Bottom margin
              ),

              children: [
                // 👉 Space before tabs
                SizedBox(height: 5.h),

                // Tabs row
                _buildTabs(),

                // 👉 Space after tabs
                SizedBox(height: 10.h),

                // Page content
                _buildContent(),
              ],
            ),
          ),

          // ================= APP BAR =================
          _buildAppBar(),
        ],
      ),
    );
  }

  // ================= APP BAR =================

  Widget _buildAppBar() {
    return Container(
      // 👉 Change AppBar height
      height: 60.h,

      decoration: const BoxDecoration(
        // 👉 AppBar background color
        color: Colors.white,

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12), // Corner radius
          bottomRight: Radius.circular(12),
        ),

        // 👉 Shadow below AppBar
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8, // Blur amount
            offset: Offset(0, 9), // Shadow position
          ),
        ],
      ),

      child: Row(
        children: [
          // 👉 Back Button
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const homeApp()),
                (route) => false,
              );
            },

            // 👉 Change icon size/color
            icon: Icon(Icons.arrow_back, size: 25.sp, color: Colors.black),
          ),

          // 👉 Title text
          Text(
            "Manage Orders",

            style: GoogleFonts.baloo2(
              // 👉 Title font size
              fontSize: 16.sp,

              // 👉 Font thickness
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TABS =================

  Widget _buildTabs() {
    return SingleChildScrollView(
      // 👉 Makes tabs scrollable horizontally
      scrollDirection: Axis.horizontal,

      child: Row(
        children: List.generate(tabs.length, (index) => _tabButton(index)),
      ),
    );
  }

  // ================= SINGLE TAB BUTTON =================
  Widget _tabButton(int index) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      // 👉 Space between buttons
      padding: EdgeInsets.only(right: 8.w),

      child: OutlinedButton(
        // 👉 When pressed
        onPressed: () {
          setState(() {
            selectedIndex = index;
          });
        },

        style: OutlinedButton.styleFrom(
          // 👉 Background when selected
          backgroundColor: isSelected
              ? const Color(0xff234C6A)
              : Colors.transparent,

          // 👉 Border color & thickness
          side: BorderSide(
            color: isSelected ? const Color(0xff234C6A) : Colors.grey.shade400,
            width: 1.5, // Border thickness
          ),

          // 👉 Button padding (size)
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),

          // 👉 Rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),

          // 👉 Remove default shadow
          elevation: 0,
        ),

        child: Text(
          tabs[index],

          style: GoogleFonts.baloo2(
            // 👉 Text size
            fontSize: 12.sp,

            fontWeight: FontWeight.w700,

            // 👉 Text color
            color: isSelected ? Colors.white : const Color(0xff234C6A),
          ),
        ),
      ),
    );
  }

  // ================= CONTENT SWITCH =================

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80.h),
          child: const CircularProgressIndicator(color: Color(0xff234C6A)),
        ),
      );
    }
    
    Widget content;
    switch (selectedIndex) {
      case 0:
        content = _liveOrders.isEmpty 
            ? _emptyState("No current orders")
            : _buildOrderList(_liveOrders, true);
        break;
      case 1:
        content = _pastOrders.isEmpty 
            ? _emptyState("No order history")
            : _buildOrderList(_pastOrders, false);
        break;
      default:
        content = const SizedBox();
    }
    
    return content.animate(key: ValueKey(selectedIndex)).fade(duration: 400.ms).slideX(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, bool isLive) {
    return Column(
      children: orders.map((order) => _buildOrderCard(order, isLive)).toList(),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isLive) {
    return GestureDetector(
      onTap: () {
        if (isLive) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LiveTrackingPage(
                senderLocation: order["senderLocation"] as LatLng,
                receiverLocation: order["receiverLocation"] as LatLng,
                partnerName: order["partnerName"] as String,
                partnerPhone: order["partnerPhone"] as String,
                orderId: order["orderId"] as String,
                status: order["status"] as String,
                initialPartnerLocation: order["partnerLocation"] as LatLng?,
              ),
            ),
          );
        } else {
          _showOrderDetails(order);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order["orderId"]}",
                  style: GoogleFonts.baloo2(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff234C6A),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isLive ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order["status"] as String,
                    style: GoogleFonts.baloo2(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isLive ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  order["date"] as String,
                  style: GoogleFonts.baloo2(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (isLive) ...[
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.directions_bike, size: 16.sp, color: const Color(0xff56A3A6)),
                  SizedBox(width: 6.w),
                  Text(
                    "Track real-time location & details",
                    style: GoogleFonts.baloo2(
                      fontSize: 12.sp,
                      color: const Color(0xff56A3A6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 12.sp, color: const Color(0xff56A3A6)),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        children: [
          // 👉 Space from top
          SizedBox(height: 80.h),

          // 👉 Icon
          Icon(
            Icons.inventory_2_outlined,

            // 👉 Icon size
            size: 60.sp,

            // 👉 Icon color
            color: Colors.grey.shade400,
          ),

          SizedBox(height: 12.h),

          // 👉 "Oops!" Text
          Text(
            "Oops!",

            style: GoogleFonts.baloo2(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(height: 4.h),

          // 👉 Subtitle text
          Text(
            text,

            style: GoogleFonts.baloo2(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(24.w),
                  children: [
                    Text(
                      "Order Summary",
                      style: GoogleFonts.baloo2(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff234C6A),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    _detailSection("Sender Details", [
                      _detailRow(Icons.person, "Name", order["senderName"]),
                      _detailRow(Icons.location_on, "Address", order["senderAddress"]),
                    ]),
                    
                    SizedBox(height: 20.h),
                    _detailSection("Receiver Details", [
                      _detailRow(Icons.person, "Name", order["receiverName"]),
                      _detailRow(Icons.location_on, "Address", order["receiverAddress"]),
                    ]),
                    
                    SizedBox(height: 20.h),
                    _detailSection("Parcel Information", (order["parcels"] as List).map((p) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${p['parcel_type']} (${p['parcel_size']})",
                              style: GoogleFonts.baloo2(fontSize: 14.sp),
                            ),
                            Text(
                                "${p['weight']} kg",
                                style: GoogleFonts.baloo2(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }).toList()),
                    
                    SizedBox(height: 20.h),
                    _detailSection("Payment & Partner", [
                      _detailRow(Icons.currency_rupee, "Total Amount", "₹${order["amount"]}"),
                      _detailRow(Icons.delivery_dining, "Delivered By", order["partnerName"]),
                      if (order["partnerPhone"].isNotEmpty)
                        _detailRow(Icons.phone, "Partner Contact", order["partnerPhone"]),
                    ]),
                    
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailSection(String title, dynamic children) {
    List<Widget> childrenList = [];
    if (children is List<Widget>) {
      childrenList = children;
    } else if (children is Iterable<Widget>) {
      childrenList = children.toList();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.baloo2(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xff56A3A6),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(children: childrenList),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xff234C6A).withOpacity(0.6)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.baloo2(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.baloo2(
                    fontSize: 14.sp,
                    color: const Color(0xff234C6A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


