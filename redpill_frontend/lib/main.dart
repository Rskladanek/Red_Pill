// lib/main.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'services/auth_service.dart';
import 'dashboard_page.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sprawdź czy mamy ważny token -> wtedy od razu dashboard
  final user = await AuthService.checkSession();

  runApp(MyApp(initialUser: user));
}

class MyApp extends StatelessWidget {
  final UserModel? initialUser;
  const MyApp({super.key, required this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Pill',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD90429),
          secondary: Color(0xFFD90429),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: initialUser != null
          ? DashboardPage(user: initialUser!)
          : const LoginPage(),
    );
  }
}

