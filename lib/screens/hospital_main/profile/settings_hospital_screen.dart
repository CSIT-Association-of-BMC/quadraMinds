import 'package:flutter/material.dart';
import '../../../models/user_models.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_screen.dart';
import '../../../utils/page_transitions.dart';
import '../../profile_client/widgets/profile_menu_item.dart';
import 'change_password_hospital_screen.dart';

class SettingsHospitalScreen extends StatefulWidget {
  final HospitalUser hospitalUser;

  const SettingsHospitalScreen({super.key, required this.hospitalUser});

  @override
  State<SettingsHospitalScreen> createState() => _SettingsHospitalScreenState();
}

class _SettingsHospitalScreenState extends State<SettingsHospitalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final AuthService _authService = AuthService();

  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _darkMode = false;
  bool _autoBackup = true;
  bool _dataSync = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Hospital Settings',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital Info Section
              _buildSectionTitle('Hospital Information'),
              const SizedBox(height: 12),
              _buildHospitalInfoSection(),

              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionTitle('Notifications'),
              const SizedBox(height: 12),
              _buildNotificationsSection(),

              const SizedBox(height: 24),

              // System Settings Section
              _buildSectionTitle('System Settings'),
              const SizedBox(height: 12),
              _buildSystemSettingsSection(),

              const SizedBox(height: 24),

              // Privacy & Security Section
              _buildSectionTitle('Privacy & Security'),
              const SizedBox(height: 12),
              _buildPrivacySection(),

              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionTitle('Data Management'),
              const SizedBox(height: 12),
              _buildDataManagementSection(),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionTitle('Account'),
              const SizedBox(height: 12),
              _buildAccountSection(),

              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildHospitalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.local_hospital_outlined,
            title: 'Hospital Profile',
            subtitle: widget.hospitalUser.hospitalName,
            onTap: () => _showComingSoon('Hospital Profile'),
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.business_outlined,
            title: 'Registration Details',
            subtitle: 'Reg. No: ${widget.hospitalUser.registrationNumber}',
            onTap: () => _showComingSoon('Registration Details'),
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.medical_services_outlined,
            title: 'Specializations',
            subtitle:
                '${widget.hospitalUser.specializations.length} specialties',
            onTap: () => _showComingSoon('Specializations'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'All Notifications',
            subtitle: 'Enable or disable all notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                if (!value) {
                  _emailNotifications = false;
                  _smsNotifications = false;
                  _pushNotifications = false;
                }
              });
            },
          ),
          if (_notificationsEnabled) ...[
            const Divider(height: 1, indent: 60),
            _buildSwitchTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Appointment updates, system alerts',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            const Divider(height: 1, indent: 60),
            _buildSwitchTile(
              icon: Icons.sms_outlined,
              title: 'SMS Notifications',
              subtitle: 'Critical alerts and reminders',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
            ),
            const Divider(height: 1, indent: 60),
            _buildSwitchTile(
              icon: Icons.phone_android_outlined,
              title: 'Push Notifications',
              subtitle: 'Real-time updates on device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              _showComingSoon('Dark Mode');
            },
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.schedule_outlined,
            title: 'Working Hours',
            subtitle: 'Set hospital operating hours',
            onTap: () => _showComingSoon('Working Hours'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordHospitalScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admin Access',
            subtitle: 'Manage admin permissions',
            onTap: () => _showComingSoon('Admin Access'),
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () => _showComingSoon('Privacy Policy'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.backup_outlined,
            title: 'Auto Backup',
            subtitle: 'Automatically backup hospital data',
            value: _autoBackup,
            onChanged: (value) {
              setState(() {
                _autoBackup = value;
              });
              _showComingSoon('Auto Backup');
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSwitchTile(
            icon: Icons.sync_outlined,
            title: 'Data Synchronization',
            subtitle: 'Sync data across all devices',
            value: _dataSync,
            onChanged: (value) {
              setState(() {
                _dataSync = value;
              });
              _showComingSoon('Data Sync');
            },
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'Download hospital records',
            onTap: () => _showComingSoon('Export Data'),
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.analytics_outlined,
            title: 'Analytics Settings',
            subtitle: 'Configure reporting preferences',
            onTap: () => _showComingSoon('Analytics Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF667EEA)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF667EEA),
            activeTrackColor: const Color(0xFF667EEA).withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption('English (US)', true),
                _buildLanguageOption('Hindi (हिंदी)', false),
                _buildLanguageOption('Bengali (বাংলা)', false),
                _buildLanguageOption('Tamil (தமிழ்)', false),
                _buildLanguageOption('Telugu (తెలుగు)', false),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showComingSoon('Language Change');
                },
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return InkWell(
      onTap: () {
        // Handle language selection
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (value) {
                // Handle radio selection
              },
              activeColor: const Color(0xFF667EEA),
            ),
            const SizedBox(width: 8),
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                color:
                    isSelected
                        ? const Color(0xFF667EEA)
                        : const Color(0xFF1F2937),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showComingSoon('Help & Support'),
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showComingSoon('About'),
          ),
          const Divider(height: 1, indent: 60),
          ProfileMenuItem(
            icon: Icons.feedback_outlined,
            title: 'Feedback',
            subtitle: 'Send feedback to improve the app',
            onTap: () => _showComingSoon('Feedback'),
          ),
          const Divider(height: 1, indent: 60),
          _buildLogoutMenuItem(),
        ],
      ),
    );
  }

  Widget _buildLogoutMenuItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.logout, size: 22, color: Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sign out of hospital account',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showLogoutDialog(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            content: Text(
              'Are you sure you want to logout from ${widget.hospitalUser.hospitalName}? You will need to sign in again to access the hospital dashboard.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _handleLogout();
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      debugPrint(
        'HospitalSettingsScreen: Starting logout process for ${widget.hospitalUser.hospitalName}...',
      );

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF667EEA)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'Signing out from ${widget.hospitalUser.hospitalName}...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      // Perform logout
      await _authService.signOut();
      debugPrint('HospitalSettingsScreen: Logout successful');

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Show success message briefly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Logged out from ${widget.hospitalUser.hospitalName} successfully',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 1),
          ),
        );

        // Small delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to login screen and clear all previous routes
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            FadeSlidePageRoute(child: const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('HospitalSettingsScreen: Logout error: $e');

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error logging out: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
