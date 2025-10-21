import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> placeOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      _orders.insert(0, order.copyWith(id: docRef.id));
      notifyListeners();
      return docRef.id;
    } catch (e) {
      debugPrint('Error placing order: $e');
      return null;
    }
  }

  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final updates = <String, dynamic>{
        'orderStatus': newStatus.name,
      };

      // Add timestamps for different statuses
      switch (newStatus) {
        case OrderStatus.accepted:
          updates['acceptedAt'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.preparing:
          updates['preparingAt'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.ready:
          updates['readyAt'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.delivered:
          updates['deliveredAt'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await _firestore.collection('orders').doc(orderId).update(updates);

      // Update local order
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        final doc = await _firestore.collection('orders').doc(orderId).get();
        _orders[index] = OrderModel.fromMap(doc.data()!, orderId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  Future<bool> updatePaymentStatus(String orderId, PaymentStatus status, {String? transactionId}) async {
    try {
      final updates = <String, dynamic>{
        'paymentStatus': status.name,
      };

      if (transactionId != null) {
        updates['transactionId'] = transactionId;
      }

      await _firestore.collection('orders').doc(orderId).update(updates);

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        final doc = await _firestore.collection('orders').doc(orderId).get();
        _orders[index] = OrderModel.fromMap(doc.data()!, orderId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      return false;
    }
  }

  Stream<OrderModel> watchOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => OrderModel.fromMap(doc.data()!, doc.id));
  }
}

extension OrderModelExtension on OrderModel {
  OrderModel copyWith({
    String? id,
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      deliveryAddress: deliveryAddress,
      items: items,
      totalAmount: totalAmount,
      orderType: orderType,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      transactionId: transactionId,
      specialInstructions: specialInstructions,
      createdAt: createdAt,
      acceptedAt: acceptedAt,
      preparingAt: preparingAt,
      readyAt: readyAt,
      deliveredAt: deliveredAt,
      rating: rating,
      review: review,
    );
  }
}
