import 'package:flutter/material.dart';
import 'package:newrapidx/Customer/customerSignup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:newrapidx/Admin/mainAdmin.dart';
import '../Customer/mainApp/homeApp/homeApp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart' hide Consumer;
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';
import 'package:newrapidx/deliveyPartner/mainApp/mainPageDP.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';

// Changed to ConsumerStatefulWidget to access Riverpod's ref
class customerLogin extends ConsumerStatefulWidget {
  const customerLogin({super.key});

  @override
  ConsumerState<customerLogin> createState() => _customerLoginState();
}

class _customerLoginState extends ConsumerState<customerLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: ListView(
        children: [
          SizedBox(
            width: 1.sw,
            child: Row(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 1.sw,
                      child: Center(
                        child: Text(
                          "Login",
                          style: GoogleFonts.baloo2(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.h),
            width: 1.sw,
            child: GestureDetector(
              onLongPress: () {
                // Set static data for Customer testing
                final userProvider = Provider.of<UserDataProvider>(
                  context,
                  listen: false,
                );
                userProvider.setUserName("username");
                userProvider.setPhoneNumber("9999999999");

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const homeApp()),
                  (route) => false,
                );
              },
              child: Image.asset(
                "assets/images/rapidXlogo.png",
                fit: BoxFit.contain,
              ),
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
          Container(
            width: 1.sw,
            padding: EdgeInsets.only(top: 20.h),
            child: GestureDetector(
              onLongPress: () {
                // Set static data for Delivery Partner testing (Riverpod)
                ref.read(deliveryPartnerProvider.notifier).setName("username");
                ref
                    .read(deliveryPartnerProvider.notifier)
                    .setPhone("9999999999");

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => mainPageDP()),
                  (route) => false,
                );
              },
              child: Image.asset(
                "assets/images/LoginPage.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
          Center(
            child: Text(
              "Welcome Back!",
              style: GoogleFonts.baloo2(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          // Email Input
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 30.w, right: 30.w),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email",

                // Normal state
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),

                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),

                // When typing / focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),

                  borderSide: const BorderSide(
                    color: Color(0xff56A3A6),
                    width: 2.7,
                  ),
                ),
              ),
            ),
          ),
          // Password Input
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 30.w, right: 30.w),
            child: TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                // Normal state
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),

                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),

                // When typing / focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),

                  borderSide: const BorderSide(
                    color: Color(0xff56A3A6),
                    width: 2.7,
                  ),
                ),
              ),
            ),
          ),
          // Log In Button
          Container(
            height: 60.h,
            padding: EdgeInsets.only(top: 30.h, left: 90.w, right: 90.w),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff234C6A),
              ),
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                if (email.isNotEmpty && password.isNotEmpty) {
                  try {
                    final response = await http.post(
                      Uri.parse('${ApiConstants.baseUrl}/users/login'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'email': email, 'password': password}),
                    );

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      final role = data['role'];
                      final token = data['token'];

                      // Save auth token to SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      if (token != null) {
                        await prefs.setString('auth_token', token);
                      }

                      debugPrint('Login Response - Role: $role');
                      print(
                        'Login Response - Role: $role',
                      ); // Fallback regular print
                      debugPrint('Login Response - Data: $data');

                      if (role == 'Admin') {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const mainAdmin()),
                          (route) => false,
                        );
                      } else if (role == 9 || role == "9") {
                        // Delivery Partner Logic (Role ID: 9) — using Riverpod
                        final userData = data['user'];
                        final String firstName = userData['first_name'] ?? '';
                        final String lastName = userData['last_name'] ?? '';
                        final String phone = userData['phone'] ?? '';

                        // Save to Riverpod DeliveryPartnerNotifier
                        final dpNotifier = ref.read(
                          deliveryPartnerProvider.notifier,
                        );
                        dpNotifier.setName("$firstName $lastName".trim());
                        dpNotifier.setPhone(phone);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => mainPageDP()),
                          (route) => false,
                        );
                      } else if (role == 5 || role == "5") {
                        // Customer Logic (Personal Use - Role ID: 5)
                        // Extract user data
                        final userData = data['user'];
                        final String firstName = userData['first_name'] ?? '';
                        final String lastName = userData['last_name'] ?? '';
                        final String phone = userData['phone'] ?? '';
                        final String email = userData['email'] ?? '';

                        // Save to UserDataProvider (still using Provider)
                        final userProvider = Provider.of<UserDataProvider>(
                          context,
                          listen: false,
                        );
                        userProvider.setUserName("$firstName $lastName".trim());
                        userProvider.setPhoneNumber(phone);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const homeApp()),
                          (route) => false,
                        );
                      } else {
                        // Default Fallback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Unknown Role: $role"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid credentials"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Connection error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter your email and password"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "Log In",
                style: GoogleFonts.baloo2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ), //button for login
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 80.w),
            child: Row(
              children: [
                Text(
                  "New To RapidX ?",
                  style: GoogleFonts.baloo2(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const customerSignUp(),
                      ),
                    );
                  },
                  child: Text(
                    "SignUp",
                    style: GoogleFonts.baloo2(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffDE9325),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
