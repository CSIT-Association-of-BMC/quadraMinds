import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_models.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'help_center_screen.dart';
import 'feedback_screen.dart';

class ProfileClientScreen extends StatefulWidget {
  final ClientUser clientUser;

  const ProfileClientScreen({super.key, required this.clientUser});

  @override
  State<ProfileClientScreen> createState() => _ProfileClientScreenState();
}

class _ProfileClientScreenState extends State<ProfileClientScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = AuthService();

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
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Enhanced Professional Header
            _buildProfileHeader(context),

            // Main Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA), // Light blue-gray background
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Account Settings Section
                      _buildSectionTitle('Account Settings'),
                      const SizedBox(height: 12),
                      _buildAccountSettingsCard(),

                      const SizedBox(height: 20),

                      // Support Section
                      _buildSectionTitle('Support'),
                      const SizedBox(height: 12),
                      _buildSupportCard(),

                      const SizedBox(height: 20),

                      // Sign Out Button
                      _buildSignOutButton(),

                      const SizedBox(height: 80), // Space for bottom navigation
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA), // Modern blue
            Color(0xFF764BA2), // Purple accent
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Bar
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              EditProfileScreen(clientUser: widget.clientUser),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),

          // Profile Avatar and Info
          Transform.translate(
            offset: const Offset(0, -35),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF8B5FBF),
                      child: Text(
                        _getInitials(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.clientUser.firstName} ${widget.clientUser.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.clientUser.email,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    String initials = '';
    if (widget.clientUser.firstName.isNotEmpty) {
      initials += widget.clientUser.firstName[0].toUpperCase();
    }
    if (widget.clientUser.lastName.isNotEmpty) {
      initials += widget.clientUser.lastName[0].toUpperCase();
    }
    return initials.isEmpty ? 'U' : initials;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF666666),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
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
          _buildSettingsItem(
            icon: Icons.person_outline,
            iconColor: const Color(0xFF667EEA),
            iconBgColor: const Color(0xFF667EEA).withValues(alpha: 0.1),
            title: 'Personal Information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          EditProfileScreen(clientUser: widget.clientUser),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFF8B5FBF),
            iconBgColor: const Color(0xFF8B5FBF).withValues(alpha: 0.1),
            title: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.delete_outline,
            iconColor: const Color(0xFFFF6B6B),
            iconBgColor: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
            title: 'Delete Account',
            titleColor: const Color(0xFFFF6B6B),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
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
          _buildSettingsItem(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF4ECDC4),
            iconBgColor: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
            title: 'Help Center',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF667EEA),
            iconBgColor: const Color(0xFF667EEA).withValues(alpha: 0.1),
            title: 'Contact Support',
            onTap: () => _contactSupport(),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.feedback_outlined,
            iconColor: const Color(0xFF8B5FBF),
            iconBgColor: const Color(0xFF8B5FBF).withValues(alpha: 0.1),
            title: 'Send Feedback',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.star_outline,
            iconColor: const Color(0xFFFFD93D),
            iconBgColor: const Color(0xFFFFD93D).withValues(alpha: 0.1),
            title: 'Rate the App',
            onTap: () => _rateApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? const Color(0xFF333333),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey[100],
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: _handleSignOut,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: const Color(0xFFFF6B6B), size: 18),
            const SizedBox(width: 6),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B6B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B6B),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performSignOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Contact Support functionality
  Future<void> _contactSupport() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose how you\'d like to contact our support team',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 24),

                  // Contact options
                  _buildContactOption(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@swasthyasetu.com',
                    color: const Color(0xFF667EEA),
                    onTap: () {
                      Navigator.pop(context);
                      _sendSupportEmail();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactOption(
                    icon: Icons.phone_outlined,
                    title: 'Call Support',
                    subtitle: '+1-800-HEALTH (24/7)',
                    color: const Color(0xFF4ECDC4),
                    onTap: () {
                      Navigator.pop(context);
                      _callSupport();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactOption(
                    icon: Icons.chat_outlined,
                    title: 'Live Chat',
                    subtitle: 'Chat with our team',
                    color: const Color(0xFF8B5FBF),
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon('Live Chat');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactOption(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Browse FAQs and guides',
                    color: const Color(0xFFFFD93D),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpCenterScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSupportEmail() async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'support@swasthyasetu.com',
        query:
            'subject=Support Request - Swasthya Setu App&body=Hello Support Team,%0A%0AI need help with:%0A%0A[Please describe your issue here]%0A%0AUser Details:%0AName: ${widget.clientUser.firstName} ${widget.clientUser.lastName}%0AEmail: ${widget.clientUser.email}%0A%0AThank you!',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: Show email details for manual copying
        _showEmailFallback();
      }
    } catch (e) {
      _showEmailFallback();
    }
  }

  Future<void> _callSupport() async {
    try {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: '+18004325844',
      ); // +1-800-HEALTH
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showError(
          'Could not launch phone dialer. Please call +1-800-HEALTH manually.',
        );
      }
    } catch (e) {
      _showError(
        'Could not launch phone dialer. Please call +1-800-HEALTH manually.',
      );
    }
  }

  void _showEmailFallback() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Email Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please send an email to:',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'support@swasthyasetu.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Include your name, email, and a detailed description of your issue.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Got it',
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Rate App functionality
  Future<void> _rateApp() async {
    // For Android, use Play Store URL
    // For iOS, use App Store URL
    // For now, we'll use a generic URL that can be updated later
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.swasthyasetu.app';
    const String appStoreUrl =
        'https://apps.apple.com/app/swasthya-setu/id123456789';

    try {
      // Try Play Store first (can be made platform-specific later)
      final Uri uri = Uri.parse(playStoreUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch app store';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open app store. Please rate us manually.'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  // Delete Account functionality
  Future<void> _deleteAccount() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Delete user account using AuthService
      await _authService.deleteUserAccount();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  // Sign Out functionality
  Future<void> _performSignOut() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Sign out using AuthService
      await _authService.signOut();

      // Close loading dialog and navigate to login screen
      if (mounted) {
        Navigator.of(context).pop();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }
}
