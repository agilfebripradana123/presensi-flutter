import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String? id;
  final String? userId;
  final String? tanggal;
  final String? jamMasuk;
  final String? jamPulang;
  final String? fotoMasuk;
  final String? fotoPulang;
  final String? status;
  final String? kehadiran;
  final double? latitudeMasuk;
  final double? longitudeMasuk;
  final double? latitudePulang;
  final double? longitudePulang;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceModel({
    this.id,
    this.userId,
    this.tanggal,
    this.jamMasuk,
    this.jamPulang,
    this.fotoMasuk,
    this.fotoPulang,
    this.status,
    this.kehadiran,
    this.latitudeMasuk,
    this.longitudeMasuk,
    this.latitudePulang,
    this.longitudePulang,
    this.createdAt,
    this.updatedAt,
  });

  bool get sudahMasuk => jamMasuk != null && jamMasuk!.isNotEmpty;

  bool get sudahPulang => jamPulang != null && jamPulang!.isNotEmpty;

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> m) =>
      AttendanceModel(
        id: id,
        userId: m['userId'] as String?,
        tanggal: m['tanggal'] as String?,
        jamMasuk: m['jamMasuk'] as String?,
        jamPulang: m['jamPulang'] as String?,
        fotoMasuk: m['fotoMasuk'] as String?,
        fotoPulang: m['fotoPulang'] as String?,
        status: m['status'] as String?,
        kehadiran: m['kehadiran'] as String?,
        latitudeMasuk: (m['latitudeMasuk'] as num?)?.toDouble(),
        longitudeMasuk: (m['longitudeMasuk'] as num?)?.toDouble(),
        latitudePulang: (m['latitudePulang'] as num?)?.toDouble(),
        longitudePulang: (m['longitudePulang'] as num?)?.toDouble(),
        createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (m['updatedAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'tanggal': tanggal,
        'jamMasuk': jamMasuk,
        'jamPulang': jamPulang,
        'fotoMasuk': fotoMasuk,
        'fotoPulang': fotoPulang,
        'status': status,
        'kehadiran': kehadiran,
        'latitudeMasuk': latitudeMasuk,
        'longitudeMasuk': longitudeMasuk,
        'latitudePulang': latitudePulang,
        'longitudePulang': longitudePulang,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}