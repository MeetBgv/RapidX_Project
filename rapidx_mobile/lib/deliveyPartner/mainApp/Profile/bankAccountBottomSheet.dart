import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';

void showBankAccountBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const BankAccountBottomSheet(),
  );
}

// Changed to ConsumerStatefulWidget
class BankAccountBottomSheet extends ConsumerStatefulWidget {
  const BankAccountBottomSheet({super.key});

  @override
  ConsumerState<BankAccountBottomSheet> createState() => _BankAccountBottomSheetState();
}

class _BankAccountBottomSheetState extends ConsumerState<BankAccountBottomSheet> {
  late TextEditingController _bankNameController;
  late TextEditingController _branchNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountHolderController;
  late TextEditingController _ifscController;
  String _accountType = "Savings";
  String _status = "Active";

  @override
  void initState() {
    super.initState();
    // Use ref.read to get initial state (no listening in initState)
    final dpState = ref.read(deliveryPartnerProvider);
    _bankNameController = TextEditingController(text: dpState.bankName);
    _branchNameController = TextEditingController(text: dpState.branchName);
    _accountNumberController = TextEditingController(text: dpState.accountNumber);
    _accountHolderController = TextEditingController(text: dpState.accountHolderName);
    _ifscController = TextEditingController(text: dpState.ifscCode);
    _accountType = dpState.accountType;
    _status = dpState.accountStatus;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _branchNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Bank Account Details",
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
                  child: const Icon(Icons.close, size: 26),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Bank Name"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _bankNameController,
                    hint: "Enter Bank Name",
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("Branch Name"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _branchNameController,
                    hint: "Enter Branch Name",
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("Account Number"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _accountNumberController,
                    hint: "Enter Account Number",
                    isNumber: true,
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("Account Type"),
                  SizedBox(height: 8.h),
                  // Dropdown/Selector for type
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _accountType,
                        isExpanded: true,
                        items: ["Savings", "Current"].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: GoogleFonts.baloo2(
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _accountType = newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("IFSC Code"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _ifscController,
                    hint: "Enter IFSC Code",
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("Account Holder Name"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _accountHolderController,
                    hint: "Enter Holder Name",
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("Account Status"),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: Text(
                      _status,
                      style: GoogleFonts.baloo2(
                        fontSize: 16.sp,
                        color: _status == "Active" ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff234C6A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  // Use ref.read to mutate state (Riverpod)
                  ref.read(deliveryPartnerProvider.notifier).updateBankAccount(
                    bank: _bankNameController.text,
                    branch: _branchNameController.text,
                    accNum: _accountNumberController.text,
                    type: _accountType,
                    ifsc: _ifscController.text,
                    holder: _accountHolderController.text,
                    status: _status,
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  "Save & Continue",
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.baloo2(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.baloo2(fontSize: 16.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
}
