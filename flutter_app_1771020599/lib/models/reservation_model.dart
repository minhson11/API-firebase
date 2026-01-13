import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
    };
  }

  double get subtotal => price * quantity;
}

class ReservationModel {
  final String? reservationId;
  final String customerId;
  final Timestamp reservationDate;
  final int numberOfGuests;
  final String? tableNumber;
  final String status;
  final String? specialRequests;
  final List<OrderItem> orderItems;
  final double subtotal;
  final double serviceCharge;
  final double discount;
  final double total;
  final String? paymentMethod;
  final String paymentStatus;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ReservationModel({
    this.reservationId,
    required this.customerId,
    required this.reservationDate,
    required this.numberOfGuests,
    this.tableNumber,
    this.status = 'pending',
    this.specialRequests,
    this.orderItems = const [],
    this.subtotal = 0.0,
    this.serviceCharge = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  // Convert từ Firestore Document sang Model
  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<OrderItem> items = [];
    if (data['orderItems'] != null) {
      items = (data['orderItems'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return ReservationModel(
      reservationId: doc.id,
      customerId: data['customerId'] ?? '',
      reservationDate: data['reservationDate'] ?? Timestamp.now(),
      numberOfGuests: data['numberOfGuests'] ?? 0,
      tableNumber: data['tableNumber'],
      status: data['status'] ?? 'pending',
      specialRequests: data['specialRequests'],
      orderItems: items,
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      serviceCharge: (data['serviceCharge'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Convert từ Map sang Model
  factory ReservationModel.fromMap(Map<String, dynamic> data, String id) {
    List<OrderItem> items = [];
    if (data['orderItems'] != null) {
      items = (data['orderItems'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return ReservationModel(
      reservationId: id,
      customerId: data['customerId'] ?? '',
      reservationDate: data['reservationDate'] ?? Timestamp.now(),
      numberOfGuests: data['numberOfGuests'] ?? 0,
      tableNumber: data['tableNumber'],
      status: data['status'] ?? 'pending',
      specialRequests: data['specialRequests'],
      orderItems: items,
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      serviceCharge: (data['serviceCharge'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Convert Model sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'reservationDate': reservationDate,
      'numberOfGuests': numberOfGuests,
      'tableNumber': tableNumber,
      'status': status,
      'specialRequests': specialRequests,
      'orderItems': orderItems.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  ReservationModel copyWith({
    String? reservationId,
    String? customerId,
    Timestamp? reservationDate,
    int? numberOfGuests,
    String? tableNumber,
    String? status,
    String? specialRequests,
    List<OrderItem>? orderItems,
    double? subtotal,
    double? serviceCharge,
    double? discount,
    double? total,
    String? paymentMethod,
    String? paymentStatus,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ReservationModel(
      reservationId: reservationId ?? this.reservationId,
      customerId: customerId ?? this.customerId,
      reservationDate: reservationDate ?? this.reservationDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      orderItems: orderItems ?? this.orderItems,
      subtotal: subtotal ?? this.subtotal,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Tính toán lại tổng tiền
  static double calculateSubtotal(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  static double calculateServiceCharge(double subtotal) {
    return subtotal * 0.1; // 10% phí dịch vụ
  }

  static double calculateTotal(double subtotal, double serviceCharge, double discount) {
    return subtotal + serviceCharge - discount;
  }

  // Danh sách các trạng thái
  static List<String> get statuses => [
        'pending',
        'confirmed',
        'seated',
        'completed',
        'cancelled',
        'no_show',
      ];

  // Danh sách phương thức thanh toán
  static List<String> get paymentMethods => [
        'cash',
        'card',
        'online',
      ];
}
