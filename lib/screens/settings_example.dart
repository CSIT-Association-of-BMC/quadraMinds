import 'package:flutter/material.dart';
import '../models/user_models.dart';
import '../models/user_type.dart';
import 'profile_client/settings_screen.dart';
import 'hospital_main/profile/settings_hospital_screen.dart';

/// Example screen showing how to navigate to different settings screens
/// based on user type (Client or Hospital)
class SettingsExampleScreen extends StatelessWidget {
  const SettingsExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Settings Demo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings Screens Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a user type to see the corresponding settings screen:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Client Settings Demo
            _buildDemoCard(
              context: context,
              title: 'Client Settings',
              subtitle: 'Settings for individual patients/clients',
              icon: Icons.person_outline,
              color: const Color(0xFF667EEA),
              onTap: () => _navigateToClientSettings(context),
            ),

            const SizedBox(height: 16),

            // Hospital Settings Demo
            _buildDemoCard(
              context: context,
              title: 'Hospital Settings',
              subtitle: 'Settings for healthcare institutions',
              icon: Icons.local_hospital_outlined,
              color: const Color(0xFF764BA2),
              onTap: () => _navigateToHospitalSettings(context),
            ),

            const SizedBox(height: 32),

            // Features List
            const Text(
              'Features Included:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            _buildFeatureItem('✓ Notification preferences'),
            _buildFeatureItem('✓ Theme and appearance settings'),
            _buildFeatureItem('✓ Privacy and security options'),
            _buildFeatureItem('✓ Language selection'),
            _buildFeatureItem('✓ Password management'),
            _buildFeatureItem('✓ Data management (Hospital only)'),
            _buildFeatureItem('✓ System settings (Hospital only)'),
            _buildFeatureItem('✓ Logout functionality'),
            _buildFeatureItem('✓ Help & Support'),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        feature,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
    );
  }

  void _navigateToClientSettings(BuildContext context) {
    // Create a sample client user for demo
    final sampleClient = ClientUser(
      uid: 'demo_client_123',
      email: 'client@example.com',
      password: '',
      firstName: 'John',
      lastName: 'Doe',
      phoneNumber: '+1234567890',
      dateOfBirth: DateTime(1990, 5, 15),
      address: '123 Main St, City, State',
      emergencyContact: '+1987654321',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(clientUser: sampleClient),
      ),
    );
  }

  void _navigateToHospitalSettings(BuildContext context) {
    // Create a sample hospital user for demo
    final sampleHospital = HospitalUser(
      uid: 'demo_hospital_123',
      email: 'hospital@example.com',
      password: '',
      hospitalName: 'City General Hospital',
      registrationNumber: 'REG123456',
      contactPerson: 'Dr. Jane Smith',
      phoneNumber: '+1234567890',
      address: '456 Hospital Ave, Medical District',
      website: 'https://citygeneral.com',
      specializations: ['Cardiology', 'Neurology', 'Pediatrics', 'Emergency'],
      licenseNumber: 'LIC789012',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SettingsHospitalScreen(hospitalUser: sampleHospital),
      ),
    );
  }
}
