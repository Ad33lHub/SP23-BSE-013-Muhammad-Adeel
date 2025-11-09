import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _soundKey = 'notification_sound';

  ThemeMode _themeMode = ThemeMode.system;
  String _notificationSound = 'default';

  ThemeMode get themeMode => _themeMode;
  String get notificationSound => _notificationSound;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    final sound = prefs.getString(_soundKey);

    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    if (sound != null) {
      _notificationSound = sound;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setNotificationSound(String sound) async {
    _notificationSound = sound;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, sound);
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}

