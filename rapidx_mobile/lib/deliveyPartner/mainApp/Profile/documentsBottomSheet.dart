import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';

void showDocumentsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const DocumentsBottomSheet(),
  );
}

// Changed to ConsumerStatefulWidget
class DocumentsBottomSheet extends ConsumerStatefulWidget {
  const DocumentsBottomSheet({super.key});

  @override
  ConsumerState<DocumentsBottomSheet> createState() => _DocumentsBottomSheetState();
}

class _DocumentsBottomSheetState extends ConsumerState<DocumentsBottomSheet> {
  late TextEditingController _docNumberController;
  late TextEditingController _vehicleNumberController;

  @override
  void initState() {
    super.initState();
    // Use ref.read to get initial state (no listening in initState)
    final dpState = ref.read(deliveryPartnerProvider);
    _docNumberController = TextEditingController(text: dpState.docNumber);
    _vehicleNumberController = TextEditingController(text: dpState.vehicleNumber);
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch state reactively for UI updates
    final dpState = ref.watch(deliveryPartnerProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          // Drag Handle
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

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      dpState.docType.isEmpty
                          ? "Documents"
                          : dpState.docType,
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
                  // 1st Card for Doc Number
                  _buildSectionTitle("Document Number"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _docNumberController,
                    hint: "Enter ${dpState.docType} Number",
                  ),

                  SizedBox(height: 20.h),

                  // 2nd for Doc Photo
                  _buildSectionTitle("Document Photo"),
                  SizedBox(height: 8.h),
                  _buildUploadCard("Upload ${dpState.docType}"),

                  SizedBox(height: 20.h),

                  // 3rd Vehicle
                  _buildSectionTitle("Vehicle Type"),
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
                      dpState.vehicleType,
                      style: GoogleFonts.baloo2(
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 4th Vehicle Number
                  _buildSectionTitle("Vehicle Number"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _vehicleNumberController,
                    hint: "Enter Vehicle Number",
                  ),

                  SizedBox(height: 20.h),

                  // 5th RC Book
                  _buildSectionTitle("RC Book"),
                  SizedBox(height: 8.h),
                  _buildUploadCard("Upload RC Book"),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          // Bottom Button
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
                  // Save logic using Riverpod
                  ref.read(deliveryPartnerProvider.notifier).updateDocuments(
                    type: dpState.docType,
                    number: _docNumberController.text,
                    vehicle: dpState.vehicleType,
                    vehicleNum: _vehicleNumberController.text,
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
  }) {
    return TextField(
      controller: controller,
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

  Widget _buildUploadCard(String label) {
    return Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 40.sp, color: const Color(0xff234C6A)),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
