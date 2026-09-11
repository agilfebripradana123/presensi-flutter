import 'package:flutter/material.dart';
import 'package:xseven_presensi/models/attendance_model.dart';
import 'package:xseven_presensi/screens/history/photo_viewer_screen.dart';
import 'package:xseven_presensi/services/attendance_service.dart';
import 'package:xseven_presensi/services/auth_service.dart';
import 'package:xseven_presensi/widgets/history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Presensi')),
      body: uid == null
          ? const _MessageState(
              icon: Icons.lock_outline,
              text: 'Silakan login terlebih dahulu.',
            )
          : StreamBuilder<List<AttendanceModel>>(
              stream: AttendanceService().getHistory(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const _MessageState(
                    icon: Icons.error_outline,
                    text: 'Gagal memuat riwayat presensi.',
                  );
                }
                final items = snapshot.data ?? const <AttendanceModel>[];
                if (items.isEmpty) {
                  return const _MessageState(
                    icon: Icons.history,
                    text: 'Belum ada riwayat presensi.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return HistoryCard(
                      attendance: item,
                      onTapFotoMasuk: () => _openPhoto(
                        context,
                        item.fotoMasuk,
                        'Foto Masuk',
                        'masuk-${item.id ?? index}',
                      ),
                      onTapFotoPulang: () => _openPhoto(
                        context,
                        item.fotoPulang,
                        'Foto Pulang',
                        'pulang-${item.id ?? index}',
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _openPhoto(
    BuildContext context,
    String? url,
    String title,
    String heroTag,
  ) {
    if (url == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          imageUrl: url,
          title: title,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}