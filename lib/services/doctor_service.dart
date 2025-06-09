import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Shared Doctor Info Model
class DoctorInfo {
  final String name;
  final String specialization;
  final List<String> qualifications;
  final double rating;
  final int reviewCount;
  final int experience;
  final String hospital;
  final int consultationFee;
  final String contactNumber;
  final bool isAvailable;
  final List<String> availableSlots;
  final String? imageUrl;
  final String about;
  final String employeeId;
  final String department;
  final String joinDate;

  DoctorInfo({
    required this.name,
    required this.specialization,
    required this.qualifications,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.hospital,
    required this.consultationFee,
    required this.contactNumber,
    required this.isAvailable,
    required this.availableSlots,
    this.imageUrl,
    required this.about,
    required this.employeeId,
    required this.department,
    required this.joinDate,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'qualifications': qualifications,
      'rating': rating,
      'reviewCount': reviewCount,
      'experience': experience,
      'hospital': hospital,
      'consultationFee': consultationFee,
      'contactNumber': contactNumber,
      'isAvailable': isAvailable,
      'availableSlots': availableSlots,
      'imageUrl': imageUrl,
      'about': about,
      'employeeId': employeeId,
      'department': department,
      'joinDate': joinDate,
    };
  }

  // Create from JSON
  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      name: json['name'],
      specialization: json['specialization'],
      qualifications: List<String>.from(json['qualifications']),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      experience: json['experience'],
      hospital: json['hospital'],
      consultationFee: json['consultationFee'],
      contactNumber: json['contactNumber'],
      isAvailable: json['isAvailable'],
      availableSlots: List<String>.from(json['availableSlots']),
      imageUrl: json['imageUrl'],
      about: json['about'],
      employeeId: json['employeeId'],
      department: json['department'],
      joinDate: json['joinDate'],
    );
  }

  // Create a copy with updated fields
  DoctorInfo copyWith({
    String? name,
    String? specialization,
    List<String>? qualifications,
    double? rating,
    int? reviewCount,
    int? experience,
    String? hospital,
    int? consultationFee,
    String? contactNumber,
    bool? isAvailable,
    List<String>? availableSlots,
    String? imageUrl,
    String? about,
    String? employeeId,
    String? department,
    String? joinDate,
  }) {
    return DoctorInfo(
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      qualifications: qualifications ?? this.qualifications,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experience: experience ?? this.experience,
      hospital: hospital ?? this.hospital,
      consultationFee: consultationFee ?? this.consultationFee,
      contactNumber: contactNumber ?? this.contactNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      availableSlots: availableSlots ?? this.availableSlots,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

// Doctor Service for managing doctor data across the app
class DoctorService {
  static final DoctorService _instance = DoctorService._internal();
  factory DoctorService() => _instance;
  DoctorService._internal();

  List<DoctorInfo> _doctors = [];
  final List<Function(List<DoctorInfo>)> _listeners = [];

  // Initialize with default data
  void initialize() {
    if (_doctors.isEmpty) {
      _doctors = [
        DoctorInfo(
          name: 'Dr. Rajesh Sharma',
          specialization: 'Cardiologist',
          qualifications: ['MBBS', 'MD Cardiology', 'FACC'],
          rating: 4.8,
          reviewCount: 245,
          experience: 15,
          hospital: 'Tribhuvan University Teaching Hospital',
          consultationFee: 1500,
          contactNumber: '+977-1-4412303',
          isAvailable: true,
          availableSlots: ['9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM'],
          imageUrl: null,
          about: 'Experienced cardiologist specializing in interventional cardiology and heart disease prevention.',
          employeeId: 'DOC001',
          department: 'Cardiology',
          joinDate: '2018-03-15',
        ),
        DoctorInfo(
          name: 'Dr. Priya Patel',
          specialization: 'Pediatrician',
          qualifications: ['MBBS', 'MD Pediatrics', 'Fellowship in Neonatology'],
          rating: 4.9,
          reviewCount: 189,
          experience: 12,
          hospital: 'Tribhuvan University Teaching Hospital',
          consultationFee: 1200,
          contactNumber: '+977-1-4412304',
          isAvailable: true,
          availableSlots: ['8:00 AM', '10:00 AM', '1:00 PM', '3:00 PM'],
          imageUrl: null,
          about: 'Dedicated pediatrician with expertise in child development and neonatal care.',
          employeeId: 'DOC002',
          department: 'Pediatrics',
          joinDate: '2019-07-22',
        ),
        DoctorInfo(
          name: 'Dr. Amit Singh',
          specialization: 'Orthopedic Surgeon',
          qualifications: ['MBBS', 'MS Orthopedics', 'Fellowship in Joint Replacement'],
          rating: 4.7,
          reviewCount: 156,
          experience: 18,
          hospital: 'Tribhuvan University Teaching Hospital',
          consultationFee: 2000,
          contactNumber: '+977-1-4412305',
          isAvailable: false,
          availableSlots: ['9:00 AM', '2:00 PM'],
          imageUrl: null,
          about: 'Expert orthopedic surgeon specializing in joint replacement and sports medicine.',
          employeeId: 'DOC003',
          department: 'Orthopedics',
          joinDate: '2016-01-10',
        ),
        DoctorInfo(
          name: 'Dr. Sunita Thapa',
          specialization: 'Dermatologist',
          qualifications: ['MBBS', 'MD Dermatology', 'Cosmetic Dermatology Certification'],
          rating: 4.6,
          reviewCount: 98,
          experience: 8,
          hospital: 'Tribhuvan University Teaching Hospital',
          consultationFee: 1800,
          contactNumber: '+977-1-4412306',
          isAvailable: true,
          availableSlots: ['10:00 AM', '12:00 PM', '4:00 PM'],
          imageUrl: null,
          about: 'Skilled dermatologist with expertise in medical and cosmetic dermatology.',
          employeeId: 'DOC004',
          department: 'Dermatology',
          joinDate: '2020-09-05',
        ),
        DoctorInfo(
          name: 'Dr. Krishna Bahadur',
          specialization: 'Neurologist',
          qualifications: ['MBBS', 'DM Neurology', 'European Fellowship'],
          rating: 4.9,
          reviewCount: 134,
          experience: 20,
          hospital: 'Tribhuvan University Teaching Hospital',
          consultationFee: 2500,
          contactNumber: '+977-1-4412307',
          isAvailable: true,
          availableSlots: ['10:00 AM', '3:00 PM'],
          imageUrl: null,
          about: 'Renowned neurologist with expertise in stroke management and epilepsy treatment.',
          employeeId: 'DOC005',
          department: 'Neurology',
          joinDate: '2015-11-18',
        ),
      ];
      _loadFromStorage();
    }
  }

  // Get all doctors
  List<DoctorInfo> getAllDoctors() {
    return List.from(_doctors);
  }

  // Get only active doctors (for client-side)
  List<DoctorInfo> getActiveDoctors() {
    return _doctors.where((doctor) => doctor.isAvailable).toList();
  }

  // Get doctor by employee ID
  DoctorInfo? getDoctorById(String employeeId) {
    try {
      return _doctors.firstWhere((doctor) => doctor.employeeId == employeeId);
    } catch (e) {
      return null;
    }
  }

  // Toggle doctor status
  Future<bool> toggleDoctorStatus(String employeeId) async {
    final doctorIndex = _doctors.indexWhere((d) => d.employeeId == employeeId);
    if (doctorIndex != -1) {
      _doctors[doctorIndex] = _doctors[doctorIndex].copyWith(
        isAvailable: !_doctors[doctorIndex].isAvailable,
      );
      await _saveToStorage();
      _notifyListeners();
      return true;
    }
    return false;
  }

  // Add listener for changes
  void addListener(Function(List<DoctorInfo>) listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(Function(List<DoctorInfo>) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_doctors);
    }
  }

  // Save to persistent storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorsJson = _doctors.map((doctor) => doctor.toJson()).toList();
      await prefs.setString('doctors_data', jsonEncode(doctorsJson));
    } catch (e) {
      print('Error saving doctors data: $e');
    }
  }

  // Load from persistent storage
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorsString = prefs.getString('doctors_data');
      if (doctorsString != null) {
        final doctorsJson = jsonDecode(doctorsString) as List;
        _doctors = doctorsJson.map((json) => DoctorInfo.fromJson(json)).toList();
        _notifyListeners();
      }
    } catch (e) {
      print('Error loading doctors data: $e');
    }
  }

  // Add new doctor
  Future<void> addDoctor(DoctorInfo doctor) async {
    _doctors.add(doctor);
    await _saveToStorage();
    _notifyListeners();
  }

  // Update doctor
  Future<bool> updateDoctor(String employeeId, DoctorInfo updatedDoctor) async {
    final doctorIndex = _doctors.indexWhere((d) => d.employeeId == employeeId);
    if (doctorIndex != -1) {
      _doctors[doctorIndex] = updatedDoctor;
      await _saveToStorage();
      _notifyListeners();
      return true;
    }
    return false;
  }

  // Remove doctor
  Future<bool> removeDoctor(String employeeId) async {
    final doctorIndex = _doctors.indexWhere((d) => d.employeeId == employeeId);
    if (doctorIndex != -1) {
      _doctors.removeAt(doctorIndex);
      await _saveToStorage();
      _notifyListeners();
      return true;
    }
    return false;
  }
}
