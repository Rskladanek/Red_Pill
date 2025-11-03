import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/quiz_question_model.dart';

class QuizBlock extends StatefulWidget {
  final String track;
  final String module;

  const QuizBlock({
    super.key,
    required this.track,
    required this.module,
  });

  @override
  State<QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends State<QuizBlock> {
  QuizQuestionModel? _current;
  int? _selectedIndex;
  bool _loading = true;
  bool _finished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFirst();
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
      _finished = false;
      _selectedIndex = null;
    });
    try {
      final q = await ApiService.startQuiz(widget.track, widget.module);
      if (!mounted) return;
      setState(() {
        _current = q;
        _finished = q == null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_current == null || _selectedIndex == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final next = await ApiService.answerQuiz(
        widget.track,
        _current!.id,
        widget.module,
        _selectedIndex!,
      );
      if (!mounted) return;
      setState(() {
        _current = next;
        _selectedIndex = null;
        _finished = next == null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _current == null && _error == null && !_finished) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadFirst,
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      );
    }
    if (_finished) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          const SizedBox(height: 12),
          const Text('Quiz ogarnięty na dziś.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadFirst,
            child: const Text('Zrób rundę od nowa'),
          ),
        ],
      );
    }
    final q = _current!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz – ${widget.module}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(q.question),
        const SizedBox(height: 12),
        ...List.generate(q.options.length, (i) {
          final option = q.options[i];
          return RadioListTile<int>(
            value: i,
            groupValue: _selectedIndex,
            onChanged: (v) {
              setState(() => _selectedIndex = v);
            },
            title: Text(option),
          );
        }),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Wyślij'),
          ),
        ),
      ],
    );
  }
}

