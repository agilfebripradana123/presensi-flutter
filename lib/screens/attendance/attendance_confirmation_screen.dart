import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xseven_presensi/screens/attendance/attendance_success_screen.dart';
import 'package:xseven_presensi/services/attendance_service.dart';
import 'package:xseven_presensi/services/auth_service.dart';
import 'package:xseven_presensi/services/storage_service.dart';
import 'package:xseven_presensi/widgets/primary_button.dart';

class AttendanceConfirmationScreen extends StatefulWidget {
  const AttendanceConfirmationScreen({
    super.key,
    required this.photo,
    required this.latitude,
    required this.longitude,
    required this.mode,
  });

  final XFile photo;
  final double latitude;
  final double longitude;

  /// 'masuk' | 'pulang'
  final String mode;

  @override
  State<AttendanceConfirmationScreen> createState() =>
      _AttendanceConfirmationScreenState();
}

class _AttendanceConfirmationScreenState
    extends State<AttendanceConfirmationScreen> {
  bool _loading = false;
  String? _error;

  bool get _isMasuk => widget.mode == 'masuk';

  String get _locationLabel =>
      '${widget.latitude.toStringAsFixed(4)}, '
      '${widget.longitude.toStringAsFixed(4)}';

  Future<void> _confirm() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      setState(() => _error = 'Silakan login terlebih dahulu.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final jenis = _isMasuk ? 'masuk' : 'pulang';
    final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String fotoUrl;
    try {
      fotoUrl = await StorageService()
          .encodeFoto(File(widget.photo.path), uid, tanggal, jenis);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Foto gagal diupload. Silakan coba lagi.';
      });
      return;
    }

    try {
      if (_isMasuk) {
        await AttendanceService().presensiMasuk(
          userId: uid,
          fotoUrl: fotoUrl,
          lat: widget.latitude,
          lng: widget.longitude,
        );
      } else {
        await AttendanceService().presensiPulang(
          userId: uid,
          fotoUrl: fotoUrl,
          lat: widget.latitude,
          lng: widget.longitude,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _mapError(e);
      });
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AttendanceSuccessScreen(
          mode: widget.mode,
          jam: DateTime.now(),
          latitude: widget.latitude,
          longitude: widget.longitude,
        ),
      ),
    );
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('sudah') && message.contains('masuk')) {
      return 'Anda sudah melakukan presensi masuk hari ini.';
    }
    if (message.contains('sudah') && message.contains('pulang')) {
      return 'Anda sudah melakukan presensi pulang hari ini.';
    }
    if (message.contains('harus') || message.contains('terlebih dahulu')) {
      return 'Anda harus melakukan presensi masuk terlebih dahulu.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('KONFIRMASI PRESENSI')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.file(
                    File(widget.photo.path),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lokasi', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(_locationLabel, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('AMBIL ULANG'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'KONFIRMASI PRESENSI',
                          loading: _loading,
                          expanded: false,
                          onPressed: _confirm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}