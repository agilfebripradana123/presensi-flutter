import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xseven_presensi/models/attendance_model.dart';
import 'package:xseven_presensi/utils/helpers.dart';

/// Riwayat presensi card per PRD §9.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.attendance,
    this.onTapFotoMasuk,
    this.onTapFotoPulang,
  });

  final AttendanceModel attendance;
  final VoidCallback? onTapFotoMasuk;
  final VoidCallback? onTapFotoPulang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = attendance.status ?? statusKehadiran(attendance.jamMasuk);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attendance.tanggal ?? '-',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _row(theme, 'Masuk', attendance.jamMasuk ?? '-'),
          _row(theme, 'Pulang', attendance.jamPulang ?? '-'),
          _row(theme, 'Status', status),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _thumb(theme, attendance.fotoMasuk, 'Foto Masuk', onTapFotoMasuk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _thumb(theme, attendance.fotoPulang, 'Foto Pulang', onTapFotoPulang),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _location(theme, 'Lokasi Masuk', attendance.latitudeMasuk, attendance.longitudeMasuk),
          const SizedBox(height: 6),
          _location(theme, 'Lokasi Pulang', attendance.latitudePulang, attendance.longitudePulang),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(ThemeData theme, String? url, String label, VoidCallback? onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest,
            child: InkWell(
              onTap: url == null ? null : onTap,
              child: AspectRatio(
                aspectRatio: 1,
                child: url == null
                    ? Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : _foto(theme, url),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }

  Widget _foto(ThemeData theme, String url) {
    // foto disimpan base64 (data:image/jpeg;base64,...)
    try {
      final bytes = base64Decode(url.split(',').last);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _broken(theme),
      );
    } catch (_) {
      return _broken(theme);
    }
  }

  Widget _broken(ThemeData theme) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );

  Widget _location(ThemeData theme, String label, double? lat, double? lng) {
    final value = (lat == null || lng == null)
        ? '-'
        : '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}