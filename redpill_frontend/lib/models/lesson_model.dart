class LessonModel {
  final int id;
  final String track;
  final String module;
  final int order;
  final String title;
  final String content;
  final bool completed;

  LessonModel({
    required this.id,
    required this.track,
    required this.module,
    required this.order,
    required this.title,
    required this.content,
    required this.completed,
  });

  factory LessonModel.fromJson(Map<String, dynamic> m) => LessonModel(
        id: (m['id'] as num).toInt(),
        track: (m['track'] ?? '').toString(),
        module: (m['module'] ?? '').toString(),
        order: (m['order'] as num).toInt(),
        title: (m['title'] ?? '').toString(),
        content: (m['content'] ?? '').toString(),
        completed: (m['completed'] ?? false) as bool,
      );
}

