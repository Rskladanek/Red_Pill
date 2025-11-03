import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lesson_model.dart';
import '../models/task_model.dart';
import 'lesson_page.dart';
import 'quiz_page.dart';

class ModulePage extends StatefulWidget {
  final String track;
  final String module;

  const ModulePage({
    super.key,
    required this.track,
    required this.module,
  });

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModuleData {
  final List<LessonModel> lessons;
  final List<TaskModel> tasks;

  _ModuleData({
    required this.lessons,
    required this.tasks,
  });
}

class _ModulePageState extends State<ModulePage> {
  late Future<_ModuleData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ModuleData> _load() async {
    final lessons = await ApiService.fetchLessons(widget.track, widget.module);
    final tasks = await ApiService.fetchTasks(widget.track, widget.module);
    return _ModuleData(lessons: lessons, tasks: tasks);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.track.toUpperCase()} / ${widget.module}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizPage(
                    track: widget.track,
                    module: widget.module,
                  ),
                ),
              );
            },
            child: const Text('QUIZ'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_ModuleData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Nie mogę pobrać modułu: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              );
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Lekcje', style: s.titleLarge),
                const SizedBox(height: 12),
                ...data.lessons.map(
                  (l) => _LessonTile(
                    lesson: l,
                    onChanged: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => LessonPage(lesson: l),
                        ),
                      );
                      if (changed == true) {
                        _refresh();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text('Zadania na dziś', style: s.titleLarge),
                const SizedBox(height: 12),
                if (data.tasks.isEmpty)
                  const Text(
                    'Brak konkretnych tasków – i tak możesz wymusić na sobie 1 blok głębokiej pracy.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...data.tasks.map((t) => _TaskCard(task: t)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onChanged;

  const _LessonTile({
    required this.lesson,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(
        lesson.completed ? Icons.check_circle : Icons.radio_button_unchecked,
        color: lesson.completed ? Colors.greenAccent : Colors.grey,
      ),
      title: Text(lesson.title, style: s.titleMedium),
      subtitle: Text(
        'Lekcja #${lesson.order}',
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onChanged,
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: s.titleMedium),
            const SizedBox(height: 6),
            Text(task.body, style: const TextStyle(color: Colors.grey)),
            if (task.checklist.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...task.checklist.map(
                (c) => Row(
                  children: [
                    const Icon(Icons.check_box_outline_blank, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

