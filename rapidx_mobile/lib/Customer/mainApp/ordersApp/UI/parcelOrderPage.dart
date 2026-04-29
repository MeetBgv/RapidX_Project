import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:newrapidx/providers/userDataProvider.dart';
import 'package:newrapidx/Common/savedAddressesPage.dart';
import 'package:newrapidx/Common/mapPickerPage.dart';
import 'package:newrapidx/services/location_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'billingPage.dart';

class DropdownItem {
  final String name;
  final IconData icon;

  DropdownItem(this.name, this.icon);
}

class ParcelOrderPage extends StatefulWidget {
  const ParcelOrderPage({super.key});

  @override
  State<ParcelOrderPage> createState() => _ParcelOrderPageState();
}

class _ParcelOrderPageState extends State<ParcelOrderPage> {
  // Vehicle Types
  final List<DropdownItem> _vehicleTypes = [
    DropdownItem("Bike", Icons.directions_bike),
    DropdownItem("Mini Tempo", Icons.local_shipping),
    DropdownItem("Tempo", Icons.fire_truck),
  ];

  // Parcel Categories
  final List<DropdownItem> _parcelCategories = [
    DropdownItem("Document", Icons.description),
    DropdownItem("Electronics", Icons.devices),
    DropdownItem("Food", Icons.restaurant),
    DropdownItem("Grocery", Icons.local_grocery_store),
    DropdownItem("Clothing", Icons.checkroom),
    DropdownItem("Fragile", Icons.wine_bar),
    DropdownItem("Other", Icons.category),
  ];

  // Parcel Sizes
  final List<DropdownItem> _parcelSizes = [
    DropdownItem("Small", Icons.inbox),
    DropdownItem("Medium", Icons.kitchen),
    DropdownItem("Large", Icons.luggage),
    DropdownItem("Very Large", Icons.inventory),
  ];

  // Urgency Levels
  final List<DropdownItem> _urgencyLevels = [
    DropdownItem("Normal", Icons.local_shipping),
    DropdownItem("Express", Icons.flash_on),
    DropdownItem("Priority", Icons.star),
  ];

  String? _selectedSize;
  String? _selectedUrgency = "Normal";
  bool _isFetchingLocation = false;
  double _distanceKm = 0.0;
  
  // Weight Controller
  final TextEditingController _weightController = TextEditingController();

  /// Maximum delivery distance in kilometers
  static const double _maxDeliveryDistanceKm = 5000.0;

  // Sender controllers (pre-filled from provider)
  late TextEditingController _senderNameController;
  late TextEditingController _senderPhoneController;
  late TextEditingController _senderAddressController;
  late TextEditingController _senderCityController;
  late TextEditingController _senderStateController;
  late TextEditingController _senderPincodeController;

  // Receiver controllers
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController =
      TextEditingController();
  final TextEditingController _receiverAddressController =
      TextEditingController();
  final TextEditingController _receiverCityController = TextEditingController();
  final TextEditingController _receiverStateController =
      TextEditingController();
  final TextEditingController _receiverPincodeController =
      TextEditingController();

  final TextEditingController _specialInstructionController =
      TextEditingController();

  Future<void> _calculateDistance() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    final lat1 = provider.senderLat;
    final lon1 = provider.senderLng;
    final lat2 = provider.receiverLat;
    final lon2 = provider.receiverLng;

    if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
      try {
        final url = Uri.parse(
          "https://router.project-osrm.org/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=false",
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final meters = (data['routes'][0]['distance'] as num?)?.toDouble();
            if (meters != null) {
              if (mounted) {
                setState(() {
                  _distanceKm = meters / 1000.0;
                });
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching OSRM distance: $e");
      }
    }
  }

  /// Helper method to extract only the leftover address part
  String _getLeftoverAddress(String fullAddress, String city, String state, String pincode) {
    if (fullAddress.isEmpty) return '';
    
    String leftover = fullAddress;

    if (pincode.isNotEmpty) {
      leftover = leftover.replaceAll(RegExp(RegExp.escape(pincode), caseSensitive: false), '');
    }
    if (state.isNotEmpty) {
      leftover = leftover.replaceAll(RegExp(RegExp.escape(state), caseSensitive: false), '');
    }
    if (city.isNotEmpty) {
      leftover = leftover.replaceAll(RegExp(RegExp.escape(city), caseSensitive: false), '');
    }
    // Remove "India" if it's there
    leftover = leftover.replaceAll(RegExp(r'\bIndia\b', caseSensitive: false), '');

    // Clean up leftover commas and spaces
    List<String> parts = leftover.split(',');
    parts = parts.map((e) => e.trim()).where((e) => e.isNotEmpty && e != '-').toList();
    
    return parts.join(', ');
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDistance();
    });

    final provider = Provider.of<UserDataProvider>(context, listen: false);

    // Pre-fill sender data from provider (signup data)
    _senderNameController = TextEditingController(text: provider.rawUserName);
    _senderPhoneController = TextEditingController(
      text: provider.rawPhoneNumber,
    );
    _senderCityController = TextEditingController(text: provider.userCity);
    _senderStateController = TextEditingController(text: provider.userState);
    _senderPincodeController = TextEditingController(
      text: provider.userPincode,
    );
    _senderAddressController = TextEditingController(
      text: _getLeftoverAddress(
        provider.rawUserAddress,
        provider.userCity,
        provider.userState,
        provider.userPincode,
      ),
    );

    _receiverCityController.text = provider.receiverCity;
    _receiverStateController.text = provider.receiverState;
    _receiverPincodeController.text = provider.receiverPincode;
    
    String initialDropAddress = provider.receiverAddress.isNotEmpty 
        ? provider.receiverAddress 
        : provider.dropAddress;
    
    _receiverAddressController.text = _getLeftoverAddress(
      initialDropAddress,
      provider.receiverCity,
      provider.receiverState,
      provider.receiverPincode,
    );

    // Auto-detect sender location if address fields are empty
    if (_senderAddressController.text.isEmpty &&
        _senderCityController.text.isEmpty) {
      _autoDetectSenderLocation();
    }
  }

  /// Auto-detect sender's current GPS location and fill address fields
  Future<void> _autoDetectSenderLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      final result = await LocationService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          _senderCityController.text = result['city'] ?? '';
          _senderStateController.text = result['state'] ?? '';
          _senderPincodeController.text = result['pincode'] ?? '';
          
          String fullAddr = result['displayName'] ?? result['address'] ?? '';
          _senderAddressController.text = _getLeftoverAddress(
            fullAddr, 
            _senderCityController.text, 
            _senderStateController.text, 
            _senderPincodeController.text
          );
          
          _isFetchingLocation = false;
        });
        // Store coordinates in provider
        final provider = Provider.of<UserDataProvider>(context, listen: false);
        provider.setSenderCoordinates(position.latitude, position.longitude);
        _calculateDistance();
      }
    } catch (e) {
      debugPrint('Auto-detect location error: $e');
      if (mounted) {
        setState(() => _isFetchingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.baloo2(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderAddressController.dispose();
    _senderCityController.dispose();
    _senderStateController.dispose();
    _senderPincodeController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressController.dispose();
    _receiverCityController.dispose();
    _receiverStateController.dispose();
    _receiverPincodeController.dispose();
    _specialInstructionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Fill sender fields from a saved address
  void _fillSenderFromSavedAddress(Map<String, String> address) {
    setState(() {
      _senderNameController.text = address['name'] ?? '';
      _senderPhoneController.text = address['phone'] ?? '';
      _senderCityController.text = address['city'] ?? '';
      _senderStateController.text = address['state'] ?? '';
      _senderPincodeController.text = address['pincode'] ?? '';
      _senderAddressController.text = _getLeftoverAddress(
        address['address'] ?? '',
        _senderCityController.text,
        _senderStateController.text,
        _senderPincodeController.text
      );
    });
  }

  /// Fill receiver fields from a saved address
  void _fillReceiverFromSavedAddress(Map<String, String> address) {
    setState(() {
      _receiverNameController.text = address['name'] ?? '';
      _receiverPhoneController.text = address['phone'] ?? '';
      _receiverCityController.text = address['city'] ?? '';
      _receiverStateController.text = address['state'] ?? '';
      _receiverPincodeController.text = address['pincode'] ?? '';
      _receiverAddressController.text = _getLeftoverAddress(
        address['address'] ?? '',
        _receiverCityController.text,
        _receiverStateController.text,
        _receiverPincodeController.text
      );
    });
  }

  /// Fill sender fields from a map picker result
  void _fillSenderFromMap(Map<String, dynamic> result) {
    setState(() {
      _senderCityController.text = result['city'] ?? '';
      _senderStateController.text = result['state'] ?? '';
      _senderPincodeController.text = result['pincode'] ?? '';
      
      String passAddress = result['address'] ?? result['displayName'] ?? '';
      _senderAddressController.text = _getLeftoverAddress(
        passAddress,
        _senderCityController.text,
        _senderStateController.text,
        _senderPincodeController.text,
      );
    });
    // Also store coordinates in provider
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    provider.setSenderCoordinates(
      result['lat'] as double,
      result['lng'] as double,
    );
    _calculateDistance();
  }

  /// Calculate straight-line distance using Haversine formula.
  double _haversineDistance(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  /// Check if receiver location is within delivery range.
  /// Returns true if within range, false otherwise (shows popup).
  bool _isWithinDeliveryRange(double dropLat, double dropLng) {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    final senderLat = provider.senderLat;
    final senderLng = provider.senderLng;

    if (senderLat == null || senderLng == null) {
      return true;
    }

    final distance = _haversineDistance(senderLat, senderLng, dropLat, dropLng);

    if (distance > _maxDeliveryDistanceKm) {
      _showOutOfRangeDialog(distance);
      return false;
    }
    return true;
  }

  /// Show a styled popup informing the user the address is out of delivery range.
  void _showOutOfRangeDialog(double distanceKm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  color: Colors.red.shade400,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Out of Delivery Range",
                style: GoogleFonts.baloo2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff234C6A),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "The selected location is ${distanceKm.toStringAsFixed(0)} km away. We currently deliver within ${_maxDeliveryDistanceKm.toInt()} km only.",
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.4.h,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Please choose a closer drop location.",
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff234C6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Got it",
                    style: GoogleFonts.baloo2(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fill receiver fields from a map picker result.
  /// Returns false if the address was rejected due to distance.
  bool _fillReceiverFromMap(Map<String, dynamic> result) {
    final dropLat = (result['lat'] as num?)?.toDouble() ?? 0;
    final dropLng = (result['lng'] as num?)?.toDouble() ?? 0;

    if (!_isWithinDeliveryRange(dropLat, dropLng)) {
      return false; // Address rejected
    }

    setState(() {
      _receiverCityController.text = result['city'] ?? '';
      _receiverStateController.text = result['state'] ?? '';
      _receiverPincodeController.text = result['pincode'] ?? '';
      
      String passAddress = result['address'] ?? result['displayName'] ?? '';
      _receiverAddressController.text = _getLeftoverAddress(
        passAddress,
        _receiverCityController.text,
        _receiverStateController.text,
        _receiverPincodeController.text,
      );
    });
    // Also store coordinates in provider
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    provider.setReceiverCoordinates(dropLat, dropLng);
    _calculateDistance();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        appBar: AppBar(
          title: Text(
            "Order Details",
            style: GoogleFonts.baloo2(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // ================= BOTTOM PROCEED PAYMENT BUTTON =================
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
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
                backgroundColor: const Color(0xff234C6A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
                shadowColor: const Color(0xff234C6A).withOpacity(0.3),
              ),
              onPressed: () {
                if (_weightController.text.isEmpty ||
                    _selectedSize == null ||
                    _selectedUrgency == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Please enter Weight, Package Size, and Urgency",
                        style: GoogleFonts.baloo2(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final double? weight = double.tryParse(_weightController.text);
                if (weight == null || weight <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Please enter a valid positive weight in kg.",
                        style: GoogleFonts.baloo2(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (_receiverNameController.text.isEmpty ||
                    _receiverPhoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Please enter Receiver Name and Phone Number",
                        style: GoogleFonts.baloo2(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final provider = Provider.of<UserDataProvider>(
                  context,
                  listen: false,
                );

                // Save sender data to provider
                if (_senderNameController.text.isNotEmpty) {
                  provider.setUserName(_senderNameController.text.trim());
                }
                if (_senderPhoneController.text.isNotEmpty) {
                  provider.setPhoneNumber(_senderPhoneController.text.trim());
                }
                if (_senderAddressController.text.isNotEmpty) {
                  provider.setUserAddress(_senderAddressController.text.trim());
                }
                provider.setUserCity(_senderCityController.text.trim());
                provider.setUserState(_senderStateController.text.trim());
                provider.setUserPincode(_senderPincodeController.text.trim());

                String category = "";
                if (weight <= 0.5 && _selectedSize!.contains("Small")) {
                  category = "Document";
                } else if (weight <= 5) {
                  category = "Small Parcel";
                } else if (weight <= 20) {
                  category = "Medium Parcel";
                } else if (weight <= 100) {
                  category = "Large Parcel";
                } else {
                  category = "Heavy Goods";
                }

                String vehicle = "";
                if (category == "Document") vehicle = "Bike";
                else if (category == "Small Parcel") vehicle = "Bike";
                else if (category == "Medium Parcel") vehicle = "Mini Tempo";
                else if (category == "Large Parcel") vehicle = "Mini Tempo";
                else vehicle = "Tempo";
                
                provider.setVehicleType(vehicle);
                provider.setParcelCategory(category);
                provider.setParcelSize(_selectedSize!);
                provider.setWeight(weight);
                provider.setUrgency(_selectedUrgency!);
                
                provider.setSpecialInstructions(
                  _specialInstructionController.text,
                );
                provider.setReceiverDetails(
                  name: _receiverNameController.text.trim(),
                  mobile: _receiverPhoneController.text.trim(),
                  address: _receiverAddressController.text.trim(),
                  city: _receiverCityController.text.trim(),
                  state: _receiverStateController.text.trim(),
                  pincode: _receiverPincodeController.text.trim(),
                );

                // Navigate to Billing Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillingPage()),
                );
              },
              child: Text(
                "Proceed Billing",
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SENDER DETAILS =================
              _buildSectionCard(
                title: "Sender Details",
                trailing: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MapPickerPage(
                              title: "Sender Location",
                            ),
                          ),
                        );
                        if (result != null && result is Map) {
                          _fillSenderFromMap(
                            result.cast<String, dynamic>(),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 16.sp,
                            color: const Color(0xff56A3A6),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Map",
                            style: GoogleFonts.baloo2(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff56A3A6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavedAddressesPage(),
                          ),
                        );
                        if (result != null && result is Map<String, String>) {
                          _fillSenderFromSavedAddress(result);
                        }
                      },
                      child: Text(
                        "Saved",
                        style: GoogleFonts.baloo2(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff234C6A),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _senderNameController,
                      hint: "Sender's Name",
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    _buildInputField(
                      controller: _senderPhoneController,
                      hint: "Sender's Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 12.h),
                    Stack(
                      children: [
                        _buildInputField(
                          controller: _senderAddressController,
                          hint: _isFetchingLocation
                              ? "Detecting your location..."
                              : "Sender's Address",
                          icon: Icons.location_on_outlined,
                        ),
                        if (_isFetchingLocation)
                          Positioned(
                            right: 12.w,
                            top: 0.h,
                            bottom: 0.h,
                            child: Center(
                              child: SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xff56A3A6),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _senderCityController,
                            hint: "City",
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildInputField(
                            controller: _senderStateController,
                            hint: "State",
                            icon: Icons.map_outlined,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildInputField(
                      controller: _senderPincodeController,
                      hint: "Pincode",
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              // ================= RECEIVER DETAILS =================
              _buildSectionCard(
                title: "Receiver Details",
                trailing: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MapPickerPage(
                              title: "Receiver Location",
                            ),
                          ),
                        );
                        if (result != null && result is Map) {
                          _fillReceiverFromMap(
                            result.cast<String, dynamic>(),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 16.sp,
                            color: const Color(0xff56A3A6),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Map",
                            style: GoogleFonts.baloo2(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff56A3A6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavedAddressesPage(),
                          ),
                        );
                        if (result != null && result is Map<String, String>) {
                          _fillReceiverFromSavedAddress(result);
                        }
                      },
                      child: Text(
                        "Saved",
                        style: GoogleFonts.baloo2(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff234C6A),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _receiverNameController,
                      hint: "Receiver's Name",
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    _buildInputField(
                      controller: _receiverPhoneController,
                      hint: "Receiver's Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 12.h),
                    _buildInputField(
                      controller: _receiverAddressController,
                      hint: "Receiver's Address",
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _receiverCityController,
                            hint: "City",
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildInputField(
                            controller: _receiverStateController,
                            hint: "State",
                            icon: Icons.map_outlined,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildInputField(
                      controller: _receiverPincodeController,
                      hint: "Pincode",
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              // ================= PACKAGE CATEGORY =================
              _buildSectionCard(
                title: "Package Details",
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _weightController,
                      hint: "Weight (in kg)",
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(
                      hint: "Parcel Size",
                      value: _selectedSize,
                      items: _parcelSizes,
                      onChanged: (value) {
                        setState(() {
                          _selectedSize = value;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(
                      hint: "Delivery Urgency",
                      value: _selectedUrgency,
                      items: _urgencyLevels,
                      onChanged: (value) {
                        setState(() {
                          _selectedUrgency = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // ================= SPECIAL INSTRUCTION =================
              _buildSectionCard(
                title: "Special Instructions",
                child: TextField(
                  controller: _specialInstructionController,
                  maxLines: 3,
                  style: GoogleFonts.baloo2(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter any instructions for the rider...",
                    hintStyle: GoogleFonts.baloo2(
                      fontSize: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                    contentPadding: EdgeInsets.all(16.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Color(0xff56A3A6),
                        width: 1.5.w,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xffF8f9fa),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff234C6A),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownItem> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xffF8f9fa),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5.w),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          hint: Text(
            hint,
            style: GoogleFonts.baloo2(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade500,
            size: 24.sp,
          ),
          isExpanded: true,
          items: items.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.name,
              child: Row(
                children: [
                  Icon(item.icon, size: 20.sp, color: Colors.grey.shade600),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.baloo2(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: GoogleFonts.baloo2(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20.sp),
        hintText: hint,
        hintStyle: GoogleFonts.baloo2(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xff56A3A6), width: 1.5.w),
        ),
        filled: true,
        fillColor: const Color(0xffF8f9fa),
      ),
    );
  }
}
