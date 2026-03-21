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

  // Mock Data
  final List<Map<String, dynamic>> orders = [
    {
      "id": "OD-2402-891",
      "date": DateTime.now().subtract(Duration(hours: 2)),
      "pickup": "Sec 18, Noida",
      "drop": "DLF Cyber City, Gurgaon",
      "amount": "₹ 350",
      "status": "Paid", // or Pending
      "parcel": "Electronics • Small",
      "isCompleted": true,
    },
    {
      "id": "OD-2402-885",
      "date": DateTime.now().subtract(Duration(hours: 5)),
      "pickup": "Laxmi Nagar, Delhi",
      "drop": "CP, New Delhi",
      "amount": "₹ 120",
      "status": "Paid",
      "parcel": "Documents",
      "isCompleted": true,
    },
    {
      "id": "OD-2402-810",
      "date": DateTime.now().subtract(Duration(days: 1)),
      "pickup": "Noida Ext, UP",
      "drop": "Ghaziabad, UP",
      "amount": "₹ 210",
      "status": "Pending",
      "parcel": "Grocery • Medium",
      "isCompleted": true,
    },
    {
      "id": "OD-2402-755",
      "date": DateTime.now().subtract(Duration(days: 2)),
      "pickup": "Saket, South Delhi",
      "drop": "Hauz Khas, Delhi",
      "amount": "₹ 95",
      "status": "Paid",
      "parcel": "Medicine",
      "isCompleted": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              itemCount: orders.length,
              separatorBuilder: (c, i) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index]).animate().fade(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (index * 100).ms);
              },
            ),
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
            SizedBox(height: 16.h),
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
                  Text("Total Earnings", style: DPTheme.body),
                  Text(
                    order['amount'],
                    style: DPTheme.h2.copyWith(color: DPColors.successGreen),
                  ),
                ],
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
