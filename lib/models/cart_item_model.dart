import 'menu_item_model.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItem.id,
      'name': menuItem.name,
      'price': menuItem.price,
      'quantity': quantity,
      'imageUrl': menuItem.imageUrl,
      'isVeg': menuItem.isVeg,
    };
  }
}
