// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

// wynik logowania/rejestracji
class AuthResult {
  final String token;
  final UserModel user;

  AuthResult({
    required this.token,
    required this.user,
  });
}

class AuthService {
  // jeśli backend jest na innym adresie/porcie -> zmień to
  static const String baseUrl = "http://127.0.0.1:8000";

  // -------- LOGIN --------
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse("$baseUrl/v1/auth/login");

    final resp = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception("LOGIN_HTTP_${resp.statusCode}");
    }

    final data = jsonDecode(resp.body);

    // token może być pod różnymi nazwami → bierzemy którykolwiek
    final token = data["token"] ?? data["access"] ?? data["jwt"];
    if (token == null || token is! String) {
      throw Exception("LOGIN_NO_TOKEN");
    }

    final userJson = data["user"];
    if (userJson == null || userJson is! Map<String, dynamic>) {
      throw Exception("LOGIN_NO_USER");
    }

    final user = UserModel.fromJson(userJson);

    // zapisz dane lokalnie (Chrome/mobile)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    await prefs.setString("user_email", user.email);
    await prefs.setString("user_rank", user.rank);

    return AuthResult(token: token, user: user);
  }

  // -------- REJESTRACJA --------
  static Future<AuthResult> rawRegister({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse("$baseUrl/v1/auth/register");

    final resp = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception("REGISTER_HTTP_${resp.statusCode}");
    }

    final data = jsonDecode(resp.body);

    final token = data["token"] ?? data["access"] ?? data["jwt"];
    if (token == null || token is! String) {
      throw Exception("REGISTER_NO_TOKEN");
    }

    final userJson = data["user"];
    if (userJson == null || userJson is! Map<String, dynamic>) {
      throw Exception("REGISTER_NO_USER");
    }

    final user = UserModel.fromJson(userJson);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    await prefs.setString("user_email", user.email);
    await prefs.setString("user_rank", user.rank);

    return AuthResult(token: token, user: user);
  }

  // -------- SESJA (sprawdź czy token jeszcze działa) --------
  static Future<UserModel?> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) return null;

    final uri = Uri.parse("$baseUrl/v1/auth/check");

    final resp = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (resp.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(resp.body);
    if (data is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(data);
  }

  // -------- WYLOGOWANIE --------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_email");
    await prefs.remove("user_rank");
  }
}

