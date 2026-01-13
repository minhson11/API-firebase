import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../models/menu_item_model.dart';
import '../services/firebase_service.dart';

class SeedData {
  final FirebaseService _firebaseService = FirebaseService();

  // Tạo 5 Customers mẫu
  Future<List<String>> seedCustomers() async {
    List<String> customerIds = [];

    List<CustomerModel> customers = [
      CustomerModel(
        email: 'nguyenvana@gmail.com',
        fullName: 'Nguyễn Văn A',
        phoneNumber: '0901234567',
        address: '123 Nguyễn Huệ, Q1, TP.HCM',
        preferences: ['spicy', 'seafood'],
        loyaltyPoints: 150,
        isActive: true,
      ),
      CustomerModel(
        email: 'tranthib@gmail.com',
        fullName: 'Trần Thị B',
        phoneNumber: '0912345678',
        address: '456 Lê Lợi, Q1, TP.HCM',
        preferences: ['vegetarian', 'sweet'],
        loyaltyPoints: 200,
        isActive: true,
      ),
      CustomerModel(
        email: 'levanc@gmail.com',
        fullName: 'Lê Văn C',
        phoneNumber: '0923456789',
        address: '789 Trần Hưng Đạo, Q5, TP.HCM',
        preferences: ['spicy', 'sour'],
        loyaltyPoints: 75,
        isActive: true,
      ),
      CustomerModel(
        email: 'phamthid@gmail.com',
        fullName: 'Phạm Thị D',
        phoneNumber: '0934567890',
        address: '321 Cách Mạng Tháng 8, Q3, TP.HCM',
        preferences: ['seafood', 'salty'],
        loyaltyPoints: 300,
        isActive: true,
      ),
      CustomerModel(
        email: 'hoangvane@gmail.com',
        fullName: 'Hoàng Văn E',
        phoneNumber: '0945678901',
        address: '654 Võ Văn Tần, Q3, TP.HCM',
        preferences: ['vegetarian'],
        loyaltyPoints: 50,
        isActive: true,
      ),
    ];

    for (CustomerModel customer in customers) {
      DocumentReference docRef =
          await _firebaseService.customersCollection.add(customer.toMap());
      customerIds.add(docRef.id);
    }

    return customerIds;
  }

  // Tạo 20 MenuItems mẫu
  Future<List<String>> seedMenuItems() async {
    List<String> itemIds = [];

    List<MenuItemModel> menuItems = [
      // Appetizer (4 món)
      MenuItemModel(
        name: 'Gỏi cuốn tôm thịt',
        description: 'Gỏi cuốn tươi ngon với tôm, thịt heo, bún và rau sống, chấm tương đậu phộng',
        category: 'Appetizer',
        price: 65000,
        ingredients: ['Tôm', 'Thịt heo', 'Bún', 'Rau sống', 'Bánh tráng'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 10,
        isAvailable: true,
        rating: 4.5,
      ),
      MenuItemModel(
        name: 'Chả giò rế',
        description: 'Chả giò giòn rụm với nhân thịt heo và nấm mèo',
        category: 'Appetizer',
        price: 75000,
        ingredients: ['Thịt heo', 'Nấm mèo', 'Cà rốt', 'Bánh tráng'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.3,
      ),
      MenuItemModel(
        name: 'Salad rau mùa chay',
        description: 'Salad tươi mát với các loại rau theo mùa và sốt dầu giấm',
        category: 'Appetizer',
        price: 55000,
        ingredients: ['Xà lách', 'Cà chua', 'Dưa leo', 'Ô liu', 'Phô mai'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 8,
        isAvailable: true,
        rating: 4.0,
      ),
      MenuItemModel(
        name: 'Cánh gà chiên nước mắm',
        description: 'Cánh gà chiên giòn với sốt nước mắm tỏi ớt đậm đà',
        category: 'Appetizer',
        price: 85000,
        ingredients: ['Cánh gà', 'Tỏi', 'Ớt', 'Nước mắm'],
        isVegetarian: false,
        isSpicy: true,
        preparationTime: 20,
        isAvailable: true,
        rating: 4.7,
      ),

      // Main Course (8 món)
      MenuItemModel(
        name: 'Cơm sườn nướng',
        description: 'Cơm trắng dẻo với sườn heo nướng than hoa, đồ chua và trứng ốp la',
        category: 'Main Course',
        price: 95000,
        ingredients: ['Cơm', 'Sườn heo', 'Trứng', 'Đồ chua', 'Nước mắm'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 25,
        isAvailable: true,
        rating: 4.6,
      ),
      MenuItemModel(
        name: 'Phở bò tái nạm',
        description: 'Phở với nước dùng ninh xương đậm đà, thịt bò tái và nạm',
        category: 'Main Course',
        price: 85000,
        ingredients: ['Bánh phở', 'Thịt bò', 'Xương bò', 'Hành', 'Gừng', 'Rau thơm'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.8,
      ),
      MenuItemModel(
        name: 'Bún bò Huế',
        description: 'Bún với nước dùng cay nồng đặc trưng Huế, thịt bò và chả',
        category: 'Main Course',
        price: 90000,
        ingredients: ['Bún', 'Thịt bò', 'Giò heo', 'Chả', 'Sả', 'Ớt'],
        isVegetarian: false,
        isSpicy: true,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.7,
      ),
      MenuItemModel(
        name: 'Cá kho tộ',
        description: 'Cá basa kho tộ với nước màu dừa, thịt ba chỉ đậm đà',
        category: 'Main Course',
        price: 120000,
        ingredients: ['Cá basa', 'Thịt ba chỉ', 'Nước dừa', 'Tiêu'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 30,
        isAvailable: true,
        rating: 4.4,
      ),
      MenuItemModel(
        name: 'Cơm chiên hải sản',
        description: 'Cơm chiên với tôm, mực, và các loại rau củ',
        category: 'Main Course',
        price: 110000,
        ingredients: ['Cơm', 'Tôm', 'Mực', 'Trứng', 'Rau củ'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 20,
        isAvailable: true,
        rating: 4.3,
      ),
      MenuItemModel(
        name: 'Mì xào chay',
        description: 'Mì xào với đậu hũ, nấm và các loại rau củ',
        category: 'Main Course',
        price: 75000,
        ingredients: ['Mì', 'Đậu hũ', 'Nấm', 'Cà rốt', 'Bắp cải'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.1,
      ),
      MenuItemModel(
        name: 'Gà nướng lá chanh',
        description: 'Đùi gà nướng thơm mùi lá chanh, ăn kèm xôi',
        category: 'Main Course',
        price: 135000,
        ingredients: ['Đùi gà', 'Lá chanh', 'Xôi', 'Nước mắm'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 35,
        isAvailable: false,
        rating: 4.5,
      ),
      MenuItemModel(
        name: 'Lẩu thái hải sản',
        description: 'Lẩu chua cay kiểu Thái với các loại hải sản tươi',
        category: 'Main Course',
        price: 280000,
        ingredients: ['Tôm', 'Mực', 'Cá', 'Nghêu', 'Nấm', 'Rau'],
        isVegetarian: false,
        isSpicy: true,
        preparationTime: 25,
        isAvailable: true,
        rating: 4.6,
      ),

      // Soup (3 món)
      MenuItemModel(
        name: 'Súp cua',
        description: 'Súp cua thơm ngon với trứng cút và nấm',
        category: 'Soup',
        price: 55000,
        ingredients: ['Cua', 'Trứng cút', 'Nấm', 'Bắp non'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.4,
      ),
      MenuItemModel(
        name: 'Canh chua cá lóc',
        description: 'Canh chua miền Nam với cá lóc, đậu bắp, giá',
        category: 'Soup',
        price: 75000,
        ingredients: ['Cá lóc', 'Đậu bắp', 'Giá', 'Me', 'Thơm'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 20,
        isAvailable: true,
        rating: 4.5,
      ),
      MenuItemModel(
        name: 'Súp nấm chay',
        description: 'Súp kem nấm thơm béo cho người ăn chay',
        category: 'Soup',
        price: 50000,
        ingredients: ['Nấm hương', 'Nấm mỡ', 'Kem', 'Hành tây'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.2,
      ),

      // Dessert (3 món)
      MenuItemModel(
        name: 'Chè ba màu',
        description: 'Chè đậu đỏ, đậu xanh, thạch với nước cốt dừa',
        category: 'Dessert',
        price: 35000,
        ingredients: ['Đậu đỏ', 'Đậu xanh', 'Thạch', 'Nước cốt dừa'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 5,
        isAvailable: true,
        rating: 4.3,
      ),
      MenuItemModel(
        name: 'Kem dừa',
        description: 'Kem dừa mát lạnh trong quả dừa tươi',
        category: 'Dessert',
        price: 45000,
        ingredients: ['Dừa', 'Kem', 'Đậu phộng'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 5,
        isAvailable: true,
        rating: 4.6,
      ),
      MenuItemModel(
        name: 'Bánh flan',
        description: 'Bánh flan mềm mịn với caramel đắng ngọt',
        category: 'Dessert',
        price: 30000,
        ingredients: ['Trứng', 'Sữa', 'Caramel', 'Vani'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 5,
        isAvailable: true,
        rating: 4.4,
      ),

      // Beverage (2 món)
      MenuItemModel(
        name: 'Nước mía',
        description: 'Nước mía tươi ép với quất',
        category: 'Beverage',
        price: 25000,
        ingredients: ['Mía', 'Quất', 'Đá'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 3,
        isAvailable: true,
        rating: 4.5,
      ),
      MenuItemModel(
        name: 'Cà phê sữa đá',
        description: 'Cà phê phin đặc trưng Việt Nam với sữa đặc',
        category: 'Beverage',
        price: 35000,
        ingredients: ['Cà phê', 'Sữa đặc', 'Đá'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 5,
        isAvailable: true,
        rating: 4.7,
      ),
    ];

    for (MenuItemModel item in menuItems) {
      DocumentReference docRef =
          await _firebaseService.menuItemsCollection.add(item.toMap());
      itemIds.add(docRef.id);
    }

    return itemIds;
  }

  // Tạo 10 Reservations mẫu
  Future<void> seedReservations(List<String> customerIds, List<String> menuItemIds) async {
    // Lấy thông tin một số menu items để tạo orderItems
    List<DocumentSnapshot> menuDocs = await Future.wait(
      menuItemIds.take(5).map((id) => _firebaseService.menuItemsCollection.doc(id).get()),
    );

    List<Map<String, dynamic>> sampleItems = menuDocs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'itemId': doc.id,
        'itemName': data['name'],
        'price': data['price'],
      };
    }).toList();

    List<Map<String, dynamic>> reservations = [
      // Pending
      {
        'customerId': customerIds[0],
        'reservationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'numberOfGuests': 4,
        'status': 'pending',
        'orderItems': [
          {...sampleItems[0], 'quantity': 2},
          {...sampleItems[1], 'quantity': 1},
        ],
        'paymentStatus': 'pending',
      },
      {
        'customerId': customerIds[1],
        'reservationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'numberOfGuests': 2,
        'status': 'pending',
        'orderItems': [],
        'paymentStatus': 'pending',
      },

      // Confirmed
      {
        'customerId': customerIds[2],
        'reservationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'numberOfGuests': 6,
        'tableNumber': 'T05',
        'status': 'confirmed',
        'orderItems': [
          {...sampleItems[0], 'quantity': 3},
          {...sampleItems[2], 'quantity': 2},
          {...sampleItems[3], 'quantity': 1},
        ],
        'paymentStatus': 'pending',
      },
      {
        'customerId': customerIds[3],
        'reservationDate': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 5))),
        'numberOfGuests': 3,
        'tableNumber': 'T10',
        'status': 'confirmed',
        'specialRequests': 'Bàn gần cửa sổ',
        'orderItems': [
          {...sampleItems[1], 'quantity': 2},
        ],
        'paymentStatus': 'pending',
      },

      // Seated
      {
        'customerId': customerIds[0],
        'reservationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
        'numberOfGuests': 2,
        'tableNumber': 'T03',
        'status': 'seated',
        'orderItems': [
          {...sampleItems[0], 'quantity': 1},
          {...sampleItems[1], 'quantity': 1},
          {...sampleItems[4], 'quantity': 2},
        ],
        'paymentStatus': 'pending',
      },

      // Completed
      {
        'customerId': customerIds[1],
        'reservationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'numberOfGuests': 4,
        'tableNumber': 'T08',
        'status': 'completed',
        'orderItems': [
          {...sampleItems[0], 'quantity': 2},
          {...sampleItems[2], 'quantity': 2},
          {...sampleItems[3], 'quantity': 1},
        ],
        'paymentMethod': 'card',
        'paymentStatus': 'paid',
      },
      {
        'customerId': customerIds[2],
        'reservationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        'numberOfGuests': 5,
        'tableNumber': 'T12',
        'status': 'completed',
        'orderItems': [
          {...sampleItems[1], 'quantity': 3},
          {...sampleItems[4], 'quantity': 2},
        ],
        'paymentMethod': 'cash',
        'paymentStatus': 'paid',
      },
      {
        'customerId': customerIds[4],
        'reservationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'numberOfGuests': 2,
        'tableNumber': 'T02',
        'status': 'completed',
        'orderItems': [
          {...sampleItems[0], 'quantity': 1},
          {...sampleItems[3], 'quantity': 1},
        ],
        'paymentMethod': 'online',
        'paymentStatus': 'paid',
      },

      // Cancelled
      {
        'customerId': customerIds[3],
        'reservationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'numberOfGuests': 8,
        'status': 'cancelled',
        'specialRequests': 'Tiệc sinh nhật',
        'orderItems': [],
        'paymentStatus': 'pending',
      },

      // No show
      {
        'customerId': customerIds[4],
        'reservationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
        'numberOfGuests': 3,
        'tableNumber': 'T07',
        'status': 'no_show',
        'orderItems': [
          {...sampleItems[2], 'quantity': 2},
        ],
        'paymentStatus': 'pending',
      },
    ];

    for (var reservationData in reservations) {
      // Calculate totals
      List<Map<String, dynamic>> items = reservationData['orderItems'] as List<Map<String, dynamic>>;
      double subtotal = 0;
      for (var item in items) {
        subtotal += (item['price'] as num) * (item['quantity'] as int);
      }
      double serviceCharge = subtotal * 0.1;
      double discount = 0;
      double total = subtotal + serviceCharge - discount;

      await _firebaseService.reservationsCollection.add({
        ...reservationData,
        'subtotal': subtotal,
        'serviceCharge': serviceCharge,
        'discount': discount,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Chạy tất cả seed
  Future<void> runAllSeeds() async {
    print('Bắt đầu tạo dữ liệu mẫu...');

    print('Tạo Customers...');
    List<String> customerIds = await seedCustomers();
    print('Đã tạo ${customerIds.length} customers');

    print('Tạo Menu Items...');
    List<String> menuItemIds = await seedMenuItems();
    print('Đã tạo ${menuItemIds.length} menu items');

    print('Tạo Reservations...');
    await seedReservations(customerIds, menuItemIds);
    print('Đã tạo 10 reservations');

    print('Hoàn tất tạo dữ liệu mẫu!');
  }

  // Xóa tất cả dữ liệu
  Future<void> clearAllData() async {
    // Xóa customers
    QuerySnapshot customers = await _firebaseService.customersCollection.get();
    for (var doc in customers.docs) {
      await doc.reference.delete();
    }

    // Xóa menu items
    QuerySnapshot menuItems = await _firebaseService.menuItemsCollection.get();
    for (var doc in menuItems.docs) {
      await doc.reference.delete();
    }

    // Xóa reservations
    QuerySnapshot reservations = await _firebaseService.reservationsCollection.get();
    for (var doc in reservations.docs) {
      await doc.reference.delete();
    }

    print('Đã xóa tất cả dữ liệu!');
  }
}
