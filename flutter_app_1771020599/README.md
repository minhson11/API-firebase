<<<<<<< HEAD
# Restaurant App - Mã sinh viên: 1771020599

Ứng dụng Flutter cho hệ thống nhà hàng với các tính năng đăng nhập và xem menu.

## Tính năng

### 🔐 **Authentication (5 điểm)**
- **Màn hình đăng nhập** với form validation
- **API Integration** với `/api/auth/login`
- **Student ID Display** - Hiển thị mã sinh viên 1771020599 khi đăng nhập thành công
- **Auto Login** - Tự động đăng nhập nếu đã có token
- **Logout** - Đăng xuất và xóa token

### 🍽️ **Menu Management (10 điểm)**
- **Danh sách món ăn** từ API `/api/menu-items`
- **Hiển thị thông tin**: Hình ảnh, tên, giá, danh mục
- **Filter theo danh mục**: Appetizer, Main Course, Dessert, Beverage, Soup
- **Search functionality** - Tìm kiếm theo tên và mô tả
- **Advanced filters**: Món chay, món cay, món có sẵn
- **Refresh to reload** - Pull to refresh

### 📱 **Menu Item Detail (5 điểm)**
- **Chi tiết món ăn** với thông tin đầy đủ
- **Thông tin dinh dưỡng**: Chay/mặn, cay/không cay
- **Thời gian chế biến** và đánh giá
- **Mô tả chi tiết** và hình ảnh lớn
- **UI/UX tối ưu** với SliverAppBar

## Cài đặt và chạy

### 1. Cài đặt dependencies
```bash
cd flutter_app_1771020599
flutter pub get
```

### 2. Chạy API server trước
Đảm bảo API server đang chạy tại http://localhost:3000

### 3. Chạy Flutter app
```bash
flutter run
```

## API Endpoints sử dụng

- `POST /api/auth/login` - Đăng nhập (trả về student_id)
- `GET /api/menu-items` - Lấy danh sách món ăn
- `GET /api/menu-items/:id` - Chi tiết món ăn
- `GET /api/menu-items/search` - Tìm kiếm món ăn

## Cấu trúc dự án

```
lib/
├── main.dart                    # Entry point với splash screen
├── models/
│   ├── user.dart               # User model
│   └── dish.dart               # MenuItem model (cập nhật)
├── services/
│   └── api_service.dart        # API service với authentication
├── screens/
│   ├── login_screen.dart       # Màn hình đăng nhập
│   ├── menu_screen.dart        # Danh sách món ăn
│   └── menu_item_detail_screen.dart # Chi tiết món ăn
└── widgets/
    ├── menu_item_card.dart     # Card hiển thị món ăn
    ├── category_filter.dart    # Filter theo danh mục
    └── search_bar_widget.dart  # Thanh tìm kiếm
```

## Tài khoản test

**Email**: john.doe@email.com  
**Password**: 123456

## Tính năng nổi bật

### 🎨 **UI/UX Design**
- Material Design 3 với theme màu cam
- Responsive layout cho các màn hình khác nhau
- Loading states và error handling
- Smooth animations và transitions

### 🔍 **Advanced Search & Filter**
- Real-time search trong tên và mô tả món
- Multi-filter: danh mục, chay, cay, có sẵn
- Visual filter chips hiển thị bộ lọc đang áp dụng
- Clear filters functionality

### 📊 **Data Management**
- Caching với SharedPreferences
- Auto-refresh khi có lỗi network
- Optimized image loading với CachedNetworkImage
- Proper error handling và user feedback

### 🔐 **Security**
- Token-based authentication
- Secure storage với SharedPreferences
- Auto logout khi token hết hạn
- Input validation và sanitization

## Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  http: ^1.1.0                    # HTTP requests
  cached_network_image: ^3.3.0    # Image caching
  shared_preferences: ^2.2.2      # Local storage
```

## Công nghệ sử dụng

- **Flutter** - Cross-platform mobile framework
- **HTTP Package** - RESTful API calls
- **SharedPreferences** - Local data persistence
- **CachedNetworkImage** - Optimized image loading
- **Material Design 3** - Modern UI components
=======
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
cd restaurant_app_1771020599
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
import 'package:restaurant_app_1771020599/data/seed_data.dart';

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
>>>>>>> 6cf7f17 (Initial commit)
