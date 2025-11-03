class TaskModel {
  final int id;
  final String track;
  final String module;
  final int order;
  final String title;
  final String body;
  final String difficulty;
  final List<String> checklist;

  TaskModel({
    required this.id,
    required this.track,
    required this.module,
    required this.order,
    required this.title,
    required this.body,
    required this.difficulty,
    required this.checklist,
  });

  factory TaskModel.fromJson(Map<String, dynamic> m) => TaskModel(
        id: (m['id'] as num).toInt(),
        track: (m['track'] ?? '').toString(),
        module: (m['module'] ?? '').toString(),
        order: (m['order'] as num).toInt(),
        title: (m['title'] ?? '').toString(),
        body: (m['body'] ?? '').toString(),
        difficulty: (m['difficulty'] ?? '').toString(),
        checklist: (m['checklist'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

