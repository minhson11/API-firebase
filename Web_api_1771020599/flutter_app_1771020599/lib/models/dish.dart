class MenuItem {
  final int id;
  final String name;
  final String? description;
  final String category;
  final double price;
  final String? imageUrl;
  final int? preparationTime;
  final bool isVegetarian;
  final bool isSpicy;
  final bool isAvailable;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    this.preparationTime,
    required this.isVegetarian,
    required this.isSpicy,
    required this.isAvailable,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      preparationTime: json['preparation_time'],
      isVegetarian: json['is_vegetarian'] == 1 || json['is_vegetarian'] == true,
      isSpicy: json['is_spicy'] == 1 || json['is_spicy'] == true,
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      rating: double.parse(json['rating']?.toString() ?? '0.0'),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'image_url': imageUrl,
      'preparation_time': preparationTime,
      'is_vegetarian': isVegetarian,
      'is_spicy': isSpicy,
      'is_available': isAvailable,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get categoryDisplayName {
    switch (category) {
      case 'Appetizer':
        return 'Khai vị';
      case 'Main Course':
        return 'Món chính';
      case 'Dessert':
        return 'Tráng miệng';
      case 'Beverage':
        return 'Đồ uống';
      case 'Soup':
        return 'Canh/Súp';
      default:
        return category;
    }
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get preparationTimeText {
    if (preparationTime == null) return 'Không xác định';
    return '$preparationTime phút';
  }
}