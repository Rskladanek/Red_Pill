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
          title: const Text('RedPill'),
          actions: [
            IconButton(
              tooltip: 'Wyloguj',
              onPressed: () {
                AuthService.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.psychology), text: 'Mind'),
              Tab(icon: Icon(Icons.build), text: 'Body'),
              Tab(icon: Icon(Icons.bolt), text: 'Soul'),
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

