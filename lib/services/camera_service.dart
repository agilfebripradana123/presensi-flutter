import 'package:camera/camera.dart';

class CameraService {
  Future<CameraController> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller =
        CameraController(camera, ResolutionPreset.high);
    await controller.initialize();
    return controller;
  }
}