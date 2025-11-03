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
      scaffoldBackgroundColor: const Color(0xFF050507),
      cardColor: const Color(0xFF111218),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFEF4444),   // CZERWIEŃ
        secondary: Color(0xFFF97316), // POMARAŃCZ – lekki akcent
        background: Color(0xFF050507),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.4,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B0C10),
        selectedItemColor: Color(0xFFEF4444),
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 22),
        type: BottomNavigationBarType.fixed,
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

