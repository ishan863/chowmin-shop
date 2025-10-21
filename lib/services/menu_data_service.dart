import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auto-populate menu items on first run
  Future<void> initializeMenuData() async {
    try {
      // Check if menu items already exist
      final snapshot = await _firestore.collection('menu_items').limit(1).get();
      
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Menu items already exist, skipping initialization');
        return;
      }

      debugPrint('Initializing menu data...');
      
      // Add all menu items
      await _addAllMenuItems();
      
      debugPrint('Menu data initialized successfully!');
    } catch (e) {
      debugPrint('Error initializing menu data: $e');
    }
  }

  Future<void> _addAllMenuItems() async {
    final items = [
      // Chowmin Items
      {
        'name': 'Veg Chowmin',
        'description': 'Delicious vegetarian chowmin with fresh vegetables',
        'price': 80.0,
        'category': 'Chowmin',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',
      },
      {
        'name': 'Chicken Chowmin',
        'description': 'Spicy chicken chowmin with special sauce',
        'price': 120.0,
        'category': 'Chowmin',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=400',
      },
      {
        'name': 'Egg Chowmin',
        'description': 'Chowmin with scrambled eggs',
        'price': 100.0,
        'category': 'Chowmin',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1603073883752-34d38b58f67f?w=400',
      },
      {
        'name': 'Mixed Chowmin',
        'description': 'Combination of chicken and egg chowmin',
        'price': 140.0,
        'category': 'Chowmin',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400',
      },
      {
        'name': 'Paneer Chowmin',
        'description': 'Chowmin with cottage cheese cubes',
        'price': 110.0,
        'category': 'Chowmin',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1626777552726-4a6b54be4b96?w=400',
      },
      
      // Noodles Items
      {
        'name': 'Hakka Noodles',
        'description': 'Indo-Chinese style noodles',
        'price': 90.0,
        'category': 'Noodles',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=400',
      },
      {
        'name': 'Schezwan Noodles',
        'description': 'Spicy schezwan sauce noodles',
        'price': 100.0,
        'category': 'Noodles',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1630384082552-dac8e403e7ad?w=400',
      },
      {
        'name': 'Singapore Noodles',
        'description': 'Curry flavored rice noodles',
        'price': 130.0,
        'category': 'Noodles',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=400',
      },
      
      // Rice Items
      {
        'name': 'Veg Fried Rice',
        'description': 'Fried rice with mixed vegetables',
        'price': 85.0,
        'category': 'Rice',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
      },
      {
        'name': 'Chicken Fried Rice',
        'description': 'Fried rice with chicken pieces',
        'price': 125.0,
        'category': 'Rice',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
      },
      {
        'name': 'Egg Fried Rice',
        'description': 'Fried rice with scrambled eggs',
        'price': 95.0,
        'category': 'Rice',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400',
      },
      {
        'name': 'Schezwan Rice',
        'description': 'Spicy schezwan fried rice',
        'price': 110.0,
        'category': 'Rice',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?w=400',
      },
      
      // Starters
      {
        'name': 'Spring Rolls',
        'description': 'Crispy vegetable spring rolls',
        'price': 70.0,
        'category': 'Starters',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400',
      },
      {
        'name': 'Chicken Momos',
        'description': 'Steamed chicken dumplings',
        'price': 90.0,
        'category': 'Starters',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1626074353765-517a65eca3c1?w=400',
      },
      {
        'name': 'Veg Momos',
        'description': 'Steamed vegetable dumplings',
        'price': 70.0,
        'category': 'Starters',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400',
      },
      {
        'name': 'Manchurian',
        'description': 'Veg manchurian in spicy sauce',
        'price': 80.0,
        'category': 'Starters',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=400',
      },
      {
        'name': 'Chilli Chicken',
        'description': 'Spicy Indo-Chinese chicken',
        'price': 140.0,
        'category': 'Starters',
        'isVeg': false,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400',
      },
      {
        'name': 'Chilli Paneer',
        'description': 'Spicy cottage cheese cubes',
        'price': 120.0,
        'category': 'Starters',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400',
      },
      {
        'name': 'Honey Chilli Potato',
        'description': 'Crispy potato in honey chilli sauce',
        'price': 90.0,
        'category': 'Starters',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1518013431117-eb1465fa5752?w=400',
      },
      {
        'name': 'Garlic Bread',
        'description': 'Toasted garlic bread with herbs',
        'price': 60.0,
        'category': 'Starters',
        'isVeg': true,
        'isAvailable': true,
        'imageUrl': 'https://images.unsplash.com/photo-1573140401552-388ed0f3b449?w=400',
      },
    ];

    // Add each item to Firestore
    for (var item in items) {
      await _firestore.collection('menu_items').add(item);
    }
  }
}
