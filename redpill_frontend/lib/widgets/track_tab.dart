import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_block.dart';

class TrackTab extends StatefulWidget {
  final String track; // 'mind' | 'body' | 'soul'
  const TrackTab({super.key, required this.track});

  @override
  State<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends State<TrackTab> {
  late Future<List<String>> _modsFuture;
  final Map<String, Future<List<Map<String, dynamic>>>> _lessonsFutures = {};

  @override
  void initState() {
    super.initState();
    _modsFuture = ApiService.getModules(widget.track);
  }

  Future<void> _startQuiz(String module) async {
    try {
      final first = await ApiService.startQuiz(widget.track, module);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: QuizBlock(track: widget.track, quiz: first),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _modsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Błąd modułów: ${snap.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _modsFuture = ApiService.getModules(widget.track)),
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          );
        }

        final modules = snap.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          separatorBuilder: (_, __) => const Divider(height: 24, thickness: .6),
          itemCount: modules.length,
          itemBuilder: (context, i) {
            final module = modules[i];
            _lessonsFutures[module] ??= ApiService.getLessons(widget.track, module);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _lessonsFutures[module],
                  builder: (context, s) {
                    if (s.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (s.hasError || s.data == null) {
                      return Text('Błąd lekcji: ${s.error}');
                    }
                    final lessons = s.data!;
                    return Column(
                      children: [
                        for (final e in lessons)
                          CheckboxListTile(
                            value: (e['completed'] ?? false) as bool,
                            onChanged: (v) async {
                              try {
                                await ApiService.markLesson((e['id'] as num).toInt(), v == true);
                                setState(() {
                                  _modsFuture = ApiService.getModules(widget.track);
                                  _lessonsFutures[module] = ApiService.getLessons(widget.track, module);
                                });
                              } catch (err) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Mark error: $err')),
                                );
                              }
                            },
                            title: Text('${e['module']} — ${e['title']}'),
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => _startQuiz(module),
                            icon: const Icon(Icons.quiz),
                            label: const Text('Start daily quiz'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

