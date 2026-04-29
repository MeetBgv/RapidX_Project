import 'package:flutter/material.dart';
import 'dart:io' as java_io;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newrapidx/Common/CommonLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/Common/updateChecker.dart';
import 'package:newrapidx/Common/myComplaintsPage.dart';
import 'package:newrapidx/Common/complaintDialog.dart';

import '../../theme/dp_theme.dart';
import 'helpBottomSheetDP.dart';
import 'privacyPolicyBottomSheetDP.dart';
import 'termsAndConditionsBottomSheetDP.dart';
import 'documentsBottomSheet.dart';
import 'workPreferenceBottomSheet.dart';
import 'bankAccountBottomSheet.dart';

// Changed to ConsumerWidget for Riverpod
class ProfilePageDP extends ConsumerWidget {
  const ProfilePageDP({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the Riverpod state reactively
    final dpState = ref.watch(deliveryPartnerProvider);

    return Scaffold(
      backgroundColor: DPColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(context, ref, dpState),
              SizedBox(height: 32.h),

              Text(
                "Account",
                style: DPTheme.h3.copyWith(
                  fontSize: 16.sp,
                  color: DPColors.greyDark,
                ),
              ),
              SizedBox(height: 12.h),

              _buildMenuSection([
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: "Documents",
                  onTap: () => showDocumentsBottomSheet(context),
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Icons.work_outline,
                  title: "Work Preference",
                  onTap: () => showWorkPreferenceBottomSheet(context),
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_outlined,
                  title: "Bank Account",
                  onTap: () => showBankAccountBottomSheet(context),
                  showDivider: false,
                ),
              ]),

              SizedBox(height: 24.h),
              Text(
                "Support & Legal",
                style: DPTheme.h3.copyWith(
                  fontSize: 16.sp,
                  color: DPColors.greyDark,
                ),
              ),
              SizedBox(height: 12.h),

              _buildMenuSection([
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: "Help & FAQs",
                  onTap: () => showHelpSupportBottomSheetDP(context),
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Icons.gavel_outlined,
                  title: "Terms & Conditions",
                  onTap: () => showTermsBottomSheetDP(context),
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                  onTap: () => showPrivacyPolicyBottomSheetDP(context),
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Icons.system_update_outlined,
                  title: "Check for Updates",
                  onTap: () => UpdateChecker.checkForUpdates(context),
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Icons.add_comment_outlined,
                  title: "Raise Complaint",
                  onTap: () {
                    showComplaintBottomSheet(context);
                  },
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Icons.report_problem_outlined,
                  title: "My Complaints",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyComplaintsPage()));
                  },
                  showDivider: false,
                ),
              ]),

              SizedBox(height: 32.h),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    backgroundColor: DPColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(
                        color: DPColors.errorRed.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Text(
                    "Log Out",
                    style: DPTheme.buttonText.copyWith(
                      color: DPColors.errorRed,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  "v1.0.0",
                  style: DPTheme.bodySmall.copyWith(color: DPColors.greyMedium),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    DeliveryPartnerState dpState,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: DPColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DPColors.greyExtraLight,
                      image: dpState.profilePicturePath.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(
                                java_io.File(dpState.profilePicturePath),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: dpState.profilePicturePath.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 32.sp,
                            color: DPColors.greyMedium,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showImagePickerOptions(context, ref),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DPColors.deepBlue,
                          border: Border.all(color: DPColors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 12.sp,
                          color: DPColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dpState.name,
                      style: DPTheme.h2.copyWith(fontSize: 20.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dpState.phone,
                      style: DPTheme.body.copyWith(color: DPColors.greyMedium),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditNameDialog(context, ref, dpState),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20.sp,
                  color: DPColors.deepBlue,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: DPColors.greyExtraLight,
                  padding: EdgeInsets.all(8.w),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: DPColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Change Profile Photo", style: DPTheme.h3),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    label: "Camera",
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(ref, ImageSource.camera);
                    },
                  ),
                  _buildImagePickerOption(
                    context: context,
                    icon: Icons.photo_library_outlined,
                    label: "Gallery",
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(ref, ImageSource.gallery);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: DPColors.greyExtraLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28.sp, color: DPColors.deepBlue),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: DPTheme.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        ref.read(deliveryPartnerProvider.notifier).setProfilePicturePath(image.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Widget _buildMenuSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: DPColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: DPColors.greyLight.withOpacity(0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: DPColors.deepBlue, size: 22.sp),
          title: Text(
            title,
            style: DPTheme.body.copyWith(fontWeight: FontWeight.w500),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 20.sp,
            color: DPColors.greyMedium,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          visualDensity: VisualDensity.compact,
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: DPColors.greyExtraLight,
            indent: 56.w,
            endIndent: 16.w,
          ),
      ],
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    DeliveryPartnerState dpState,
  ) {
    TextEditingController nameController = TextEditingController(
      text: dpState.name,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: DPColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text("Edit Name", style: DPTheme.h3),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter your name",
              filled: true,
              fillColor: DPColors.greyExtraLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: DPColors.greyMedium),
              ),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(deliveryPartnerProvider.notifier).setName(nameController.text);
                }
                Navigator.pop(context);
              },
              child: Text(
                "Save",
                style: TextStyle(
                  color: DPColors.deepBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: DPColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text("Log Out", style: DPTheme.h3),
          content: Text(
            "Are you sure you want to log out?",
            style: DPTheme.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: DPColors.greyMedium),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Clear persistent storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const customerLogin(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                "Log Out",
                style: TextStyle(
                  color: DPColors.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
