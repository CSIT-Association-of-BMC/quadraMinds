import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';
import '../../utils/page_transitions.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state_service.dart';
import '../../models/user_type.dart';
import '../../models/user_models.dart';
import '../home/home_screen_client.dart';
import '../hospital_main/home/home_screen_hospital.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final AuthStateService _authStateService = AuthStateService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        debugPrint('LoginScreen: Starting login process...');
        final result = await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        debugPrint('LoginScreen: Login result: ${result['success']}');
        if (result['error'] != null) {
          debugPrint('LoginScreen: Login error: ${result['error']}');
        }

        if (mounted) {
          if (result['success']) {
            debugPrint('LoginScreen: Login successful, detecting user type...');
            // Enhanced user type detection using email-based detection
            final userEmail =
                result['user'].email ?? _emailController.text.trim();
            var userType = await _authService.detectUserTypeFromEmail(
              userEmail,
            );
            debugPrint('LoginScreen: Detected user type: ${userType?.name}');

            // Fallback to stored user type if detection fails
            if (userType == null) {
              userType = await _authService.getUserType(result['user'].uid);
              debugPrint(
                'LoginScreen: Fallback user type from storage: $userType',
              );
            }

            // Final fallback to client if still null
            if (userType == null) {
              debugPrint('LoginScreen: Defaulting to client user type');
              userType = UserType.client;
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate based on user type
              if (userType == UserType.client) {
                debugPrint('LoginScreen: Navigating to client home screen...');
                // Create ClientUser from userData for navigation
                final userData = result['userData'];
                debugPrint('LoginScreen: User data retrieved: $userData');

                final clientUser = ClientUser(
                  uid: result['user'].uid,
                  email: userData['email'] ?? result['user'].email ?? '',
                  password: '', // Don't store password
                  firstName: userData['firstName'] ?? '',
                  lastName: userData['lastName'] ?? '',
                  phoneNumber: userData['phoneNumber'] ?? '',
                  dateOfBirth:
                      userData['dateOfBirth'] != null
                          ? (userData['dateOfBirth'] is String
                              ? DateTime.tryParse(userData['dateOfBirth'])
                              : userData['dateOfBirth'])
                          : null,
                  address: userData['address'],
                  emergencyContact: userData['emergencyContact'],
                );

                debugPrint(
                  'LoginScreen: Created ClientUser with name: "${clientUser.firstName}" "${clientUser.lastName}"',
                );

                // Save client authentication state
                try {
                  await _authStateService.saveAuthState(user: clientUser);
                  debugPrint('LoginScreen: Client authentication state saved');
                } catch (e) {
                  debugPrint(
                    'LoginScreen: Failed to save client auth state: $e',
                  );
                  // Continue with navigation even if state saving fails
                }

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    FadeSlidePageRoute(
                      child: HomeScreenClient(clientUser: clientUser),
                    ),
                    (route) => false,
                  );
                }
              } else if (userType == UserType.hospital) {
                debugPrint(
                  'LoginScreen: Navigating to hospital home screen...',
                );
                final userData = result['userData'];
                debugPrint('LoginScreen: Hospital user data: $userData');

                final hospitalUser = HospitalUser(
                  uid: result['user'].uid,
                  email: userData['email'] ?? result['user'].email ?? '',
                  password: '', // Don't store password
                  hospitalName: userData['hospitalName'] ?? '',
                  registrationNumber: userData['registrationNumber'] ?? '',
                  contactPerson: userData['contactPerson'] ?? '',
                  phoneNumber: userData['phoneNumber'] ?? '',
                  address: userData['address'] ?? '',
                  website: userData['website'],
                  specializations: List<String>.from(
                    userData['specializations'] ?? [],
                  ),
                  licenseNumber: userData['licenseNumber'],
                );

                // Save hospital authentication state
                try {
                  await _authStateService.saveHospitalAuthState(
                    user: hospitalUser,
                  );
                  debugPrint(
                    'LoginScreen: Hospital authentication state saved',
                  );
                } catch (e) {
                  debugPrint(
                    'LoginScreen: Failed to save hospital auth state: $e',
                  );
                  // Continue with navigation even if state saving fails
                }

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    FadeSlidePageRoute(
                      child: HomeScreenHospital(hospitalUser: hospitalUser),
                    ),
                    (route) => false,
                  );
                }
              } else {
                debugPrint('LoginScreen: Unknown user type, showing error');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Unable to determine user type. Please try again.',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            }
          } else {
            debugPrint('LoginScreen: Login failed, showing error message');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ?? 'Login failed'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('LoginScreen: Unexpected error during login: $e');
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo and Title
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.health_and_safety,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue to Swasthya Setu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5D6D7E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                FadeSlidePageRoute(
                                  child: const ResetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Color(0xFF5D6D7E),
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            FadeSlidePageRoute(child: const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
