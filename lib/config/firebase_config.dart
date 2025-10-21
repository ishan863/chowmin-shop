import 'package:firebase_core/firebase_core.dart';

/// Firebase Configuration for ChowMin Shop
/// This file contains all Firebase initialization settings
class FirebaseConfig {
  // Firebase project configuration
  static const String projectId = 'chowmin-shop';
  static const String storageBucket = 'chowmin-shop.firebasestorage.app';
  static const String apiKey = 'AIzaSyD2HsMebh3YnZNFLHOesPNvuIx-MwoiQgE';
  static const String appId = '1:420599805511:android:734a9434d854d64683e362';
  static const String messagingSenderId = '420599805511';
  
  /// Firebase options for Android platform
  static FirebaseOptions get androidOptions => const FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );
  
  /// Initialize Firebase with Android configuration
  /// Call this before using any Firebase services
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: androidOptions,
      );
      print('✅ Firebase initialized successfully!');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }
}

