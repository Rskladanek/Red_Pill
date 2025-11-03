import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/home_tab.dart';
import '../widgets/track_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;

  static const _tracks = ['mind', 'body', 'soul'];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeTab(),
      const TrackTab(track: 'mind'),
      const TrackTab(track: 'body'),
      const TrackTab(track: 'soul'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('REDPILL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () {
              AuthService.logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            label: 'MIND',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'BODY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'SOUL',
          ),
        ],
      ),
    );
  }
}

