import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static String get _base => AuthService.baseUrl;

  static Map<String, String> _headers() {
    final h = <String, String>{'Content-Type': 'application/json'};
    final t = AuthService.token;
    if (t != null) h['Authorization'] = 'Bearer $t';
    return h;
  }

  // ------------ HOME SUMMARY ------------
  static Future<Map<String, dynamic>> getSummary() async {
    final r = await http.get(Uri.parse('$_base/v1/progress/summary'), headers: _headers());
    if (r.statusCode == 200) {
      return (jsonDecode(r.body) as Map).cast<String, dynamic>();
    }
    throw Exception('summary ${r.statusCode}');
  }

  // ------------ MODULES ------------
  static Future<List<String>> getModules(String track) async {
    final r = await http.get(Uri.parse('$_base/v1/content/$track/modules'), headers: _headers());
    if (r.statusCode == 200) {
      final body = jsonDecode(r.body);
      if (body is List) return body.map((e) => e.toString()).toList();
      if (body is Map && body['modules'] is List) {
        return (body['modules'] as List).map((e) => e.toString()).toList();
      }
      throw Exception('Unexpected modules payload: $body');
    }
    throw Exception('modules ${r.statusCode}');
  }

  // ------------ LESSONS ------------
  static Future<List<Map<String, dynamic>>> getLessons(String track, String module) async {
    final uri = Uri.parse('$_base/v1/content/$track/lessons')
        .replace(queryParameters: {'module': module});
    final r = await http.get(uri, headers: _headers());
    if (r.statusCode == 200) {
      final body = jsonDecode(r.body);
      final list = body is List ? body : (body is Map && body['lessons'] is List ? body['lessons'] : []);
      return (list as List)
          .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
          .toList();
    }
    throw Exception('lessons ${r.statusCode}');
  }

  /// Backend oczekuje JSON { "complete": true/false }
  static Future<void> markLesson(int lessonId, bool complete) async {
    final r = await http.post(
      Uri.parse('$_base/v1/content/lessons/$lessonId/complete'),
      headers: _headers(),
      body: jsonEncode({'complete': complete}),
    );
    if (r.statusCode != 200) {
      throw Exception('markLesson ${r.statusCode}: ${r.body}');
    }
  }

  // ------------ QUIZ ------------
  /// W Twoim backendzie /quiz/start jest GET -> ?module=…
  static Future<Map<String, dynamic>> startQuiz(String track, String module) async {
    final uri = Uri.parse('$_base/v1/content/$track/quiz/start')
        .replace(queryParameters: {'module': module});
    final r = await http.get(uri, headers: _headers());

    if (r.statusCode == 200) {
      return (jsonDecode(r.body) as Map).cast<String, dynamic>();
    }
    // awaryjnie spróbuj POST jeśli ktoś zmieni backend:
    if (r.statusCode == 405) {
      final p = await http.post(
        Uri.parse('$_base/v1/content/$track/quiz/start'),
        headers: _headers(),
        body: jsonEncode({'module': module}),
      );
      if (p.statusCode == 200) {
        return (jsonDecode(p.body) as Map).cast<String, dynamic>();
      }
      throw Exception('startQuiz ${p.statusCode}: ${p.body}');
    }
    throw Exception('startQuiz ${r.statusCode}: ${r.body}');
  }

  static Future<Map<String, dynamic>?> answerQuiz({
    required String track,
    required String module,
    required int questionId,
    required int answerIndex,
  }) async {
    final r = await http.post(
      Uri.parse('$_base/v1/content/$track/quiz/answer'),
      headers: _headers(),
      body: jsonEncode({
        'module': module,
        'question_id': questionId,
        'answer_index': answerIndex,
      }),
    );
    if (r.statusCode != 200) {
      throw Exception("answerQuiz ${r.statusCode}: ${r.body}");
    }
    if (r.body.isEmpty) return null;
    final body = jsonDecode(r.body);
    if (body is Map && body.isEmpty) return null;
    return (body as Map).cast<String, dynamic>();
  }
}

