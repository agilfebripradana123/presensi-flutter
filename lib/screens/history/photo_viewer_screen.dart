import 'dart:convert';

import 'package:flutter/material.dart';

class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({
    super.key,
    required this.imageUrl,
    this.title,
    this.heroTag,
  });

  /// Base64 data URI (data:image/jpeg;base64,...) dari Firestore.
  final String imageUrl;
  final String? title;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget image;
    try {
      final bytes = base64Decode(imageUrl.split(',').last);
      image = Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 56),
        ),
      );
    } catch (_) {
      image = const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 56),
      );
    }

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(title ?? 'Foto Presensi'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: image,
        ),
      ),
    );
  }
}