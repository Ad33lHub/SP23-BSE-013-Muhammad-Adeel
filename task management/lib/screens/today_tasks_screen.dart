import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../services/repeat_task_service.dart';
import '../widgets/glass_widgets.dart';
import '../theme/glassmorphism_theme.dart';
import 'add_task_screen.dart';

class TodayTasksScreen extends StatefulWidget {
  const TodayTasksScreen({super.key});

  @override
  State<TodayTasksScreen> createState() => _TodayTasksScreenState();
}

class _TodayTasksScreenState extends State<TodayTasksScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final RepeatTaskService _repeatTaskService = RepeatTaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    await _repeatTaskService.processRepeatedTasks();
    final tasks = await _dbHelper.getTodayTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _tasks.isEmpty) {
      _loadTasks();
    }
  }

  Future<void> _toggleTaskComplete(Task task) async {
    if (task.isCompleted) {
      await _dbHelper.uncompleteTask(task.id!);
    } else {
      await _dbHelper.completeTask(task.id!);
    }
    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Task',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteTask(task.id!);
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismTheme.neonBlue.withOpacity(0.3),
                    GlassmorphismTheme.neonPurple.withOpacity(0.3),
                  ],
                ),
              ),
              child: const Icon(Icons.today, color: GlassmorphismTheme.neonBlue),
            ),
            const SizedBox(width: 12),
            Text(
              'Today\'s Tasks',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            GlassmorphismTheme.neonBlue,
          ),
        ),
      )
          : _tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismTheme.neonBlue.withOpacity(0.2),
                    GlassmorphismTheme.neonPurple.withOpacity(0.2),
                  ],
                ),
              ),
              child: Icon(
                Icons.task_alt,
                size: 64,
                color: Colors.white.withOpacity(0.38),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks for today',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a new task',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.38),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadTasks,
        color: GlassmorphismTheme.neonBlue,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return TaskCard(
              task: task,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(task: task),
                  ),
                );
                if (result == true) {
                  _loadTasks();
                }
              },
              onToggleComplete: () => _toggleTaskComplete(task),
              onDelete: () => _deleteTask(task),
            );
          },
        ),
      ),
    );
  }
}