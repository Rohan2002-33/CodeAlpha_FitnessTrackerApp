import 'package:flutter/material.dart';

import 'add_edit_activity_screen.dart';
import 'dashboard_screen.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'insights_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(onSeeAll: () => setState(() => _index = 1)),
          const HistoryScreen(),
          const InsightsScreen(),
          const GoalsScreen(),
        ],
      ),
      floatingActionButton: _index <= 1
          ? FloatingActionButton.extended(
              onPressed: () => openActivityForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log activity'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: 'Goals',
          ),
        ],
      ),
    );
  }
}
