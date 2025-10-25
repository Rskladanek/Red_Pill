import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'models.dart';        // Import modeli
import 'user_provider.dart'; // Import providera

class HabitsPage extends StatefulWidget {
  final Future<void> Function() onLogout;
  const HabitsPage({super.key, required this.onLogout});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  bool loading = true;
  List<dynamic> habits = [];
  String? error;
  Lesson? lesson; // Stan do trzymania lekcji dnia

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {loading = true; error = null;});
    try {
      // Równolegle ładujemy nawyki i lekcję
      final habitsFuture = Api.listHabits();
      final lessonFuture = Api.getLesson();

      final habitsResponse = await habitsFuture;
      final lessonResponse = await lessonFuture;

      setState(() {
        habits = habitsResponse.data as List<dynamic>;
        lesson = Lesson.fromJson(lessonResponse.data as Map<String, dynamic>);
      });
    } catch (e) {
      setState(() => error = 'Błąd ładowania danych: $e');
      // Jeśli token wygasł, UserProvider powinien to wykryć
      // przy następnym odświeżeniu i wylogować.
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _addHabit() async {
    final titleCtrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nowy rytuał'),
        content: TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tytuł')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Anuluj')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Dodaj')),
        ],
      ),
    );

    if (created == true && titleCtrl.text.isNotEmpty) {
      try {
        await Api.createHabit(titleCtrl.text);
        await _load(); // refresh
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
      }
    }
  }

  // Logika check-in pozostaje bez zmian na razie
  Future<void> _checkIn(int habitId) async {
    try {
      // Prosty check-in na "done"
      await Api.checkIn(habitId, 'done', '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zaliczone!'), backgroundColor: Colors.green),
      );
      // TODO: odświeżyć XP usera
      // Provider.of<UserProvider>(context, listen: false).fetchUser();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nasłuchujemy zmian w UserProviderze
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        // Wyświetlamy rangę i XP usera
        title: Text(user != null ? '${user.rank} (${user.xp} XP)' : 'Red Pill'),
        actions: [
          IconButton(onPressed: () async { await widget.onLogout(); }, icon: const Icon(Icons.logout)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _load,
                  // Używamy CustomScrollView, aby połączyć różne typy widgetów
                  child: CustomScrollView(
                    slivers: [
                      // --- 1. Lekcja Dnia (jeśli jest) ---
                      if (lesson != null)
                        SliverToBoxAdapter(
                          child: _buildLessonCard(lesson!),
                        ),
                      
                      // --- 2. Nagłówek listy nawyków ---
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Text(
                            'Moje Rytuały',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      // --- 3. Lista nawyków ---
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final h = habits[i] as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: ListTile(
                                title: Text(h['title'] ?? ''),
                                subtitle: Text('Kategoria: ${h['category']} • Trudność: ${h['difficulty']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                                  selectedIcon: const Icon(Icons.check_circle, color: Colors.green),
                                  // TODO: Sprawdzać, czy nawyk jest dziś zaliczony
                                  // isSelected: h['today_status'] == 'done',
                                  
                                  // POPRAWKA: Używamy int.parse() zamiast 'as int'
                                  onPressed: () => _checkIn(int.parse(h['id'].toString())),
                                ),
                              ),
                            );
                          },
                          childCount: habits.length,
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper widget do budowania karty lekcji
  Widget _buildLessonCard(Lesson lesson) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lekcja Dnia: ${lesson.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              lesson.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Zastosowanie: ${lesson.application}',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${lesson.source}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


