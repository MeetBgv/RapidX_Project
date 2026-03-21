import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/Common/addressDetailsBottomSheet.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/providers/userDataProvider.dart';

class SavedAddressesPage extends StatelessWidget {
  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "Saved Addresses",
              style: GoogleFonts.baloo2(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Manage your saved addresses",
              style: GoogleFonts.baloo2(
                color: Colors.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              SizedBox(width: 10.w),
              Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
            ],
          ),
        ),
        leadingWidth: 80.w,
      ),
      floatingActionButton: SizedBox(
        width: 100.w,
        child: FloatingActionButton(
          onPressed: () {
            showAddressDetailsBottomSheet(context);
          },
          backgroundColor: const Color(0xff234C6A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            "Add +",
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          final addresses = provider.savedAddresses;
          if (addresses.isEmpty) {
            return Center(
              child: Text(
                "No Saved Addresses",
                style: GoogleFonts.baloo2(fontSize: 18.sp, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: GestureDetector(
                  onTap: () {
                    // Return the selected address
                    Navigator.pop(context, address);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Top Section
                        Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconForType(address['type']),
                                size: 38.sp,
                                color: const Color(0xff234C6A),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      address['type'] ?? "Home",
                                      style: GoogleFonts.baloo2(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xff234C6A),
                                      ),
                                    ),
                                    Text(
                                      "${address['name']}, ${address['phone']}",
                                      style: GoogleFonts.baloo2(
                                        fontSize: 12.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Delete Button
                              GestureDetector(
                                onTap: () {
                                  // Add delete logic here
                                },
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 15.w),
                              // Edit Button
                              GestureDetector(
                                onTap: () {
                                  showAddressDetailsBottomSheet(
                                    context,
                                    address: address,
                                    index: index,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Edit",
                                      style: GoogleFonts.baloo2(
                                        color: const Color(0xff234C6A),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: const Color(0xff234C6A),
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                        // Bottom Section (Address)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            // color: Colors.grey.shade50,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            "${address['address']}",
                            style: GoogleFonts.baloo2(
                              fontSize: 13.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(String? type) {
    if (type == null) return Icons.home_outlined;
    switch (type.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'home':
      default:
        return Icons.home_outlined;
    }
  }
}
