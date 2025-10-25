import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// jeśli jedziesz przez Chrome na tym samym kompie co backend:
const String apiBase = 'http://127.0.0.1:8000';
// jeśli kiedyś odpalisz na emulatorze Androida, zmienisz na:
// const String apiBase = 'http://10.0.2.2:8000';

class Api {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBase,
      // można dorzucić connectTimeout itp. jeśli będziemy chcieli
    ),
  );

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // -------- auth --------

  static Future<Response> login(String email, String password) async {
    // Zwracamy cały response, bo teraz zawiera { "access": "...", "user": {...} }
    return _dio.post(
      '/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  static Future<Response> register(String email, String password) async {
    return _dio.post(
      '/v1/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  // -------- user (nowe) --------

  static Future<Response> getProfile() async {
    final t = await _token();
    return _dio.get(
      '/v1/users/me',
      options: Options(
        headers: {'Authorization': 'Bearer $t'},
      ),
    );
  }

  // -------- content (nowe) --------

  static Future<Response> getLesson() async {
    final t = await _token();
    return _dio.get(
      '/v1/content/lesson',
      options: Options(
        headers: {'Authorization': 'Bearer $t'},
      ),
    );
  }

  // -------- habits --------

  static Future<Response> listHabits() async {
    final t = await _token();
    return _dio.get(
      '/v1/habits',
      options: Options(
        headers: {'Authorization': 'Bearer $t'},
      ),
    );
  }

  static Future<Response> createHabit(
    String title, {
    String cadence = 'daily',
    int difficulty = 3,
  }) async {
    final t = await _token();
    return _dio.post(
      '/v1/habits',
      data: {
        'title': title,
        'cadence': cadence,
        'difficulty': difficulty,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $t'},
      ),
    );
  }

  static Future<Response> checkIn(
    int habitId,
    String status,
    String note,
  ) async {
    final t = await _token();
    return _dio.post(
      '/v1/habits/$habitId/checkin',
      data: {
        'status': status,
        'note': note,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $t'},
      ),
    );
  }
}


