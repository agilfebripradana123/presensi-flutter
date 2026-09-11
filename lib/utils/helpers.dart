import 'package:intl/intl.dart';

import '../models/attendance_model.dart';
import 'constants.dart';

String formatTanggal(DateTime d) =>
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);

String formatJam(DateTime d) => DateFormat('HH:mm').format(d);

String statusPresensi(AttendanceModel? a) {
  if (a == null || !a.sudahMasuk) return AppConstants.statusBelumPresensi;
  if (a.sudahPulang) return AppConstants.statusSelesai;
  return AppConstants.statusSudahMasuk;
}

String statusKehadiran(String? jamMasuk) {
  if (jamMasuk == null || jamMasuk.isEmpty) return AppConstants.kehadiranHadir;
  final parts = jamMasuk.split(':');
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return (h > 8 || (h == 8 && m > 0))
      ? AppConstants.kehadiranTerlambat
      : AppConstants.kehadiranHadir;
}