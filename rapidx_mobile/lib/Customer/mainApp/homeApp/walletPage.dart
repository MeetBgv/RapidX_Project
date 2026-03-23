import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff234C6A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Wallet",
          style: GoogleFonts.baloo2(
            color: const Color(0xff234C6A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.r),
              decoration: BoxDecoration(
                color: const Color(0xff234C6A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 80.sp,
                color: const Color(0xff234C6A),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Coming Soon!",
              style: GoogleFonts.baloo2(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xff234C6A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "We are working hard to bring this feature to you.",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
