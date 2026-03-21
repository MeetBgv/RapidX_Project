import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showHelpSupportBottomSheetDP(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const HelpSupportBottomSheetDP(),
  );
}

class HelpSupportBottomSheetDP extends StatelessWidget {
  const HelpSupportBottomSheetDP({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                    child: const Icon(Icons.close, size: 26),
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
                title: "partner-support@gmail.com",
                subtitle: "Email Support",
              ),

              supportTile(
                icon: Icons.phone_outlined,
                title: "+91 8000 123 456",
                subtitle: "Partner Helpline",
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
                question: "How do I start receiving orders?",
                answer:
                    "Go exclusively online in the app to start receiving delivery requests nearby.",
              ),

              faqItem(
                question: "How are my earnings calculated?",
                answer:
                    "Earnings are based on distance, order value, and bonuses. Check the Earnings tab for details.",
              ),

              faqItem(
                question: "What if I can't deliver an order?",
                answer:
                    "Please contact support immediately if you face issues during a delivery.",
              ),

              faqItem(
                question: "How do I update my documents?",
                answer:
                    "Go to Profile > Documents to upload or update your driving license and other details.",
              ),

              // Footer Note
              SizedBox(height: 20.h),
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
            child: Icon(icon, color: const Color(0xff234C6A), size: 22),
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
