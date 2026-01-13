import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;

  // Initialize Firebase
  Future<void> initialize() async {
    // Firebase đã được khởi tạo trong main.dart, chỉ cần lấy instance
    _firestore = FirebaseFirestore.instance;
  }

  // Get Firestore instance
  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  // Collection references
  CollectionReference get customersCollection => firestore.collection('customers');
  CollectionReference get menuItemsCollection => firestore.collection('menu_items');
  CollectionReference get reservationsCollection => firestore.collection('reservations');
}
