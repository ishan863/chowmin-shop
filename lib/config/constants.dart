import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'ChowMin Corner Delight';
  static const String appVersion = '1.0.0';
  
  // Contact Info
  static const String shopPhone = '+91 9876543210';
  static const String shopEmail = 'chowmincorner@example.com';
  static const String shopAddress = 'Shop 123, Food Street, City';
  
  // UPI Info
  static const String upiId = 'chowmincorner@upi';
  static const String upiName = 'ChowMin Corner';
  
  // Categories
  static const List<String> foodCategories = [
    'All',
    'Chowmin',
    'Fried Rice',
    'Momos',
    'Soups',
    'Snacks',
    'Beverages',
  ];
  
  // Order Status Messages
  static const Map<String, String> orderStatusMessages = {
    'placed': '🎉 Order Placed Successfully!',
    'accepted': '✅ Order Accepted by Restaurant',
    'preparing': '👨‍🍳 Chef is Preparing Your Food',
    'ready': '✨ Your Order is Ready!',
    'outForDelivery': '🚴 Out for Delivery',
    'delivered': '🎊 Order Delivered! Enjoy!',
    'cancelled': '❌ Order Cancelled',
  };
  
  // Animations
  static const String splashAnimation = 'assets/animations/splash.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String cookingAnimation = 'assets/animations/cooking.json';
  static const String deliveryAnimation = 'assets/animations/delivery.json';
  
  // Images
  static const String logoImage = 'assets/images/logo.png';
  static const String placeholderFood = 'assets/images/placeholder_food.png';
  
  // Timings
  static const int splashDuration = 3;
  static const int orderRefreshInterval = 30; // seconds
  
  // Limits
  static const int maxCartItems = 20;
  static const double minOrderAmount = 50.0;
  static const double deliveryCharge = 20.0;
  static const double freeDeliveryAbove = 200.0;
  
  // Regex
  static final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
}
