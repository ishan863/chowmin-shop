import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuProvider extends ChangeNotifier {
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _selectedCategory;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> get categories {
    final cats = _menuItems.map((item) => item.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<MenuItem> get filteredItems {
    if (_selectedCategory == null) {
      return _menuItems.where((item) => item.isAvailable).toList();
    }
    return _menuItems
        .where((item) => item.category == _selectedCategory && item.isAvailable)
        .toList();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchMenuItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔍 Fetching menu items from Firestore...');
      final snapshot = await _firestore.collection('menu_items').get();
      debugPrint('📦 Found ${snapshot.docs.length} documents in menu_items collection');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ No documents found in menu_items collection!');
        _menuItems = [];
      } else {
        _menuItems = [];
        for (var doc in snapshot.docs) {
          try {
            debugPrint('📄 Processing document: ${doc.id}');
            debugPrint('   Data: ${doc.data()}');
            final item = MenuItem.fromMap(doc.data(), doc.id);
            _menuItems.add(item);
            debugPrint('✅ Successfully added: ${item.name}');
          } catch (e) {
            debugPrint('❌ Error parsing document ${doc.id}: $e');
            debugPrint('   Document data: ${doc.data()}');
          }
        }
        debugPrint('✅ Total items loaded: ${_menuItems.length}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching menu items: $e');
      _menuItems = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMenuItem(MenuItem item) async {
    try {
      final docRef = await _firestore.collection('menu_items').add(item.toMap());
      final newItem = item.copyWith(id: docRef.id);
      _menuItems.add(newItem);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding menu item: $e');
      return false;
    }
  }

  Future<bool> updateMenuItem(MenuItem item) async {
    try {
      await _firestore.collection('menu_items').doc(item.id).update(item.toMap());
      final index = _menuItems.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _menuItems[index] = item;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      return false;
    }
  }

  Future<bool> deleteMenuItem(String itemId) async {
    try {
      await _firestore.collection('menu_items').doc(itemId).delete();
      _menuItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      return false;
    }
  }
}
