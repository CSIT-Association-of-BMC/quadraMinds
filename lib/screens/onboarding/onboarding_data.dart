import 'package:flutter/material.dart';

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class OnboardingContent {
  static List<OnboardingData> get pages => [
    OnboardingData(
      title: "Welcome to Swasthya Setu",
      description:
          "Your comprehensive healthcare companion that connects you with quality medical services and health information.",
      icon: Icons.health_and_safety,
      backgroundColor: const Color(0xFFE8F5E8),
      iconColor: const Color(0xFF2E7D32),
    ),
    OnboardingData(
      title: "Find Healthcare Services",
      description:
          "Locate nearby hospitals, clinics, pharmacies, and healthcare professionals with ease.",
      icon: Icons.local_hospital,
      backgroundColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1976D2),
    ),
    OnboardingData(
      title: "Book Appointments",
      description:
          "Schedule appointments with doctors, specialists, and healthcare providers at your convenience.",
      icon: Icons.calendar_today,
      backgroundColor: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFFF9800),
    ),
    OnboardingData(
      title: "Health Records",
      description:
          "Keep track of your medical history, prescriptions, and health reports in one secure place.",
      icon: Icons.folder_shared,
      backgroundColor: const Color(0xFFF3E5F5),
      iconColor: const Color(0xFF9C27B0),
    ),
    OnboardingData(
      title: "Emergency Services",
      description:
          "Quick access to emergency contacts, nearby emergency services, and first aid information.",
      icon: Icons.emergency,
      backgroundColor: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFD32F2F),
    ),
  ];
}
