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
import 'package:hustlehub/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 HustleHub App Starting...');
  
  try {
    debugPrint('🔥 Initializing Firebase...');
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');
    } else {
      debugPrint('✅ Firebase already initialized');
    }
  } catch (e) {
    if ('$e'.contains('duplicate-app')) {
      debugPrint('✅ Firebase already initialized (duplicate detected)');
    } else {
      debugPrint("❌ Firebase init error: $e");
      debugPrint("⚠️  Running in demo mode - Firebase features may be limited");
    }
  }
  
  debugPrint('📦 Setting up providers and launching app...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          debugPrint('📝 Creating AuthProvider');
          return AuthProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('👥 Creating ClientsProvider');
          return ClientsProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('📁 Creating ProjectsProvider');
          return ProjectsProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('✔️ Creating TasksProvider');
          return TasksProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('💰 Creating PaymentsProvider');
          return PaymentsProvider();
        }),
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
    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('❌ Auth error: ${snapshot.error}');
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Firebase Configuration Error', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                      child: const Text('Try Login'),
                    ),
                  ],
                ),
              ),
            );
          }
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
    } catch (e) {
      debugPrint('❌ AuthWrapper error: $e');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Setup Required', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('$e', 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                child: const Text('Continue to Login'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
