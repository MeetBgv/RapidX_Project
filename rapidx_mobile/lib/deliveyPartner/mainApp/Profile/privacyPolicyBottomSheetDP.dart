import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showPrivacyPolicyBottomSheetDP(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PrivacyPolicyBottomSheetDP(),
  );
}

class PrivacyPolicyBottomSheetDP extends StatelessWidget {
  const PrivacyPolicyBottomSheetDP({super.key});

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
                      "Privacy Policy",
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
                    policySection(
                      title: "1. Information Collection",
                      content:
                          "We collect personal information such as name, contact details, vehicle information, and location data to facilitate delivery services.",
                    ),
                    policySection(
                      title: "2. Location Data",
                      content:
                          "We collect precise location data from your device when the app is running in the foreground or background to track deliveries and calculate earnings.",
                    ),
                    policySection(
                      title: "3. Use of Information",
                      content:
                          "Your data is used to match you with delivery requests, process payments, providing customer support, and improve our services.",
                    ),
                    policySection(
                      title: "4. Information Sharing",
                      content:
                          "We share your name, photo, and vehicle details with customers and merchants solely for the purpose of fulfilling orders.",
                    ),
                    policySection(
                      title: "5. Data Security",
                      content:
                          "We implement security measures to protect your personal information. However, no transmission over the internet is completely secure.",
                    ),
                    policySection(
                      title: "6. Your Rights",
                      content:
                          "You have the right to access, correct, or delete your personal information, subject to certain legal obligations.",
                    ),
                    policySection(
                      title: "7. Updates",
                      content:
                          "We may update this privacy policy from time to time. You will be notified of significant changes through the app.",
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
  Widget policySection({required String title, required String content}) {
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
