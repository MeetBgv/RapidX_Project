import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  // ==================== USER DATA ====================
  String _phoneNumber = '';
  String _userName = '';
  String _userAddress = '';
  String _userCity = '';
  String _userState = '';
  String _userPincode = '';

  // ==================== ORDER DATA ====================
  String _pickupAddress = '';
  String _dropAddress = '';
  String _specialInstructions = '';
  String _vehicleType = '';
  String _parcelCategory = '';
  String _parcelSize = '';
  double _weight = 0.0;
  String _urgency = 'Normal';
  bool _isInCity = true;
  Map<String, dynamic> _fareBreakdown = {};

  // Receiver Data
  String _receiverName = '';
  String _receiverMobile = '';
  String _receiverAddress = '';
  String _receiverCity = '';
  String _receiverState = '';
  String _receiverPincode = '';

  // ==================== COORDINATES ====================
  double? _senderLat;
  double? _senderLng;
  double? _receiverLat;
  double? _receiverLng;

  // ==================== SAVED ADDRESSES ====================
  List<Map<String, String>> _savedAddresses = [];

  // ==================== GETTERS (display defaults) ====================
  String get phoneNumber =>
      _phoneNumber.isEmpty ? 'User phone number' : _phoneNumber;
  String get userName => _userName.isEmpty ? 'Username' : _userName;
  String get userAddress =>
      _userAddress.isEmpty ? 'User address' : _userAddress;
  String get userCity => _userCity;
  String get userState => _userState;
  String get userPincode => _userPincode;

  // Raw getters (return actual value, for form pre-fill)
  String get rawPhoneNumber => _phoneNumber;
  String get rawUserName => _userName;
  String get rawUserAddress => _userAddress;

  String get pickupAddress => _pickupAddress;
  String get dropAddress => _dropAddress;
  String get specialInstructions => _specialInstructions;
  String get vehicleType => _vehicleType;
  String get parcelCategory => _parcelCategory;
  String get parcelSize => _parcelSize;
  double get weight => _weight;
  String get urgency => _urgency;
  bool get isInCity => _isInCity;
  Map<String, dynamic> get fareBreakdown => _fareBreakdown;

  // Sender is the logged-in user
  String get senderName => _userName.isEmpty ? '' : _userName;
  String get senderMobile => _phoneNumber.isEmpty ? '' : _phoneNumber;
  String get senderAddress => _userAddress.isEmpty ? '' : _userAddress;
  String get senderCity => _userCity;
  String get senderState => _userState;
  String get senderPincode => _userPincode;

  // Receiver
  String get receiverName => _receiverName;
  String get receiverMobile => _receiverMobile;
  String get receiverAddress => _receiverAddress;
  String get receiverCity => _receiverCity;
  String get receiverState => _receiverState;
  String get receiverPincode => _receiverPincode;

  // Coordinates
  double? get senderLat => _senderLat;
  double? get senderLng => _senderLng;
  double? get receiverLat => _receiverLat;
  double? get receiverLng => _receiverLng;

  List<Map<String, String>> get savedAddresses => _savedAddresses;

  // ==================== SETTERS ====================
  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserAddress(String address) {
    _userAddress = address;
    notifyListeners();
  }

  void setUserCity(String city) {
    _userCity = city;
    notifyListeners();
  }

  void setUserState(String state) {
    _userState = state;
    notifyListeners();
  }

  void setUserPincode(String pincode) {
    _userPincode = pincode;
    notifyListeners();
  }

  void setPickupAddress(String address) {
    _pickupAddress = address;
    notifyListeners();
  }

  void setDropAddress(String address) {
    _dropAddress = address;
    notifyListeners();
  }

  void setSpecialInstructions(String instruction) {
    _specialInstructions = instruction;
    notifyListeners();
  }

  void setVehicleType(String type) {
    _vehicleType = type;
    notifyListeners();
  }

  void setParcelCategory(String category) {
    _parcelCategory = category;
    notifyListeners();
  }

  void setParcelSize(String size) {
    _parcelSize = size;
    notifyListeners();
  }

  void setWeight(double weight) {
    _weight = weight;
    notifyListeners();
  }

  void setUrgency(String urgency) {
    _urgency = urgency;
    notifyListeners();
  }

  void setIsInCity(bool isInCity) {
    _isInCity = isInCity;
    notifyListeners();
  }

  void setFareBreakdown(Map<String, dynamic> breakdown) {
    _fareBreakdown = breakdown;
    notifyListeners();
  }

  void setReceiverDetails({
    required String name,
    required String mobile,
    String address = '',
    String city = '',
    String state = '',
    String pincode = '',
  }) {
    _receiverName = name;
    _receiverMobile = mobile;
    _receiverAddress = address;
    _receiverCity = city;
    _receiverState = state;
    _receiverPincode = pincode;
    notifyListeners();
  }

  void addAddress(Map<String, String> address) {
    _savedAddresses.add(address);
    notifyListeners();
  }

  void editAddress(int index, Map<String, String> address) {
    if (index >= 0 && index < _savedAddresses.length) {
      _savedAddresses[index] = address;
      notifyListeners();
    }
  }

  // ==================== COORDINATE SETTERS ====================
  void setSenderCoordinates(double lat, double lng) {
    _senderLat = lat;
    _senderLng = lng;
    notifyListeners();
  }

  void setReceiverCoordinates(double lat, double lng) {
    _receiverLat = lat;
    _receiverLng = lng;
    notifyListeners();
  }

  /// Set full receiver location from map picker result.
  void setReceiverLocation({
    required double lat,
    required double lng,
    String address = '',
    String city = '',
    String state = '',
    String pincode = '',
  }) {
    _receiverLat = lat;
    _receiverLng = lng;
    _receiverAddress = address;
    _receiverCity = city;
    _receiverState = state;
    _receiverPincode = pincode;
    notifyListeners();
  }

  /// Set full sender location from map picker result.
  void setSenderLocation({
    required double lat,
    required double lng,
    String address = '',
    String city = '',
    String state = '',
    String pincode = '',
  }) {
    _senderLat = lat;
    _senderLng = lng;
    _userAddress = address;
    _userCity = city;
    _userState = state;
    _userPincode = pincode;
    notifyListeners();
  }
}
