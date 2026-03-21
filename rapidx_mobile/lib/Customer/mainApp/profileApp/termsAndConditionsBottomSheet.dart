import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showTermsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const TermsBottomSheet(),
  );
}

class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),

      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: 20.h,
        ),

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
                      title: "1. Acceptance of Terms",
                      content:
                          "By using this application, you agree to comply with and be bound by these terms and conditions.",
                    ),

                    termSection(
                      title: "2. User Responsibilities",
                      content:
                          "Users must provide accurate information and maintain the confidentiality of their account.",
                    ),

                    termSection(
                      title: "3. Privacy Policy",
                      content:
                          "We respect your privacy. Your personal data will be handled securely and will not be shared without consent.",
                    ),

                    termSection(
                      title: "4. Service Usage",
                      content:
                          "Our services are intended for personal and non-commercial use only.",
                    ),

                    termSection(
                      title: "5. Payment & Refunds",
                      content:
                          "Payments once made are non-refundable unless otherwise stated.",
                    ),

                    termSection(
                      title: "6. Order Cancellation",
                      content:
                          "Orders can be cancelled within a limited time after placement.",
                    ),

                    termSection(
                      title: "7. Account Termination",
                      content:
                          "We reserve the right to suspend or terminate accounts in case of misuse.",
                    ),

                    termSection(
                      title: "8. Limitation of Liability",
                      content:
                          "We are not responsible for any indirect or consequential damages.",
                    ),

                    termSection(
                      title: "9. Changes to Terms",
                      content:
                          "Terms may be updated periodically. Continued use implies acceptance.",
                    ),

                    termSection(
                      title: "10. Contact Information",
                      content:
                          "For any legal or policy-related queries, contact support@genuinest.com.",
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
