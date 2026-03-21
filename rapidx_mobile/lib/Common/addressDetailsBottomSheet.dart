import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/providers/userDataProvider.dart';

/// Function to show the bottom sheet.
/// [address] and [index] are optional. If provided, the sheet opens in Edit mode.
void showAddressDetailsBottomSheet(
  BuildContext context, {
  Map<String, String>? address,
  int? index,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddressDetailsBottomSheet(address: address, index: index),
  );
}

class AddressDetailsBottomSheet extends StatefulWidget {
  final Map<String, String>? address;
  final int? index;

  const AddressDetailsBottomSheet({super.key, this.address, this.index});

  @override
  State<AddressDetailsBottomSheet> createState() => _AddressDetailsBottomSheetState();
}

class _AddressDetailsBottomSheetState extends State<AddressDetailsBottomSheet> {
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _name2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  String _selectedType = 'Home'; // Default

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    final provider = Provider.of<UserDataProvider>(context, listen: false);

    _selectedType = address != null ? (address['type'] ?? 'Home') : 'Home';

    if (address != null) {
      // Editing existing address — use address data
      final fullName = address['name'] ?? "";
      final nameParts = fullName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : "";
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

      _nameController = TextEditingController(text: firstName);
      _name2Controller = TextEditingController(text: lastName);
      _phoneController = TextEditingController(text: address['phone'] ?? "");
      _streetController = TextEditingController(text: address['details'] ?? "");
      _areaController = TextEditingController(text: address['area'] ?? "");
      _cityController = TextEditingController(text: address['city'] ?? "");
      _stateController = TextEditingController(text: address['state'] ?? "");
      _pincodeController = TextEditingController(text: address['pincode'] ?? "");
    } else {
      // Adding new address — pre-fill name & phone from provider (signup data)
      final rawName = provider.rawUserName;
      final nameParts = rawName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : "";
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

      _nameController = TextEditingController(text: firstName);
      _name2Controller = TextEditingController(text: lastName);
      _phoneController = TextEditingController(text: provider.rawPhoneNumber);
      _streetController = TextEditingController(text: "");
      _areaController = TextEditingController(text: "");
      _cityController = TextEditingController(text: provider.userCity);
      _stateController = TextEditingController(text: provider.userState);
      _pincodeController = TextEditingController(text: provider.userPincode);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _name2Controller.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.6.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 10.h, 
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Drag handle
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.index != null ? "Edit Address" : "Add Address",
                      style: GoogleFonts.baloo2(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff234C6A),
                      ),
                    ),
                    Text(
                      widget.index != null
                          ? "Update your saved address details"
                          : "Add a new address",
                      style: GoogleFonts.baloo2(
                        fontSize: 12.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                   child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.close, size: 20.sp, color: Colors.black)
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Address Type Chips
            Text(
              "Address Type",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xff234C6A),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildTypeChip("Home"),
                SizedBox(width: 10.w),
                _buildTypeChip("Work"),
                SizedBox(width: 10.w),
                _buildTypeChip("Other"),
              ],
            ),
            SizedBox(height: 16.h),

            // Name Fields
            Text(
              "Name",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h),
            _buildTextField(_nameController, "First Name"),
            SizedBox(height: 8.h),
            _buildTextField(_name2Controller, "Last Name"),
            SizedBox(height: 16.h),

            // Phone Number
            Text(
              "Phone Number",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h),
            _buildTextField(
              _phoneController, 
              "Phone Number",
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 16.h),

            // Street / Building
            Text(
              "Street/ Building",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h),
            _buildTextField(_streetController, ""),
            SizedBox(height: 16.h),

            // Area / Locality
            Text(
              "Area/ Locality",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h),
            _buildTextField(_areaController, ""),
            SizedBox(height: 16.h),

            // City & State Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "City",
                        style: GoogleFonts.baloo2(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      _buildTextField(_cityController, ""),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "State",
                        style: GoogleFonts.baloo2(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      _buildTextField(_stateController, ""),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Pincode
            Text(
              "Pincode",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h),
            _buildTextField(_pincodeController, ""),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.baloo2(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff234C6A),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Save Address",
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
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    bool isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff234C6A) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xff234C6A) : Colors.black,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: GoogleFonts.baloo2(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade400, fontSize: 14.sp),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xff234C6A), width: 1.5),
        ),
      ),
    );
  }

  void _saveAddress() {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    
    String fullName = _nameController.text.trim();
    if (_name2Controller.text.isNotEmpty) {
      fullName += " ${_name2Controller.text.trim()}";
    }

    String fullAddress = "";
    if (_streetController.text.isNotEmpty) fullAddress += "${_streetController.text}, ";
    if (_areaController.text.isNotEmpty) fullAddress += "${_areaController.text}, ";
    if (_cityController.text.isNotEmpty) fullAddress += "${_cityController.text}, ";
    if (_stateController.text.isNotEmpty) fullAddress += "${_stateController.text}, ";
    if (_pincodeController.text.isNotEmpty) fullAddress += _pincodeController.text;

    if (fullAddress.isEmpty) fullAddress = "No Address Provided";

    final newAddress = {
      'type': _selectedType,
      'address': fullAddress, 
      'details': _streetController.text,
      'area': _areaController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      'name': fullName,
      'phone': _phoneController.text,
    };

    if (widget.index != null) {
      provider.editAddress(widget.index!, newAddress);
    } else {
      provider.addAddress(newAddress);
    }

    // Sync name, phone, address, city, state, pincode to the main user data
    if (fullName.isNotEmpty) {
      provider.setUserName(fullName);
    }
    if (_phoneController.text.isNotEmpty) {
      provider.setPhoneNumber(_phoneController.text);
    }
    if (fullAddress != "No Address Provided") {
      provider.setUserAddress(fullAddress);
    }
    provider.setUserCity(_cityController.text.trim());
    provider.setUserState(_stateController.text.trim());
    provider.setUserPincode(_pincodeController.text.trim());

    Navigator.pop(context);
  }
}
