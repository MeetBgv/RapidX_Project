import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/Common/roleSelectionPage.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';

class customerSignUp extends StatefulWidget {
  const customerSignUp({super.key});

  @override
  State<customerSignUp> createState() => _customerSignUpState();
}

class _customerSignUpState extends State<customerSignUp> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
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
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 25.sp,
                      ),
                    ),
                    SizedBox(
                      width: 1.sw,
                      child: Center(
                        child: Text(
                          "Sign Up",
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
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 30.w),
            child: Text(
              "Enter your details",
              style: GoogleFonts.baloo2(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          // First Name
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 30.w, right: 30.w),
            child: TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                hintText: "First Name",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(color: Colors.grey, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(
                    color: Color(0xff56A3A6),
                    width: 2.7.w,
                  ),
                ),
              ),
            ),
          ),
          // Last Name
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 30.w, right: 30.w),
            child: TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                hintText: "Last Name",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(color: Colors.grey, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(
                    color: Color(0xff56A3A6),
                    width: 2.7.w,
                  ),
                ),
              ),
            ),
          ),
          // Phone Number
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 30.w, right: 30.w),
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "Phone Number",
                counterText: "",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(color: Colors.grey, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(
                    color: Color(0xff56A3A6),
                    width: 2.7.w,
                  ),
                ),
              ),
            ),
          ),
          // Email
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 30.w, right: 30.w),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(color: Colors.grey, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(
                    color: Color(0xff56A3A6),
                    width: 2.7.w,
                  ),
                ),
              ),
            ),
          ),
          // Password
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(color: Colors.grey, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.r),
                  borderSide: BorderSide(
                    color: Color(0xff56A3A6),
                    width: 2.7.w,
                  ),
                ),
              ),
            ),
          ),
          // Sign Up Button
          Container(
            height: 60.h,
            padding: EdgeInsets.only(top: 30.h, left: 90.w, right: 90.w),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff234C6A),
              ),
              onPressed: () async {
                final firstName = firstNameController.text.trim();
                final lastName = lastNameController.text.trim();
                final phone = phoneController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (firstName.isNotEmpty &&
                    lastName.isNotEmpty &&
                    phone.isNotEmpty &&
                    email.isNotEmpty &&
                    password.isNotEmpty) {
                  // Construct request body
                  final body = {
                    'first_name': firstName,
                    'last_name': lastName,
                    'email': email,
                    'phone': phone,
                    'password': password,
                    'address': 'N/A',
                    'state': 'N/A',
                    'city': 'N/A',
                    'pincode': '000000',
                    'address_type': 'Home',
                  };

                  try {
                    final response = await http.post(
                      Uri.parse(
                        '${ApiConstants.baseUrl}/users/register/customer',
                      ),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(body),
                    );

                    if (response.statusCode == 201) {
                      // Save auth token to SharedPreferences
                      final token = jsonDecode(response.body);
                      if (token is String && token.isNotEmpty) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('auth_token', token);
                      }

                      // Save data to provider
                      final userProvider = Provider.of<UserDataProvider>(
                        context,
                        listen: false,
                      );
                      userProvider.setUserName("$firstName $lastName");
                      userProvider.setPhoneNumber(phone);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Registration Successful!"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Navigate to Role Selection Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RoleSelectionPage(phoneNumber: phone),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Registration Failed: ${response.body}",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all the fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "Sign Up",
                style: GoogleFonts.baloo2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
