class User {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final int loyaltyPoints;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.address,
    required this.loyaltyPoints,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      loyaltyPoints: json['loyalty_points'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      'loyalty_points': loyaltyPoints,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}