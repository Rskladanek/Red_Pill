import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../services/api_service.dart';

class LessonPage extends StatefulWidget {
  final LessonModel lesson;

  const LessonPage({super.key, required this.lesson});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  bool _saving = false;
  bool _completedLocally = false;

  @override
  void initState() {
    super.initState();
    _completedLocally = widget.lesson.completed;
  }

  Future<void> _toggleComplete() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ApiService.setLessonComplete(widget.lesson.id, true);
      setState(() => _completedLocally = true);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać progresu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    final contentParagraphs =
        widget.lesson.content.split('\n\n').where((e) => e.trim().isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lekcja #${widget.lesson.order}', style: s.labelSmall),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...contentParagraphs.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          p,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completedLocally ? null : _toggleComplete,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_completedLocally
                        ? 'Już zaliczone'
                        : 'Zrobione – zgarnij XP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

