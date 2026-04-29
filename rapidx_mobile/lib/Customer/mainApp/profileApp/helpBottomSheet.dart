import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showHelpSupportBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const HelpSupportBottomSheet(),
  );
}

class HelpSupportBottomSheet extends StatelessWidget {
  const HelpSupportBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),

      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: 20.h,
        ),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        "Help & Support",
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
                    child: Icon(Icons.close, size: 26.sp),
                  ),
                ],
              ),

              SizedBox(height: 25.h),

              // Contact Section
              Text(
                "Contact Us",
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12.h),

              supportTile(
                icon: Icons.email_outlined,
                title: "support@gmail.com",
                subtitle: "Email Support",
              ),

              supportTile(
                icon: Icons.phone_outlined,
                title: "+91 8000 123 456",
                subtitle: "Customer Care",
              ),

              supportTile(
                icon: Icons.chat_outlined,
                title: "+91 8000 123 456",
                subtitle: "WhatsApp Support",
              ),

              SizedBox(height: 25.h),

              // FAQ Section
              Text(
                "Frequently Asked Questions",
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12.h),

              faqItem(
                question: "How can I track my order?",
                answer:
                    "You can track your order from the Orders section in your app.",
              ),

              faqItem(
                question: "How do I change my address?",
                answer:
                    "Go to Profile > Saved Addresses and update your location.",
              ),

              faqItem(
                question: "What if my order is delayed?",
                answer:
                    "If your order is delayed, please contact our support team.",
              ),

              faqItem(
                question: "How do I cancel my order?",
                answer:
                    "You can cancel your order within 5 minutes after placing it.",
              ),

              // Footer Note
              Center(
                child: Text(
                  "We are available 24/7 to assist you",
                  style: GoogleFonts.baloo2(
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Support Row
  Widget supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),

      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xff234C6A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),

            child: Icon(icon, color: const Color(0xff234C6A), size: 22.sp),
          ),

          SizedBox(width: 12.w),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.baloo2(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                subtitle,
                style: GoogleFonts.baloo2(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // FAQ Widget
  Widget faqItem({required String question, required String answer}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.baloo2(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            answer,
            style: GoogleFonts.baloo2(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
