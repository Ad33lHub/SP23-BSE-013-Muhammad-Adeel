
import 'package:flutter/material.dart';
import 'dart:ui';
import 'today_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'settings_screen.dart';
import '../services/repeat_task_service.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/custom_background_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final RepeatTaskService _repeatTaskService = RepeatTaskService();

  // Define glass blur constant
  static const double glassBlur = 10.0;

  @override
  void initState() {
    super.initState();
    _processRepeatedTasks();
  }

  Future<void> _processRepeatedTasks() async {
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
    return CustomBackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: _getScreen(_currentIndex),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    GlassmorphismTheme.glassWhite.withOpacity(0.1),
                    GlassmorphismTheme.glassWhite.withOpacity(0.05),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: GlassmorphismTheme.glassWhite.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.today_outlined, Icons.today, 'Today', 0),
                      _buildNavItem(Icons.check_circle_outline, Icons.check_circle, 'Done', 1),
                      _buildNavItem(Icons.repeat_outlined, Icons.repeat, 'Repeat', 2),
                      _buildNavItem(Icons.settings_outlined, Icons.settings, 'Settings', 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: _currentIndex == 0
            ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: GlassmorphismTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: GlassmorphismTheme.neonBlue.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/add-task');
              if (result == true && mounted) {
                setState(() {});
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected
                  ? GlassmorphismTheme.neonBlue
                  : GlassmorphismTheme.glassWhite.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? GlassmorphismTheme.neonBlue
                    : GlassmorphismTheme.glassWhite.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}