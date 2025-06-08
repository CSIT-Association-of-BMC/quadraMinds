import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/auth_wrapper.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Auth Service persistence
  final authService = AuthService();
  await authService.initializeAuthPersistence();

  runApp(const SwasthyaSetuApp());
}

class SwasthyaSetuApp extends StatelessWidget {
  const SwasthyaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swasthya Setu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Healthcare green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
    );
  }
}
