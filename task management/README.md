# 📱 Task Management App

A polished Flutter task management application crafted with a premium glassmorphism UI, local notifications, SQLite storage, and smart task organization features. Built with Material Design 3 and optimized for both Android and iOS.

---

## 📥 Install IPA (iOS)

Download the latest IPA:

👉 [task_mgmt1.ipa](https://drive.google.com/file/d/1HZwnC0bZvo5s9ZZ_b_j_7Z0rVwwYEbDW/view?usp=sharing)

---

## ✨ Features

### 🎯 Core Features

* Create, update, and delete tasks
* Smart categories: **Today**, **Completed**, **Repeated**
* Subtasks with progress indicators
* Daily/weekly recurring tasks
* Local notifications with custom scheduling
* Export tasks to **CSV** and **PDF**
* Light, dark, and system themes
* Elegant **glassmorphism UI**

### 🛠 Technical Features

* SQLite database (optimized queries)
* Timezone-aware notifications
* Automatic reset for repeated tasks
* Cross-platform (Android + iOS)
* Smooth animations and modern design

---

## 🎥 Demo

[application video](https://drive.google.com/file/d/13iHuiLrtY5x9PiEFKZJSYphsjsOWcnJl/view?usp=sharing)


---

## 🚀 Installation & Setup

### Requirements

* Flutter SDK (stable)
* Dart SDK (bundled)
* Android Studio / VS Code (Flutter plugin)
* Xcode (for iOS on macOS)

### Android

```
flutter run
```

### iOS (macOS)

```
cd ios
pod install
cd ..
flutter run
```

---

## 📖 Usage Guide

### Creating a Task

1. Tap the **+** FAB
2. Enter task title & description
3. Select date/time
4. Add subtasks
5. Set repeat options
6. Save

### Task Management

* Mark complete using checkbox
* Edit via long press or edit icon
* Delete via swipe
* Navigate between categories

### Notifications

* Allow permissions on first launch
* Tasks trigger scheduled reminders

### Exporting

1. Open **Completed Tasks**
2. Tap **Export**
3. Select CSV / PDF
4. Share via email or apps

---

## 🏗 Project Structure

```
lib/
├── main.dart
├── models/
│   ├── task.dart
│   ├── subtask.dart
│   └── background_settings.dart
├── database/
│   └── database_helper.dart
├── providers/
│   └── theme_provider.dart
├── services/
│   ├── notification_service.dart
│   ├── export_service.dart
│   └── repeat_task_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── today_tasks_screen.dart
│   ├── completed_tasks_screen.dart
│   ├── repeated_tasks_screen.dart
│   ├── add_task_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── task_card.dart
│   ├── subtask_list.dart
│   ├── glass_widgets.dart
│   └── custom_background_container.dart
└── theme/
    └── glassmorphism_theme.dart
```

---

## 📦 Dependencies

| Package                     | Purpose            |
| --------------------------- | ------------------ |
| sqflite                     | Local database     |
| provider                    | State management   |
| flutter_local_notifications | Notifications      |
| timezone                    | TZ handling        |
| pdf                         | PDF generation     |
| csv                         | CSV export         |
| share_plus                  | Sharing files      |
| shared_preferences          | Key-value storage  |
| intl                        | Date formatting    |
| path_provider               | File paths         |
| permission_handler          | Permissions        |
| flutter_timezone            | Timezone utilities |
| google_fonts                | Custom fonts       |

---

## 🎨 Design System

### Glassmorphism

* Background gradient: `#0A0E27 → #1A1F3A → #0F1429`
* Blur: **30px**
* Opacity: **15%**
* Border radius: **20px**

### Color Palette

* Neon Blue: `#00D9FF`
* Purple: `#B026FF`
* Cyan: `#00F5FF`

### Typography

* **Poppins** (headings)
* **Inter** (body text)

### Components

* `GlassCard`
* `GlassButton`
* `GlassContainer`
* `NeonText`

---

## 🧪 Testing

```
flutter test
flutter drive --target=test_driver/app.dart
flutter run -d <device-id>
```

---

## 🚀 Deployment

### Android (Play Store)

```
flutter build apk --release
```

Then sign & upload.

### iOS (App Store)

```
flutter build ios --release
```

Archive and upload via Xcode/Transporter.

---

## 🤝 Contributing

1. Fork the repo
2. Create a branch
3. Commit changes
4. Push & open a PR

Guidelines:

* Use clean architecture
* Follow Flutter best practices
* Write tests
* Update docs when needed

---

## 📄 License

MIT License. See `LICENSE`.

---

## 🆘 Support

* Create a GitHub Issue
* Check documentation
* Review troubleshooting guides

---

Made with ❤️ using Flutter

Give the repo a ⭐ if you like it!
