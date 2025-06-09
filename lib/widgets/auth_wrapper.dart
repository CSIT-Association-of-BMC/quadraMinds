import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_type.dart';
import '../models/user_models.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen_client.dart';
import '../screens/hospital_main/home/home_screen_hospital.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  UserType? _userType;
  ClientUser? _currentClientUser;
  HospitalUser? _currentHospitalUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAuthState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('AuthWrapper: App resumed, checking auth state...');
      _checkAuthenticationState();
    }
  }

  Future<void> _initializeAuthState() async {
    try {
      debugPrint('AuthWrapper: Initializing authentication state...');

      // Initialize auth persistence
      await _authService.initializeAuthPersistence();

      // Add a small delay to ensure Firebase is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Listen to Firebase auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        debugPrint(
          'AuthWrapper: Firebase auth state changed - User: ${user?.uid}',
        );
        _handleAuthStateChange(user);
      });

      // Initial check
      await _checkAuthenticationState();
    } catch (e) {
      debugPrint('AuthWrapper: Error initializing auth state: $e');
      setState(() {
        _isAuthenticated = false;
        _userType = null;
        _currentClientUser = null;
        _currentHospitalUser = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        debugPrint('AuthWrapper: Firebase user signed out');
        setState(() {
          _isAuthenticated = false;
          _userType = null;
          _currentClientUser = null;
          _currentHospitalUser = null;
          _isLoading = false;
        });
        return;
      }

      debugPrint('AuthWrapper: Firebase user signed in: ${firebaseUser.uid}');
      await _checkAuthenticationState();
    } catch (e) {
      debugPrint('AuthWrapper: Error handling auth state change: $e');
    }
  }

  Future<void> _checkAuthenticationState() async {
    try {
      debugPrint(
        'AuthWrapper: ========== CHECKING AUTHENTICATION STATE ==========',
      );

      // Add detailed debugging for hot reload issues
      final firebaseUser = _authService.currentUser;
      debugPrint('AuthWrapper: Firebase user: ${firebaseUser?.uid}');
      debugPrint('AuthWrapper: Firebase email: ${firebaseUser?.email}');

      // Check if user is authenticated
      final isAuthenticated = await _authService.isUserAuthenticated();
      debugPrint(
        'AuthWrapper: isUserAuthenticated() returned: $isAuthenticated',
      );

      if (isAuthenticated) {
        debugPrint('AuthWrapper: User is authenticated, getting user type...');

        // First, get the stored user type to determine which user data to fetch
        final storedUserType = await _authService.getStoredUserType();
        debugPrint(
          'AuthWrapper: getStoredUserType() returned: $storedUserType',
        );

        // Additional debugging: Check SharedPreferences directly
        try {
          final prefs = await SharedPreferences.getInstance();
          final storedUserTypeString = prefs.getString('user_type');
          final isAuthenticatedLocal = prefs.getBool('is_authenticated');
          debugPrint(
            'AuthWrapper: Direct SharedPrefs check - user_type: $storedUserTypeString',
          );
          debugPrint(
            'AuthWrapper: Direct SharedPrefs check - is_authenticated: $isAuthenticatedLocal',
          );
        } catch (e) {
          debugPrint('AuthWrapper: Error checking SharedPreferences: $e');
        }

        if (storedUserType == UserType.client) {
          debugPrint(
            'AuthWrapper: User type is CLIENT, getting client user data...',
          );
          // Get current client user data
          final currentClientUser = await _authService.getCurrentClientUser();
          debugPrint(
            'AuthWrapper: getCurrentClientUser() returned: ${currentClientUser != null ? "CLIENT USER FOUND" : "NULL"}',
          );
          if (currentClientUser != null) {
            debugPrint(
              'AuthWrapper: Found authenticated client user: ${currentClientUser.firstName} ${currentClientUser.lastName}',
            );
            setState(() {
              _isAuthenticated = true;
              _userType = UserType.client;
              _currentClientUser = currentClientUser;
              _currentHospitalUser = null;
              _isLoading = false;
            });
            debugPrint('AuthWrapper: STATE SET TO CLIENT USER - RETURNING');
            return;
          }
        } else if (storedUserType == UserType.hospital) {
          debugPrint(
            'AuthWrapper: User type is HOSPITAL, getting hospital user data...',
          );
          // Get current hospital user data
          final currentHospitalUser =
              await _authService.getCurrentHospitalUser();
          debugPrint(
            'AuthWrapper: getCurrentHospitalUser() returned: ${currentHospitalUser != null ? "HOSPITAL USER FOUND" : "NULL"}',
          );
          if (currentHospitalUser != null) {
            debugPrint(
              'AuthWrapper: Found authenticated hospital user: ${currentHospitalUser.hospitalName}',
            );
            setState(() {
              _isAuthenticated = true;
              _userType = UserType.hospital;
              _currentClientUser = null;
              _currentHospitalUser = currentHospitalUser;
              _isLoading = false;
            });
            debugPrint('AuthWrapper: STATE SET TO HOSPITAL USER - RETURNING');
            return;
          }
        } else {
          debugPrint('AuthWrapper: UNKNOWN USER TYPE: $storedUserType');

          // Try fallback detection using Firebase user email
          final firebaseUser = _authService.currentUser;
          if (firebaseUser != null && firebaseUser.email != null) {
            debugPrint(
              'AuthWrapper: Attempting fallback user type detection for email: ${firebaseUser.email}',
            );

            final fallbackUserType = await _authService.getUserType(
              firebaseUser.uid,
            );

            debugPrint(
              'AuthWrapper: Fallback detection returned: $fallbackUserType',
            );

            if (fallbackUserType == UserType.client) {
              debugPrint(
                'AuthWrapper: Fallback detected CLIENT, getting user data...',
              );
              final currentClientUser =
                  await _authService.getCurrentClientUser();
              if (currentClientUser != null) {
                setState(() {
                  _isAuthenticated = true;
                  _userType = UserType.client;
                  _currentClientUser = currentClientUser;
                  _currentHospitalUser = null;
                  _isLoading = false;
                });
                return;
              }
            } else if (fallbackUserType == UserType.hospital) {
              debugPrint(
                'AuthWrapper: Fallback detected HOSPITAL, getting user data...',
              );
              final currentHospitalUser =
                  await _authService.getCurrentHospitalUser();
              if (currentHospitalUser != null) {
                setState(() {
                  _isAuthenticated = true;
                  _userType = UserType.hospital;
                  _currentClientUser = null;
                  _currentHospitalUser = currentHospitalUser;
                  _isLoading = false;
                });
                return;
              }
            }
          }
        }

        // If we reach here, user type is unknown or user data is invalid
        debugPrint(
          'AuthWrapper: Unknown user type or invalid user data, clearing auth state',
        );
        await _authService.signOut();
      }

      debugPrint(
        'AuthWrapper: User is not authenticated or no valid user found - SHOWING ONBOARDING',
      );
      setState(() {
        _isAuthenticated = false;
        _userType = null;
        _currentClientUser = null;
        _currentHospitalUser = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('AuthWrapper: ERROR checking authentication state: $e');
      setState(() {
        _isAuthenticated = false;
        _userType = null;
        _currentClientUser = null;
        _currentHospitalUser = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // DEBUG: Force hospital view for testing (set this to true to test hospital side)
    const bool forceHospitalView =
        false; // Change this to true to test hospital

    if (_isAuthenticated && forceHospitalView) {
      debugPrint('AuthWrapper: DEBUG - Forcing Hospital view for testing');
      final mockHospitalUser = HospitalUser(
        uid: _authService.currentUser?.uid ?? 'mock_hospital_uid',
        email: _authService.currentUser?.email ?? 'test@hospital.com',
        password: '',
        hospitalName: 'Test Hospital',
        registrationNumber: 'REG123456',
        contactPerson: 'Dr. Test',
        phoneNumber: '1234567890',
        address: 'Hospital Address',
        website: 'www.testhospital.com',
        specializations: ['General Medicine', 'Cardiology'],
        licenseNumber: 'LIC123456',
      );
      return HomeScreenHospital(hospitalUser: mockHospitalUser);
    }

    if (_isAuthenticated &&
        _userType == UserType.client &&
        _currentClientUser != null) {
      debugPrint(
        'AuthWrapper: Navigating to HomeScreenClient for user: ${_currentClientUser!.firstName}',
      );
      return HomeScreenClient(clientUser: _currentClientUser!);
    }

    if (_isAuthenticated &&
        _userType == UserType.hospital &&
        _currentHospitalUser != null) {
      debugPrint(
        'AuthWrapper: Navigating to HomeScreenHospital for user: ${_currentHospitalUser!.hospitalName}',
      );
      return HomeScreenHospital(hospitalUser: _currentHospitalUser!);
    }

    // User is not authenticated, show onboarding
    debugPrint('AuthWrapper: User not authenticated, showing onboarding');
    return const OnboardingScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32), // Healthcare green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.health_and_safety,
                size: 60,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 30),

            // App Name
            const Text(
              'Swasthya Setu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 10),

            // Tagline
            const Text(
              'Your Health, Our Priority',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 50),

            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),

            const SizedBox(height: 20),

            // Loading Text
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
