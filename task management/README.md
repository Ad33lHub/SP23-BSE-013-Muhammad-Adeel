<img width="1284" height="2778" alt="image" src="https://github.com/user-attachments/assets/4c28905f-ef3d-4368-9684-5c9fa64219a6" />


# Task Management Application

A comprehensive Flutter-based task management application with SQLite database, local notifications, and export functionality. This application allows users to manage their daily tasks effectively through features like task addition, modification, deletion, categorization, and custom notifications.

## Features

### Core Functionality
- ✅ **Task Management**: Add, edit, delete, and mark tasks as completed
- ✅ **Task Categorization**: Organize tasks by Today, Completed, and Repeated
- ✅ **Subtasks**: Break down tasks into smaller subtasks with progress tracking
- ✅ **Progress Tracking**: Visual progress bars showing completion percentage based on subtasks
- ✅ **Due Dates & Times**: Set due dates and optional due times for tasks
- ✅ **Repeat Tasks**: Configure tasks to repeat daily or on specific days of the week
- ✅ **Local Notifications**: Get notified about upcoming tasks based on due dates and times
- ✅ **Theme Customization**: Switch between light, dark, and system default themes
- ✅ **Notification Sounds**: Choose from different notification sound options
- ✅ **Export Functionality**: Export tasks to CSV or PDF format and share via email

### User Interface
- **Today Tasks**: View all tasks due on the current day
- **Completed Tasks**: Browse through completed tasks with export options
- **Repeated Tasks**: Manage and view all recurring tasks
- **Settings**: Customize app appearance and notification preferences

## Project Structure

```
lib/
├── main.dart                 # App entry point with theme provider setup
├── models/
│   ├── task.dart            # Task model
│   └── subtask.dart         # Subtask model
├── database/
│   └── database_helper.dart # SQLite database operations
├── providers/
│   └── theme_provider.dart  # Theme management with shared preferences
├── services/
│   ├── notification_service.dart  # Local notifications handling
│   ├── export_service.dart        # CSV/PDF export functionality
│   └── repeat_task_service.dart   # Repeat task logic
├── screens/
│   ├── home_screen.dart           # Main navigation screen
│   ├── today_tasks_screen.dart    # Today's tasks view
│   ├── completed_tasks_screen.dart # Completed tasks view
│   ├── repeated_tasks_screen.dart  # Repeated tasks view
│   ├── add_task_screen.dart        # Add/Edit task form
│   └── settings_screen.dart        # Settings and preferences
└── widgets/
    ├── task_card.dart       # Task card widget with progress
    └── subtask_list.dart    # Subtask list widget
```

## Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `sqflite`: SQLite database for local storage
- `path`: Path manipulation for database files
- `provider`: State management for themes and settings
- `shared_preferences`: Persistent storage for user preferences

### Notification Dependencies
- `flutter_local_notifications`: Local notifications
- `timezone`: Timezone support for scheduled notifications

### Export Dependencies
- `path_provider`: Access to device file system
- `share_plus`: Share files via email or other apps
- `pdf`: PDF generation
- `csv`: CSV file generation
- `mailer`: Email functionality

### UI Dependencies
- `intl`: Internationalization and date formatting
- `table_calendar`: Calendar widget (for future enhancements)

## Installation

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Android SDK / iOS SDK



## Configuration

### Android Configuration
The Android manifest includes necessary permissions for:
- Notifications (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`)

### iOS Configuration
For iOS, you'll need to add notification permissions in `Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## Usage

### Adding a Task
1. Navigate to the "Today" tab
2. Tap the floating action button (+)
3. Fill in task details:
   - Title (required)
   - Description (required)
   - Due date
   - Due time (optional)
   - Repeat settings (none, daily, or weekly)
   - Subtasks (optional)

### Managing Tasks
- **Mark as Complete**: Tap the checkbox on any task card
- **Edit Task**: Tap on a task card or use the menu
- **Delete Task**: Use the menu option on a task card
- **Add Subtasks**: Edit a task and use "Add Subtask" button

### Repeat Tasks
- **Daily**: Task repeats every day
- **Weekly**: Select specific days of the week for the task to repeat
- Completed repeated tasks automatically reset for the next occurrence

### Exporting Tasks
1. Navigate to "Completed Tasks" or "Settings"
2. Tap the export icon or "Export All Tasks"
3. Choose format (CSV or PDF)
4. Share via email or save to device

### Theme Customization
1. Go to "Settings"
2. Select "Theme Mode"
3. Choose between Light, Dark, or System Default

### Notification Settings
1. Go to "Settings"
2. Select "Notification Sound"
3. Choose from available sound options

## Database Schema

### Tasks Table
- `id`: Primary key
- `title`: Task title
- `description`: Task description
- `dueDate`: Due date
- `dueTime`: Due time (optional)
- `isCompleted`: Completion status
- `completedAt`: Completion timestamp
- `repeatType`: Repeat type (none, daily, weekly)
- `repeatDays`: Selected days for weekly repeat (JSON array)
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp
- `notificationId`: Notification ID
- `notificationSound`: Notification sound preference

### Subtasks Table
- `id`: Primary key
- `taskId`: Foreign key to tasks table
- `title`: Subtask title
- `isCompleted`: Completion status
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

## Testing

### Manual Testing
1. Test task creation, editing, and deletion
2. Test task completion and uncompletion
3. Test repeat task functionality
4. Test notification scheduling
5. Test export functionality (CSV and PDF)
6. Test theme switching
7. Test subtask management and progress tracking







## Authors

- Muhammad Adeel


## Support

For issues, questions, or contributions, please open an issue on the GitHub repository.


**Note**: This application requires proper permissions for notifications and file access. Make sure to grant these permissions when prompted on first launch.
