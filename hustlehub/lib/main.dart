import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/clients_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/payments_provider.dart';
import 'providers/projects_provider.dart';
import 'screens/home_screen.dart'; // landing page
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/payments_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization is optional during local setup.
  // If config files are missing, providers gracefully fall back to local mode.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ClientsProvider>(
          create: (_) => ClientsProvider(),
          update: (_, auth, clientsProvider) {
            final provider = clientsProvider ?? ClientsProvider();
            provider.updateUserId(auth.currentUser?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TasksProvider>(
          create: (_) => TasksProvider(),
          update: (_, auth, tasksProvider) {
            final provider = tasksProvider ?? TasksProvider();
            provider.updateUserId(auth.currentUser?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, PaymentsProvider>(
          create: (_) => PaymentsProvider(),
          update: (_, auth, paymentsProvider) {
            final provider = paymentsProvider ?? PaymentsProvider();
            provider.updateUserId(auth.currentUser?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProjectsProvider>(
          create: (_) => ProjectsProvider(),
          update: (_, auth, projectsProvider) {
            final provider = projectsProvider ?? ProjectsProvider();
            provider.updateUserId(auth.currentUser?.id);
            return provider;
          },
        ),
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
      debugShowCheckedModeBanner: false,
      // start on landing page; user can sign in or sign up from there
      initialRoute: '/',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/projects': (context) => const ProjectsScreen(),
        '/clients': (context) => const ClientsScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/payments': (context) => const PaymentsScreen(),
      },
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    );
  }
}
