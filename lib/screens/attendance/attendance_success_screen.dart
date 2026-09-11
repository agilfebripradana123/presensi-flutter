import 'package:flutter/material.dart';
import 'package:xseven_presensi/utils/helpers.dart';
import 'package:xseven_presensi/widgets/primary_button.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  const AttendanceSuccessScreen({
    super.key,
    required this.mode,
    required this.jam,
    required this.latitude,
    required this.longitude,
  });

  /// 'masuk' | 'pulang'
  final String mode;
  final DateTime jam;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masuk = mode == 'masuk';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Presensi Berhasil',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                masuk
                    ? 'Presensi masuk berhasil dicatat.'
                    : 'Presensi pulang berhasil dicatat.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              _InfoRow(label: 'Jam', value: formatJam(jam)),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'Lokasi',
                value: '${latitude.toStringAsFixed(4)}, '
                    '${longitude.toStringAsFixed(4)}',
              ),
              const Spacer(),
              PrimaryButton(
                label: 'KEMBALI KE DASHBOARD',
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}