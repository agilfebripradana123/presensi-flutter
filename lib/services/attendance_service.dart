import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

import '../models/attendance_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: AppConstants.firestoreDatabaseId,
  );

  static final DateFormat _tanggalFmt = DateFormat('yyyy-MM-dd');
  static final DateFormat _jamFmt = DateFormat('HH:mm');

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.presensiCollection);

  String _docId(String userId, DateTime now) =>
      '${userId}_${_tanggalFmt.format(now)}';

  Future<AttendanceModel?> getTodayAttendance(String userId) async {
    final doc = await _col.doc(_docId(userId, DateTime.now())).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return AttendanceModel.fromMap(doc.id, data);
  }

  Future<void> presensiMasuk({
    required String userId,
    required String fotoUrl,
    required double lat,
    required double lng,
  }) async {
    final now = DateTime.now();
    final ref = _col.doc(_docId(userId, now));

    if ((await ref.get()).exists) {
      throw Exception('Anda sudah melakukan presensi masuk hari ini.');
    }

    final jamMasuk = _jamFmt.format(now);

    await ref.set({
      'userId': userId,
      'tanggal': _tanggalFmt.format(now),
      'jamMasuk': jamMasuk,
      'fotoMasuk': fotoUrl,
      'latitudeMasuk': lat,
      'longitudeMasuk': lng,
      'status': AppConstants.statusSudahMasuk,
      'kehadiran': statusKehadiran(jamMasuk),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> presensiPulang({
    required String userId,
    required String fotoUrl,
    required double lat,
    required double lng,
  }) async {
    final ref = _col.doc(_docId(userId, DateTime.now()));
    final snap = await ref.get();

    if (!snap.exists) {
      throw Exception('Anda harus melakukan presensi masuk terlebih dahulu.');
    }
    if (((snap.data()!['jamPulang'] ?? '') as String).isNotEmpty) {
      throw Exception('Anda sudah melakukan presensi pulang hari ini.');
    }

    await ref.update({
      'jamPulang': _jamFmt.format(DateTime.now()),
      'fotoPulang': fotoUrl,
      'latitudePulang': lat,
      'longitudePulang': lng,
      'status': AppConstants.statusSelesai,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AttendanceModel>> getHistory(String userId) => _col
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) => s.docs
          .map((d) => AttendanceModel.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => (b.tanggal ?? '').compareTo(a.tanggal ?? '')));
}