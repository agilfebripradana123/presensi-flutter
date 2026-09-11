import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Menyimpan foto sebagai base64 di Firestore (tanpa Firebase Storage,
/// karena Storage butuh upgrade plan Blaze).
class StorageService {
  /// Resize foto ke lebar maksimal lalu encode jadi base64 JPEG.
  /// [jenis] dipakai hanya untuk konsistensi API; tidak berpengaruh ke output.
  Future<String> encodeFoto(
      File file, String uid, String tanggal, String jenis) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception('Foto tidak valid.');
      }

      // ponytail: resize ke lebar 640px agar base64 kecil (<~100KB).
      // Naikkan bila butuh kualitas lebih; awas batas 1MB/doc Firestore.
      img.Image resized = decoded;
      if (decoded.width > 640) {
        resized = img.copyResize(
          decoded,
          width: 640,
          height: (decoded.height * 640 / decoded.width).round(),
          interpolation: img.Interpolation.linear,
        );
      }

      final Uint8List jpg = Uint8List.fromList(img.encodeJpg(resized, quality: 70));
      return 'data:image/jpeg;base64,${base64Encode(jpg)}';
    } catch (_) {
      throw Exception('Foto gagal diupload. Silakan coba lagi.');
    }
  }
}
