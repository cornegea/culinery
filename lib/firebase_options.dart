// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAvkUrnvh46GDHBoxTReMM9Dz8LKM94Y7o',
    appId: '1:871803560680:web:b314f7e216774d5c67df5d',
    messagingSenderId: '871803560680',
    projectId: 'masakan-7a664',
    authDomain: 'masakan-7a664.firebaseapp.com',
    storageBucket: 'masakan-7a664.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAosKAnp805sFl1p434yqpSOMDrrCguW08',
    appId: '1:871803560680:android:24021096c1f7236467df5d',
    messagingSenderId: '871803560680',
    projectId: 'masakan-7a664',
    storageBucket: 'masakan-7a664.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvm2KwfCOs5gtKSppeqfZ1JpFP9k945bM',
    appId: '1:871803560680:ios:8294a42c29629f3167df5d',
    messagingSenderId: '871803560680',
    projectId: 'masakan-7a664',
    storageBucket: 'masakan-7a664.appspot.com',
    iosBundleId: 'com.example.culiner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDvm2KwfCOs5gtKSppeqfZ1JpFP9k945bM',
    appId: '1:871803560680:ios:3d99d796361acbc767df5d',
    messagingSenderId: '871803560680',
    projectId: 'masakan-7a664',
    storageBucket: 'masakan-7a664.appspot.com',
    iosBundleId: 'com.example.culiner.RunnerTests',
  );
}
