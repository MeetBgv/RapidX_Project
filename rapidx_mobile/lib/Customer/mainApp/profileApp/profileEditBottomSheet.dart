import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showProfileEditBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ProfileEditBottomSheet(),
  );
}

class ProfileEditBottomSheet extends StatefulWidget {
  const ProfileEditBottomSheet({super.key});

  @override
  State<ProfileEditBottomSheet> createState() => _ProfileEditBottomSheetState();
}

class _ProfileEditBottomSheetState extends State<ProfileEditBottomSheet> {
  final TextEditingController firstNameController = TextEditingController(
    text: "Meet",
  );

  final TextEditingController lastNameController = TextEditingController(
    text: "Bhagvakar",
  );

  final TextEditingController phoneController = TextEditingController(
    text: "8160319283",
  );

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),

      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),

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
                      "View & Edit Your Profile",
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
                  child: Icon(Icons.close, size: 26.sp),
                ),
              ],
            ),

            SizedBox(height: 30.h),

            // Name Label
            Text(
              "Name",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 10.h),

            // First Name
            buildInputField(
              controller: firstNameController,
              hint: "First Name",
            ),

            SizedBox(height: 12.h),

            // Last Name
            buildInputField(controller: lastNameController, hint: "Last Name"),

            SizedBox(height: 25.h),

            // Phone Label
            Text(
              "Phone Number",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 10.h),

            // Phone
            buildInputField(
              controller: phoneController,
              hint: "Phone Number",
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  print("Saved:");
                  print(firstNameController.text);
                  print(lastNameController.text);
                  print(phoneController.text);

                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff234C6A),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),

                child: Text(
                  "Save Changes",
                  style: GoogleFonts.baloo2(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable TextField
  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,

      style: GoogleFonts.baloo2(fontSize: 15.sp, fontWeight: FontWeight.w500),

      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        filled: true,
        fillColor: Colors.grey.shade50,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.w),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Color(0xff234C6A), width: 1.5.w),
        ),

        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}
