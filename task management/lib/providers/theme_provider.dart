import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/background_settings.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _soundKey = 'notification_sound';
  static const String _backgroundKey = 'background_settings';

  ThemeMode _themeMode = ThemeMode.system;
  String _notificationSound = 'default';
  BackgroundSettings _backgroundSettings = BackgroundSettings();

  ThemeMode get themeMode => _themeMode;
  String get notificationSound => _notificationSound;
  BackgroundSettings get backgroundSettings => _backgroundSettings;

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

    final backgroundJson = prefs.getString(_backgroundKey);
    if (backgroundJson != null) {
      _backgroundSettings = BackgroundSettings.fromJson(json.decode(backgroundJson));
    }
    notifyListeners();
  }

  Future<void> setBackgroundImage(String? imagePath) async {
    _backgroundSettings = _backgroundSettings.copyWith(
      imagePath: imagePath,
      backgroundColor: null,
      useDefault: false,
    );
    notifyListeners();
    await _saveBackgroundSettings();
  }

  Future<void> setBackgroundColor(Color color) async {
    _backgroundSettings = _backgroundSettings.copyWith(
      backgroundColor: color.toARGB32(),
      imagePath: null,
      useDefault: false,
    );
    notifyListeners();
    await _saveBackgroundSettings();
  }

  Future<void> resetBackgroundToDefault() async {
    _backgroundSettings = BackgroundSettings();
    notifyListeners();
    await _saveBackgroundSettings();
  }

  Future<void> _saveBackgroundSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundKey, json.encode(_backgroundSettings.toJson()));
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

