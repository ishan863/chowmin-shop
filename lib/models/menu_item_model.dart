class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isVeg;
  final bool isAvailable;
  final int preparationTime; // in minutes
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getters for backwards compatibility
  String get image => imageUrl;
  double get rating => 4.5; // Default rating

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.isVeg,
    this.isAvailable = true,
    this.preparationTime = 15,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map, String id) {
    final now = DateTime.now();
    DateTime parseDateTime(dynamic value) {
      if (value == null) return now;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return now;
        }
      }
      return now;
    }

    return MenuItem(
      id: id,
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      price: ((map['price'] ?? 0) as num).toDouble(),
      category: (map['category'] ?? '') as String,
      imageUrl: (map['imageUrl'] ?? '') as String,
      isVeg: (map['isVeg'] ?? true) as bool,
      isAvailable: (map['isAvailable'] ?? true) as bool,
      preparationTime: (map['preparationTime'] ?? 15) as int,
      tags: List<String>.from((map['tags'] ?? <dynamic>[]) as List<dynamic>),
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
      'preparationTime': preparationTime,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isVeg,
    bool? isAvailable,
    int? preparationTime,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isVeg: isVeg ?? this.isVeg,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTime: preparationTime ?? this.preparationTime,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
