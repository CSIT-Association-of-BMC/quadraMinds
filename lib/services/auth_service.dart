import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_models.dart';
import '../models/user_type.dart';
import 'auth_state_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthStateService _authStateService = AuthStateService();

  // Initialize Firebase Auth persistence
  Future<void> initializeAuthPersistence() async {
    try {
      debugPrint('AuthService: Initializing Firebase Auth persistence...');

      // Set persistence to LOCAL (default behavior, but explicit)
      // This ensures Firebase Auth state persists across app restarts
      await _auth.setPersistence(Persistence.LOCAL);

      debugPrint(
        'AuthService: Firebase Auth persistence initialized successfully',
      );
    } catch (e) {
      debugPrint('AuthService: Error initializing auth persistence: $e');
      // Don't throw error as this is not critical for functionality
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthService: Attempting to sign in user: $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint(
        'AuthService: Firebase Auth successful for UID: ${result.user?.uid}',
      );

      if (result.user != null) {
        // Try to get user data from local storage first
        debugPrint('AuthService: Checking local user data...');
        final localUserData = await _authStateService.getStoredClientUser();

        if (localUserData != null) {
          debugPrint('AuthService: Local user data found');
          final userData = {
            'uid': localUserData.uid,
            'email': localUserData.email,
            'firstName': localUserData.firstName,
            'lastName': localUserData.lastName,
            'phoneNumber': localUserData.phoneNumber,
            'dateOfBirth': localUserData.dateOfBirth?.toIso8601String(),
            'address': localUserData.address,
            'emergencyContact': localUserData.emergencyContact,
            'userType': 'client',
          };
          return {'success': true, 'user': result.user, 'userData': userData};
        }

        // Check for hospital user data
        final localHospitalData =
            await _authStateService.getStoredHospitalUser();
        if (localHospitalData != null) {
          debugPrint('AuthService: Local hospital data found');
          final userData = {
            'uid': localHospitalData.uid,
            'email': localHospitalData.email,
            'hospitalName': localHospitalData.hospitalName,
            'registrationNumber': localHospitalData.registrationNumber,
            'contactPerson': localHospitalData.contactPerson,
            'phoneNumber': localHospitalData.phoneNumber,
            'address': localHospitalData.address,
            'website': localHospitalData.website,
            'specializations': localHospitalData.specializations,
            'licenseNumber': localHospitalData.licenseNumber,
            'userType': 'hospital',
          };
          return {'success': true, 'user': result.user, 'userData': userData};
        }

        debugPrint(
          'AuthService: No local user data found, creating fallback data',
        );

        // Enhanced fallback logic when Firestore data is missing or incomplete
        debugPrint('AuthService: Creating enhanced fallback user data...');

        // Try to extract name from email as a better fallback
        String fallbackFirstName = '';
        String fallbackLastName = '';

        if (result.user!.email != null && result.user!.email!.isNotEmpty) {
          final emailParts = result.user!.email!.split('@');
          if (emailParts.isNotEmpty) {
            final emailName = emailParts[0];
            // Try to split by common separators
            final nameParts = emailName.split(RegExp(r'[._-]'));
            if (nameParts.length >= 2) {
              fallbackFirstName = _capitalizeFirst(nameParts[0]);
              fallbackLastName = _capitalizeFirst(nameParts[1]);
            } else {
              fallbackFirstName = _capitalizeFirst(emailName);
            }
          }
        }

        // If displayName is available, prefer it over email extraction
        if (result.user!.displayName != null &&
            result.user!.displayName!.isNotEmpty) {
          final displayNameParts = result.user!.displayName!.split(' ');
          fallbackFirstName = displayNameParts.first;
          if (displayNameParts.length > 1) {
            fallbackLastName = displayNameParts.skip(1).join(' ');
          }
        }

        final fallbackUserData = {
          'email': result.user!.email ?? '',
          'uid': result.user!.uid,
          'userType': 'client', // Default to client
          'firstName': fallbackFirstName,
          'lastName': fallbackLastName,
          'phoneNumber': '',
          'address': null,
          'emergencyContact': null,
        };

        debugPrint(
          'AuthService: Using enhanced fallback user data: $fallbackUserData',
        );
        // Save authentication state for client users
        if (fallbackUserData['userType'] == 'client') {
          try {
            final clientUser = ClientUser(
              uid: result.user!.uid,
              email: fallbackUserData['email'] ?? result.user!.email ?? '',
              password: '', // Don't store password
              firstName: fallbackUserData['firstName'] ?? '',
              lastName: fallbackUserData['lastName'] ?? '',
              phoneNumber: fallbackUserData['phoneNumber'] ?? '',
              dateOfBirth:
                  fallbackUserData['dateOfBirth'] != null
                      ? (fallbackUserData['dateOfBirth'] is String
                          ? DateTime.tryParse(
                            fallbackUserData['dateOfBirth'] as String,
                          )
                          : fallbackUserData['dateOfBirth'] as DateTime?)
                      : null,
              address: fallbackUserData['address'],
              emergencyContact: fallbackUserData['emergencyContact'],
            );

            await _authStateService.saveAuthState(user: clientUser);
            debugPrint('AuthService: Authentication state saved successfully');
          } catch (e) {
            debugPrint('AuthService: Failed to save auth state: $e');
            // Don't fail the login if state saving fails
          }
        }

        return {
          'success': true,
          'user': result.user,
          'userData': fallbackUserData,
        };
      }
      debugPrint(
        'AuthService: Login failed - no user returned from Firebase Auth',
      );
      return {'success': false, 'error': 'Login failed - no user returned'};
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception: ${e.code} - ${e.message}',
      );
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      debugPrint('AuthService: Unexpected error during sign in: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Register client user
  Future<Map<String, dynamic>> registerClient({
    required ClientUser clientUser,
  }) async {
    try {
      debugPrint(
        'AuthService: Starting client registration for ${clientUser.email}',
      );

      // Test Firebase connection first by checking current user
      try {
        // Simple connection test - this will fail quickly if no connection
        final currentUser = _auth.currentUser;
        debugPrint(
          'AuthService: Firebase connection test successful (current user: ${currentUser?.uid})',
        );
      } catch (connectionError) {
        debugPrint(
          'AuthService: Firebase connection test failed: $connectionError',
        );
        return {
          'success': false,
          'error':
              'Unable to connect to Firebase. Please check your internet connection and try again.',
        };
      }

      // Create user with timeout
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(
            email: clientUser.email,
            password: clientUser.password,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Firebase Auth timeout - please check your internet connection',
              );
            },
          );

      debugPrint(
        'AuthService: Firebase Auth user created with UID: ${result.user?.uid}',
      );

      if (result.user != null) {
        // Update user's display name in Firebase Auth
        try {
          await result.user!.updateDisplayName(
            '${clientUser.firstName} ${clientUser.lastName}',
          );
          debugPrint('AuthService: Updated user display name successfully');
        } catch (displayNameError) {
          debugPrint(
            'AuthService: Failed to update display name: $displayNameError',
          );
          // Don't fail registration if display name update fails
        }

        // Save authentication state
        try {
          final clientUserWithUid = ClientUser(
            uid: result.user!.uid,
            email: clientUser.email,
            password: '', // Don't store password
            firstName: clientUser.firstName,
            lastName: clientUser.lastName,
            phoneNumber: clientUser.phoneNumber,
            dateOfBirth: clientUser.dateOfBirth,
            address: clientUser.address,
            emergencyContact: clientUser.emergencyContact,
          );

          await _authStateService.saveAuthState(user: clientUserWithUid);
          debugPrint(
            'AuthService: Authentication state saved after registration',
          );
        } catch (e) {
          debugPrint(
            'AuthService: Failed to save auth state after registration: $e',
          );
          // Don't fail the registration if state saving fails
        }

        return {'success': true, 'user': result.user, 'userData': clientUser};
      }
      debugPrint('AuthService: Registration failed - no user returned');
      return {
        'success': false,
        'error': 'Registration failed - no user created',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception: ${e.code} - ${e.message}',
      );
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      debugPrint('AuthService: Unexpected error during registration: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Register hospital user
  Future<Map<String, dynamic>> registerHospital({
    required HospitalUser hospitalUser,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: hospitalUser.email,
        password: hospitalUser.password,
      );

      if (result.user != null) {
        // Update user's display name in Firebase Auth
        try {
          await result.user!.updateDisplayName(hospitalUser.hospitalName);
          debugPrint('AuthService: Updated hospital display name successfully');
        } catch (displayNameError) {
          debugPrint(
            'AuthService: Failed to update hospital display name: $displayNameError',
          );
          // Don't fail registration if display name update fails
        }

        // Save authentication state for hospital users
        try {
          final hospitalUserWithUid = HospitalUser(
            uid: result.user!.uid,
            email: hospitalUser.email,
            password: '', // Don't store password
            hospitalName: hospitalUser.hospitalName,
            registrationNumber: hospitalUser.registrationNumber,
            contactPerson: hospitalUser.contactPerson,
            phoneNumber: hospitalUser.phoneNumber,
            address: hospitalUser.address,
            website: hospitalUser.website,
            specializations: hospitalUser.specializations,
            licenseNumber: hospitalUser.licenseNumber,
          );

          await _authStateService.saveHospitalAuthState(
            user: hospitalUserWithUid,
          );
          debugPrint(
            'AuthService: Hospital authentication state saved after registration',
          );
        } catch (e) {
          debugPrint(
            'AuthService: Failed to save hospital auth state after registration: $e',
          );
          // Don't fail the registration if state saving fails
        }

        return {'success': true, 'user': result.user, 'userData': hospitalUser};
      }
      return {'success': false, 'error': 'Registration failed'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
  }

  // Get user data from local storage
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      debugPrint(
        'AuthService: Getting user data for UID: $uid from local storage',
      );

      // Check for client user data first
      final clientUser = await _authStateService.getStoredClientUser();
      if (clientUser != null && clientUser.uid == uid) {
        debugPrint('AuthService: Found client user data in local storage');
        return {
          'uid': clientUser.uid,
          'email': clientUser.email,
          'firstName': clientUser.firstName,
          'lastName': clientUser.lastName,
          'phoneNumber': clientUser.phoneNumber,
          'dateOfBirth': clientUser.dateOfBirth?.toIso8601String(),
          'address': clientUser.address,
          'emergencyContact': clientUser.emergencyContact,
          'userType': 'client',
        };
      }

      // Check for hospital user data
      final hospitalUser = await _authStateService.getStoredHospitalUser();
      if (hospitalUser != null && hospitalUser.uid == uid) {
        debugPrint('AuthService: Found hospital user data in local storage');
        return {
          'uid': hospitalUser.uid,
          'email': hospitalUser.email,
          'hospitalName': hospitalUser.hospitalName,
          'registrationNumber': hospitalUser.registrationNumber,
          'contactPerson': hospitalUser.contactPerson,
          'phoneNumber': hospitalUser.phoneNumber,
          'address': hospitalUser.address,
          'website': hospitalUser.website,
          'specializations': hospitalUser.specializations,
          'licenseNumber': hospitalUser.licenseNumber,
          'userType': 'hospital',
        };
      }

      debugPrint(
        'AuthService: No user data found in local storage for UID: $uid',
      );
      return null;
    } catch (e) {
      debugPrint('AuthService: Error getting user data from local storage: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final currentUser = _auth.currentUser;
      debugPrint(
        'AuthService: Starting sign out process for user: ${currentUser?.uid ?? 'No user'}',
      );

      // Clear local authentication state first
      debugPrint('AuthService: Clearing local authentication state...');
      await _authStateService.clearAuthState();
      debugPrint(
        'AuthService: Local authentication state cleared successfully',
      );

      // Sign out from Firebase
      debugPrint('AuthService: Signing out from Firebase...');
      await _auth.signOut();
      debugPrint('AuthService: Firebase sign out completed');

      // Verify sign out was successful
      final userAfterSignOut = _auth.currentUser;
      if (userAfterSignOut == null) {
        debugPrint(
          'AuthService: Sign out verification successful - no current user',
        );
      } else {
        debugPrint(
          'AuthService: Warning - User still exists after sign out: ${userAfterSignOut.uid}',
        );
      }

      debugPrint('AuthService: User signed out successfully');
    } catch (e) {
      debugPrint('AuthService: Error during sign out: $e');
      debugPrint('AuthService: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Save authentication state for client user (wrapper method)
  Future<void> saveAuthState({required ClientUser user}) async {
    try {
      await _authStateService.saveAuthState(user: user);
    } catch (e) {
      debugPrint('AuthService: Error saving client auth state: $e');
      rethrow;
    }
  }

  // Save authentication state for hospital user (wrapper method)
  Future<void> saveHospitalAuthState({required HospitalUser user}) async {
    try {
      await _authStateService.saveHospitalAuthState(user: user);
    } catch (e) {
      debugPrint('AuthService: Error saving hospital auth state: $e');
      rethrow;
    }
  }

  // Check if user is authenticated (prioritize Firebase auth state)
  Future<bool> isUserAuthenticated() async {
    try {
      // Check Firebase auth state first
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        debugPrint('AuthService: No Firebase user found');
        // Clear local state if Firebase user is null
        await _authStateService.clearAuthState();
        return false;
      }

      debugPrint('AuthService: Firebase user found: ${firebaseUser.uid}');

      // Check local authentication state
      final isLocallyAuthenticated = await _authStateService.isAuthenticated();
      if (!isLocallyAuthenticated) {
        debugPrint(
          'AuthService: User not authenticated locally, but Firebase user exists',
        );

        // Try to create fallback user data from Firebase user info
        try {
          debugPrint(
            'AuthService: Creating fallback user data from Firebase user',
          );

          // Extract name from email or display name
          String fallbackFirstName = '';
          String fallbackLastName = '';

          if (firebaseUser.displayName != null &&
              firebaseUser.displayName!.isNotEmpty) {
            final displayNameParts = firebaseUser.displayName!.split(' ');
            fallbackFirstName = displayNameParts.first;
            if (displayNameParts.length > 1) {
              fallbackLastName = displayNameParts.skip(1).join(' ');
            }
          } else if (firebaseUser.email != null &&
              firebaseUser.email!.isNotEmpty) {
            final emailParts = firebaseUser.email!.split('@');
            if (emailParts.isNotEmpty) {
              final emailName = emailParts[0];
              final nameParts = emailName.split(RegExp(r'[._-]'));
              if (nameParts.length >= 2) {
                fallbackFirstName = _capitalizeFirst(nameParts[0]);
                fallbackLastName = _capitalizeFirst(nameParts[1]);
              } else {
                fallbackFirstName = _capitalizeFirst(emailName);
              }
            }
          }

          final clientUser = ClientUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            password: '', // Don't store password
            firstName: fallbackFirstName,
            lastName: fallbackLastName,
            phoneNumber: '',
            dateOfBirth: null,
            address: null,
            emergencyContact: null,
          );

          await _authStateService.saveAuthState(user: clientUser);
          debugPrint(
            'AuthService: Fallback local auth state created successfully',
          );
          return true;
        } catch (e) {
          debugPrint('AuthService: Failed to create fallback auth state: $e');
        }

        return false;
      }

      debugPrint('AuthService: User is authenticated (Firebase + Local)');
      return true;
    } catch (e) {
      debugPrint('AuthService: Error checking authentication: $e');
      return false;
    }
  }

  // Get current authenticated client user
  Future<ClientUser?> getCurrentClientUser() async {
    try {
      final isAuth = await isUserAuthenticated();
      if (!isAuth) {
        debugPrint(
          'AuthService: User not authenticated, cannot get client user',
        );
        return null;
      }

      final userType = await _authStateService.getUserType();
      if (userType != UserType.client) {
        debugPrint('AuthService: User is not a client type');
        return null;
      }

      final clientUser = await _authStateService.getStoredClientUser();
      debugPrint(
        'AuthService: Retrieved current client user: ${clientUser?.firstName} ${clientUser?.lastName}',
      );
      return clientUser;
    } catch (e) {
      debugPrint('AuthService: Error getting current client user: $e');
      return null;
    }
  }

  // Get current authenticated hospital user
  Future<HospitalUser?> getCurrentHospitalUser() async {
    try {
      final isAuth = await isUserAuthenticated();
      if (!isAuth) {
        debugPrint(
          'AuthService: User not authenticated, cannot get hospital user',
        );
        return null;
      }

      final userType = await _authStateService.getUserType();
      if (userType != UserType.hospital) {
        debugPrint('AuthService: User is not a hospital type');
        return null;
      }

      final hospitalUser = await _authStateService.getStoredHospitalUser();
      debugPrint(
        'AuthService: Retrieved current hospital user: ${hospitalUser?.hospitalName}',
      );
      return hospitalUser;
    } catch (e) {
      debugPrint('AuthService: Error getting current hospital user: $e');
      return null;
    }
  }

  // Get stored user type (wrapper for AuthStateService method)
  Future<UserType?> getStoredUserType() async {
    try {
      return await _authStateService.getUserType();
    } catch (e) {
      debugPrint('AuthService: Error getting stored user type: $e');
      return null;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
  }

  // Change password for authenticated user
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user is currently signed in'};
      }

      debugPrint(
        'AuthService: Attempting to change password for user: ${user.email}',
      );

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      debugPrint('AuthService: User re-authentication successful');

      // Update password
      await user.updatePassword(newPassword);
      debugPrint('AuthService: Password updated successfully');

      return {'success': true, 'message': 'Password changed successfully'};
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception during password change: ${e.code} - ${e.message}',
      );
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      debugPrint('AuthService: Unexpected error during password change: $e');
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      debugPrint('AuthService: Attempting to delete user account: ${user.uid}');

      // Clear local authentication state (this removes all local user data)
      await _authStateService.clearAuthState();
      debugPrint('AuthService: Local auth state and user data cleared');

      // Delete Firebase Auth user
      await user.delete();
      debugPrint('AuthService: Firebase Auth user deleted successfully');
    } catch (e) {
      debugPrint('AuthService: Error deleting user account: $e');
      rethrow;
    }
  }

  // Get user type from local storage
  Future<UserType?> getUserType(String uid) async {
    try {
      // Use the AuthStateService method which gets user type from local storage
      return await _authStateService.getUserType();
    } catch (e) {
      debugPrint('Error getting user type: $e');
      return null;
    }
  }

  // Enhanced email-based user type detection with Gmail-specific logic
  Future<UserType?> detectUserTypeFromEmail(String email) async {
    try {
      debugPrint('AuthService: Detecting user type from email: $email');

      // First check local storage for existing user type by email
      final storedUserTypeByEmail = await _authStateService.getUserTypeByEmail(
        email,
      );
      if (storedUserTypeByEmail != null) {
        debugPrint(
          'AuthService: Found stored user type by email: ${storedUserTypeByEmail.name}',
        );
        return storedUserTypeByEmail;
      }

      // Fallback to general stored user type
      final storedUserType = await _authStateService.getUserType();
      if (storedUserType != null) {
        debugPrint(
          'AuthService: Found general stored user type: ${storedUserType.name}',
        );
        return storedUserType;
      }

      // Check if we have stored client user data with this email
      final storedClientUser = await _authStateService.getStoredClientUser();
      if (storedClientUser != null &&
          storedClientUser.email.toLowerCase() == email.toLowerCase()) {
        debugPrint('AuthService: Found client user data for email');
        return UserType.client;
      }

      // Check if we have stored hospital user data with this email
      final storedHospitalUser =
          await _authStateService.getStoredHospitalUser();
      if (storedHospitalUser != null &&
          storedHospitalUser.email.toLowerCase() == email.toLowerCase()) {
        debugPrint('AuthService: Found hospital user data for email');
        return UserType.hospital;
      }

      // Enhanced email pattern-based detection
      final emailLower = email.toLowerCase();
      final emailUsername = emailLower.split('@').first;
      final emailDomain =
          emailLower.contains('@') ? emailLower.split('@').last : '';

      debugPrint(
        'AuthService: Analyzing email - Username: $emailUsername, Domain: $emailDomain',
      );

      // Enhanced hospital email patterns with more comprehensive coverage
      final hospitalPatterns = [
        // Medical institutions
        'hospital',
        'medical',
        'health',
        'clinic',
        'healthcare',
        'medcenter',
        'medicalcenter',
        'hospice', 'infirmary', 'sanitarium', 'polyclinic', 'dispensary',

        // Medical specialties
        'surgery',
        'cardiology',
        'oncology',
        'pediatrics',
        'orthopedics',
        'neurology',
        'radiology', 'pathology', 'pharmacy', 'dental', 'veterinary', 'rehab',
        'psychiatry',
        'therapy',
        'physiotherapy',
        'dermatology',
        'ophthalmology',
        'ent', 'gynecology', 'urology', 'gastroenterology', 'pulmonology',
        'nephrology',
        'endocrinology',
        'hematology',
        'immunology',
        'anesthesiology',
        'surgical', 'obstetrics', 'geriatrics', 'rheumatology', 'infectious',

        // Medical professionals
        'doctor', 'dr', 'physician', 'specialist', 'consultant', 'practitioner',
        'surgeon', 'nurse', 'medic', 'paramedic', 'therapist', 'pharmacist',

        // Healthcare facilities and services
        'nursing', 'care', 'wellness', 'diagnostic', 'laboratory', 'lab',
        'emergency', 'trauma', 'icu', 'nicu', 'maternity', 'ambulatory',
        'outpatient', 'inpatient', 'rehabilitation', 'recovery', 'treatment',

        // Medical organizations and networks
        'healthsystem', 'healthnetwork', 'medgroup', 'healthgroup', 'mednet',
        'healthcorp',
        'medcorp',
        'healthservices',
        'medservices',
        'healthcenter',
        'medic',
        'nurse',
        'paramedic',
        'therapist',
        'counselor',
        'psychologist',
        'psychiatrist',
        'pharmacist',
        'technician',
        'technologist',
        'assistant',
        'aide',
        'coordinator',
        'administrator',
        'manager',
        'director',
        'supervisor',
        'staff',
        'employee',
        'worker',
        'professional',
        'provider',
        'service',
        'services',
        'center',
        'centre',
        'institute',
        'institution',
        'foundation',
        'organization',
        'association',
        'society',
        'group',
        'network',
        'system',
        'systems',
        'corp',
        'corporation',
        'company',
        'inc',
        'ltd',
        'llc',
        'org',
        'gov',
        'edu',
        'ac',
        'nhs',
        'who',
        'cdc',
        'nih',
        'fda',
        'cms',
        'hhs',
        'va',
        'dod',
        'military',
        'army',
        'navy',
        'airforce',
        'marines',
        'coastguard',
        'veterans',
        'public',
        'state',
        'county',
        'city',
        'municipal',
        'federal',
        'national',
        'regional',
        'local',
        'community',
        'rural',
        'urban',
        'suburban',
        'metro',
        'metropolitan',
        'district',
        'zone',
        'area',
        'region',
        'territory',
        'province',
        'state',
        'country',
        'nation',
        'international',
        'global',
        'worldwide',
        'universal',
        'general',
        'specialty',
        'specialized',
        'comprehensive',
        'integrated',
        'holistic',
        'alternative',
        'complementary',
        'traditional',
        'modern',
        'advanced',
        'innovative',
        'cutting-edge',
        'state-of-the-art',
        'world-class',
        'premier',
        'leading',
        'top',
        'best',
        'excellent',
        'quality',
        'superior',
        'outstanding',
        'exceptional',
        'remarkable',
        'extraordinary',
        'unique',
        'special',
        'exclusive',
        'premium',
        'luxury',
        'elite',
        'prestigious',
        'renowned',
        'famous',
        'well-known',
        'established',
        'trusted',
        'reliable',
        'dependable',
        'professional',
        'expert',
        'experienced',
        'skilled',
        'qualified',
        'certified',
        'licensed',
        'accredited',
        'approved',
        'authorized',
        'recognized',
        'endorsed',
        'recommended',
        'preferred',
        'chosen',
        'selected',
        'designated',
        'appointed',
        'assigned',
        'allocated',
        'dedicated',
        'committed',
        'devoted',
        'focused',
        'specialized',
        'concentrated',
        'centralized',
        'decentralized',
        'distributed',
        'networked',
        'connected',
        'linked',
        'associated',
        'affiliated',
        'partnered',
        'allied',
        'united',
        'joint',
        'collaborative',
        'cooperative',
        'coordinated',
        'integrated',
        'unified',
        'consolidated',
        'merged',
        'combined',
        'joined',
        'connected',
        'linked',
        'associated',
        'affiliated',
        'partnered',
        'allied',
        'united',
        'joint',
        'collaborative',
        'cooperative',
        'coordinated',
        'integrated',
        'unified',
        'consolidated',
        'merged',
        'combined',
        'joined',
      ];

      // Special handling for Gmail and other common email providers
      final isCommonProvider = [
        'gmail.com',
        'yahoo.com',
        'hotmail.com',
        'outlook.com',
        'icloud.com',
        'aol.com',
        'live.com',
        'msn.com',
      ].contains(emailDomain);

      if (isCommonProvider) {
        debugPrint('AuthService: Detected common email provider: $emailDomain');

        // For Gmail and other common providers, focus on username patterns
        // Check if username contains hospital-related patterns
        for (final pattern in hospitalPatterns) {
          if (emailUsername.contains(pattern)) {
            debugPrint(
              'AuthService: Gmail username contains hospital pattern: $pattern',
            );
            return UserType.hospital;
          }
        }

        // Additional Gmail-specific patterns for hospitals
        final gmailHospitalPatterns = [
          'hosp',
          'med',
          'clinic',
          'health',
          'care',
          'doc',
          'dr',
          'nurse',
          'pharmacy',
          'dental',
          'vet',
          'therapy',
          'rehab',
          'surgery',
          'cardio',
          'neuro',
          'ortho',
          'pedia',
          'gyne',
          'uro',
          'ent',
          'admin',
          'staff',
          'dept',
          'unit',
          'ward',
          'icu',
          'er',
          'lab',
        ];

        for (final pattern in gmailHospitalPatterns) {
          if (emailUsername.contains(pattern)) {
            debugPrint(
              'AuthService: Gmail username contains specific hospital pattern: $pattern',
            );
            return UserType.hospital;
          }
        }

        // Check for common hospital naming conventions in Gmail
        // e.g., firstname.lastname.hospital@gmail.com, hospitalname.admin@gmail.com
        if (emailUsername.contains('.')) {
          final usernameParts = emailUsername.split('.');
          for (final part in usernameParts) {
            for (final pattern in hospitalPatterns) {
              if (part == pattern ||
                  part.startsWith(pattern) ||
                  part.endsWith(pattern)) {
                debugPrint(
                  'AuthService: Gmail username part contains hospital pattern: $part -> $pattern',
                );
                return UserType.hospital;
              }
            }
          }
        }

        debugPrint(
          'AuthService: No hospital patterns found in Gmail username, defaulting to client',
        );
        return UserType.client;
      } else {
        // For institutional domains, check both domain and username
        debugPrint('AuthService: Checking institutional domain: $emailDomain');

        // Check domain for hospital patterns
        for (final pattern in hospitalPatterns) {
          if (emailDomain.contains(pattern)) {
            debugPrint(
              'AuthService: Domain contains hospital pattern: $pattern',
            );
            return UserType.hospital;
          }
        }

        // Check username for hospital patterns
        for (final pattern in hospitalPatterns) {
          if (emailUsername.contains(pattern)) {
            debugPrint(
              'AuthService: Username contains hospital pattern: $pattern',
            );
            return UserType.hospital;
          }
        }

        // Check for common institutional domain patterns
        final institutionalPatterns = ['.edu', '.gov', '.org', '.mil'];
        final hasInstitutionalDomain = institutionalPatterns.any(
          (pattern) => emailDomain.endsWith(pattern),
        );

        if (hasInstitutionalDomain) {
          debugPrint(
            'AuthService: Institutional domain detected, checking for healthcare context',
          );
          // For institutional domains, be more lenient with healthcare detection
          final healthcareKeywords = [
            'health',
            'med',
            'hospital',
            'clinic',
            'care',
          ];
          for (final keyword in healthcareKeywords) {
            if (emailDomain.contains(keyword) ||
                emailUsername.contains(keyword)) {
              debugPrint(
                'AuthService: Healthcare context found in institutional email',
              );
              return UserType.hospital;
            }
          }
        }

        debugPrint(
          'AuthService: No hospital patterns found in institutional domain, defaulting to client',
        );
        return UserType.client;
      }
    } catch (e) {
      debugPrint('AuthService: Error detecting user type from email: $e');
      // Default to client on error
      return UserType.client;
    }
  }

  // Helper method to capitalize first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Debug method to check authentication state
  Future<Map<String, dynamic>> getAuthDebugInfo() async {
    try {
      final firebaseUser = _auth.currentUser;
      final localAuthInfo = await _authStateService.getAuthDebugInfo();
      final isAuthenticated = await isUserAuthenticated();
      final currentUser = await getCurrentClientUser();

      return {
        'firebaseUser': {
          'uid': firebaseUser?.uid,
          'email': firebaseUser?.email,
          'isAnonymous': firebaseUser?.isAnonymous,
          'emailVerified': firebaseUser?.emailVerified,
        },
        'localAuth': localAuthInfo,
        'isAuthenticated': isAuthenticated,
        'currentUser':
            currentUser != null
                ? {
                  'uid': currentUser.uid,
                  'email': currentUser.email,
                  'firstName': currentUser.firstName,
                  'lastName': currentUser.lastName,
                }
                : null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address. Please check your email or create a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please try logging in instead.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 8 characters with uppercase, lowercase, and numbers.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes before trying again.';
      case 'operation-not-allowed':
        return 'This operation is not currently allowed. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection and try again.';
      case 'timeout':
        return 'The request timed out. Please check your connection and try again.';
      default:
        return 'An unexpected error occurred. Please check your connection and try again.';
    }
  }
}
