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

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B59FF), brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF0F0E11),
      cardColor: const Color(0xFF17161A),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RedPill',
      theme: theme,
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
      },
      home: FutureBuilder<UserModel?>(
        future: AuthService.checkSession(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snap.data;
          if (user == null) {
            return const LoginPage();
          }
          return const DashboardPage();
        },
      ),
    );
  }
}

