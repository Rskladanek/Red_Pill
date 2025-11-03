import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/summary_model.dart';
import '../models/lesson_model.dart';
import '../models/task_model.dart';
import '../models/quiz_question_model.dart';

class ApiService {
  ApiService._();

  static Uri _uri(String path, [Map<String, String>? query]) {
    final base = AuthService.baseUrl;
    final uri = Uri.parse(base + path);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  static Future<SummaryModel> fetchSummary() async {
    final resp = await http.get(
      _uri('/v1/progress/summary'),
      headers: AuthService.authHeaders(),
    );
    if (resp.statusCode != 200) {
      throw Exception('summary ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return SummaryModel.fromJson(data);
  }

  static Future<List<String>> fetchModules(String track) async {
    final resp = await http.get(
      _uri('/v1/content/$track/modules'),
      headers: AuthService.authHeaders(),
    );
    if (resp.statusCode != 200) {
      throw Exception('modules ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as List<dynamic>;
    return data.map((e) => e.toString()).toList();
  }

  static Future<List<LessonModel>> fetchLessons(String track, String module) async {
    final resp = await http.get(
      _uri('/v1/content/$track/lessons', {'module': module}),
      headers: AuthService.authHeaders(),
    );
    if (resp.statusCode != 200) {
      throw Exception('lessons ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as List<dynamic>;
    return data
        .map((e) => LessonModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  static Future<void> setLessonComplete(int lessonId, bool complete) async {
    final resp = await http.post(
      _uri('/v1/content/lessons/$lessonId/complete'),
      headers: AuthService.authHeaders(),
      body: jsonEncode({'complete': complete}),
    );
    if (resp.statusCode != 200) {
      throw Exception('complete lesson ${resp.statusCode}: ${resp.body}');
    }
  }

  static Future<QuizQuestionModel?> startQuiz(String track, String module) async {
    final resp = await http.get(
      _uri('/v1/content/$track/quiz/start', {'module': module}),
      headers: AuthService.authHeaders(),
    );
    if (resp.statusCode == 404) {
      return null;
    }
    if (resp.statusCode != 200) {
      throw Exception('quiz start ${resp.statusCode}: ${resp.body}');
    }
    final body = jsonDecode(resp.body);
    if (body is Map && body.isEmpty) return null;
    return QuizQuestionModel.fromJson((body as Map).cast<String, dynamic>());
  }

  static Future<QuizQuestionModel?> answerQuiz(
    String track,
    int questionId,
    String module,
    int answerIndex,
  ) async {
    final resp = await http.post(
      _uri('/v1/content/$track/quiz/answer'),
      headers: AuthService.authHeaders(),
      body: jsonEncode({
        'module': module,
        'question_id': questionId,
        'answer_index': answerIndex,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('quiz answer ${resp.statusCode}: ${resp.body}');
    }
    if (resp.body.isEmpty) return null;
    final body = jsonDecode(resp.body);
    if (body is Map && body.isEmpty) return null;
    return QuizQuestionModel.fromJson((body as Map).cast<String, dynamic>());
  }

  static Future<List<TaskModel>> fetchTasks(String track, String module) async {
    final resp = await http.get(
      _uri('/v1/content/$track/tasks', {'module': module}),
      headers: AuthService.authHeaders(),
    );
    if (resp.statusCode != 200) {
      throw Exception('tasks ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as List<dynamic>;
    return data
        .map((e) => TaskModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}

