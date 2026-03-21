import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/Common/CommonLogin.dart';

class splashPage extends StatelessWidget {
  const splashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),
            SizedBox(
              width: 1.sw,
              child: Text(
                "Move Anything,",
                style: GoogleFonts.baloo2(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff234C6A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 1.sw,
              child: Text(
                "Anywhere.",
                style: GoogleFonts.baloo2(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff234C6A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 1.sw,
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                "assets/images/LandingPage.png",
                fit: BoxFit.contain,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 40),
              width: 1.sw,
              child: Image.asset(
                "assets/images/rapidXlogo.png",
                fit: BoxFit.contain,
              ),
            ),
            Text(
              "Fast • Reliable • On-Demand Logistics",
              style: GoogleFonts.baloo2(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xff56A3A6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 90.h),
            SizedBox(
              width: 300.w,
              height: 40.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff234C6A),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const customerLogin(),
                    ),
                  );
                },
                child: Text(
                  "Let's Start",
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h), // Add some bottom padding
          ],
        ),
      ),
    );
  }
}
