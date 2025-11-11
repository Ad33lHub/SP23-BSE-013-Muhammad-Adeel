// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import '../models/task.dart';

// class NotificationService {
//   static final NotificationService instance = NotificationService._init();
//   final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
//   bool _isInitialized = false;

//   NotificationService._init();

//   Future<void> _ensureInitialized() async {
//     if (_isInitialized) return;
    
//     tz.initializeTimeZones();
//     // Use local timezone
//     final location = tz.local;
//     tz.setLocalLocation(location);

//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _notifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     // Request permissions for Android 13+
//     await _requestPermissions();
//     _isInitialized = true;
//   }

//   Future<void> _requestPermissions() async {
//     final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//     if (androidPlugin != null) {
//       await androidPlugin.requestNotificationsPermission();
//     }
//   }

//   void _onNotificationTapped(NotificationResponse response) {
//     // Handle notification tap
//     // You can navigate to task details here if needed
//   }

//   Future<void> _scheduleFiveMinuteReminder(Task task, DateTime dueDateTime, int notificationId) async {
//     if (dueDateTime.isBefore(DateTime.now())) return;

//     final reminderTime = dueDateTime.subtract(const Duration(minutes: 5));
//     if (reminderTime.isBefore(DateTime.now())) return;

//     final androidDetails = AndroidNotificationDetails(
//       'task_reminder_channel',
//       'Task Reminders',
//       channelDescription: 'Urgent reminders for tasks due in 5 minutes',
//       importance: Importance.high,
//       priority: Priority.high,
//       icon: '@mipmap/ic_launcher',
//       enableVibration: true,
//       playSound: true,
//       visibility: NotificationVisibility.public, // Show on lock screen
//       fullScreenIntent: true, // This will show as a heads-up notification
//       category: AndroidNotificationCategory.alarm,
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       interruptionLevel: InterruptionLevel.timeSensitive, // High priority on iOS
//     );

//     final notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _notifications.zonedSchedule(
//       notificationId + 1000, // Use different ID for reminder
//       '⚠️ Task Due in 5 Minutes!',
//       '${task.title} needs to be completed soon',
//       tz.TZDateTime.from(reminderTime, tz.local),
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }

//   Future<void> scheduleTaskNotification(Task task) async {
//     await _ensureInitialized();
    
//     try {
//       if (task.dueDate.isBefore(DateTime.now()) && task.repeatType == 'none') {
//         return; // Don't schedule notifications for past tasks
//       }

//       final notificationId = task.notificationId ?? (task.id ?? 0);
//       final dueDateTime = task.dueTime ?? DateTime(
//         task.dueDate.year,
//         task.dueDate.month,
//         task.dueDate.day,
//         9, // Default to 9 AM if no time specified
//       );

//       // Schedule the 5-minute reminder notification
//       await _scheduleFiveMinuteReminder(task, dueDateTime, notificationId);

//       final androidDetails = AndroidNotificationDetails(
//         'task_channel',
//         'Task Notifications',
//         channelDescription: 'Notifications for upcoming tasks',
//         importance: Importance.high,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//         enableVibration: true,
//         playSound: true,
//       );

//       const iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       final notificationDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       final now = tz.TZDateTime.now(tz.local);
//       final scheduledDate = tz.TZDateTime.from(dueDateTime, tz.local);

//       if (task.repeatType == 'daily') {
//         // For daily notifications, schedule the next occurrence
//         // Note: This schedules for the next day only
//         // For true daily repeats, consider rescheduling after notification fires
//         var nextDate = scheduledDate;
//         if (!nextDate.isAfter(now)) {
//           // If time has passed today, schedule for tomorrow at the same time
//           nextDate = tz.TZDateTime(
//             tz.local,
//             now.year,
//             now.month,
//             now.day,
//             scheduledDate.hour,
//             scheduledDate.minute,
//           ).add(const Duration(days: 1));
//         }
        
//         // Schedule the notification
//         await _notifications.zonedSchedule(
//           notificationId,
//           task.title,
//           task.description,
//           nextDate,
//           notificationDetails,
//           androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//           uiLocalNotificationDateInterpretation:
//               UILocalNotificationDateInterpretation.absoluteTime,
//         );
//       } else if (task.repeatType == 'weekly' && task.repeatDays != null) {
//         // For weekly tasks, schedule for each selected day
//         final days = _parseRepeatDays(task.repeatDays!);
//         for (final day in days) {
//           await _scheduleWeeklyNotification(
//             notificationId + day,
//             task,
//             day,
//             dueDateTime,
//             notificationDetails,
//           );
//         }
//       } else {
//         // One-time notification
//         if (scheduledDate.isAfter(now)) {
//           await _notifications.zonedSchedule(
//             notificationId,
//             task.title,
//             task.description,
//             scheduledDate,
//             notificationDetails,
//             androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//             uiLocalNotificationDateInterpretation:
//                 UILocalNotificationDateInterpretation.absoluteTime,
//           );
//         }
//       }
//     } catch (e) {
//       // Log error but don't throw - allow task to be saved even if notification fails
//       // Error is handled in the calling code
//       rethrow; // Re-throw so calling code can handle it appropriately
//     }
//   }

//   Future<void> _scheduleWeeklyNotification(
//     int id,
//     Task task,
//     int dayOfWeek,
//     DateTime dueDateTime,
//     NotificationDetails details,
//   ) async {
//     final now = tz.TZDateTime.now(tz.local);
//     final scheduledDate = _getNextWeekday(now, dayOfWeek, dueDateTime);

//     if (scheduledDate.isAfter(now)) {
//       await _notifications.zonedSchedule(
//         id,
//         task.title,
//         task.description,
//         scheduledDate,
//         details,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//       );
//     }
//   }

//   tz.TZDateTime _getNextWeekday(tz.TZDateTime now, int dayOfWeek, DateTime dueTime) {
//     var next = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       dueTime.hour,
//       dueTime.minute,
//     );

//     final currentDay = now.weekday;
//     final daysUntilNext = (dayOfWeek - currentDay) % 7;
    
//     if (daysUntilNext == 0 && next.isBefore(now)) {
//       next = next.add(const Duration(days: 7));
//     } else {
//       next = next.add(Duration(days: daysUntilNext));
//     }

//     return next;
//   }

//   List<int> _parseRepeatDays(String repeatDays) {
//     try {
//       // Parse JSON array string like "[1,3,5]"
//       final cleaned = repeatDays.replaceAll('[', '').replaceAll(']', '');
//       return cleaned.split(',').map((e) => int.parse(e.trim())).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<void> cancelNotification(int notificationId) async {
//     await _notifications.cancel(notificationId);
//   }

//   Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//   }

//   Future<void> updateTaskNotification(Task task) async {
//     await _ensureInitialized();
    
//     if (task.notificationId != null) {
//       await cancelNotification(task.notificationId!);
//     }
//     if (!task.isCompleted) {
//       await scheduleTaskNotification(task);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._init();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    tz.initializeTimeZones();
    final location = tz.local;
    tz.setLocalLocation(location);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      // Request exact alarm permission for Android 12+
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  // Schedule 1-minute reminder
  Future<void> _scheduleOneMinuteReminder(Task task, DateTime dueDateTime, int notificationId) async {
    final now = DateTime.now();
    if (dueDateTime.isBefore(now)) return;

    final reminderTime = dueDateTime.subtract(const Duration(minutes: 1));
    if (reminderTime.isBefore(now)) return;

    final androidDetails = AndroidNotificationDetails(
      'task_urgent_reminder_channel',
      'Urgent Task Reminders',
      channelDescription: 'Critical reminders for tasks due in 1 minute',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      autoCancel: false,
      ongoing: false,
      channelShowBadge: true,
      enableLights: true,
      ledColor: Colors.red,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId + 2000, // Different ID for 1-minute reminder
      '🚨 URGENT: 1 Minute Left!',
      '${task.title} - Complete now!',
      tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Schedule 5-minute reminder
  Future<void> _scheduleFiveMinuteReminder(Task task, DateTime dueDateTime, int notificationId) async {
    final now = DateTime.now();
    if (dueDateTime.isBefore(now)) return;

    final reminderTime = dueDateTime.subtract(const Duration(minutes: 5));
    if (reminderTime.isBefore(now)) return;

    final androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Important reminders for tasks due in 5 minutes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
      autoCancel: false,
      ongoing: false,
      channelShowBadge: true,
      enableLights: true,
      ledColor: Colors.orange,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId + 1000, // Different ID for 5-minute reminder
      '⚠️ Task Due in 5 Minutes!',
      '${task.title} - ${task.description.isEmpty ? "Don't forget!" : task.description}',
      tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleTaskNotification(Task task) async {
    await _ensureInitialized();
    
    try {
      if (task.dueDate.isBefore(DateTime.now()) && task.repeatType == 'none') {
        return;
      }

      final notificationId = task.notificationId ?? (task.id ?? 0);
      final dueDateTime = task.dueTime ?? DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
        9,
      );

      // Schedule both reminder notifications
      await _scheduleFiveMinuteReminder(task, dueDateTime, notificationId);
      await _scheduleOneMinuteReminder(task, dueDateTime, notificationId);

      // Main notification settings with maximum priority
      final androidDetails = AndroidNotificationDetails(
        'task_channel',
        'Task Notifications',
        channelDescription: 'Notifications for upcoming tasks',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.event,
        autoCancel: false,
        ongoing: false,
        channelShowBadge: true,
        enableLights: true,
        ledColor: Colors.green,
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime.from(dueDateTime, tz.local);

      if (task.repeatType == 'daily') {
        var nextDate = scheduledDate;
        if (!nextDate.isAfter(now)) {
          nextDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            scheduledDate.hour,
            scheduledDate.minute,
          ).add(const Duration(days: 1));
        }
        
        await _notifications.zonedSchedule(
          notificationId,
          '📅 ${task.title}',
          task.description.isEmpty ? 'Task is due now!' : task.description,
          nextDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else if (task.repeatType == 'weekly' && task.repeatDays != null) {
        final days = _parseRepeatDays(task.repeatDays!);
        for (final day in days) {
          await _scheduleWeeklyNotification(
            notificationId + day,
            task,
            day,
            dueDateTime,
            notificationDetails,
          );
        }
      } else {
        if (scheduledDate.isAfter(now)) {
          await _notifications.zonedSchedule(
            notificationId,
            '📅 ${task.title}',
            task.description.isEmpty ? 'Task is due now!' : task.description,
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _scheduleWeeklyNotification(
    int id,
    Task task,
    int dayOfWeek,
    DateTime dueDateTime,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = _getNextWeekday(now, dayOfWeek, dueDateTime);

    if (scheduledDate.isAfter(now)) {
      await _notifications.zonedSchedule(
        id,
        '📅 ${task.title}',
        task.description.isEmpty ? 'Task is due now!' : task.description,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _getNextWeekday(tz.TZDateTime now, int dayOfWeek, DateTime dueTime) {
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      dueTime.hour,
      dueTime.minute,
    );

    final currentDay = now.weekday;
    final daysUntilNext = (dayOfWeek - currentDay) % 7;
    
    if (daysUntilNext == 0 && next.isBefore(now)) {
      next = next.add(const Duration(days: 7));
    } else {
      next = next.add(Duration(days: daysUntilNext));
    }

    return next;
  }

  List<int> _parseRepeatDays(String repeatDays) {
    try {
      final cleaned = repeatDays.replaceAll('[', '').replaceAll(']', '');
      return cleaned.split(',').map((e) => int.parse(e.trim())).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    // Also cancel reminder notifications
    await _notifications.cancel(notificationId + 1000); // 5-min reminder
    await _notifications.cancel(notificationId + 2000); // 1-min reminder
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> updateTaskNotification(Task task) async {
    await _ensureInitialized();
    
    if (task.notificationId != null) {
      await cancelNotification(task.notificationId!);
    }
    if (!task.isCompleted) {
      await scheduleTaskNotification(task);
    }
  }
}