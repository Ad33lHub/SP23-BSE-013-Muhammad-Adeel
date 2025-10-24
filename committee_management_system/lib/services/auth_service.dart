import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return false; // User already exists
      }

      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        password: password, // In production, hash this password
        createdAt: DateTime.now(),
      );

      await _dbHelper.insertUser(user);
      _currentUser = user;
      notifyListeners();

      // Save user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);

      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user != null && user.password == password) {
        _currentUser = user;
        notifyListeners();

        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);

        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      _currentUser = null;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      return true;
    } catch (e) {
      print('Sign out error: $e');
      return false;
    }
  }

  Future<bool> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        final user = await _dbHelper.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Load session error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          name: name,
          phone: phone,
        );
        
        await _dbHelper.updateUser(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}
