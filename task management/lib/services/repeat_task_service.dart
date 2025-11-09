import '../models/task.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class RepeatTaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;

  Future<void> processRepeatedTasks() async {
    final repeatedTasks = await _dbHelper.getRepeatedTasks();
    final now = DateTime.now();

    for (final task in repeatedTasks) {
      if (task.isCompleted) {
        // Check if we need to reset the task for the next occurrence
        if (shouldResetTask(task, now)) {
          await resetTaskForNextOccurrence(task);
        }
      } else {
        // Update due date for recurring tasks that haven't been completed yet
        if (task.dueDate.isBefore(now) && task.repeatType != 'none') {
          await updateTaskForNextOccurrence(task);
        }
      }
    }
  }

  bool shouldResetTask(Task task, DateTime now) {
    if (task.repeatType == 'daily') {
      // Reset if completed date is before today
      if (task.completedAt != null) {
        return task.completedAt!.day != now.day ||
            task.completedAt!.month != now.month ||
            task.completedAt!.year != now.year;
      }
      return false;
    } else if (task.repeatType == 'weekly' && task.repeatDays != null) {
      // Reset if we've passed the last occurrence day
      final days = _parseRepeatDays(task.repeatDays!);
      if (days.isEmpty) return false;

      final lastDay = days.last;
      final currentDay = now.weekday;

      // If we're past the last day of the week for this task, reset it
      if (currentDay > lastDay || (task.completedAt != null && 
          task.completedAt!.add(const Duration(days: 7)).isBefore(now))) {
        return true;
      }
      return false;
    }
    return false;
  }

  Future<void> resetTaskForNextOccurrence(Task task) async {
    DateTime nextDueDate = task.dueDate;

    if (task.repeatType == 'daily') {
      nextDueDate = DateTime.now().add(const Duration(days: 1));
    } else if (task.repeatType == 'weekly' && task.repeatDays != null) {
      nextDueDate = getNextWeeklyOccurrence(task);
    }

    final updatedTask = task.copyWith(
      isCompleted: false,
      completedAt: null,
      dueDate: nextDueDate,
    );

    await _dbHelper.updateTask(updatedTask);
    await _notificationService.updateTaskNotification(updatedTask);
  }

  Future<void> updateTaskForNextOccurrence(Task task) async {
    DateTime nextDueDate = task.dueDate;

    if (task.repeatType == 'daily') {
      nextDueDate = DateTime.now().add(const Duration(days: 1));
    } else if (task.repeatType == 'weekly' && task.repeatDays != null) {
      nextDueDate = getNextWeeklyOccurrence(task);
    }

    final updatedTask = task.copyWith(dueDate: nextDueDate);
    await _dbHelper.updateTask(updatedTask);
    await _notificationService.updateTaskNotification(updatedTask);
  }

  DateTime getNextWeeklyOccurrence(Task task) {
    final days = _parseRepeatDays(task.repeatDays!);
    if (days.isEmpty) return task.dueDate;

    final now = DateTime.now();
    final currentDay = now.weekday;

    // Find the next day in the list
    for (final day in days) {
      if (day > currentDay) {
        final daysUntilNext = day - currentDay;
        return DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilNext));
      }
    }

    // If no day found this week, use the first day of next week
    final firstDay = days.first;
    final daysUntilNext = (7 - currentDay) + firstDay;
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilNext));
  }

  List<int> _parseRepeatDays(String repeatDays) {
    try {
      final cleaned = repeatDays.replaceAll('[', '').replaceAll(']', '');
      return cleaned.split(',').map((e) => int.parse(e.trim())).toList();
    } catch (e) {
      return [];
    }
  }
}

