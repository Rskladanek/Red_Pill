class QuizQuestionModel {
  final int id;
  final String module;
  final String question;
  final List<String> options;

  QuizQuestionModel({
    required this.id,
    required this.module,
    required this.question,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> m) =>
      QuizQuestionModel(
        id: (m['question_id'] as num).toInt(),
        module: (m['module'] ?? '').toString(),
        question: (m['question'] ?? '').toString(),
        options: (m['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

