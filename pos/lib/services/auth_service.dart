import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign up method
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Save login state
      await _saveLoginState(true);
      
      return {
        'success': true,
        'message': 'Account created successfully',
        'data': {
          'user': {
            'uid': userCredential.user!.uid,
            'name': name,
            'email': email,
          }
        },
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email';
          break;
        case 'invalid-email':
          message = 'The email address is invalid';
          break;
        default:
          message = e.message ?? 'Signup failed';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
  
  // Sign in method
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      final userData = userDoc.data();
      
      // Save login state
      await _saveLoginState(true);
      
      return {
        'success': true,
        'message': 'Login successful',
        'data': {
          'user': {
            'uid': userCredential.user!.uid,
            'name': userData?['name'] ?? userCredential.user!.displayName,
            'email': email,
          }
        },
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for this email';
          break;
        case 'wrong-password':
          message = 'Wrong password provided';
          break;
        case 'invalid-email':
          message = 'The email address is invalid';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
  
  // Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) return null;
      
      return userDoc.data();
    } catch (e) {
      return null;
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _saveLoginState(false);
  }
  
  // Save login state to shared preferences
  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', isLoggedIn);
  }
  
  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.data();
    } catch (e) {
      return null;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (name != null) {
        await user.updateDisplayName(name);
        updates['name'] = name;
      }
      
      if (email != null) {
        await user.updateEmail(email);
        updates['email'] = email;
      }
      
      await _firestore.collection('users').doc(user.uid).update(updates);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
