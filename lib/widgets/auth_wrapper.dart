import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_type.dart';
import '../models/user_models.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen_client.dart';

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
  ClientUser? _currentUser;

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
        _currentUser = null;
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
          _currentUser = null;
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
      debugPrint('AuthWrapper: Checking authentication state...');

      // Check if user is authenticated
      final isAuthenticated = await _authService.isUserAuthenticated();

      if (isAuthenticated) {
        debugPrint('AuthWrapper: User is authenticated, getting user data...');

        // Get current user data
        final currentUser = await _authService.getCurrentClientUser();

        if (currentUser != null) {
          debugPrint(
            'AuthWrapper: Found authenticated client user: ${currentUser.firstName} ${currentUser.lastName}',
          );
          setState(() {
            _isAuthenticated = true;
            _userType = UserType.client;
            _currentUser = currentUser;
            _isLoading = false;
          });
          return;
        }
      }

      debugPrint(
        'AuthWrapper: User is not authenticated or no valid user found',
      );
      setState(() {
        _isAuthenticated = false;
        _userType = null;
        _currentUser = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('AuthWrapper: Error checking authentication state: $e');
      setState(() {
        _isAuthenticated = false;
        _userType = null;
        _currentUser = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_isAuthenticated &&
        _userType == UserType.client &&
        _currentUser != null) {
      debugPrint(
        'AuthWrapper: Navigating to HomeScreenClient for user: ${_currentUser!.firstName}',
      );
      return HomeScreenClient(clientUser: _currentUser!);
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
