import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== STATE CLASS ====================
class DeliveryPartnerState {
  final String name;
  final String phone;
  final String birthDate;
  final String licenseNumber;
  final String licenseExpiryDate;
  final String profilePicturePath;
  final String licensePhotoPath;
  final String documentPhotoPath;
  final String rcBookPhotoPath;

  // Documents
  final String docType;
  final String docNumber;
  final String vehicleType;
  final String vehicleNumber;

  // Work Preference
  final String state;
  final String city;
  final String timeSlot;

  // Bank Account
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String accountType;
  final String ifscCode;
  final String accountHolderName;
  final String accountStatus;

  const DeliveryPartnerState({
    this.name = "Delivery Partner",
    this.phone = "+91 9876543210",
    this.birthDate = "",
    this.licenseNumber = "",
    this.licenseExpiryDate = "",
    this.profilePicturePath = "",
    this.licensePhotoPath = "",
    this.documentPhotoPath = "",
    this.rcBookPhotoPath = "",
    this.docType = "Driving License",
    this.docNumber = "",
    this.vehicleType = "Two Wheeler",
    this.vehicleNumber = "",
    this.state = "",
    this.city = "",
    this.timeSlot = "Morning (6AM - 2PM)",
    this.bankName = "",
    this.branchName = "",
    this.accountNumber = "",
    this.accountType = "Savings",
    this.ifscCode = "",
    this.accountHolderName = "",
    this.accountStatus = "Active",
  });

  DeliveryPartnerState copyWith({
    String? name,
    String? phone,
    String? birthDate,
    String? licenseNumber,
    String? licenseExpiryDate,
    String? profilePicturePath,
    String? licensePhotoPath,
    String? documentPhotoPath,
    String? rcBookPhotoPath,
    String? docType,
    String? docNumber,
    String? vehicleType,
    String? vehicleNumber,
    String? state,
    String? city,
    String? timeSlot,
    String? bankName,
    String? branchName,
    String? accountNumber,
    String? accountType,
    String? ifscCode,
    String? accountHolderName,
    String? accountStatus,
  }) {
    return DeliveryPartnerState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      licensePhotoPath: licensePhotoPath ?? this.licensePhotoPath,
      documentPhotoPath: documentPhotoPath ?? this.documentPhotoPath,
      rcBookPhotoPath: rcBookPhotoPath ?? this.rcBookPhotoPath,
      docType: docType ?? this.docType,
      docNumber: docNumber ?? this.docNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      state: state ?? this.state,
      city: city ?? this.city,
      timeSlot: timeSlot ?? this.timeSlot,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }
}

// ==================== STATE NOTIFIER ====================
class DeliveryPartnerNotifier extends StateNotifier<DeliveryPartnerState> {
  DeliveryPartnerNotifier() : super(const DeliveryPartnerState());

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
    state = state.copyWith(
      name: newName,
      phone: newPhone,
      birthDate: newDob,
      licenseNumber: newLicenseNo,
      licenseExpiryDate: newExpiry,
      profilePicturePath: profilePath ?? state.profilePicturePath,
      licensePhotoPath: licensePath ?? state.licensePhotoPath,
      documentPhotoPath: docPath ?? state.documentPhotoPath,
      rcBookPhotoPath: rcPath ?? state.rcBookPhotoPath,
    );
  }

  void updateDocuments({
    required String type,
    required String number,
    required String vehicle,
    required String vehicleNum,
    String? docPath,
    String? rcPath,
  }) {
    state = state.copyWith(
      docType: type,
      docNumber: number,
      vehicleType: vehicle,
      vehicleNumber: vehicleNum,
      documentPhotoPath: docPath ?? state.documentPhotoPath,
      rcBookPhotoPath: rcPath ?? state.rcBookPhotoPath,
    );
  }

  void setName(String newName) {
    state = state.copyWith(name: newName);
  }

  void setPhone(String newPhone) {
    state = state.copyWith(phone: newPhone);
  }

  void setProfilePicturePath(String path) {
    state = state.copyWith(profilePicturePath: path);
  }

  void updateWorkPreference({
    required String newState,
    required String newCity,
    required String newSlot,
  }) {
    state = state.copyWith(
      state: newState,
      city: newCity,
      timeSlot: newSlot,
    );
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
    state = state.copyWith(
      bankName: bank,
      branchName: branch,
      accountNumber: accNum,
      accountType: type,
      ifscCode: ifsc,
      accountHolderName: holder,
      accountStatus: status,
    );
  }

  void setAllData(Map<String, dynamic> data) {
    state = state.copyWith(
      name: "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim(),
      phone: data['phone']?.toString() ?? state.phone,
      birthDate: data['birth_date']?.toString().split('T').first ?? state.birthDate,
      licenseNumber: data['license_number']?.toString() ?? state.licenseNumber,
      licenseExpiryDate: data['expiry_date']?.toString().split('T').first ?? state.licenseExpiryDate,
      profilePicturePath: data['profile_picture']?.toString() ?? state.profilePicturePath,
      licensePhotoPath: data['license_photo']?.toString() ?? state.licensePhotoPath,
      documentPhotoPath: data['document_photo']?.toString() ?? state.documentPhotoPath,
      rcBookPhotoPath: data['rc_book_picture']?.toString() ?? state.rcBookPhotoPath,
      docNumber: data['document_number']?.toString() ?? state.docNumber,
      vehicleType: data['vehicle_type_name']?.toString() ?? state.vehicleType,
      vehicleNumber: data['vehicle_number']?.toString() ?? state.vehicleNumber,
      state: data['working_state']?.toString() ?? state.state,
      city: data['working_city']?.toString() ?? state.city,
      timeSlot: data['time_slot']?.toString() ?? state.timeSlot,
      bankName: data['bank_name']?.toString() ?? state.bankName,
      branchName: data['branch_name']?.toString() ?? state.branchName,
      accountNumber: data['account_number']?.toString() ?? state.accountNumber,
      accountType: data['account_type']?.toString() ?? state.accountType,
      ifscCode: data['ifsc_code']?.toString() ?? state.ifscCode,
      accountHolderName: data['account_holder_name']?.toString() ?? state.accountHolderName,
    );
  }
}


// ==================== RIVERPOD PROVIDER ====================
final deliveryPartnerProvider =
    StateNotifierProvider<DeliveryPartnerNotifier, DeliveryPartnerState>(
  (ref) => DeliveryPartnerNotifier(),
);
