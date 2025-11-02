import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizBlock extends StatefulWidget {
  final String track; // 'mind' | 'body' | 'soul'
  final Map<String, dynamic> quiz; // payload pierwszego pytania

  const QuizBlock({super.key, required this.track, required this.quiz});

  @override
  State<QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends State<QuizBlock> {
  late Map<String, dynamic> _current;
  int? _selected;
  bool _busy = false;

  String get _module =>
      (_current['module'] ?? widget.quiz['module'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _current = Map<String, dynamic>.from(widget.quiz);
  }

  Future<void> _submit() async {
    if (_selected == null || _busy) return;
    setState(() => _busy = true);
    try {
      final int qid = (_current['question_id'] as num).toInt();
      final next = await ApiService.answerQuiz(
        track: widget.track,
        module: _module,
        questionId: qid,
        answerIndex: _selected!,
      );

      if (!mounted) return;

      if (next == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Quiz ukończony')));
      } else {
        setState(() {
          _current = next;
          _selected = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String question = (_current['question'] ?? 'Question').toString();
    final List<String> options = (_current['options'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...List.generate(options.length, (i) {
            return RadioListTile<int>(
              value: i,
              groupValue: _selected,
              onChanged: _busy ? null : (v) => setState(() => _selected = v),
              title: Text(options[i]),
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selected != null && !_busy) ? _submit : null,
              child: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Wyślij'),
            ),
          ),
          const SizedBox(height: 8),
          Text("Module: $_module", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

