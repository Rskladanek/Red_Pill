import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  AuthService._();

  static String get baseUrl =>
      const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

  static String? _token;
  static UserModel? _currentUser;

  static Map<String, String> _headers({bool withAuth = false}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (withAuth && _token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  static void _saveSession(String token, UserModel user) {
    _token = token;
    _currentUser = user;
    final payload = jsonEncode({
      'token': token,
      'user': user.toJson(),
    });
    html.window.localStorage['session'] = payload;
  }

  static Future<UserModel?> loadSession() async {
    try {
      final raw = html.window.localStorage['session'];
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final token = decoded['token'] as String?;
      final userMap = decoded['user'] as Map<String, dynamic>?;
      if (token == null || userMap == null) return null;
      _token = token;
      _currentUser = UserModel.fromMap(userMap);
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  static String? get token => _token;
  static UserModel? get currentUser => _currentUser;

  static Future<UserModel> register(String email, String password) async {
    final uri = Uri.parse('$baseUrl/v1/auth/register');
    final resp = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 409) {
      throw Exception('Email already in use');
    }
    if (resp.statusCode != 200) {
      throw Exception('Register failed (${resp.statusCode})');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final token = (data['token'] ?? '').toString();
    final user = UserModel.fromMap((data['user'] as Map).cast<String, dynamic>());
    _saveSession(token, user);
    return user;
  }

  static Future<UserModel> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/v1/auth/login');
    final resp = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 401) {
      throw Exception('Invalid email or password');
    }
    if (resp.statusCode != 200) {
      throw Exception('Login failed (${resp.statusCode})');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final token = (data['token'] ?? '').toString();
    final user = UserModel.fromMap((data['user'] as Map).cast<String, dynamic>());
    _saveSession(token, user);
    return user;
  }

  static void logout() {
    _token = null;
    _currentUser = null;
    html.window.localStorage.remove('session');
  }

  static Map<String, String> authHeaders() => _headers(withAuth: true);
}

