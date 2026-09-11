import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Akses lokasi diperlukan untuk melakukan presensi.');
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Aktifkan GPS untuk melakukan presensi.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      throw Exception(
          'Lokasi tidak dapat ditemukan.\nPastikan GPS perangkat aktif.');
    }
  }

  Future<String> getCurrentPositionLabel() async {
    final p = await getCurrentPosition();
    return '${p.latitude}, ${p.longitude}';
  }
}