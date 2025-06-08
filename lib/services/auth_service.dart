import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_models.dart';
import '../models/user_type.dart';
import 'auth_state_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        // Get user data from Firestore
        debugPrint('AuthService: Fetching user data from Firestore...');
        final userData = await getUserData(result.user!.uid);

        if (userData != null) {
          debugPrint('AuthService: User data retrieved successfully');
          debugPrint('AuthService: User data details: $userData');

          // Validate that we have essential user information
          final hasValidData =
              (userData['firstName'] != null &&
                  userData['firstName'].toString().isNotEmpty) ||
              (userData['lastName'] != null &&
                  userData['lastName'].toString().isNotEmpty) ||
              (userData['hospitalName'] != null &&
                  userData['hospitalName'].toString().isNotEmpty) ||
              (userData['contactPerson'] != null &&
                  userData['contactPerson'].toString().isNotEmpty);

          if (hasValidData) {
            return {'success': true, 'user': result.user, 'userData': userData};
          } else {
            debugPrint(
              'AuthService: Warning - User data found but missing essential name fields',
            );
          }
        } else {
          debugPrint(
            'AuthService: Warning - No user data found in Firestore, but auth succeeded',
          );
        }

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
        // Store client data in Firestore with timeout
        final userData = {
          'uid': result.user!.uid,
          'email': clientUser.email,
          'firstName': clientUser.firstName,
          'lastName': clientUser.lastName,
          'phoneNumber': clientUser.phoneNumber,
          'dateOfBirth': clientUser.dateOfBirth?.toIso8601String(),
          'address': clientUser.address,
          'emergencyContact': clientUser.emergencyContact,
          'userType': 'client',
          'createdAt': FieldValue.serverTimestamp(),
        };

        debugPrint('AuthService: Storing user data in Firestore...');
        try {
          await _firestore
              .collection('clients')
              .doc(result.user!.uid)
              .set(userData)
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  throw Exception(
                    'Firestore write timeout - please check your internet connection',
                  );
                },
              );
          debugPrint('AuthService: User data stored successfully');
        } catch (firestoreError) {
          debugPrint('AuthService: Firestore error: $firestoreError');
          // Even if Firestore fails, we can still return success since the user was created
          // The user data can be added later or the user can still use the app
          debugPrint(
            'AuthService: Continuing with registration despite Firestore error',
          );

          // Try to update the user's display name as a fallback
          try {
            await result.user!.updateDisplayName(
              '${clientUser.firstName} ${clientUser.lastName}',
            );
            debugPrint('AuthService: Updated user display name as fallback');
          } catch (displayNameError) {
            debugPrint(
              'AuthService: Failed to update display name: $displayNameError',
            );
          }
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
        // Store hospital data in Firestore
        await _firestore.collection('hospitals').doc(result.user!.uid).set({
          'uid': result.user!.uid,
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
          'createdAt': FieldValue.serverTimestamp(),
        });

        return {'success': true, 'user': result.user, 'userData': hospitalUser};
      }
      return {'success': false, 'error': 'Registration failed'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
  }

  // Get user data from Firestore with retry mechanism
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        debugPrint(
          'AuthService: Getting user data for UID: $uid (attempt ${retryCount + 1}/$maxRetries)',
        );

        // Check clients collection first with timeout
        debugPrint('AuthService: Checking clients collection...');
        DocumentSnapshot clientDoc = await _firestore
            .collection('clients')
            .doc(uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception(
                  'Firestore read timeout for clients collection',
                );
              },
            );

        if (clientDoc.exists) {
          final data = clientDoc.data() as Map<String, dynamic>;
          debugPrint(
            'AuthService: Found user data in clients collection: $data',
          );

          // Validate that essential fields exist
          if (data['firstName'] != null ||
              data['lastName'] != null ||
              data['email'] != null) {
            return data;
          } else {
            debugPrint(
              'AuthService: Warning - Client data exists but missing essential fields',
            );
          }
        }

        // Check hospitals collection with timeout
        debugPrint('AuthService: Checking hospitals collection...');
        DocumentSnapshot hospitalDoc = await _firestore
            .collection('hospitals')
            .doc(uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception(
                  'Firestore read timeout for hospitals collection',
                );
              },
            );

        if (hospitalDoc.exists) {
          final data = hospitalDoc.data() as Map<String, dynamic>;
          debugPrint(
            'AuthService: Found user data in hospitals collection: $data',
          );
          return data;
        }

        debugPrint('AuthService: No user data found in either collection');
        return null;
      } catch (e) {
        retryCount++;
        debugPrint(
          'AuthService: Error getting user data (attempt $retryCount): $e',
        );

        if (retryCount >= maxRetries) {
          debugPrint('AuthService: Max retries reached, giving up');
          return null;
        }

        debugPrint(
          'AuthService: Retrying in ${retryDelay.inSeconds} seconds...',
        );
        await Future.delayed(retryDelay);
      }
    }

    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('AuthService: Signing out user');

      // Clear local authentication state
      await _authStateService.clearAuthState();

      // Sign out from Firebase
      await _auth.signOut();

      debugPrint('AuthService: User signed out successfully');
    } catch (e) {
      debugPrint('AuthService: Error during sign out: $e');
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

        // Try to restore local state from Firebase user data
        try {
          final userData = await getUserData(firebaseUser.uid);
          if (userData != null && userData['userType'] == 'client') {
            debugPrint(
              'AuthService: Restoring local auth state from Firebase data',
            );

            final clientUser = ClientUser(
              uid: firebaseUser.uid,
              email: userData['email'] ?? firebaseUser.email ?? '',
              password: '', // Don't store password
              firstName: userData['firstName'] ?? '',
              lastName: userData['lastName'] ?? '',
              phoneNumber: userData['phoneNumber'] ?? '',
              dateOfBirth:
                  userData['dateOfBirth'] != null
                      ? (userData['dateOfBirth'] is String
                          ? DateTime.tryParse(userData['dateOfBirth'] as String)
                          : userData['dateOfBirth'] as DateTime?)
                      : null,
              address: userData['address'],
              emergencyContact: userData['emergencyContact'],
            );

            await _authStateService.saveAuthState(user: clientUser);
            debugPrint('AuthService: Local auth state restored successfully');
            return true;
          }
        } catch (e) {
          debugPrint('AuthService: Failed to restore local auth state: $e');
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

  // Get user type from Firestore
  Future<UserType?> getUserType(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData != null && userData['userType'] != null) {
        return userData['userType'] == 'client'
            ? UserType.client
            : UserType.hospital;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user type: $e');
      return null;
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
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
