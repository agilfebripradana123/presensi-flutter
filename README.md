# XSeven Presensi

Aplikasi presensi pegawai berbasis Flutter + Firebase. Pegawai login, melakukan presensi masuk/pulang dengan foto (kamera) dan lokasi GPS, serta melihat riwayat presensi pribadi. Tanpa role admin.

## Tech Stack

- Flutter / Dart
- Firebase Authentication (email/password)
- Cloud Firestore (database `x7presensi`)
- Camera + Geolocator (GPS)
- `image` (resize foto sebelum disimpan)

## Fitur

- Login / logout pegawai
- Dashboard pribadi (jam live, status presensi, kehadiran Hadir/Terlambat)
- Presensi masuk & pulang dengan foto + GPS
- Foto disimpan sebagai base64 di Firestore (tanpa Firebase Storage)
- Riwayat presensi pribadi

## Struktur

```
lib/
  config/firebase_options.dart      # kredensial Firebase
  models/                           # UserModel, AttendanceModel
  services/                         # auth, attendance, camera, location, storage(base64)
  screens/                          # splash, login, dashboard, attendance, history
  utils/                            # constants, helpers
  widgets/                          # primary_button, thumbnail, badge
```

## Setup

### 1. Prasyarat

- Flutter 3.47+ / Dart 3.13+
- Project Firebase dengan layanan: Authentication (email/password), Cloud Firestore (database ID `x7presensi`)

### 2. Konfigurasi Firebase

File `android/app/google-services.json` dan `lib/config/firebase_options.dart` harus menunjuk ke project Firebase.

Nilai kredensial di `firebase_options.dart`:
- `projectId`, `apiKey`, `appId`, `messagingSenderId`, `storageBucket`
- `databaseId` Firestore di `lib/utils/constants.dart` (`firestoreDatabaseId`)

### 3. Jalankan

```bash
flutter pub get
flutter run
```

## Firestore Rules (mode test)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Data

- Collection `users`: doc ID = UID user, field `nama`, `email`, `jabatan`, `departemen`
- Collection `presensi`: doc ID = `{uid}_{tanggal}` (yyyy-MM-dd). Field: `userId`, `tanggal`, `jamMasuk`, `jamPulang`, `fotoMasuk`, `fotoPulang` (base64), `latitudeMasuk`, `longitudeMasuk`, `latitudePulang`, `longitudePulang`, `status`, `kehadiran` (Hadir/Terlambat), `createdAt`, `updatedAt`

## Catatan

- Foto di-resize ke lebar 640px lalu disimpan base64 di Firestore (menghindari biaya Firebase Storage / upgrade plan Blaze).
- Status kehadiran: masuk ≤ 08:00 = "Hadir", > 08:00 = "Terlambat".
- `kotlin.incremental=false` di `android/gradle.properties` untuk menghindari bug Kotlin incremental beda drive (pub cache di C:, project di D:).
