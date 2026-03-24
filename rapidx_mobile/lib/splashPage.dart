import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/Common/CommonLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';
import 'package:newrapidx/Customer/mainApp/homeApp/homeApp.dart';
import 'package:newrapidx/deliveyPartner/mainApp/mainPageDP.dart';
import 'package:newrapidx/Admin/mainAdmin.dart';

class splashPage extends ConsumerStatefulWidget {
  const splashPage({super.key});

  @override
  ConsumerState<splashPage> createState() => _splashPageState();
}

class _splashPageState extends ConsumerState<splashPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('role');

    if (token != null && role != null) {
      if (role == 'Admin') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const mainAdmin()),
        );
        return;
      } else if (role == '9') {
        final firstName = prefs.getString('first_name') ?? '';
        final lastName = prefs.getString('last_name') ?? '';
        final phone = prefs.getString('phone') ?? '';

        final dpNotifier = ref.read(deliveryPartnerProvider.notifier);
        dpNotifier.setName("$firstName $lastName".trim());
        dpNotifier.setPhone(phone);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => mainPageDP()),
        );
        return;
      } else if (role == '5') {
        final firstName = prefs.getString('first_name') ?? '';
        final lastName = prefs.getString('last_name') ?? '';
        final phone = prefs.getString('phone') ?? '';

        final userProvider = Provider.of<UserDataProvider>(context, listen: false);
        userProvider.setUserName("$firstName $lastName".trim());
        userProvider.setPhoneNumber(phone);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const homeApp()),
        );
        return;
      }
    }
    
    // Not logged in or invalid token
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xff234C6A),
          ),
        ),
      );
    }

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
