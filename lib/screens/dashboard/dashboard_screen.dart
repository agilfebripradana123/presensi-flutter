import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:xseven_presensi/models/attendance_model.dart';
import 'package:xseven_presensi/models/user_model.dart';
import 'package:xseven_presensi/screens/attendance/attendance_camera_screen.dart';
import 'package:xseven_presensi/screens/history/photo_viewer_screen.dart';
import 'package:xseven_presensi/screens/login/login_screen.dart';
import 'package:xseven_presensi/services/attendance_service.dart';
import 'package:xseven_presensi/services/auth_service.dart';
import 'package:xseven_presensi/utils/constants.dart';
import 'package:xseven_presensi/utils/helpers.dart';
import 'package:xseven_presensi/widgets/primary_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _auth = AuthService();
  final AttendanceService _attendance = AttendanceService();

  Timer? _clock;
  DateTime _now = DateTime.now();
  UserModel? _user;
  AttendanceModel? _today;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _load();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final user = await _auth.getUserData(uid);
      final today = await _attendance.getTodayAttendance(uid);
      if (!mounted) return;
      setState(() {
        _user = user;
        _today = today;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data. Silakan coba lagi.';
        _loading = false;
      });
    }
  }

  Future<void> _openPresensi(String mode) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AttendanceCameraScreen(mode: mode)),
    );
    if (mounted) _load();
  }

  void _openPhoto(String? base64, String title) {
    if (base64 == null || base64.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(imageUrl: base64, title: title),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _auth.logout();
    } catch (_) {
      // ignore: logout failure should not block the user.
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.statusSelesai:
        return Colors.green;
      case AppConstants.statusSudahMasuk:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _user;
    final today = _today;
    final sudahMasuk = today?.sudahMasuk ?? false;
    final sudahPulang = today?.sudahPulang ?? false;
    final status = statusPresensi(today);
    final jabatan = user?.jabatan ?? '';
    final departemen = user?.departemen ?? '';
    final sub = [
      if (jabatan.isNotEmpty) jabatan,
      if (departemen.isNotEmpty) departemen,
    ].join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('XSeven Presensi'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _InfoSection(user: user, sub: sub, tanggal: formatTanggal(_now)),
            const SizedBox(height: 20),
            _JamKerjaCard(),
            const SizedBox(height: 20),
            _StatusBadge(status: status, color: _statusColor(status)),
            if (today != null && sudahMasuk) ...[
              const SizedBox(height: 12),
              _KehadiranBadge(today: today),
              const SizedBox(height: 4),
              _WorkPill(today: today),
            ],
            const SizedBox(height: 24),
            if (_loading && user == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!sudahMasuk)
              PrimaryButton(
                label: 'PRESENSI MASUK',
                icon: Icons.login,
                onPressed: () => _openPresensi('masuk'),
              )
            else if (!sudahPulang)
              PrimaryButton(
                label: 'PRESENSI PULANG',
                icon: Icons.timer_outlined,
                onPressed: () => _openPresensi('pulang'),
              )
            else
              const _SelesaiButton(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 28),
            _PresensiTable(
              record: _today,
              onPhotoTap: _openPhoto,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.user, required this.sub, required this.tanggal});

  final UserModel? user;
  final String sub;
  final String tanggal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            'XP',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang, ${user?.nama ?? '-'}',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                tanggal,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JamKerjaCard extends StatelessWidget {
  const _JamKerjaCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Text(
            'Jam Kerja: 08:00 - 17:00 WIB',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 8),
            Text(
              'Status: $status',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _KehadiranBadge extends StatelessWidget {
  const _KehadiranBadge({required this.today});

  final AttendanceModel today;

  @override
  Widget build(BuildContext context) {
    final kehadiran = today.kehadiran ?? statusKehadiran(today.jamMasuk);
    final terlambat = kehadiran == AppConstants.kehadiranTerlambat;
    final color = terlambat ? Colors.red : Colors.green;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              terlambat ? Icons.warning_amber_rounded : Icons.check_circle,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              'Kehadiran: $kehadiran',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkPill extends StatelessWidget {
  const _WorkPill({required this.today});

  final AttendanceModel today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jamMasuk = today.jamMasuk;
    final jamPulang = today.jamPulang;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pillRow(context, Icons.login, 'Jam Masuk', jamMasuk),
          const SizedBox(height: 8),
          _pillRow(context, Icons.logout, 'Jam Pulang', jamPulang),
        ],
      ),
    );
  }

  Widget _pillRow(BuildContext context, IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label: ${value != null && value.isNotEmpty ? '$value WIB' : '-'}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _SelesaiButton extends StatelessWidget {
  const _SelesaiButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: null,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          'PRESENSI SELESAI HARI INI',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.4),
        ),
      ),
    );
  }
}

Color _statusColorOf(String status) {
  switch (status) {
    case AppConstants.statusSelesai:
      return Colors.green;
    case AppConstants.statusSudahMasuk:
      return Colors.orange;
    default:
      return Colors.red;
  }
}

Color _kehadiranColorOf(String kehadiran) =>
    kehadiran == AppConstants.kehadiranTerlambat ? Colors.red : Colors.green;

class _PresensiTable extends StatelessWidget {
  const _PresensiTable({
    required this.record,
    required this.onPhotoTap,
  });

  final AttendanceModel? record;
  final void Function(String? base64, String title) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presensi Hari Ini',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: record == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada data presensi hari ini.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: _PresensiGrid(record: record!, onPhotoTap: onPhotoTap),
                ),
        ),
      ],
    );
  }
}

class _PresensiGrid extends StatelessWidget {
  const _PresensiGrid({required this.record, required this.onPhotoTap});

  final AttendanceModel record;
  final void Function(String? base64, String title) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kehadiran = record.kehadiran ?? statusKehadiran(record.jamMasuk);
    final status = statusPresensi(record);
    final statusColor = _statusColorOf(status);
    final kehadiranColor = _kehadiranColorOf(kehadiran);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                record.tanggal ?? '-',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            _Badge(text: status, color: statusColor),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Badge(text: kehadiran, color: kehadiranColor),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _PhotoBlock(
          label: 'Foto Masuk',
          base64: record.fotoMasuk,
          onPhotoTap: onPhotoTap,
        ),
        const SizedBox(height: 12),
        _PhotoBlock(
          label: 'Foto Pulang',
          base64: record.fotoPulang,
          onPhotoTap: onPhotoTap,
        ),
        if (record.latitudeMasuk != null || record.longitudeMasuk != null) ...[
          const SizedBox(height: 16),
          _LokasiText(label: 'Lokasi Masuk', lat: record.latitudeMasuk, lng: record.longitudeMasuk),
        ],
        if (record.latitudePulang != null || record.longitudePulang != null) ...[
          const SizedBox(height: 6),
          _LokasiText(label: 'Lokasi Pulang', lat: record.latitudePulang, lng: record.longitudePulang),
        ],
      ],
    );
  }
}

class _PhotoBlock extends StatelessWidget {
  const _PhotoBlock({
    required this.label,
    required this.base64,
    required this.onPhotoTap,
  });

  final String label;
  final String? base64;
  final void Function(String? base64, String title) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        _Thumbnail(base64: base64, title: label, onTap: onPhotoTap),
      ],
    );
  }
}

class _LokasiText extends StatelessWidget {
  const _LokasiText({required this.label, required this.lat, required this.lng});

  final String label;
  final double? lat;
  final double? lng;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final has = lat != null || lng != null;
    final value = [
      if (lat != null) 'lat ${lat!.toStringAsFixed(6)}',
      if (lng != null) 'lng ${lng!.toStringAsFixed(6)}',
    ].join(' · ');
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            has ? value : '-',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Thumbnail extends StatefulWidget {
  const _Thumbnail({
    required this.base64,
    required this.title,
    required this.onTap,
  });

  final String? base64;
  final String title;
  final void Function(String? base64, String title) onTap;

  @override
  State<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<_Thumbnail> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(_Thumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64 != widget.base64) {
      _decode();
    }
  }

  void _decode() {
    final b64 = widget.base64;
    if (b64 == null || b64.isEmpty) {
      _bytes = null;
      return;
    }
    try {
      _bytes = base64Decode(b64.split(',').last);
    } catch (_) {
      _bytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final has = _bytes != null;

    Widget child;
    if (has) {
      child = Image.memory(
        _bytes!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      child = Icon(Icons.image_outlined,
          color: theme.colorScheme.onSurfaceVariant);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: has ? () => widget.onTap(widget.base64, widget.title) : null,
        child: Container(
          width: 56,
          height: 56,
          color: theme.colorScheme.surfaceContainerHighest,
          child: child,
        ),
      ),
    );
  }
}
