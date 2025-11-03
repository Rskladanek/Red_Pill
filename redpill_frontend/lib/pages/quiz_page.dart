import 'package:flutter/material.dart';
import '../widgets/quiz_block.dart';

class QuizPage extends StatelessWidget {
  final String track;
  final String module;

  const QuizPage({
    super.key,
    required this.track,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QUIZ – ${track.toUpperCase()} / $module'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: QuizBlock(
              track: track,
              module: module,
            ),
          ),
        ),
      ),
    );
  }
}

