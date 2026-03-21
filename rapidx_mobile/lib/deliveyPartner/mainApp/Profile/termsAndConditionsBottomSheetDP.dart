import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showTermsBottomSheetDP(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const TermsBottomSheetDP(),
  );
}

class TermsBottomSheetDP extends StatelessWidget {
  const TermsBottomSheetDP({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // Drag Handle
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

            // Header
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Terms & Conditions",
                      style: GoogleFonts.baloo2(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff234C6A),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 26),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    termSection(
                      title: "1. Service Agreement",
                      content:
                          "As a Delivery Partner, you agree to provide timely and safe delivery services in accordance with our standards.",
                    ),
                    termSection(
                      title: "2. Eligibility",
                      content:
                          "You represent that you hold a valid driving license and vehicle registration for the vehicle you operate.",
                    ),
                    termSection(
                      title: "3. Earnings & Payments",
                      content:
                          "Payouts are processed weekly. Any disputes regarding earnings must be raised within 48 hours.",
                    ),
                    termSection(
                      title: "4. Conduct",
                      content:
                          "Professional conduct with customers and merchants is mandatory. Harassment or misconduct will lead to immediate termination.",
                    ),
                    termSection(
                      title: "5. Privacy & Data",
                      content:
                          "You agree to keep customer information confidential and use it solely for delivery purposes.",
                    ),
                    termSection(
                      title: "6. Liability",
                      content:
                          "You are responsible for your vehicle's maintenance and insurance. We hold no liability for accidents during service.",
                    ),
                    termSection(
                      title: "7. Termination",
                      content:
                          "Either party may terminate this agreement at any time. We reserve the right to deactivate accounts for inactivity or violations.",
                    ),
                    termSection(
                      title: "8. Updates to Terms",
                      content:
                          "These terms may be updated. Continued use of the platform constitutes acceptance of new terms.",
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Section Widget
  Widget termSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: GoogleFonts.baloo2(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
