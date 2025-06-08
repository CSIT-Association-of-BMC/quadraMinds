import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_models.dart';
import '../models/user_type.dart';

class AuthStateService {
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyUserType = 'user_type';
  static const String _keyUserData = 'user_data';
  static const String _keyAuthTimestamp = 'auth_timestamp';
  
  // Singleton pattern
  static final AuthStateService _instance = AuthStateService._internal();
  factory AuthStateService() => _instance;
  AuthStateService._internal();

  /// Save authentication state after successful login/registration
  Future<void> saveAuthState({
    required ClientUser user,
  }) async {
    try {
      debugPrint('AuthStateService: Saving authentication state for user: ${user.uid}');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Save authentication status
      await prefs.setBool(_keyIsAuthenticated, true);
      
      // Save user type
      await prefs.setString(_keyUserType, user.userType.name);
      
      // Save user data as JSON
      final userDataJson = jsonEncode(user.toMap());
      await prefs.setString(_keyUserData, userDataJson);
      
      // Save timestamp for session management
      await prefs.setInt(_keyAuthTimestamp, DateTime.now().millisecondsSinceEpoch);
      
      debugPrint('AuthStateService: Authentication state saved successfully');
    } catch (e) {
      debugPrint('AuthStateService: Error saving auth state: $e');
      rethrow;
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool(_keyIsAuthenticated) ?? false;
      
      if (!isAuth) {
        debugPrint('AuthStateService: User is not authenticated');
        return false;
      }
      
      // Check if session is still valid (optional: implement session timeout)
      final timestamp = prefs.getInt(_keyAuthTimestamp);
      if (timestamp == null) {
        debugPrint('AuthStateService: No auth timestamp found, clearing auth state');
        await clearAuthState();
        return false;
      }
      
      // Optional: Check for session timeout (e.g., 30 days)
      final authTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final daysSinceAuth = now.difference(authTime).inDays;
      
      if (daysSinceAuth > 30) {
        debugPrint('AuthStateService: Session expired (${daysSinceAuth} days old), clearing auth state');
        await clearAuthState();
        return false;
      }
      
      debugPrint('AuthStateService: User is authenticated (session ${daysSinceAuth} days old)');
      return true;
    } catch (e) {
      debugPrint('AuthStateService: Error checking auth state: $e');
      return false;
    }
  }

  /// Get stored user type
  Future<UserType?> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userTypeString = prefs.getString(_keyUserType);
      
      if (userTypeString == null) {
        debugPrint('AuthStateService: No user type found in storage');
        return null;
      }
      
      // Convert string back to UserType enum
      switch (userTypeString) {
        case 'client':
          return UserType.client;
        case 'hospital':
          return UserType.hospital;
        default:
          debugPrint('AuthStateService: Unknown user type: $userTypeString');
          return null;
      }
    } catch (e) {
      debugPrint('AuthStateService: Error getting user type: $e');
      return null;
    }
  }

  /// Get stored user data
  Future<ClientUser?> getStoredClientUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_keyUserData);
      
      if (userDataJson == null) {
        debugPrint('AuthStateService: No user data found in storage');
        return null;
      }
      
      final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
      final clientUser = ClientUser.fromMap(userDataMap);
      
      debugPrint('AuthStateService: Retrieved stored client user: ${clientUser.firstName} ${clientUser.lastName}');
      return clientUser;
    } catch (e) {
      debugPrint('AuthStateService: Error getting stored user data: $e');
      return null;
    }
  }

  /// Clear all authentication state (for logout)
  Future<void> clearAuthState() async {
    try {
      debugPrint('AuthStateService: Clearing authentication state');
      
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_keyIsAuthenticated);
      await prefs.remove(_keyUserType);
      await prefs.remove(_keyUserData);
      await prefs.remove(_keyAuthTimestamp);
      
      debugPrint('AuthStateService: Authentication state cleared successfully');
    } catch (e) {
      debugPrint('AuthStateService: Error clearing auth state: $e');
      rethrow;
    }
  }

  /// Update stored user data (useful for profile updates)
  Future<void> updateStoredUserData(ClientUser user) async {
    try {
      debugPrint('AuthStateService: Updating stored user data for: ${user.uid}');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Update user data
      final userDataJson = jsonEncode(user.toMap());
      await prefs.setString(_keyUserData, userDataJson);
      
      // Update timestamp
      await prefs.setInt(_keyAuthTimestamp, DateTime.now().millisecondsSinceEpoch);
      
      debugPrint('AuthStateService: User data updated successfully');
    } catch (e) {
      debugPrint('AuthStateService: Error updating user data: $e');
      rethrow;
    }
  }

  /// Get authentication details for debugging
  Future<Map<String, dynamic>> getAuthDebugInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_keyAuthTimestamp);
      
      return {
        'isAuthenticated': prefs.getBool(_keyIsAuthenticated) ?? false,
        'userType': prefs.getString(_keyUserType),
        'hasUserData': prefs.getString(_keyUserData) != null,
        'authTimestamp': timestamp,
        'authDate': timestamp != null 
            ? DateTime.fromMillisecondsSinceEpoch(timestamp).toString()
            : null,
        'daysSinceAuth': timestamp != null 
            ? DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)).inDays
            : null,
      };
    } catch (e) {
      debugPrint('AuthStateService: Error getting debug info: $e');
      return {'error': e.toString()};
    }
  }
}
