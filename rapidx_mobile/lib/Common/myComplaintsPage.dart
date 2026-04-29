import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';

class MyComplaintsPage extends StatefulWidget {
  const MyComplaintsPage({super.key});

  @override
  State<MyComplaintsPage> createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends State<MyComplaintsPage> {
  List<dynamic> _complaints = [];
  bool _isLoading = true;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
    // Auto refresh every 10 seconds while page is open
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchComplaints(isAutoRefresh: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchComplaints({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse('${ApiConstants.baseUrl}/users/my-complaints');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _complaints = json.decode(response.body);
        });
      } else {
        debugPrint('Failed to load complaints: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching complaints: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "My Complaints",
                        style: GoogleFonts.baloo2(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w), // Balance alignment
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff234C6A),
                      ),
                    )
                  : _complaints.isEmpty
                      ? Center(
                          child: Text(
                            "No complaints found.",
                            style: GoogleFonts.baloo2(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchComplaints,
                          color: const Color(0xff234C6A),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            itemCount: _complaints.length,
                            itemBuilder: (context, index) {
                              final complaint = _complaints[index];
                              final isResolved = complaint['complaint_status_name'] == 'Resolved';

                              return Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          complaint['order_id'] != null 
                                            ? "Order #${complaint['order_id']}"
                                            : "General Complaint",
                                          style: GoogleFonts.baloo2(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xff234C6A),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: isResolved
                                                ? Colors.green.shade50
                                                : Colors.orange.shade50,
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                            border: Border.all(
                                              color: isResolved
                                                  ? Colors.green.shade200
                                                  : Colors.orange.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            complaint['complaint_status_name'] ??
                                                'Pending',
                                            style: GoogleFonts.baloo2(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: isResolved
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      complaint['complaint_type_name'] ?? 'N/A',
                                      style: GoogleFonts.baloo2(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      complaint['description'] ?? '',
                                      style: GoogleFonts.baloo2(
                                        fontSize: 14.sp,
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (isResolved &&
                                        complaint['admin_note'] != null &&
                                        complaint['admin_note'].toString().isNotEmpty) ...[
                                      SizedBox(height: 12.h),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                              color: Colors.green.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.check_circle,
                                                    size: 16.sp,
                                                    color: Colors.green.shade700),
                                                SizedBox(width: 6.w),
                                                Text(
                                                  "Admin Response",
                                                  style: GoogleFonts.baloo2(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.green.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6.h),
                                            Text(
                                              complaint['admin_note'],
                                              style: GoogleFonts.baloo2(
                                                fontSize: 13.sp,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
