import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../services/firebase_service.dart';

class MenuItemRepository {
  final FirebaseService _firebaseService = FirebaseService();

  CollectionReference get _collection => _firebaseService.menuItemsCollection;

  // 1. Thêm MenuItem
  Future<String> addMenuItem(MenuItemModel menuItem) async {
    try {
      DocumentReference docRef = await _collection.add(menuItem.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi khi thêm menu item: $e');
    }
  }

  // 2. Lấy MenuItem theo ID
  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    try {
      DocumentSnapshot doc = await _collection.doc(itemId).get();
      if (doc.exists) {
        return MenuItemModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy menu item: $e');
    }
  }

  // 3. Lấy tất cả MenuItems
  Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      QuerySnapshot snapshot = await _collection.get();
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách menu items: $e');
    }
  }

  // Stream tất cả MenuItems (real-time)
  Stream<List<MenuItemModel>> getMenuItemsStream() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList());
  }

  // 4. Tìm kiếm MenuItems - Tìm trong name, description, ingredients
  Future<List<MenuItemModel>> searchMenuItems(String searchTerm) async {
    try {
      // Firestore không hỗ trợ full-text search, nên ta phải lấy tất cả và filter
      QuerySnapshot snapshot = await _collection.get();
      List<MenuItemModel> allItems =
          snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();

      String searchLower = searchTerm.toLowerCase();
      return allItems.where((item) {
        bool nameMatch = item.name.toLowerCase().contains(searchLower);
        bool descMatch = item.description.toLowerCase().contains(searchLower);
        bool ingredientMatch = item.ingredients
            .any((ingredient) => ingredient.toLowerCase().contains(searchLower));
        return nameMatch || descMatch || ingredientMatch;
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm menu items: $e');
    }
  }

  // 5. Lọc MenuItems theo category
  Future<List<MenuItemModel>> getMenuItemsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _collection
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lọc menu items theo category: $e');
    }
  }

  // Lọc MenuItems theo isVegetarian
  Future<List<MenuItemModel>> getVegetarianItems() async {
    try {
      QuerySnapshot snapshot = await _collection
          .where('isVegetarian', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lọc món chay: $e');
    }
  }

  // Lọc MenuItems theo isSpicy
  Future<List<MenuItemModel>> getSpicyItems() async {
    try {
      QuerySnapshot snapshot = await _collection
          .where('isSpicy', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lọc món cay: $e');
    }
  }

  // Lọc MenuItems theo nhiều tiêu chí
  Stream<List<MenuItemModel>> getFilteredMenuItemsStream({
    String? category,
    bool? isVegetarian,
    bool? isSpicy,
    bool? isAvailable,
  }) {
    Query query = _collection;

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (isVegetarian != null && isVegetarian) {
      query = query.where('isVegetarian', isEqualTo: true);
    }
    if (isSpicy != null && isSpicy) {
      query = query.where('isSpicy', isEqualTo: true);
    }
    if (isAvailable != null) {
      query = query.where('isAvailable', isEqualTo: isAvailable);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList());
  }

  // Cập nhật MenuItem
  Future<void> updateMenuItem(String itemId, MenuItemModel menuItem) async {
    try {
      await _collection.doc(itemId).update(menuItem.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật menu item: $e');
    }
  }

  // Cập nhật trạng thái available
  Future<void> updateAvailability(String itemId, bool isAvailable) async {
    try {
      await _collection.doc(itemId).update({'isAvailable': isAvailable});
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái: $e');
    }
  }

  // Xóa MenuItem
  Future<void> deleteMenuItem(String itemId) async {
    try {
      await _collection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa menu item: $e');
    }
  }

  // Lấy menu items available
  Future<List<MenuItemModel>> getAvailableMenuItems() async {
    try {
      QuerySnapshot snapshot = await _collection
          .where('isAvailable', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy menu items available: $e');
    }
  }
}
