import 'package:flutter/material.dart';

class DeliveryPartnerProvider extends ChangeNotifier {
  // Personal Details
  String name = "Delivery Partner";
  String phone = "+91 9876543210";
  String birthDate = "";
  String licenseNumber = "";
  String licenseExpiryDate = "";
  String profilePicturePath = "";
  String licensePhotoPath = "";
  String documentPhotoPath = "";
  String rcBookPhotoPath = "";

  // Documents
  String docType = "Driving License";
  String docNumber = "";
  String vehicleType = "Two Wheeler";
  String vehicleNumber = "";

  void updatePersonalDetails({
    required String newName,
    required String newPhone,
    required String newDob,
    required String newLicenseNo,
    required String newExpiry,
    String? profilePath,
    String? licensePath,
    String? docPath,
    String? rcPath,
  }) {
    name = newName;
    phone = newPhone;
    birthDate = newDob;
    licenseNumber = newLicenseNo;
    licenseExpiryDate = newExpiry;
    if (profilePath != null) profilePicturePath = profilePath;
    if (licensePath != null) licensePhotoPath = licensePath;
    if (docPath != null) documentPhotoPath = docPath;
    if (rcPath != null) rcBookPhotoPath = rcPath;
    notifyListeners();
  }
  
  // Work Preference
  String state = "";
  String city = "";
  String timeSlot = "Morning (6AM - 2PM)";

  // Bank Account
  String bankName = "";
  String branchName = "";
  String accountNumber = "";
  String accountType = "Savings";
  String ifscCode = "";
  String accountHolderName = "";
  String accountStatus = "Active";

  void updateDocuments({
    required String type,
    required String number,
    required String vehicle,
    required String vehicleNum,
    String? docPath,
    String? rcPath,
  }) {
    docType = type;
    docNumber = number;
    vehicleType = vehicle;
    vehicleNumber = vehicleNum;
    if (docPath != null) documentPhotoPath = docPath;
    if (rcPath != null) rcBookPhotoPath = rcPath;
    notifyListeners();
  }

  void setName(String newName) {
    name = newName;
    notifyListeners();
  }

  void setPhone(String newPhone) {
    phone = newPhone;
    notifyListeners();
  }

  void setProfilePicturePath(String path) {
    profilePicturePath = path;
    notifyListeners();
  }

  void updateWorkPreference({
    required String newState,
    required String newCity,
    required String newSlot,
  }) {
    state = newState;
    city = newCity;
    timeSlot = newSlot;
    notifyListeners();
  }

  void updateBankAccount({
    required String bank,
    required String branch,
    required String accNum,
    required String type,
    required String ifsc,
    required String holder,
    required String status,
  }) {
    bankName = bank;
    branchName = branch;
    accountNumber = accNum;
    accountType = type;
    ifscCode = ifsc;
    accountHolderName = holder;
    accountStatus = status;
    notifyListeners();
  }
}
