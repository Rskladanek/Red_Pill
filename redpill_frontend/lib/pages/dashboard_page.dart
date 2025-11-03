import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/home_tab.dart';
import '../widgets/track_tab.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'HOME'),
              Tab(text: 'MIND'),
              Tab(text: 'BODY'),
              Tab(text: 'SOUL'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomeTab(),
            TrackTab(track: 'mind'),
            TrackTab(track: 'body'),
            TrackTab(track: 'soul'),
          ],
        ),
      ),
    );
  }
}

