import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newrapidx/Common/complaintDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/dp_theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String selectedFilter = "Today";
  final List<String> filters = ["Today", "This Week", "This Month"];

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  List<Map<String, dynamic>> get filteredOrders {
    final now = DateTime.now();
    return orders.where((order) {
      final date = order['date'] as DateTime;
      if (selectedFilter == "Today") {
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } else if (selectedFilter == "This Week") {
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(weekAgo);
      } else if (selectedFilter == "This Month") {
        return date.year == now.year && date.month == now.month;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/delivery-partner-orders'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        final List<Map<String, dynamic>> mapped = data.map((item) {
          final parcels = item['parcels'] as List?;
          final parcelStr = parcels != null && parcels.isNotEmpty
              ? "${parcels[0]['parcel_type']} • ${parcels[0]['parcel_size']}"
              : "Standard Parcel";

          final amount = (item['order_amount'] as num?)?.toDouble() ?? 0.0;
          final dpShare = (item['dp_share'] as num?)?.toDouble() ?? (amount * 0.8);

          return {
            "id": item['order_id']?.toString() ?? "OD-000",
            "date": DateTime.tryParse(item['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
            "pickup": item['sender_address']?.toString() ?? "Unknown Pickup",
            "drop": item['receiver_address']?.toString() ?? "Unknown Drop",
            "amount": "₹ ${dpShare.toStringAsFixed(2)}",
            "status": item['is_complete'] == true ? "Paid" : "Pending",
            "parcel": parcelStr,
            "isCompleted": item['is_complete'] == true,
            "paymentFlag": item['payment_method'] == 'online' ? 1 : 0,
          };
        }).toList();

        if (mounted) {
          setState(() {
            orders = mapped;
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching DP orders: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayOrders = filteredOrders; // 👇 use filtered list

    return Scaffold(
      backgroundColor: DPColors.background,
      appBar: AppBar(
        backgroundColor: DPColors.white,
        elevation: 0,
        title: Text("Order History", style: DPTheme.h2),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff234C6A)))
                : displayOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        itemCount: displayOrders.length,
                        separatorBuilder: (c, i) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          return _buildOrderCard(displayOrders[index])
                              .animate()
                              .fade(duration: 400.ms, delay: (index * 100).ms)
                              .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (index * 100).ms);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            "No orders yet",
            style: DPTheme.h2.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: DPColors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = filter == selectedFilter;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? DPColors.deepBlue : DPColors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isSelected ? DPColors.deepBlue : DPColors.greyLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? DPColors.white : DPColors.greyDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return InkWell(
      onTap: () {
        _showOrderDetails(context, order);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: DPColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: DPColors.greyLight.withOpacity(0.6)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: DPColors.greyExtraLight,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    order['id'],
                    style: DPTheme.h3.copyWith(
                      fontSize: 12.sp,
                      color: DPColors.greyDark,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(order['date']),
                  style: DPTheme.bodySmall.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: order['paymentFlag'] == 1 ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: order['paymentFlag'] == 1 ? const Color(0xFF7DD3FC) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        order['paymentFlag'] == 1 ? Icons.credit_card : Icons.money,
                        size: 14.sp,
                        color: order['paymentFlag'] == 1 ? const Color(0xFF0369A1) : const Color(0xFFD97706),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        order['paymentFlag'] == 1 ? "Online (Flag 1)" : "Cash (Flag 0)",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: order['paymentFlag'] == 1 ? const Color(0xFF0369A1) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8.sp,
                        color: DPColors.PickUpGreen,
                      ),
                      Expanded(
                        child: Container(
                          width: 1.w,
                          color: DPColors.greyLight,
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                        ),
                      ),
                      Icon(Icons.square, size: 8.sp, color: DPColors.DropRed),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['pickup'],
                          style: DPTheme.body.copyWith(
                            fontSize: 13.sp,
                            color: DPColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          order['drop'],
                          style: DPTheme.body.copyWith(
                            fontSize: 13.sp,
                            color: DPColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Divider(height: 1.h, color: DPColors.greyLight.withOpacity(0.5)),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16.sp,
                      color: DPColors.greyMedium,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      order['parcel'],
                      style: DPTheme.bodySmall.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      order['amount'],
                      style: DPTheme.h3.copyWith(
                        color: DPColors.successGreen,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: DPColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: DPColors.greyLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text("Order Details", style: DPTheme.h2),
              SizedBox(height: 12.h),
              _detailRow("Order ID", order['id']),
              _detailRow(
                "Date",
                DateFormat('dd MMM yyyy, hh:mm a').format(order['date']),
              ),
              Divider(height: 32.h),
              Text("Locations", style: DPTheme.h3),
              SizedBox(height: 12.h),
              _locationDetail(true, order['pickup']),
              SizedBox(height: 12.h),
              _locationDetail(false, order['drop']),
              Divider(height: 32.h),
              Text("Payment", style: DPTheme.h3),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Payment Method", style: DPTheme.body),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: order['paymentFlag'] == 1 ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      order['paymentFlag'] == 1 ? "Online (Flag 1)" : "Offline/Cash (Flag 0)",
                      style: DPTheme.h3.copyWith(
                        fontSize: 12.sp,
                        color: order['paymentFlag'] == 1 ? const Color(0xFF0369A1) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Earnings", style: DPTheme.body),
                  Text(
                    order['amount'],
                    style: DPTheme.h2.copyWith(color: DPColors.successGreen),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close details sheet first
                    showComplaintBottomSheet(context, orderId: order['id']);
                  },
                  icon: const Icon(Icons.support_agent, color: Color(0xFFD97706)),
                  label: Text("Report Issue / Complain", style: DPTheme.h3.copyWith(color: const Color(0xFFD97706), fontSize: 14.sp)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFEF3C7)),
                    backgroundColor: const Color(0xFFFEF3C7).withOpacity(0.3),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DPTheme.body.copyWith(color: DPColors.greyMedium)),
          Text(value, style: DPTheme.h3.copyWith(fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _locationDetail(bool isPickup, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isPickup ? Icons.radio_button_checked : Icons.location_on,
          color: isPickup ? DPColors.PickUpGreen : DPColors.DropRed,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPickup ? "Pickup" : "Drop",
                style: DPTheme.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(address, style: DPTheme.body),
            ],
          ),
        ),
      ],
    );
  }
}
