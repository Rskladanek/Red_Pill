import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../pages/module_page.dart';
import '../pages/quiz_page.dart';

class TrackTab extends StatefulWidget {
  final String track; // 'mind' | 'body' | 'soul'
  const TrackTab({super.key, required this.track});

  @override
  State<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends State<TrackTab> {
  late Future<List<String>> _modsFuture;

  @override
  void initState() {
    super.initState();
    _modsFuture = ApiService.fetchModules(widget.track);
  }

  Future<void> _refresh() async {
    setState(() {
      _modsFuture = ApiService.fetchModules(widget.track);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<String>>(
        future: _modsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Nie mogę pobrać modułów dla ${widget.track}: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            );
          }
          final modules = snapshot.data ?? const <String>[];
          if (modules.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 80),
                Text('Brak modułów dla tego filaru (jeszcze).'),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return _ModuleCard(
                track: widget.track,
                module: module,
              );
            },
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String track;
  final String module;

  const _ModuleCard({
    required this.track,
    required this.module,
  });

  String get _trackLabel => track.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _trackLabel,
                    style: s.labelSmall?.copyWith(
                      color: Colors.grey,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module,
                    style: s.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ModulePage(
                          track: track,
                          module: module,
                        ),
                      ),
                    );
                  },
                  child: const Text('Moduł'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizPage(
                          track: track,
                          module: module,
                        ),
                      ),
                    );
                  },
                  child: const Text('Daily quiz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

