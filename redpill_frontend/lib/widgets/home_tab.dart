import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/summary_model.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<SummaryModel> _f;

  @override
  void initState() {
    super.initState();
    _f = _load();
  }

  Future<SummaryModel> _load() async {
    final m = await ApiService.getSummary();
    return SummaryModel.fromJson(m);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SummaryModel>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => _f = _load()),
              child: Text('Błąd: ${snap.error}. Odśwież'),
            ),
          );
        }
        final s = snap.data!;
        final tiles = [
          _StatCard(label: 'XP Mind', value: s.xpMind),
          _StatCard(label: 'XP Body', value: s.xpBody),
          _StatCard(label: 'XP Soul', value: s.xpSoul),
          _StatCard(label: 'Streak', value: s.streakDays),
          _StatCard(label: 'EXP', value: s.experience),
        ];
        return Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cross = w > 1200 ? 4 : w > 800 ? 3 : 2;
              return GridView.count(
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: tiles,
              );
            },
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

