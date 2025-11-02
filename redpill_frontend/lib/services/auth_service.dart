import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static String get baseUrl =>
      const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

  static String? token;

  static Map<String, String> _headers({bool withAuth = false}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (withAuth && token != null) h['Authorization'] = 'Bearer $token';
    return h;
    }

  // zapis/odczyt sesji w localStorage
  static void _saveSession(String tkn, UserModel user) {
    token = tkn;
    final payload = jsonEncode({'token': tkn, 'user': user.toJson()});
    html.window.localStorage['session'] = payload;
  }

  static Future<UserModel?> checkSession() async {
    try {
      final raw = html.window.localStorage['session'];
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      token = (map['token'] ?? '').toString();
      final userMap = (map['user'] as Map?)?.cast<String, dynamic>() ?? {};
      return UserModel.fromMap(userMap);
    } catch (_) {
      return null;
    }
  }

  static Future<UserModel> register(String email, String password) async {
    final r = await http.post(
      Uri.parse('$baseUrl/v1/auth/register'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (r.statusCode == 200) {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final tkn = (data['token'] ?? '').toString();
      final user = UserModel.fromMap((data['user'] as Map).cast<String, dynamic>());
      _saveSession(tkn, user);
      return user;
    }

    if (r.statusCode == 409) {
      // użytkownik istnieje -> spróbuj zalogować
      return login(email, password);
    }

    throw Exception('Register failed (${r.statusCode})');
  }

  static Future<UserModel> login(String email, String password) async {
    final r = await http.post(
      Uri.parse('$baseUrl/v1/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (r.statusCode == 200) {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final tkn = (data['token'] ?? '').toString();
      final user = UserModel.fromMap((data['user'] as Map).cast<String, dynamic>());
      _saveSession(tkn, user);
      return user;
    }

    throw Exception('Login failed (${r.statusCode})');
  }

  static void logout() {
    token = null;
    html.window.localStorage.remove('session'); // w Dart jest remove(), nie removeItem()
  }
}

