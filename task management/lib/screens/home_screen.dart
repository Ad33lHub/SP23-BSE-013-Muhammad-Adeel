import 'package:flutter/material.dart';
import 'today_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'settings_screen.dart';
import '../services/repeat_task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final RepeatTaskService _repeatTaskService = RepeatTaskService();

  @override
  void initState() {
    super.initState();
    _processRepeatedTasks();
  }

  Future<void> _processRepeatedTasks() async {
    // Process repeated tasks when app starts
    await _repeatTaskService.processRepeatedTasks();
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const TodayTasksScreen();
      case 1:
        return const CompletedTasksScreen();
      case 2:
        return const RepeatedTasksScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const TodayTasksScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Repeated',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/add-task');
                if (result == true && mounted) {
                  // Refresh the current screen by rebuilding
                  setState(() {});
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

