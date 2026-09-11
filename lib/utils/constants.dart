import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'XSeven Presensi';

  static const Color primaryColor = Color(0xFF1565C0);

  static const String usersCollection = 'users';
  static const String presensiCollection = 'presensi';

  // Database Firestore yang dipakai (bukan default). Sesuaikan bila diubah.
  static const String firestoreDatabaseId = 'x7presensi';

  static const String statusBelumPresensi = 'Belum Presensi';
  static const String statusSudahMasuk = 'Sudah Presensi Masuk';
  static const String statusSelesai = 'Presensi Selesai';

  static const String kehadiranHadir = 'Hadir';
  static const String kehadiranTerlambat = 'Terlambat';

  static const String batasJamMasuk = '08:00';
}