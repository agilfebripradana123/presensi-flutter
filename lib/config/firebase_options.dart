// File generated from google-services.json (project: absensi-pegawai-x7).
// Regenerate with `flutterfire configure` if Firebase project changes.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini - '
          'jalankan `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiXsrsH-EkoRuVOUpBTS--vK8u_YWBt-Y',
    appId: '1:547533760776:android:8c8695297bc6c99dc5e4bd',
    messagingSenderId: '547533760776',
    projectId: 'absensi-pegawai-x7',
    storageBucket: 'absensi-pegawai-x7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiXsrsH-EkoRuVOUpBTS--vK8u_YWBt-Y',
    appId: '1:547533760776:ios:placeholder',
    messagingSenderId: '547533760776',
    projectId: 'absensi-pegawai-x7',
    storageBucket: 'absensi-pegawai-x7.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDiXsrsH-EkoRuVOUpBTS--vK8u_YWBt-Y',
    appId: '1:547533760776:ios:placeholder',
    messagingSenderId: '547533760776',
    projectId: 'absensi-pegawai-x7',
    storageBucket: 'absensi-pegawai-x7.firebasestorage.app',
  );
}
