# Restaurant App - Ứng dụng Quản lý Nhà hàng

Ứng dụng Flutter quản lý nhà hàng với Firebase Firestore.

## 📋 Tính năng

- **Đăng ký/Đăng nhập**: Khách hàng có thể đăng ký tài khoản và đăng nhập
- **Xem Menu**: Hiển thị danh sách món ăn với tìm kiếm và lọc
- **Đặt bàn**: Tạo đơn đặt bàn với chọn ngày giờ, số khách
- **Đặt món**: Thêm món ăn vào đơn đặt bàn
- **Thanh toán**: Thanh toán với điểm tích lũy
- **Lịch sử đặt bàn**: Xem các đơn đặt bàn đã tạo

## 🗄️ Cấu trúc Database

### Collection: customers
- `customerId`: ID duy nhất
- `email`: Email đăng nhập
- `fullName`: Họ và tên
- `phoneNumber`: Số điện thoại
- `address`: Địa chỉ
- `preferences`: Array sở thích ăn uống
- `loyaltyPoints`: Điểm tích lũy
- `createdAt`: Thời gian tạo
- `isActive`: Trạng thái tài khoản

### Collection: menu_items
- `itemId`: ID món ăn
- `name`: Tên món
- `description`: Mô tả
- `category`: Danh mục (Appetizer, Main Course, Dessert, Beverage, Soup)
- `price`: Giá
- `imageUrl`: URL hình ảnh
- `ingredients`: Danh sách nguyên liệu
- `isVegetarian`: Món chay
- `isSpicy`: Món cay
- `preparationTime`: Thời gian chế biến
- `isAvailable`: Còn phục vụ
- `rating`: Đánh giá

### Collection: reservations
- `reservationId`: ID đặt bàn
- `customerId`: ID khách hàng
- `reservationDate`: Ngày giờ đặt
- `numberOfGuests`: Số khách
- `tableNumber`: Số bàn
- `status`: Trạng thái (pending, confirmed, seated, completed, cancelled, no_show)
- `specialRequests`: Yêu cầu đặc biệt
- `orderItems`: Danh sách món đặt
- `subtotal`, `serviceCharge`, `discount`, `total`: Thông tin thanh toán
- `paymentMethod`: Phương thức thanh toán
- `paymentStatus`: Trạng thái thanh toán

## 📁 Cấu trúc Project

```
lib/
├── data/
│   └── seed_data.dart          # Dữ liệu mẫu
├── models/
│   ├── customer_model.dart     # Model khách hàng
│   ├── menu_item_model.dart    # Model món ăn
│   └── reservation_model.dart  # Model đặt bàn
├── repositories/
│   ├── customer_repository.dart    # CRUD khách hàng
│   ├── menu_item_repository.dart   # CRUD món ăn
│   └── reservation_repository.dart # CRUD đặt bàn
├── screens/
│   ├── login_screen.dart           # Màn hình đăng nhập/đăng ký
│   ├── home_screen.dart            # Màn hình chính
│   ├── menu_screen.dart            # Màn hình menu
│   ├── reservation_screen.dart     # Màn hình đặt bàn
│   └── my_reservations_screen.dart # Màn hình lịch sử đặt bàn
├── services/
│   └── firebase_service.dart   # Service kết nối Firebase
└── main.dart                   # Entry point
```

## 🚀 Cài đặt và Chạy

### 1. Cài đặt Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 2. Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới
3. Bật Firestore Database

### 3. Cấu hình Firebase cho Flutter
```bash
# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình Firebase
flutterfire configure
```

### 4. Chạy ứng dụng
```bash
cd restaurant_app_1771020519
flutter pub get
flutter run
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  cloud_firestore: ^latest
  shared_preferences: ^latest
  intl: ^latest
```

## 🌱 Tạo dữ liệu mẫu

Sử dụng class `SeedData` để tạo dữ liệu mẫu:

```dart
import 'package:restaurant_app_1771020519/data/seed_data.dart';

// Trong màn hình admin hoặc console
final seedData = SeedData();
await seedData.runAllSeeds();
```

Dữ liệu mẫu bao gồm:
- 5 customers
- 20 menu items (đa dạng category)
- 10 reservations (nhiều trạng thái)

## 📱 Tài khoản test

Sau khi chạy seed data, có thể đăng nhập với các email:
- nguyenvana@gmail.com
- tranthib@gmail.com
- levanc@gmail.com
- phamthid@gmail.com
- hoangvane@gmail.com

## ⚠️ Lưu ý quan trọng

1. **Firebase Configuration**: Cần cấu hình `firebase_options.dart` trước khi chạy
2. **Firestore Rules**: Thiết lập rules phù hợp cho production
3. **Error Handling**: Đã implement error handling cho các trường hợp:
   - Món hết
   - Đặt bàn trùng
   - Network errors

## 📝 Checklist nộp bài

- [x] Project hoàn chỉnh, có thể chạy được
- [x] Firebase project đã tạo và kết nối
- [x] Có ít nhất 5 customers mẫu
- [x] Có ít nhất 20 menu_items mẫu
- [x] Có ít nhất 10 reservations mẫu
- [x] Tất cả chức năng CRUD hoạt động
- [x] UI hiển thị dữ liệu từ Firestore
- [x] Real-time updates hoạt động
- [x] Error handling đầy đủ
- [x] Code tổ chức rõ ràng
- [x] File README.md

---

Chúc các bạn làm bài tốt! 🚀