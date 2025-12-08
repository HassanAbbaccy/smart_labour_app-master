import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyADR91LNDXiwGifaUAi0LCi1F_utcAWkBc',
    authDomain: 'smartlabour-marketplace.firebaseapp.com',
    projectId: 'smartlabour-marketplace',
    storageBucket: 'smartlabour-marketplace.firebasestorage.app',
    messagingSenderId: '520907284454',
    appId: '1:520907284454:web:fb16b9d55d393e9b2e8027',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDtuuL0GktcUOXeL72u81enrz_2S8rFdM',
    appId: '1:520907284454:android:b137e25010b3cb032e8027',
    messagingSenderId: '520907284454',
    projectId: 'smartlabour-marketplace',
    storageBucket: 'smartlabour-marketplace.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADR91LNDXiwGifaUAi0LCi1F_utcAWkBc',
    appId: '1:520907284454:ios:REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: '520907284454',
    projectId: 'smartlabour-marketplace',
    storageBucket: 'smartlabour-marketplace.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyMacOSKeyForDevelopment123456789',
    appId: '1:123456789:macos:abcdef1234567890abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartlabour-app',
    storageBucket: 'smartlabour-app.appspot.com',
    iosBundleId: 'com.smartlabour.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyWindowsKeyForDevelopment123456789',
    appId: '1:123456789:windows:abcdef1234567890abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartlabour-app',
    storageBucket: 'smartlabour-app.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDummyLinuxKeyForDevelopment123456789',
    appId: '1:123456789:linux:abcdef1234567890abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartlabour-app',
    storageBucket: 'smartlabour-app.appspot.com',
  );
}
