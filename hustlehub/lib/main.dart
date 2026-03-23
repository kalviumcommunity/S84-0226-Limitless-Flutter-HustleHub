import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:hustlehub/theme/app_theme.dart';
import 'package:hustlehub/providers/auth_provider.dart';
import 'package:hustlehub/providers/clients_provider.dart';
import 'package:hustlehub/providers/projects_provider.dart';
import 'package:hustlehub/providers/tasks_provider.dart';
import 'package:hustlehub/providers/payments_provider.dart';
import 'package:hustlehub/screens/login_screen.dart';
import 'package:hustlehub/screens/signup_screen.dart';
import 'package:hustlehub/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error (might need firebase_options.dart): $e");
  }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ClientsProvider()),
          ChangeNotifierProvider(create: (_) => ProjectsProvider()),
          ChangeNotifierProvider(create: (_) => TasksProvider()),
          ChangeNotifierProvider(create: (_) => PaymentsProvider()),
        ],
        child: const HustleHubApp(),
      ),
    );
}

class HustleHubApp extends StatelessWidget {
  const HustleHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HustleHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
