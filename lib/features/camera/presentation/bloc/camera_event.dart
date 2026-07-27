part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();
}

class InitializeCamera extends CameraEvent {
  const InitializeCamera();
  @override
  List<Object> get props => [];
}

class CaptureFrame extends CameraEvent {
  final Uint8List imageBytes;
  const CaptureFrame({required this.imageBytes});
  @override
  List<Object> get props => [imageBytes];
}

class ToggleFlash extends CameraEvent {
  const ToggleFlash();
  @override
  List<Object> get props => [];
}

class ResetCapture extends CameraEvent {
  const ResetCapture();
  @override
  List<Object> get props => [];
}

class DisposeCamera extends CameraEvent {
  const DisposeCamera();
  @override
  List<Object> get props => [];
}

class ImportFromGallery extends CameraEvent {
  final Uint8List imageBytes;
  const ImportFromGallery({required this.imageBytes});
  @override
  List<Object> get props => [imageBytes];
}
