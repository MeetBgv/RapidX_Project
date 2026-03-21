import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:provider/provider.dart' hide Consumer;
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';
import 'package:newrapidx/Common/showOtpBottomSheet.dart';
import 'package:newrapidx/deliveyPartner/mainApp/mainPageDP.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:newrapidx/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Changed to ConsumerStatefulWidget
class DeliveryPartnerSignUp extends ConsumerStatefulWidget {
  const DeliveryPartnerSignUp({super.key});

  @override
  ConsumerState<DeliveryPartnerSignUp> createState() => _DeliveryPartnerSignUpState();
}

class _DeliveryPartnerSignUpState extends ConsumerState<DeliveryPartnerSignUp> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  int get _totalSteps => _stepTitles.length;
  final ImagePicker _picker = ImagePicker();

  // Step 0: Personal Details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController documentNumberController =
      TextEditingController();
  String? _selectedDocumentType;
  File? _profilePicture;
  File? _licensePhoto;
  File? _documentPhoto;

  // Step 1: Vehicle Details
  final TextEditingController vehicleNumberController = TextEditingController();
  String? _selectedVehicleType;
  File? _rcBookPicture;

  // Step 2: Work Preferences
  final TextEditingController workingStateController = TextEditingController();
  final TextEditingController workingCityController = TextEditingController();
  final TextEditingController timeSlotController = TextEditingController();

  // Step 3: Bank Details
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController accountStatusController = TextEditingController();

  // Dropdown Options (from backend value_master)
  final List<String> _documentTypes = [
    "Aadhaar Card",
    "PAN Card",
    "Voter ID",
    "Passport",
  ];

  final List<String> _vehicleTypes = [
    "Bike",
    "Mini Tempo",
    "Tempo",
  ];

  final List<String> _timeSlots = [
    "Morning (6AM - 2PM)",
    "Afternoon (2PM - 10PM)",
    "Night (10PM - 6AM)",
  ];

  final List<String> _accountTypes = [
    "Savings",
    "Current",
  ];

  String? _selectedTimeSlot;
  String? _selectedAccountType;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    birthdateController.dispose();
    licenseNumberController.dispose();
    expiryDateController.dispose();
    documentNumberController.dispose();
    vehicleNumberController.dispose();
    workingStateController.dispose();
    workingCityController.dispose();
    timeSlotController.dispose();
    bankNameController.dispose();
    branchNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    accountHolderNameController.dispose();
    accountStatusController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2040),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff234C6A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  Future<File?> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  List<String> get _stepTitles => [
    "Personal & License Details",
    "Vehicle Details",
    "Work Preferences",
    "Bank Details",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SizedBox(
              width: 1.sw,
              child: Row(
                children: [
                  Stack(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep--);
                          } else {
                            Navigator.pop(context);
                          }
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
                            "Partner Sign Up",
                            style: GoogleFonts.baloo2(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff1E1E1E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Step Indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
              child: Column(
                children: [
                  Row(
                    children: List.generate(_totalSteps, (index) {
                      return Expanded(
                        child: Container(
                          height: 4.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? const Color(0xff234C6A)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Step ${_currentStep + 1} of $_totalSteps: ${_stepTitles[_currentStep]}",
                    style: GoogleFonts.baloo2(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                children: [
                  if (_currentStep == 0) ..._buildStep0(),
                  if (_currentStep == 1) ..._buildStep1(),
                  if (_currentStep == 2) ..._buildStep2(),
                  if (_currentStep == 3) ..._buildStep3(),
                ],
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff234C6A), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            setState(() => _currentStep--);
                          },
                          child: Text(
                            "Back",
                            style: GoogleFonts.baloo2(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff234C6A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 16.w),
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff234C6A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () async {
                          if (_currentStep < _totalSteps - 1) {
                            setState(() => _currentStep++);
                          } else {
                            // ── SUBMIT: call backend API directly ──
                            setState(() => _isSubmitting = true);

                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('auth_token') ?? '';

                              final response = await http.post(
                                Uri.parse('${ApiConstants.baseUrl}/users/delivery-partners/profile'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: jsonEncode({
                                  'birth_date': birthdateController.text.isEmpty ? null : birthdateController.text,
                                  'license_number': licenseNumberController.text,
                                  'expiry_date': expiryDateController.text.isEmpty ? null : expiryDateController.text,
                                  'document_type_name': _selectedDocumentType ?? 'Aadhaar Card',
                                  'document_number': documentNumberController.text,
                                  'vehicle_type_name': _selectedVehicleType ?? 'Bike',
                                  'vehicle_number': vehicleNumberController.text,
                                  'working_type_name': 'Full Time',
                                  'working_state': workingStateController.text,
                                  'working_city': workingCityController.text,
                                  'time_slot': _selectedTimeSlot ?? 'Morning (6AM - 2PM)',
                                  'bank_name': bankNameController.text,
                                  'branch_name': branchNameController.text,
                                  'account_number': accountNumberController.text,
                                  'account_holder_name': accountHolderNameController.text,
                                  'account_type': _selectedAccountType ?? 'Savings',
                                  'ifsc_code': ifscCodeController.text,
                                }),
                              );

                              setState(() => _isSubmitting = false);

                              if (response.statusCode == 201) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Profile saved successfully!'),
                                      backgroundColor: Color(0xff234C6A),
                                    ),
                                  );
                                }
                              } else {
                                debugPrint('❌ Profile save failed: ${response.body}');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Warning: Profile not saved (${response.statusCode}). Continuing anyway.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              setState(() => _isSubmitting = false);
                              debugPrint('❌ Error saving profile: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Network error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }

                            // Navigate to main DP page
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => mainPageDP()),
                                (route) => false,
                              );
                            }
                          }
                        },
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                          _currentStep < _totalSteps - 1
                              ? "Continue"
                              : "Submit",
                          style: GoogleFonts.baloo2(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================ STEP 0: Personal & License Details ================
  List<Widget> _buildStep0() {
    return [
      _buildDateField(
        controller: birthdateController,
        label: "Birthdate",
        onTap: () => _pickDate(birthdateController),
      ),
      SizedBox(height: 16.h),
      _buildImagePicker(
        label: "Profile Picture",
        file: _profilePicture,
        onTap: () async {
          final file = await _pickImage();
          if (file != null) setState(() => _profilePicture = file);
        },
      ),
      SizedBox(height: 16.h),
      _buildTextField(
        controller: licenseNumberController,
        hint: "License Number",
      ),
      SizedBox(height: 16.h),
      _buildDateField(
        controller: expiryDateController,
        label: "License Expiry Date",
        onTap: () => _pickDate(expiryDateController),
      ),
      SizedBox(height: 16.h),
      _buildImagePicker(
        label: "License Photo",
        file: _licensePhoto,
        onTap: () async {
          final file = await _pickImage();
          if (file != null) setState(() => _licensePhoto = file);
        },
      ),
      SizedBox(height: 16.h),
      _buildDropdownField(
        hint: "Document Type",
        value: _selectedDocumentType,
        items: _documentTypes,
        onChanged: (value) => setState(() => _selectedDocumentType = value),
      ),
      SizedBox(height: 16.h),
      _buildTextField(
        controller: documentNumberController,
        hint: "Document Number",
      ),
      SizedBox(height: 16.h),
      _buildImagePicker(
        label: "Document Photo",
        file: _documentPhoto,
        onTap: () async {
          final file = await _pickImage();
          if (file != null) setState(() => _documentPhoto = file);
        },
      ),
      SizedBox(height: 20.h),
    ];
  }

  // ================ STEP 1: Vehicle Details ================
  List<Widget> _buildStep1() {
    return [
      _buildDropdownField(
        hint: "Vehicle Type",
        value: _selectedVehicleType,
        items: _vehicleTypes,
        onChanged: (value) => setState(() => _selectedVehicleType = value),
      ),
      SizedBox(height: 16.h),
      _buildTextField(
        controller: vehicleNumberController,
        hint: "Vehicle Number",
      ),
      SizedBox(height: 16.h),
      _buildImagePicker(
        label: "RC Book Picture",
        file: _rcBookPicture,
        onTap: () async {
          final file = await _pickImage();
          if (file != null) setState(() => _rcBookPicture = file);
        },
      ),
      SizedBox(height: 20.h),
    ];
  }

  // ================ STEP 2: Work Preferences ================
  List<Widget> _buildStep2() {
    return [
      _buildTextField(
        controller: workingStateController,
        hint: "Working State",
      ),
      SizedBox(height: 16.h),
      _buildTextField(controller: workingCityController, hint: "Working City"),
      SizedBox(height: 16.h),
      _buildDropdownField(
        hint: "Preferred Time Slot",
        value: _selectedTimeSlot,
        items: _timeSlots,
        onChanged: (value) => setState(() => _selectedTimeSlot = value),
      ),
      SizedBox(height: 20.h),
    ];
  }

  // ================ STEP 3: Bank Details ================
  List<Widget> _buildStep3() {
    return [
      _buildTextField(controller: bankNameController, hint: "Bank Name"),
      SizedBox(height: 16.h),
      _buildTextField(controller: branchNameController, hint: "Branch Name"),
      SizedBox(height: 16.h),
      _buildTextField(
        controller: accountNumberController,
        hint: "Account Number",
        keyboardType: TextInputType.number,
      ),
      SizedBox(height: 16.h),
      _buildDropdownField(
        hint: "Account Type",
        value: _selectedAccountType,
        items: _accountTypes,
        onChanged: (value) => setState(() => _selectedAccountType = value),
      ),
      SizedBox(height: 16.h),
      _buildTextField(controller: ifscCodeController, hint: "IFSC Code"),
      SizedBox(height: 16.h),
      _buildTextField(
        controller: accountHolderNameController,
        hint: "Account Holder Name",
      ),
      SizedBox(height: 16.h),
      _buildTextField(
        controller: accountStatusController,
        hint: "Account Status",
      ),
      SizedBox(height: 20.h),
    ];
  }

  // ================ REUSABLE WIDGETS ================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.baloo2(fontSize: 16.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xff234C6A), width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.baloo2(fontSize: 16.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600, size: 20.sp),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xff234C6A), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.baloo2(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: file != null ? const Color(0xff234C6A).withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: file != null ? const Color(0xff234C6A) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                file != null ? file.path.split('/').last : label,
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  color: file != null ? const Color(0xff234C6A) : Colors.grey.shade500,
                  fontWeight: file != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              file != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
              color: file != null ? const Color(0xff234C6A) : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}

/// A wrapper widget that automatically submits the delivery partner profile
/// to the backend API when navigated to (after OTP validation).
/// On success or failure, it immediately navigates to mainPageDP.
class _SubmitWrapper extends StatefulWidget {
  final String birthDate;
  final String licenseNumber;
  final String expiryDate;
  final String documentTypeName;
  final String documentNumber;
  final String vehicleTypeName;
  final String vehicleNumber;
  final String workingTypeName;
  final String workingState;
  final String workingCity;
  final String timeSlot;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String accountHolderName;
  final String accountType;
  final String ifscCode;

  const _SubmitWrapper({
    required this.birthDate,
    required this.licenseNumber,
    required this.expiryDate,
    required this.documentTypeName,
    required this.documentNumber,
    required this.vehicleTypeName,
    required this.vehicleNumber,
    required this.workingTypeName,
    required this.workingState,
    required this.workingCity,
    required this.timeSlot,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.accountType,
    required this.ifscCode,
  });

  @override
  State<_SubmitWrapper> createState() => _SubmitWrapperState();
}

class _SubmitWrapperState extends State<_SubmitWrapper> {
  @override
  void initState() {
    super.initState();
    _submitAndNavigate();
  }

  Future<void> _submitAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/delivery-partners/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'birth_date': widget.birthDate.isEmpty ? null : widget.birthDate,
          'license_number': widget.licenseNumber,
          'expiry_date': widget.expiryDate.isEmpty ? null : widget.expiryDate,
          'document_type_name': widget.documentTypeName,
          'document_number': widget.documentNumber,
          'vehicle_type_name': widget.vehicleTypeName,
          'vehicle_number': widget.vehicleNumber,
          'working_type_name': widget.workingTypeName,
          'working_state': widget.workingState,
          'working_city': widget.workingCity,
          'time_slot': widget.timeSlot,
          'bank_name': widget.bankName,
          'branch_name': widget.branchName,
          'account_number': widget.accountNumber,
          'account_holder_name': widget.accountHolderName,
          'account_type': widget.accountType,
          'ifsc_code': widget.ifscCode,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('✅ Delivery partner profile created successfully');
      } else {
        debugPrint('❌ Failed to create profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error submitting profile: $e');
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => mainPageDP()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff234C6A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Setting up your profile...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
