import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase app configuration for the QwikGrocery Firebase project.
///
/// The provided configuration is for the registered web app. Add native app
/// registrations in Firebase Console before shipping Android or iOS builds.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDjT-x7Q5uIBDVkDBp24T3LHmDt-_KRSR8',
    authDomain: 'qwikgrocery-22631.firebaseapp.com',
    projectId: 'qwikgrocery-22631',
    storageBucket: 'qwikgrocery-22631.firebasestorage.app',
    messagingSenderId: '563192241880',
    appId: '1:563192241880:web:ea3bfc5e90294d20f801ad',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOuZRExCPEK5NrcSdp51MRIpstfrgEhyY',
    projectId: 'qwikgrocery-22631',
    storageBucket: 'qwikgrocery-22631.firebasestorage.app',
    messagingSenderId: '563192241880',
    appId: '1:563192241880:android:9095d7413e8a645cf801ad',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjT-x7Q5uIBDVkDBp24T3LHmDt-_KRSR8',
    projectId: 'qwikgrocery-22631',
    storageBucket: 'qwikgrocery-22631.firebasestorage.app',
    messagingSenderId: '563192241880',
    appId: '1:563192241880:ios:ea3bfc5e90294d20f801ad',
    iosBundleId: 'com.qwikgrocery.app',
  );
}
