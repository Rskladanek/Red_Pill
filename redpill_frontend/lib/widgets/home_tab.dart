import 'dart:math';
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
  late final List<String> _todayTasks;
  late final String _todayQuote;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchSummary();

    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final rnd = Random(seed);

    const allTasks = [
      'Zrób 2 bloki głębokiej pracy po 25 min – telefon w innym pokoju.',
      '10 minut spaceru bez słuchawek i bez telefonu.',
      'Zapisz 3 rzeczy, które dziś spierdoliłeś i czego Cię uczą.',
      'Przeczytaj 10 stron książki rozwojowej zamiast scrolla.',
      'Napisz jutro plan dnia dziś wieczorem (max 5 zadań).',
      '1 trening: minimum 30 minut ruchu z podniesionym tętnem.',
      'Wyrzuć 1 rzecz, której nie używasz – fizyczny declutter.',
      'Wyślij 1 wiadomość, którą odkładasz od tygodnia.',
    ];

    const allQuotes = [
      'Dyscyplina to wolność. Wymówki to klatka.',
      'Twój mózg nie jest zmęczony. Jest rozpuszczony przez dopaminę.',
      'Jeśli dziś odpuszczasz, uczysz się odpuszczać jutro.',
      'Ból progresu mija. Ból bycia przegrywem zostaje.',
      'Albo odpalasz hard mode, albo jesteś tłem dla innych.',
      'To, co robisz między 20:00 a 24:00, decyduje kim jesteś za rok.',
    ];

    List<String> pickTasks(int count) {
      final pool = List<String>.from(allTasks);
      final result = <String>[];
      while (result.length < count && pool.isNotEmpty) {
        final i = rnd.nextInt(pool.length);
        result.add(pool.removeAt(i));
      }
      return result;
    }

    String pickQuote() => allQuotes[rnd.nextInt(allQuotes.length)];

    _todayTasks = pickTasks(3);
    _todayQuote = pickQuote();
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
          final textTheme = Theme.of(context).textTheme;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Dzisiaj',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
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
                'Daily quest',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _todayTasks
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(
                                  child: Text(
                                    t,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cytat dnia',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF14151B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    _todayQuote,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Jak używać:',
                style: textTheme.titleMedium,
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

