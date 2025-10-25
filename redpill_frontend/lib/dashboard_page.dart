import 'package:flutter/material.dart';
import 'models/user_model.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // Tu później wepniemy backend.
  // Na razie mock (żeby było widać UI).
  Map<String, dynamic>? mindTask;
  Map<String, dynamic>? bodyTask;
  Map<String, dynamic>? soulTask;

  bool loadingDaily = true;

  @override
  void initState() {
    super.initState();
    _loadDaily();
  }

  Future<void> _loadDaily() async {
    // Tu później zrobimy GET /v1/daily/today.
    // Teraz tylko wypełniamy przykładowe dane po 200ms,
    // żeby zobaczyć ekran.
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      mindTask = {
        "id": 44,
        "track": "mind",
        "title": "Kontakt wzrokowy",
        "description":
            "Nie uciekaj wzrokiem pierwszy. Trzymaj spojrzenie spokojne, nie nerwowe.",
        "status": "pending",
      };
      bodyTask = {
        "id": 45,
        "track": "body",
        "title": "Postawa barki w dół",
        "description":
            "3 razy dzisiaj skoryguj barki: w dół i lekko do tyłu. Zero garba.",
        "status": "pending",
      };
      soulTask = {
        "id": 46,
        "track": "soul",
        "title": "Twoje dlaczego",
        "description":
            "Napisz jedno zdanie: dlaczego nie możesz być miękki. Zachowaj je.",
        "status": "pending",
      };

      loadingDaily = false;
    });
  }

  Future<void> _checkTask(Map<String, dynamic> task, String newStatus) async {
    // Tu później zrobimy POST /v1/daily/{id}/check.
    // Teraz tylko lokalnie zmieniamy status.
    setState(() {
      task["status"] = newStatus;
    });
  }

  Widget _taskCard(Map<String, dynamic>? task) {
    const accent = Color(0xFFD90429);

    if (loadingDaily) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (task == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "Brak zadania.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final disabled = task["status"] != "pending";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1F),
          border: Border.all(color: accent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task["title"] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task["description"] ?? "",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Status: ${task["status"]}",
                style: TextStyle(
                  color: task["status"] == "done"
                      ? Colors.greenAccent
                      : task["status"] == "fail"
                          ? Colors.redAccent
                          : Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed:
                        disabled ? null : () => _checkTask(task, "done"),
                    child: const Text("Wykonane"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.black,
                    ),
                    onPressed:
                        disabled ? null : () => _checkTask(task, "skip"),
                    child: const Text("Pominięte"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed:
                        disabled ? null : () => _checkTask(task, "fail"),
                    child: const Text("Zjebane"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFD90429);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0B0E),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Red Pill Dashboard",
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: accent,
            labelColor: accent,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "MIND"),
              Tab(text: "BODY"),
              Tab(text: "SOUL"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- MIND TAB ---
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Witaj, ${widget.user.email}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Ranga: ${widget.user.rank}",
                    style: const TextStyle(color: Colors.white)),
                Text("Doświadczenie: ${widget.user.experience}",
                    style: const TextStyle(color: Colors.white)),
                Text(
                    "Hard Mode: ${widget.user.hardMode ? "ON" : "OFF"}",
                    style: const TextStyle(color: Colors.white)),
                Text("Strefa czasowa: ${widget.user.timezone}",
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                _taskCard(mindTask),
              ],
            ),

            // --- BODY TAB ---
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _taskCard(bodyTask),
              ],
            ),

            // --- SOUL TAB ---
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _taskCard(soulTask),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

