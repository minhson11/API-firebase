# 🔥 Hướng dẫn cấu hình Firebase

## Bước 1: Tạo Firebase Project

1. Truy cập: https://console.firebase.google.com/
2. Click **"Create a project"** hoặc **"Add project"**
3. Nhập tên project: `restaurant-app` 
4. Click **Continue**
5. Tắt Google Analytics (tùy chọn) → Click **Create Project**
6. Đợi vài giây → Click **Continue**

## Bước 2: Tạo Firestore Database

1. Trong menu bên trái, click **Build** → **Firestore Database**
2. Click **Create database**
3. Chọn **Start in test mode** (cho phép đọc/ghi không cần auth)
4. Click **Next**
5. Chọn location: `asia-southeast1` (Singapore) hoặc gần nhất
6. Click **Enable**

## Bước 3: Đăng ký Android App

1. Quay về **Project Overview** (trang chủ project)
2. Click biểu tượng **Android** (hình robot xanh)
3. Điền thông tin:
   - **Android package name**: `com.example.restaurant_app_1771020519`
   - **App nickname**: Restaurant App (tùy chọn)
   - **Debug signing certificate SHA-1**: Bỏ qua
4. Click **Register app**

## Bước 4: Download và Copy google-services.json

1. Click **Download google-services.json**
2. Copy file vào thư mục:
   ```
   restaurant_app_1771020519/android/app/google-services.json
   ```
3. Click **Next** → **Next** → **Continue to console**

## Bước 5: Cập nhật firebase_options.dart

1. Mở file `lib/firebase_options.dart`
2. Mở file `google-services.json` vừa download
3. Thay thế các giá trị:

### Trong google-services.json, tìm:
```json
{
  "project_info": {
    "project_number": "123456789012",      // → messagingSenderId
    "project_id": "restaurant-app-xxxxx",   // → projectId
    "storage_bucket": "restaurant-app-xxxxx.appspot.com"  // → storageBucket
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "1:123456789012:android:abc123..."  // → appId
    },
    "api_key": [{
      "current_key": "AIzaSy..."  // → apiKey
    }]
  }]
}
```

### Cập nhật trong firebase_options.dart:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...',                           // current_key
  appId: '1:123456789012:android:abc123...',     // mobilesdk_app_id
  messagingSenderId: '123456789012',             // project_number
  projectId: 'restaurant-app-xxxxx',             // project_id
  storageBucket: 'restaurant-app-xxxxx.appspot.com',  // storage_bucket
);
```

## Bước 6: Chạy ứng dụng

```bash
cd restaurant_app_1771020519
flutter clean
flutter pub get
flutter run
```

## Bước 7: Tạo dữ liệu mẫu (Tùy chọn)

Thêm nút tạo data mẫu trong app hoặc chạy code:

```dart
import 'package:restaurant_app_1771020519/data/seed_data.dart';

// Gọi trong initState hoặc một button
final seedData = SeedData();
await seedData.runAllSeeds();
```

---

## 🔒 Firestore Security Rules (Production)

Khi deploy production, thay đổi rules trong Firebase Console > Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Customers collection
    match /customers/{customerId} {
      allow read: if true;
      allow write: if true;
    }
    
    // Menu items collection
    match /menu_items/{itemId} {
      allow read: if true;
      allow write: if true;
    }
    
    // Reservations collection  
    match /reservations/{reservationId} {
      allow read: if true;
      allow write: if true;
    }
  }
}
```

---

## ❓ Troubleshooting

### Lỗi: "No Firebase App '[DEFAULT]' has been created"
- Kiểm tra `firebase_options.dart` đã đúng chưa
- Đảm bảo `await Firebase.initializeApp()` trong main()

### Lỗi: "Could not resolve all files for configuration"
- Chạy: `flutter clean && flutter pub get`

### Lỗi: "google-services.json is missing"
- Đảm bảo file nằm đúng vị trí: `android/app/google-services.json`

### App crash khi khởi động
- Kiểm tra minSdk >= 21 trong `android/app/build.gradle.kts`
- Kiểm tra multiDexEnabled = true
