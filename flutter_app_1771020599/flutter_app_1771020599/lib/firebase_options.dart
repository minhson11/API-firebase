// File được tạo tự động cho Firebase
// Thông tin lấy từ google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDRdO_-PMF56Ht-Yb__URzYHHMQxtcuiCg',
    appId: '1:734868299598:web:5865353f0bed362291481f',
    messagingSenderId: '734868299598',
    projectId: 'restaurant-app-177102051-ec3d8',
    authDomain: 'restaurant-app-177102051-ec3d8.firebaseapp.com',
    storageBucket: 'restaurant-app-177102051-ec3d8.firebasestorage.app',
    measurementId: 'G-2YYCMGG6Y5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHpayt4XrnAi8cRdI_ceTP4WhyCntlEcU',
    appId: '1:734868299598:android:55ad1af0e1ff47eb91481f',
    messagingSenderId: '734868299598',
    projectId: 'restaurant-app-177102051-ec3d8',
    storageBucket: 'restaurant-app-177102051-ec3d8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHpayt4XrnAi8cRdI_ceTP4WhyCntlEcU',
    appId: '1:734868299598:android:55ad1af0e1ff47eb91481f',
    messagingSenderId: '734868299598',
    projectId: 'restaurant-app-177102051-ec3d8',
    storageBucket: 'restaurant-app-177102051-ec3d8.firebasestorage.app',
    iosBundleId: 'com.example.MSV1771020519',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDHpayt4XrnAi8cRdI_ceTP4WhyCntlEcU',
    appId: '1:734868299598:android:55ad1af0e1ff47eb91481f',
    messagingSenderId: '734868299598',
    projectId: 'restaurant-app-177102051-ec3d8',
    storageBucket: 'restaurant-app-177102051-ec3d8.firebasestorage.app',
    iosBundleId: 'com.example.MSV1771020519',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDHpayt4XrnAi8cRdI_ceTP4WhyCntlEcU',
    appId: '1:734868299598:android:55ad1af0e1ff47eb91481f',
    messagingSenderId: '734868299598',
    projectId: 'restaurant-app-177102051-ec3d8',
    storageBucket: 'restaurant-app-177102051-ec3d8.firebasestorage.app',
  );
}
