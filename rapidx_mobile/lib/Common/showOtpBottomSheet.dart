import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Customer/mainApp/homeApp/homeApp.dart';

// ---------------- GLOBAL OTP FUNCTION ----------------

void showOtpSheet(
  BuildContext context, {
  String phoneNumber = '',
  Widget? destinationPage,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,

    builder: (_) =>
        OtpSheet(phoneNumber: phoneNumber, destinationPage: destinationPage),
  );
}

// ---------------- OTP SHEET ----------------

class OtpSheet extends StatefulWidget {
  final String phoneNumber;
  final Widget? destinationPage;
  const OtpSheet({super.key, this.phoneNumber = '', this.destinationPage});

  @override
  State<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  int seconds = 180;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
      }
    });
  }

  String get timeText {
    final min = seconds ~/ 60;
    final sec = seconds % 60;

    return "$min:${sec.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();

    for (var c in controllers) {
      c.dispose();
    }

    for (var f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  // Get Full OTP
  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Title
          Text(
            "Enter OTP",
            style: GoogleFonts.baloo2(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // OTP sent to phone number text
          if (widget.phoneNumber.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                "OTP sent to \"${widget.phoneNumber}\"",
                style: GoogleFonts.baloo2(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

          const SizedBox(height: 25),

          // OTP Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return _buildOtpBox(index);
            }),
          ),

          const SizedBox(height: 20),

          // Resend Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Resend OTP in "),
              Text(
                "($timeText)",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Validate Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                final otp = getOtp();
                debugPrint("Entered OTP: $otp");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => widget.destinationPage ?? const homeApp(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff234C6A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                "Validate OTP",
                style: GoogleFonts.baloo2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // Single OTP Box
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 55,
      height: 55,

      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],

        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,

        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

        decoration: InputDecoration(
          counterText: "",

          filled: true,
          fillColor: Colors.grey[50],

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xff234C6A), width: 1.5),
          ),
        ),

        onChanged: (value) {
          // Move to next box
          if (value.isNotEmpty && index < 3) {
            focusNodes[index + 1].requestFocus();
          }

          // Go back if deleted
          if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
