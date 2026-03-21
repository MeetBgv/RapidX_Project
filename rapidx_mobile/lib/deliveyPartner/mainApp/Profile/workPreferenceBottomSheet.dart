import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';

void showWorkPreferenceBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const WorkPreferenceBottomSheet(),
  );
}

// Changed to ConsumerStatefulWidget
class WorkPreferenceBottomSheet extends ConsumerStatefulWidget {
  const WorkPreferenceBottomSheet({super.key});

  @override
  ConsumerState<WorkPreferenceBottomSheet> createState() =>
      _WorkPreferenceBottomSheetState();
}

class _WorkPreferenceBottomSheetState extends ConsumerState<WorkPreferenceBottomSheet> {
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  String _selectedSlot = "Morning (6AM - 2PM)";

  // Sample Slots
  final List<String> _slots = [
    "Morning (6AM - 2PM)",
    "Afternoon (2PM - 10PM)",
    "Night (10PM - 6AM)",
  ];

  @override
  void initState() {
    super.initState();
    // Use ref.read to get initial state (no listening in initState)
    final dpState = ref.read(deliveryPartnerProvider);
    _cityController = TextEditingController(text: dpState.city);
    _stateController = TextEditingController(text: dpState.state);
    _selectedSlot = dpState.timeSlot;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                      "Work Preference",
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
                  _buildSectionTitle("Preferred State"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _stateController,
                    hint: "Enter State",
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("Preferred City"),
                  SizedBox(height: 8.h),
                  _buildInputField(
                    controller: _cityController,
                    hint: "Enter City",
                  ),

                  SizedBox(height: 20.h),

                  _buildSectionTitle("Preferred Time Slot"),
                  SizedBox(height: 8.h),
                  // Dropdown/Selector for time slot
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSlot,
                        isExpanded: true,
                        items: _slots.map((String slot) {
                          return DropdownMenuItem<String>(
                            value: slot,
                            child: Text(
                              slot,
                              style: GoogleFonts.baloo2(
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSlot = newValue!;
                          });
                        },
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
                  ref.read(deliveryPartnerProvider.notifier).updateWorkPreference(
                    newState: _stateController.text,
                    newCity: _cityController.text,
                    newSlot: _selectedSlot,
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
}
