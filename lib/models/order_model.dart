enum OrderStatus {
  placed,
  accepted,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

enum PaymentMode {
  online,
  payAtShop,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
}

enum OrderType {
  takeAway,
  dineIn,
  homeDelivery,
}

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final bool isVeg;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isVeg,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: (map['menuItemId'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      price: ((map['price'] ?? 0) as num).toDouble(),
      quantity: (map['quantity'] ?? 1) as int,
      isVeg: (map['isVeg'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isVeg': isVeg,
    };
  }

  double get totalPrice => price * quantity;
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String? deliveryAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderType orderType;
  final PaymentMode paymentMode;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final String? transactionId;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? deliveredAt;
  final int? rating;
  final String? review;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.orderType,
    required this.paymentMode,
    required this.paymentStatus,
    required this.orderStatus,
    this.transactionId,
    this.specialInstructions,
    required this.createdAt,
    this.acceptedAt,
    this.preparingAt,
    this.readyAt,
    this.deliveredAt,
    this.rating,
    this.review,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? '') as String,
      userPhone: (map['userPhone'] ?? '') as String,
      deliveryAddress: map['deliveryAddress'] as String?,
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          <OrderItem>[],
      totalAmount: ((map['totalAmount'] ?? 0) as num).toDouble(),
      orderType: OrderType.values.firstWhere(
        (e) => e.name == map['orderType'],
        orElse: () => OrderType.takeAway,
      ),
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.name == map['paymentMode'],
        orElse: () => PaymentMode.payAtShop,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      orderStatus: OrderStatus.values.firstWhere(
        (e) => e.name == map['orderStatus'],
        orElse: () => OrderStatus.placed,
      ),
      transactionId: map['transactionId'] as String?,
      specialInstructions: map['specialInstructions'] as String?,
      createdAt: DateTime.parse((map['createdAt'] ?? DateTime.now().toIso8601String()) as String),
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt'] as String) : null,
      preparingAt: map['preparingAt'] != null ? DateTime.parse(map['preparingAt'] as String) : null,
      readyAt: map['readyAt'] != null ? DateTime.parse(map['readyAt'] as String) : null,
      deliveredAt: map['deliveredAt'] != null ? DateTime.parse(map['deliveredAt'] as String) : null,
      rating: map['rating'] as int?,
      review: map['review'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'deliveryAddress': deliveryAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderType': orderType.name,
      'paymentMode': paymentMode.name,
      'paymentStatus': paymentStatus.name,
      'orderStatus': orderStatus.name,
      'transactionId': transactionId,
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'preparingAt': preparingAt?.toIso8601String(),
      'readyAt': readyAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'rating': rating,
      'review': review,
    };
  }

  String get orderStatusText {
    switch (orderStatus) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Order Accepted';
      case OrderStatus.preparing:
        return 'Preparing Your Food';
      case OrderStatus.ready:
        return 'Ready for Pickup/Delivery';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
