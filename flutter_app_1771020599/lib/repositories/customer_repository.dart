import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../services/firebase_service.dart';

class CustomerRepository {
  final FirebaseService _firebaseService = FirebaseService();

  CollectionReference get _collection => _firebaseService.customersCollection;

  // 1. Thêm Customer
  Future<String> addCustomer(CustomerModel customer) async {
    try {
      DocumentReference docRef = await _collection.add(customer.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi khi thêm customer: $e');
    }
  }

  // 2. Lấy Customer theo ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      DocumentSnapshot doc = await _collection.doc(customerId).get();
      if (doc.exists) {
        return CustomerModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy customer: $e');
    }
  }

  // 3. Lấy tất cả Customers
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      QuerySnapshot snapshot = await _collection.get();
      return snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách customers: $e');
    }
  }

  // Stream tất cả Customers (real-time)
  Stream<List<CustomerModel>> getCustomersStream() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList());
  }

  // 4. Cập nhật Customer
  Future<void> updateCustomer(String customerId, CustomerModel customer) async {
    try {
      await _collection.doc(customerId).update(customer.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật customer: $e');
    }
  }

  // 5. Cập nhật Loyalty Points
  Future<void> updateLoyaltyPoints(String customerId, int points) async {
    try {
      await _collection.doc(customerId).update({
        'loyaltyPoints': FieldValue.increment(points),
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật loyalty points: $e');
    }
  }

  // Xóa Customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _collection.doc(customerId).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa customer: $e');
    }
  }

  // Tìm Customer theo email
  Future<CustomerModel?> getCustomerByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _collection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return CustomerModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi tìm customer: $e');
    }
  }

  // Lấy Customer active
  Future<List<CustomerModel>> getActiveCustomers() async {
    try {
      QuerySnapshot snapshot = await _collection
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách active customers: $e');
    }
  }
}
