import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I book an appointment?',
      answer: 'To book an appointment, go to the home screen, select "Find Hospitals" or "Find Doctors", choose your preferred healthcare provider, and tap "Book Appointment". Follow the prompts to select your preferred date and time.',
    ),
    FAQItem(
      question: 'How can I cancel or reschedule my appointment?',
      answer: 'You can manage your appointments by going to the "Your Appointments" section from the home screen. There you can view, cancel, or reschedule your upcoming appointments.',
    ),
    FAQItem(
      question: 'Is my personal information secure?',
      answer: 'Yes, we take your privacy seriously. All your personal and medical information is encrypted and stored securely. We comply with healthcare data protection standards and never share your information without your consent.',
    ),
    FAQItem(
      question: 'How do I update my profile information?',
      answer: 'Go to your Profile screen and tap the edit icon in the top right corner. You can update your personal information, contact details, and emergency contacts from there.',
    ),
    FAQItem(
      question: 'What should I do if I forgot my password?',
      answer: 'On the login screen, tap "Forgot Password?" and enter your email address. You\'ll receive a password reset link via email. Follow the instructions in the email to create a new password.',
    ),
    FAQItem(
      question: 'How do I enable notifications?',
      answer: 'Go to Profile > Settings > Notifications to manage your notification preferences. You can enable or disable email, SMS, and push notifications according to your preference.',
    ),
    FAQItem(
      question: 'Can I search for specific doctors or specializations?',
      answer: 'Yes, you can search for doctors by name, specialization, or hospital. Use the search feature on the home screen or browse through the categories to find the right healthcare provider for your needs.',
    ),
    FAQItem(
      question: 'How do I contact customer support?',
      answer: 'You can contact our support team through the "Contact Support" option in your profile, or email us directly at support@swasthyasetu.com. We typically respond within 24 hours.',
    ),
  ];

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Section
              _buildQuickActionsSection(),
              
              const SizedBox(height: 24),
              
              // FAQ Section
              _buildSectionTitle('Frequently Asked Questions'),
              const SizedBox(height: 12),
              _buildFAQSection(),
              
              const SizedBox(height: 24),
              
              // Contact Section
              _buildContactSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
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
          _buildQuickActionItem(
            icon: Icons.phone_outlined,
            title: 'Call Support',
            subtitle: 'Get immediate help',
            color: const Color(0xFF4ECDC4),
            onTap: () => _makePhoneCall('+1-800-HEALTH'),
          ),
          _buildDivider(),
          _buildQuickActionItem(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'Send us your questions',
            color: const Color(0xFF667EEA),
            onTap: () => _sendEmail(),
          ),
          _buildDivider(),
          _buildQuickActionItem(
            icon: Icons.chat_outlined,
            title: 'Live Chat',
            subtitle: 'Chat with our team',
            color: const Color(0xFF8B5FBF),
            onTap: () => _showComingSoon('Live Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildFAQSection() {
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
        children: _faqItems.asMap().entries.map((entry) {
          int index = entry.key;
          FAQItem item = entry.value;
          return Column(
            children: [
              _buildFAQItem(item),
              if (index < _faqItems.length - 1) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            item.answer,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Still need help?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our support team is available 24/7 to assist you with any questions or concerns.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _sendEmail(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showError('Could not launch phone dialer');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@swasthyasetu.com',
      query: 'subject=Support Request&body=Hello, I need help with...',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showError('Could not launch email client');
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
