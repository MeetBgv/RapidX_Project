import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:newrapidx/Common/myComplaintsPage.dart';
import 'package:newrapidx/Common/complaintDialog.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<UserDataProvider>(
          builder: (context, userData, child) {
            return Column(
              children: [
                // Header
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 20.sp,
                              color: Colors.black,
                            ),
                            SizedBox(width: 50.w),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Account Settings",
                            style: GoogleFonts.baloo2(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 60.w),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Section: Avatar + Info + Edit Icon
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25.r,
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 30.r,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData.userName,
                                      style: GoogleFonts.baloo2(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xff234C6A),
                                      ),
                                    ),
                                    Text(
                                      userData.phoneNumber,
                                      style: GoogleFonts.baloo2(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit Icon
                              GestureDetector(
                                onTap: () =>
                                    _showEditBottomSheet(context, userData),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 22.sp,
                                  color: const Color(0xff234C6A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 1.h, thickness: 1),

                        // Middle Section: Address
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            userData.userAddress,
                            style: GoogleFonts.baloo2(
                              fontSize: 14.sp,
                              color: Colors.black,
                              height: 1.4.h,
                            ),
                          ),
                        ),

                        // Bottom Section: Buttons
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 12.w,
                            runSpacing: 8.h,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyComplaintsPage()));
                                },
                                child: Text(
                                  "My Complaints",
                                  style: GoogleFonts.baloo2(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff234C6A),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showComplaintBottomSheet(context);
                                },
                                child: Text(
                                  "Raise Complaint",
                                  style: GoogleFonts.baloo2(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff234C6A),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _showDeleteConfirmation(context),
                                child: Text(
                                  "Delete Account",
                                  style: GoogleFonts.baloo2(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Add Account Button
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Static action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff234C6A),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "Add Account +",
                        style: GoogleFonts.baloo2(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Edit Bottom Sheet
  void _showEditBottomSheet(BuildContext context, UserDataProvider userData) {
    final nameController =
        TextEditingController(text: userData.rawUserName);
    final addressController =
        TextEditingController(text: userData.rawUserAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Details",
                      style: GoogleFonts.baloo2(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff234C6A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 24.sp),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Name Field
                Text(
                  "Full Name",
                  style: GoogleFonts.baloo2(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.baloo2(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    hintStyle: GoogleFonts.baloo2(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Color(0xff234C6A)),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Address Field
                Text(
                  "Address",
                  style: GoogleFonts.baloo2(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  style: GoogleFonts.baloo2(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: "Enter your address",
                    hintStyle: GoogleFonts.baloo2(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Color(0xff234C6A)),
                    ),
                  ),
                ),

                const Spacer(),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();

                      if (name.isNotEmpty) {
                        userData.setUserName(name);
                      }
                      if (address.isNotEmpty) {
                        userData.setUserAddress(address);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff234C6A),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Save",
                      style: GoogleFonts.baloo2(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 20.sp),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Are You sure you want to delete this account permanant;y",
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff234C6A),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.baloo2(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Static "Yes" action
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff234C6A),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Yes",
                        style: GoogleFonts.baloo2(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
