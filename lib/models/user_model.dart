class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final List<String> addresses;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.addresses = const [],
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      email: map['email'] as String?,
      addresses: List<String>.from((map['addresses'] ?? <dynamic>[]) as List<dynamic>),
      createdAt: DateTime.parse((map['createdAt'] ?? DateTime.now().toIso8601String()) as String),
      isActive: (map['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'addresses': addresses,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    List<String>? addresses,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
