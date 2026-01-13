import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import '../models/menu_item_model.dart';
import '../services/firebase_service.dart';
import 'customer_repository.dart';
import 'menu_item_repository.dart';

class ReservationRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final CustomerRepository _customerRepository = CustomerRepository();
  final MenuItemRepository _menuItemRepository = MenuItemRepository();

  CollectionReference get _collection => _firebaseService.reservationsCollection;

  // 1. Đặt Bàn
  Future<String> createReservation(
    String customerId,
    Timestamp reservationDate,
    int numberOfGuests,
    String? specialRequests,
  ) async {
    try {
      // Kiểm tra customer tồn tại
      final customer = await _customerRepository.getCustomerById(customerId);
      if (customer == null) {
        throw Exception('Không tìm thấy khách hàng');
      }

      ReservationModel reservation = ReservationModel(
        customerId: customerId,
        reservationDate: reservationDate,
        numberOfGuests: numberOfGuests,
        specialRequests: specialRequests,
        status: 'pending',
        orderItems: [],
        subtotal: 0,
        serviceCharge: 0,
        discount: 0,
        total: 0,
        paymentStatus: 'pending',
      );

      DocumentReference docRef = await _collection.add(reservation.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi khi đặt bàn: $e');
    }
  }

  // 2. Thêm Món vào Đơn
  Future<void> addItemToReservation(
    String reservationId,
    String itemId,
    int quantity,
  ) async {
    try {
      // Lấy thông tin món ăn
      MenuItemModel? menuItem = await _menuItemRepository.getMenuItemById(itemId);
      if (menuItem == null) {
        throw Exception('Không tìm thấy món ăn');
      }

      // Kiểm tra món còn phục vụ không
      if (!menuItem.isAvailable) {
        throw Exception('Món ${menuItem.name} hiện đã hết');
      }

      // Lấy reservation hiện tại
      DocumentSnapshot doc = await _collection.doc(reservationId).get();
      if (!doc.exists) {
        throw Exception('Không tìm thấy đặt bàn');
      }

      ReservationModel reservation = ReservationModel.fromFirestore(doc);

      // Kiểm tra xem món đã có trong đơn chưa
      List<OrderItem> updatedItems = List.from(reservation.orderItems);
      int existingIndex = updatedItems.indexWhere((item) => item.itemId == itemId);

      if (existingIndex >= 0) {
        // Cập nhật số lượng nếu món đã có
        OrderItem existingItem = updatedItems[existingIndex];
        updatedItems[existingIndex] = OrderItem(
          itemId: existingItem.itemId,
          itemName: existingItem.itemName,
          quantity: existingItem.quantity + quantity,
          price: existingItem.price,
        );
      } else {
        // Thêm món mới
        updatedItems.add(OrderItem(
          itemId: itemId,
          itemName: menuItem.name,
          quantity: quantity,
          price: menuItem.price,
        ));
      }

      // Tính lại tổng tiền
      double newSubtotal = ReservationModel.calculateSubtotal(updatedItems);
      double newServiceCharge = ReservationModel.calculateServiceCharge(newSubtotal);
      double newTotal = ReservationModel.calculateTotal(
        newSubtotal,
        newServiceCharge,
        reservation.discount,
      );

      // Cập nhật reservation
      await _collection.doc(reservationId).update({
        'orderItems': updatedItems.map((item) => item.toMap()).toList(),
        'subtotal': newSubtotal,
        'serviceCharge': newServiceCharge,
        'total': newTotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi thêm món: $e');
    }
  }

  // Xóa món khỏi đơn
  Future<void> removeItemFromReservation(
    String reservationId,
    String itemId,
  ) async {
    try {
      DocumentSnapshot doc = await _collection.doc(reservationId).get();
      if (!doc.exists) {
        throw Exception('Không tìm thấy đặt bàn');
      }

      ReservationModel reservation = ReservationModel.fromFirestore(doc);
      List<OrderItem> updatedItems = reservation.orderItems
          .where((item) => item.itemId != itemId)
          .toList();

      double newSubtotal = ReservationModel.calculateSubtotal(updatedItems);
      double newServiceCharge = ReservationModel.calculateServiceCharge(newSubtotal);
      double newTotal = ReservationModel.calculateTotal(
        newSubtotal,
        newServiceCharge,
        reservation.discount,
      );

      await _collection.doc(reservationId).update({
        'orderItems': updatedItems.map((item) => item.toMap()).toList(),
        'subtotal': newSubtotal,
        'serviceCharge': newServiceCharge,
        'total': newTotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi xóa món: $e');
    }
  }

  // Cập nhật số lượng món
  Future<void> updateItemQuantity(
    String reservationId,
    String itemId,
    int newQuantity,
  ) async {
    try {
      if (newQuantity <= 0) {
        await removeItemFromReservation(reservationId, itemId);
        return;
      }

      DocumentSnapshot doc = await _collection.doc(reservationId).get();
      if (!doc.exists) {
        throw Exception('Không tìm thấy đặt bàn');
      }

      ReservationModel reservation = ReservationModel.fromFirestore(doc);
      List<OrderItem> updatedItems = reservation.orderItems.map((item) {
        if (item.itemId == itemId) {
          return OrderItem(
            itemId: item.itemId,
            itemName: item.itemName,
            quantity: newQuantity,
            price: item.price,
          );
        }
        return item;
      }).toList();

      double newSubtotal = ReservationModel.calculateSubtotal(updatedItems);
      double newServiceCharge = ReservationModel.calculateServiceCharge(newSubtotal);
      double newTotal = ReservationModel.calculateTotal(
        newSubtotal,
        newServiceCharge,
        reservation.discount,
      );

      await _collection.doc(reservationId).update({
        'orderItems': updatedItems.map((item) => item.toMap()).toList(),
        'subtotal': newSubtotal,
        'serviceCharge': newServiceCharge,
        'total': newTotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật số lượng: $e');
    }
  }

  // 3. Xác nhận Đặt Bàn
  Future<void> confirmReservation(String reservationId, String tableNumber) async {
    try {
      await _collection.doc(reservationId).update({
        'status': 'confirmed',
        'tableNumber': tableNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi xác nhận đặt bàn: $e');
    }
  }

  // Cập nhật trạng thái seated
  Future<void> setSeated(String reservationId) async {
    try {
      await _collection.doc(reservationId).update({
        'status': 'seated',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái: $e');
    }
  }

  // 4. Thanh toán
  Future<void> payReservation(String reservationId, String paymentMethod) async {
    try {
      DocumentSnapshot doc = await _collection.doc(reservationId).get();
      if (!doc.exists) {
        throw Exception('Không tìm thấy đặt bàn');
      }

      ReservationModel reservation = ReservationModel.fromFirestore(doc);

      // Lấy thông tin customer
      final customer = await _customerRepository.getCustomerById(reservation.customerId);
      if (customer == null) {
        throw Exception('Không tìm thấy khách hàng');
      }

      // Tính discount từ loyaltyPoints (1 point = 1000đ, tối đa 50% total)
      int availablePoints = customer.loyaltyPoints;
      double maxDiscount = reservation.subtotal * 0.5; // Tối đa 50%
      double pointDiscount = availablePoints * 1000.0; // 1 point = 1000đ
      double actualDiscount = pointDiscount > maxDiscount ? maxDiscount : pointDiscount;
      int pointsUsed = (actualDiscount / 1000).floor();

      // Tính lại total
      double newTotal = ReservationModel.calculateTotal(
        reservation.subtotal,
        reservation.serviceCharge,
        actualDiscount,
      );

      // Cập nhật reservation
      await _collection.doc(reservationId).update({
        'discount': actualDiscount,
        'total': newTotal,
        'paymentMethod': paymentMethod,
        'paymentStatus': 'paid',
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Cộng loyaltyPoints cho customer (1% total)
      int earnedPoints = (newTotal * 0.01).floor();

      // Cập nhật loyaltyPoints: cộng điểm mới - trừ điểm đã dùng
      await _customerRepository.updateLoyaltyPoints(
        reservation.customerId,
        earnedPoints - pointsUsed,
      );
    } catch (e) {
      throw Exception('Lỗi khi thanh toán: $e');
    }
  }

  // 5. Lấy Đặt Bàn theo Customer
  Future<List<ReservationModel>> getReservationsByCustomer(String customerId) async {
    try {
      QuerySnapshot snapshot = await _collection
          .where('customerId', isEqualTo: customerId)
          .orderBy('reservationDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đặt bàn: $e');
    }
  }

  // Stream đặt bàn theo Customer (real-time)
  Stream<List<ReservationModel>> getReservationsByCustomerStream(String customerId) {
    return _collection
        .where('customerId', isEqualTo: customerId)
        .orderBy('reservationDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc)).toList());
  }

  // Lấy Đặt Bàn theo ngày
  Future<List<ReservationModel>> getReservationsByDate(String date) async {
    try {
      // Parse date string to DateTime
      DateTime parsedDate = DateTime.parse(date);
      DateTime startOfDay = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await _collection
          .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('reservationDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      return snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy đặt bàn theo ngày: $e');
    }
  }

  // Lấy reservation theo ID
  Future<ReservationModel?> getReservationById(String reservationId) async {
    try {
      DocumentSnapshot doc = await _collection.doc(reservationId).get();
      if (doc.exists) {
        return ReservationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy đặt bàn: $e');
    }
  }

  // Stream reservation theo ID (real-time)
  Stream<ReservationModel?> getReservationByIdStream(String reservationId) {
    return _collection.doc(reservationId).snapshots().map((doc) {
      if (doc.exists) {
        return ReservationModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Lấy tất cả reservations
  Future<List<ReservationModel>> getAllReservations() async {
    try {
      QuerySnapshot snapshot = await _collection
          .orderBy('reservationDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đặt bàn: $e');
    }
  }

  // Hủy đặt bàn
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _collection.doc(reservationId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi hủy đặt bàn: $e');
    }
  }

  // Xóa reservation
  Future<void> deleteReservation(String reservationId) async {
    try {
      await _collection.doc(reservationId).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa đặt bàn: $e');
    }
  }
}
