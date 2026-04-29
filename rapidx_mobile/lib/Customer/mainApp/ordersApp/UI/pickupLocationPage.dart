import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/Common/savedAddressesPage.dart';
import 'package:newrapidx/Common/mapPickerPage.dart';
import 'package:newrapidx/services/nominatim_service.dart';

/// Page for selecting or entering the pickup location.
/// Users can enter text manually, select from map (future), or choose from saved addresses.
class PickupLocationPage extends StatefulWidget {
  const PickupLocationPage({super.key});

  @override
  State<PickupLocationPage> createState() => _PickupLocationPageState();
}

class _PickupLocationPageState extends State<PickupLocationPage> {
  // Controller for the pickup location input field
  final TextEditingController _pickupLocationController =
      TextEditingController();
  List<NominatimPlace> _results = [];
  bool _isSearching = false;
  Map<String, dynamic>? _selectedLocationData;

  @override
  void dispose() {
    // Dipose controller to free resources
    _pickupLocationController.dispose();
    NominatimService.cancelSearch();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _selectedLocationData = null;
    }); // Update UI for clear icon
    if (query.trim().length < 3) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
      }
      return;
    }

    setState(() => _isSearching = true);

    NominatimService.debouncedSearch(query, (results) {
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Back button to return to previous screen
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
        ),
        title: Text(
          "Pickup Location",
          style: GoogleFonts.baloo2(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      // ================= BOTTOM CONFIRM BUTTON =================
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff234C6A), // Dark blue background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
              shadowColor: const Color(0xff234C6A).withOpacity(0.3),
            ),
            onPressed: () {
              if (_selectedLocationData != null) {
                Navigator.pop(context, _selectedLocationData);
              } else {
                Navigator.pop(context, _pickupLocationController.text);
              }
            },
            child: Text(
              "Confirm and proceed",
              style: GoogleFonts.baloo2(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      // ================= MAIN BODY =================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
          children: [
            // Input Container with shadow and rounded corners
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                // Shadow effect
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Pickup Location Input Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        // Green dot indicator for Pickup
                        Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // Vertical Divider line
                        Container(
                          width: 1.w,
                          height: 24.h,
                          color: Colors.grey.shade200,
                        ),

                        SizedBox(width: 12.w),

                        // Text Input Field for Address
                        Expanded(
                          child: TextField(
                            controller: _pickupLocationController,
                            onChanged: _onSearchChanged,
                            style: GoogleFonts.baloo2(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: "Where is your PickUp ?",
                              hintStyle: GoogleFonts.baloo2(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                              ),
                              // Microphone or Close icon
                              suffixIcon: _pickupLocationController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _pickupLocationController.clear();
                                        _onSearchChanged('');
                                        FocusScope.of(context).requestFocus(FocusNode());
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.grey.shade400,
                                        size: 20.sp,
                                      ),
                                    )
                                  : Icon(
                                      Icons.mic_none_outlined,
                                      color: const Color(0xff234C6A), // Dark blue color
                                      size: 20.sp,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Horizontal Divider
                  Divider(height: 1.h, color: Colors.grey.shade100),

                  SizedBox(height: 16.h),

                  // Action Buttons Row (Map & Saved Addresses)
                  Row(
                    children: [
                      // Select on map Button (Placeholder)
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MapPickerPage(
                                  title: "Pickup Location",
                                ),
                              ),
                            );
                            if (result != null && result is Map) {
                              setState(() {
                                _pickupLocationController.text =
                                    result['address'] ?? '';
                                _selectedLocationData = result.cast<String, dynamic>();
                              });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18.sp,
                                color: const Color(0xff234C6A),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Select on map",
                                style: GoogleFonts.baloo2(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff234C6A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Vertical Divider between buttons
                      Container(
                        height: 24.h,
                        width: 1.w,
                        color: Colors.grey.shade200,
                      ),

                      // Saved Addresses Button
                      Expanded(
                        child: InkWell(
                          // Navigate to Saved Addresses Page
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SavedAddressesPage(),
                              ),
                            );

                            // Update controller if an address was selected and returned
                            if (result != null && result is Map) {
                              setState(() {
                                _pickupLocationController.text =
                                    "${result['details']}, ${result['address']}";
                                _selectedLocationData = {
                                  'address': result['details'] ?? result['address'],
                                  'displayName': "${result['details']}, ${result['address']}",
                                };
                              });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 18.sp,
                                color: const Color(0xff234C6A),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Saved Addresses",
                                style: GoogleFonts.baloo2(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff234C6A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Results
            if (_isSearching)
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: const CircularProgressIndicator(
                  color: Color(0xff56A3A6),
                  strokeWidth: 2.5,
                ),
              ),
            if (!_isSearching && _results.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => Divider(height: 1.h, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final place = _results[index];
                    final parts = place.displayName.split(', ');
                    final primary = parts.isNotEmpty ? parts.first : place.displayName;
                    final secondary = parts.length > 1 ? parts.sublist(1).join(', ') : '';

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLocationData = {
                            'address': place.address,
                            'city': place.city,
                            'state': place.state,
                            'pincode': place.pincode,
                            'lat': place.lat,
                            'lng': place.lng,
                            'displayName': place.displayName,
                          };
                          _pickupLocationController.text = place.displayName;
                          _results = [];
                        });
                        FocusScope.of(context).unfocus();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: const Color(0xff234C6A).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: const Color(0xff234C6A),
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    primary,
                                    style: GoogleFonts.baloo2(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (secondary.isNotEmpty)
                                    Text(
                                      secondary,
                                      style: GoogleFonts.baloo2(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade500,
                                        height: 1.3.h,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.north_east,
                              color: Colors.grey.shade300,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
