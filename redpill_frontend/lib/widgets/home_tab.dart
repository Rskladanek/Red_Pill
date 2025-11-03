import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/summary_model.dart';
import 'power_triangle.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<SummaryModel> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchSummary();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.fetchSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<SummaryModel>(
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
                  'Coś się wyjebało z /progress/summary.\n${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            );
          }
          final s = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Dzisiaj',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Power triangle',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.4,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PowerTriangle(
                        mind: s.xpMind,
                        body: s.xpBody,
                        soul: s.xpSoul,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'TOTAL XP',
                      value: s.experience,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'STREAK',
                      value: s.streakDays,
                      suffix: ' dni',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Jak używać:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Wejdź w zakładkę MIND / BODY / SOUL, wybierz moduł, '
                'zrób lekcję, zaznacz jako zrobioną i odpal quiz. '
                'Każdy dzień z czymś zrobionym utrzymuje streak.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final String? suffix;

  const _StatCard({
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: s.labelSmall?.copyWith(
                color: Colors.grey,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value${suffix ?? ''}',
              style: s.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

