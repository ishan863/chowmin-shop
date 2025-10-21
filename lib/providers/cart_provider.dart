import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  double _discount = 0.0;

  List<CartItem> get items => _items;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  // Calculate subtotal (sum of all items)
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  // Delivery charges
  double get deliveryCharges {
    if (_items.isEmpty) return 0.0;
    if (subtotal >= 500) return 0.0; // Free delivery above ₹500
    return 40.0;
  }
  
  // GST calculation (5%)
  double get gstAmount => subtotal * 0.05;
  
  // Discount
  double get discount => _discount;
  
  // Total amount with all charges
  double get totalAmount => subtotal + deliveryCharges + gstAmount - _discount;

  void addItem(MenuItem menuItem) {
    final existingIndex = _items.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(menuItem: menuItem));
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }
  
  void applyDiscount(double amount) {
    _discount = amount;
    notifyListeners();
  }
  
  void applyCoupon(String couponCode) {
    // Apply discount based on coupon code
    switch (couponCode.toUpperCase()) {
      case 'WELCOME10':
        _discount = subtotal * 0.1; // 10% off
        break;
      case 'SAVE50':
        _discount = 50.0; // Flat ₹50 off
        break;
      case 'RAJEEV20':
        _discount = subtotal * 0.2; // 20% off (special)
        break;
      default:
        _discount = 0.0;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discount = 0.0;
    notifyListeners();
  }
}
