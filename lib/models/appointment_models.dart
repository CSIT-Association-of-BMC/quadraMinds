class AppointmentBooking {
  final String id;
  final String hospitalName;
  final String hospitalLocation;
  final String patientName;
  final String phoneNumber;
  final DateTime appointmentDate;
  final String timeSlot;
  final String? doctorName;
  final double consultationFee;
  final double bookingFee;
  final double totalAmount;
  final AppointmentStatus status;
  final DateTime createdAt;

  AppointmentBooking({
    required this.id,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.patientName,
    required this.phoneNumber,
    required this.appointmentDate,
    required this.timeSlot,
    this.doctorName,
    required this.consultationFee,
    required this.bookingFee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory AppointmentBooking.fromJson(Map<String, dynamic> json) {
    return AppointmentBooking(
      id: json['id'],
      hospitalName: json['hospitalName'],
      hospitalLocation: json['hospitalLocation'],
      patientName: json['patientName'],
      phoneNumber: json['phoneNumber'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      timeSlot: json['timeSlot'],
      doctorName: json['doctorName'],
      consultationFee: json['consultationFee'].toDouble(),
      bookingFee: json['bookingFee'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospitalName': hospitalName,
      'hospitalLocation': hospitalLocation,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'doctorName': doctorName,
      'consultationFee': consultationFee,
      'bookingFee': bookingFee,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String hospitalId;
  final List<String> availableTimeSlots;
  final double consultationFee;
  final double rating;
  final bool isAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospitalId,
    required this.availableTimeSlots,
    required this.consultationFee,
    required this.rating,
    required this.isAvailable,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      hospitalId: json['hospitalId'],
      availableTimeSlots: List<String>.from(json['availableTimeSlots']),
      consultationFee: json['consultationFee'].toDouble(),
      rating: json['rating'].toDouble(),
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'hospitalId': hospitalId,
      'availableTimeSlots': availableTimeSlots,
      'consultationFee': consultationFee,
      'rating': rating,
      'isAvailable': isAvailable,
    };
  }
}

class TimeSlot {
  final String id;
  final String time;
  final bool isAvailable;
  final int maxPatients;
  final int currentPatients;

  TimeSlot({
    required this.id,
    required this.time,
    required this.isAvailable,
    required this.maxPatients,
    required this.currentPatients,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      time: json['time'],
      isAvailable: json['isAvailable'],
      maxPatients: json['maxPatients'],
      currentPatients: json['currentPatients'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'isAvailable': isAvailable,
      'maxPatients': maxPatients,
      'currentPatients': currentPatients,
    };
  }
}
