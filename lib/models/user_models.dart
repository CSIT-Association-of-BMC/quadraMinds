import 'user_type.dart';

class BaseUser {
  final String? uid;
  final String email;
  final String password;
  final UserType userType;

  BaseUser({
    this.uid,
    required this.email,
    required this.password,
    required this.userType,
  });

  // Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'userType': userType.name};
  }
}

class ClientUser extends BaseUser {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? emergencyContact;

  ClientUser({
    super.uid,
    required super.email,
    required super.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
  }) : super(userType: UserType.client);

  // Convert to Map for local storage
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }

  // Create ClientUser from Map (for loading from local storage)
  factory ClientUser.fromMap(Map<String, dynamic> map) {
    return ClientUser(
      uid: map['uid'],
      email: map['email'] ?? '',
      password: '', // Don't store password locally
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      dateOfBirth:
          map['dateOfBirth'] != null
              ? DateTime.tryParse(map['dateOfBirth'])
              : null,
      address: map['address'],
      emergencyContact: map['emergencyContact'],
    );
  }
}

class HospitalUser extends BaseUser {
  final String hospitalName;
  final String registrationNumber;
  final String contactPerson;
  final String phoneNumber;
  final String address;
  final String? website;
  final List<String> specializations;
  final String? licenseNumber;

  HospitalUser({
    super.uid,
    required super.email,
    required super.password,
    required this.hospitalName,
    required this.registrationNumber,
    required this.contactPerson,
    required this.phoneNumber,
    required this.address,
    this.website,
    required this.specializations,
    this.licenseNumber,
  }) : super(userType: UserType.hospital);
}
