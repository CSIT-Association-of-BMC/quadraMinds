import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_models.dart';
import '../models/user_type.dart';
import 'auth/login_screen.dart';
import '../utils/page_transitions.dart';

/// Test screen to verify logout functionality works correctly
class LogoutTestScreen extends StatefulWidget {
  const LogoutTestScreen({super.key});

  @override
  State<LogoutTestScreen> createState() => _LogoutTestScreenState();
}

class _LogoutTestScreenState extends State<LogoutTestScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _statusMessage = 'Ready to test logout functionality';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Logout Test',
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
              'Logout Functionality Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test the logout functionality to ensure it works correctly.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current User Info
            FutureBuilder<String>(
              future: _getCurrentUserInfo(),
              builder: (context, snapshot) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current User:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.data ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Test Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Test Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Check Auth Status Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _checkAuthStatus,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF667EEA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Check Auth Status',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getCurrentUserInfo() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        return 'Firebase User: ${currentUser.email ?? 'No email'}\nUID: ${currentUser.uid}';
      }
      
      final isAuth = await _authService.isUserAuthenticated();
      if (isAuth) {
        return 'Authenticated via local storage';
      }
      
      return 'No user authenticated';
    } catch (e) {
      return 'Error getting user info: $e';
    }
  }

  Future<void> _testLogout() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing logout...';
    });

    try {
      await _authService.signOut();
      
      setState(() {
        _statusMessage = 'Logout successful! Redirecting to login...';
      });
      
      // Wait a moment to show success message
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          FadeSlidePageRoute(child: const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Logout failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _statusMessage = 'Checking authentication status...';
    });

    try {
      final isAuth = await _authService.isUserAuthenticated();
      final currentUser = _authService.currentUser;
      
      setState(() {
        _statusMessage = 'Auth Status: ${isAuth ? 'Authenticated' : 'Not Authenticated'}\n'
                        'Firebase User: ${currentUser?.email ?? 'None'}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking auth status: $e';
      });
    }
  }
}
