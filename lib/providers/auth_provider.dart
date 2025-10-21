import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAdmin = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _isAdmin;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final isAdmin = prefs.getBool('isAdmin') ?? false;
    
    if (userId != null) {
      _isAdmin = isAdmin;
      if (!isAdmin) {
        await _loadUser(userId);
      }
    }
  }

  Future<void> _loadUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, userId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<bool> register(String name, String phone, {String? email}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUsers = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false; // User already exists
      }

      // Create new user
      final userDoc = _firestore.collection('users').doc();
      final user = UserModel(
        id: userDoc.id,
        name: name,
        phone: phone,
        email: email,
        createdAt: DateTime.now(),
      );

      await userDoc.set(user.toMap());
      _currentUser = user;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);
      await prefs.setBool('isAdmin', false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error registering user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final users = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (users.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = UserModel.fromMap(users.docs.first.data(), users.docs.first.id);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);
      await prefs.setBool('isAdmin', false);

      _isLoading = false;
      _isAdmin = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error logging in: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> adminLogin(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final admins = await _firestore
          .collection('admins')
          .where('phone', isEqualTo: phone)
          .where('password', isEqualTo: password)
          .get();

      if (admins.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Save admin session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', admins.docs.first.id);
      await prefs.setBool('isAdmin', true);

      _isAdmin = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error admin login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Quick admin login with phone only (for specific admin numbers)
  Future<void> loginAsAdmin(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', 'admin_$phone');
    await prefs.setBool('isAdmin', true);
    _isAdmin = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAdmin = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('isAdmin');

    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    List<String>? addresses,
  }) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        email: email,
        addresses: addresses,
      );

      await _firestore.collection('users').doc(_currentUser!.id).update(
        updatedUser.toMap(),
      );

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;

      await _firestore.collection('users').doc(_currentUser!.id).update(updates);

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
}
