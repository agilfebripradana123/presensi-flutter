import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xseven_presensi/screens/attendance/attendance_confirmation_screen.dart';
import 'package:xseven_presensi/services/camera_service.dart';
import 'package:xseven_presensi/services/location_service.dart';
import 'package:xseven_presensi/widgets/primary_button.dart';

class AttendanceCameraScreen extends StatefulWidget {
  const AttendanceCameraScreen({super.key, required this.mode});

  /// 'masuk' | 'pulang'
  final String mode;

  @override
  State<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

class _AttendanceCameraScreenState extends State<AttendanceCameraScreen> {
  CameraController? _controller;
  Position? _position;

  bool _initializing = true;
  bool _locating = true;
  bool _capturing = false;
  String? _error;

  bool get _isMasuk => widget.mode == 'masuk';

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadLocation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final controller = await CameraService().initCamera();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Akses kamera diperlukan untuk melakukan presensi.';
      });
    }
  }

  Future<void> _loadLocation() async {
    try {
      final position = await LocationService().getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _position = position;
        _locating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _locating = false);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      setState(() => _error = 'Akses kamera diperlukan untuk melakukan presensi.');
      return;
    }
    final position = _position;
    if (position == null) {
      setState(() {
        _error = 'Lokasi tidak dapat ditemukan.\n'
            'Pastikan GPS perangkat aktif.';
      });
      return;
    }

    setState(() {
      _capturing = true;
      _error = null;
    });

    try {
      final photo = await controller.takePicture();
      if (!mounted) return;
      setState(() => _capturing = false);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AttendanceConfirmationScreen(
            photo: photo,
            latitude: position.latitude,
            longitude: position.longitude,
            mode: widget.mode,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _capturing = false;
        _error = 'Gagal mengambil foto. Silakan coba lagi.';
      });
    }
  }

  String _locationLabel() {
    if (_locating) return 'Mengambil lokasi...';
    final position = _position;
    if (position == null) {
      return 'Lokasi tidak dapat ditemukan.\nPastikan GPS perangkat aktif.';
    }
    return '${position.latitude.toStringAsFixed(4)}, '
        '${position.longitude.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMasuk ? 'PRESENSI MASUK' : 'PRESENSI PULANG'),
      ),
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
                child: _buildPreview(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place_outlined,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _locationLabel(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
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
                  PrimaryButton(
                    label: 'AMBIL FOTO',
                    icon: Icons.camera_alt,
                    loading: _capturing,
                    onPressed: (_controller == null || _initializing) ? null : _capture,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error ?? 'Akses kamera diperlukan untuk melakukan presensi.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: 1 / controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}