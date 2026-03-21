import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/Common/showOtpBottomSheet.dart';
import 'package:newrapidx/deliveyPartner/deliveryPartnerSignUp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newrapidx/api_constants.dart';

class RoleSelectionPage extends StatelessWidget {
  final String phoneNumber;
  const RoleSelectionPage({super.key, this.phoneNumber = ''});

  Future<void> _updateRole(BuildContext context, int roleId, VoidCallback onSuccess) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/update-role'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber, // Using the phone number passed to this widget
          'role_id': roleId,
        }),
      );

      if (response.statusCode == 200) {
        onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        title: Text(
          "Select Role",
          style: GoogleFonts.baloo2(
            color: Colors.black,
            fontSize: 22.sp,
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          children: [
            _buildRoleCard(
              context,
              title: "For Personal Use",
              description: "Book rides and deliveries for yourself.",
              icon: Icons.person_outline,
              onTap: () {
                _updateRole(context, 5, () {
                  // Show OTP sheet for personal use
                  showOtpSheet(context, phoneNumber: phoneNumber);
                });
              },
            ),
            SizedBox(height: 16.h),
            _buildRoleCard(
              context,
              title: "Join us as delivery partner",
              description: "Earn money by delivering with RapidX.",
              icon: Icons.delivery_dining_outlined,
              onTap: () {
                _updateRole(context, 9, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeliveryPartnerSignUp()),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xffEDF6F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28.sp,
                color: const Color(0xff234C6A),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.baloo2(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: GoogleFonts.baloo2(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
