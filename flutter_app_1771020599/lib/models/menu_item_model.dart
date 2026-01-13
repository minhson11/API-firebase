import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String? itemId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final bool isVegetarian;
  final bool isSpicy;
  final int preparationTime;
  final bool isAvailable;
  final double rating;
  final Timestamp? createdAt;

  MenuItemModel({
    this.itemId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl = '',
    required this.ingredients,
    this.isVegetarian = false,
    this.isSpicy = false,
    this.preparationTime = 15,
    this.isAvailable = true,
    this.rating = 0.0,
    this.createdAt,
  });

  // Convert từ Firestore Document sang Model
  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MenuItemModel(
      itemId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      isVegetarian: data['isVegetarian'] ?? false,
      isSpicy: data['isSpicy'] ?? false,
      preparationTime: data['preparationTime'] ?? 15,
      isAvailable: data['isAvailable'] ?? true,
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: data['createdAt'],
    );
  }

  // Convert từ Map sang Model
  factory MenuItemModel.fromMap(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      itemId: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      isVegetarian: data['isVegetarian'] ?? false,
      isSpicy: data['isSpicy'] ?? false,
      preparationTime: data['preparationTime'] ?? 15,
      isAvailable: data['isAvailable'] ?? true,
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: data['createdAt'],
    );
  }

  // Convert Model sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'isVegetarian': isVegetarian,
      'isSpicy': isSpicy,
      'preparationTime': preparationTime,
      'isAvailable': isAvailable,
      'rating': rating,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  MenuItemModel copyWith({
    String? itemId,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    List<String>? ingredients,
    bool? isVegetarian,
    bool? isSpicy,
    int? preparationTime,
    bool? isAvailable,
    double? rating,
    Timestamp? createdAt,
  }) {
    return MenuItemModel(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isSpicy: isSpicy ?? this.isSpicy,
      preparationTime: preparationTime ?? this.preparationTime,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Danh sách các category
  static List<String> get categories => [
        'Appetizer',
        'Main Course',
        'Dessert',
        'Beverage',
        'Soup',
      ];
}
