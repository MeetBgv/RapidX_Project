import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newrapidx/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showComplaintBottomSheet(BuildContext context, {String? orderId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ComplaintBottomSheet(orderId: orderId),
  );
}

class ComplaintBottomSheet extends StatefulWidget {
  final String? orderId;

  const ComplaintBottomSheet({super.key, this.orderId});

  @override
  State<ComplaintBottomSheet> createState() => _ComplaintBottomSheetState();
}

class _ComplaintBottomSheetState extends State<ComplaintBottomSheet> {
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _issueTypes = [
    {"id": 48, "name": "Late Delivery"},
    {"id": 49, "name": "Damaged Item"},
    {"id": 50, "name": "Wrong Delivery"},
    {"id": 51, "name": "Payment Issue"},
    {"id": 52, "name": "Delivery Partner Issue"},
    {"id": 53, "name": "App Issue"},
    {"id": 54, "name": "Other"}
  ];
  
  int _selectedIssueId = 54; // Default to 'Other'

  Future<void> _submitComplaint() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      _showTopNotification('Please enter a description', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final orderIdInt = widget.orderId != null 
          ? int.tryParse(widget.orderId.toString().replaceAll(RegExp(r'[^0-9]'), ''))
          : null;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'order_id': orderIdInt,
          'complaint_type_id': _selectedIssueId,
          'description': desc
        })
      );

      if (response.statusCode == 201) {
        if (context.mounted) {
          _showTopNotification('Complaint submitted successfully');
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          _showTopNotification('Failed to submit, try again', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showTopNotification('Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTopNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    
    final overlay = Overlay.of(context, rootOverlay: true);
    final topPadding = MediaQuery.of(context).padding.top;
    
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding > 0 ? topPadding + 20.h : 40.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: -100.0, end: 0.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.baloo2(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.65.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 10.h, 
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Report Issue",
                  style: GoogleFonts.baloo2(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff234C6A),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: Icon(Icons.close, size: 20.sp, color: Colors.black)
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (widget.orderId != null) ...[
              Text(
                "Order ID: #${widget.orderId}",
                style: GoogleFonts.baloo2(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 16.h),
            ],
            Text("Select Issue Type", style: GoogleFonts.baloo2(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedIssueId,
                  items: _issueTypes.map((t) => DropdownMenuItem<int>(
                    value: t['id'] as int,
                    child: Text(t['name'] as String, style: GoogleFonts.baloo2(fontSize: 14.sp)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedIssueId = val);
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text("Description", style: GoogleFonts.baloo2(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: GoogleFonts.baloo2(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "Please describe your issue in detail...",
                hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade400, fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.all(12.w),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xff234C6A))),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff234C6A),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: _isLoading
                    ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Submit Complaint", style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
