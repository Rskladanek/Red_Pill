import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/dashboard_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'models/user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RedPillApp());
}

class RedPillApp extends StatelessWidget {
  const RedPillApp({super.key});

  Future<UserModel?> _loadUser() async {
    return AuthService.loadSession();
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    final theme = base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF050509),
      cardColor: const Color(0xFF111827),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF7C3AED),
        secondary: const Color(0xFFEC4899),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RedPill',
      theme: theme,
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
      home: FutureBuilder<UserModel?>(
        future: _loadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          }
          return const DashboardPage();
        },
      ),
    );
  }
}

