import 'package:flutter/material.dart';
import 'package:xseven_presensi/models/attendance_model.dart';

/// Status card per PRD §4.5.
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key, required this.attendance});

  final AttendanceModel? attendance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = attendance;

    final bool belum = a == null || !a.sudahMasuk;
    final bool selesai = a != null && a.sudahPulang;

    late final String status;
    late final IconData icon;
    late final Color accent;

    if (belum) {
      status = 'BELUM PRESENSI';
      icon = Icons.error_outline;
      accent = theme.colorScheme.error;
    } else if (!selesai) {
      status = 'SUDAH PRESENSI MASUK';
      icon = Icons.login;
      accent = Colors.orange.shade700;
    } else {
      status = 'PRESENSI SELESAI';
      icon = Icons.check_circle_outline;
      accent = Colors.green.shade700;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUS PRESENSI',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (a != null && a.sudahMasuk) ...[
            const SizedBox(height: 16),
            _row(theme, 'Jam Masuk', a.jamMasuk ?? '-'),
          ],
          if (a != null && a.sudahPulang) ...[
            const SizedBox(height: 6),
            _row(theme, 'Jam Pulang', a.jamPulang ?? '-'),
          ],
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}