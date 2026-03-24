import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/Admin/mainAdmin.dart';
import 'package:newrapidx/Customer/mainApp/profileApp/termsAndConditionsBottomSheet.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/Common/CommonLogin.dart';
import '../../../Common/savedAddressesPage.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/Common/updateChecker.dart';

import 'accountSettingsPage.dart';
import 'helpBottomSheet.dart';

class profileApp extends StatefulWidget {
  const profileApp({super.key});

  @override
  State<profileApp> createState() => _profileAppState();
}

class _profileAppState extends State<profileApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light grey background to match design

      body: Stack(
        children: [
          // Background Image with Opacity
          // opacity: controls transparency — 0.0 = invisible, 1.0 = fully visible.
          // Increase the value below to make the doodle more prominent.
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                "assets/images/DoodleProfileBack1.png",
                fit: BoxFit.cover,
                // NOTE: Do NOT set 'color' here — it replaces the image pixels
                // with a solid colour, making the doodle invisible at low opacity.
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ListView(
                children: [
                  SizedBox(height: 40.h),

                  // Avatar
                  CircleAvatar(
                    radius: 55.r,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 55.r, color: Colors.white),
                  ),

                  SizedBox(height: 15.h),

                  // Username — reads from provider
                  Consumer<UserDataProvider>(
                    builder: (context, userData, child) {
                      return Text(
                        userData.userName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.baloo2(
                          fontSize: 22.sp,
                          color: const Color(0xff234C6A),
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 15.h),

                  // Buttons with Actions
                  // buildButton(
                  //   icon: Icons.person_outline,
                  //   title: "Profile",
                  //   onTap: () {
                  //     print("Profile Clicked");
                  //     showProfileEditBottomSheet(context);
                  //   },
                  // ),
                  buildButton(
                    icon: Icons.location_on_outlined,
                    title: "Saved Addresses",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedAddressesPage(),
                        ),
                      );
                      //print("Saved Address Clicked");
                    },
                  ),

                  buildButton(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    onTap: () {
                      print("Help Clicked");
                      showHelpSupportBottomSheet(context);
                    },
                  ),

                  buildButton(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                    onTap: () {
                      print("Terms Clicked");
                      showTermsBottomSheet(context);
                    },
                  ),

                  buildButton(
                    icon: Icons.info_outline,
                    title: "About Us",
                    onTap: () {
                      print("About Clicked");
                    },
                  ),

                  buildButton(
                    icon: Icons.system_update,
                    title: "Check for Updates",
                    onTap: () {
                      UpdateChecker.checkForUpdates(context);
                    },
                  ),

                  buildButton(
                    icon: Icons.settings_outlined,
                    title: "Account Settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsPage(),
                        ),
                      );
                    },
                  ),

                  buildButton(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () {
                      showLogoutDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Button with Arrow + Action
  Widget buildButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),

      child: OutlinedButton(
        onPressed: onTap,

        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 45.h),
          side: const BorderSide(color: Color(0xff234C6A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),

        child: Row(
          children: [
            // Left Icon
            Icon(icon, color: const Color(0xff234C6A)),

            SizedBox(width: 15.w),

            // Text
            Text(
              title,
              style: GoogleFonts.baloo2(
                fontSize: 16.sp,
                color: const Color(0xff234C6A),
                fontWeight: FontWeight.w500,
              ),
            ),

            // Push Arrow to Right
            const Spacer(),

            // Right Arrow
            const Icon(Icons.chevron_right, color: Color(0xff234C6A)),
          ],
        ),
      ),
    );
  }

  // Logout Dialog Example
  void showLogoutDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          title: Text("Logout", style: GoogleFonts.baloo2(color: Colors.black)),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.baloo2(color: Colors.black),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.baloo2(color: Color(0xff234C6A)),
              ),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                print("User Logged Out");
                
                // Clear persistent storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Add logout logic here
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const customerLogin(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                "Logout",
                style: GoogleFonts.baloo2(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
