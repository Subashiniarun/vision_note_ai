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
  final CameraImage frame;
  final Uint8List imageBytes;
  const CaptureFrame({required this.frame, required this.imageBytes});
  @override
  List<Object> get props => [frame, imageBytes];
}

class ToggleFlash extends CameraEvent {
  const ToggleFlash();
  @override
  List<Object> get props => [];
}

class DisposeCamera extends CameraEvent {
  const DisposeCamera();
  @override
  List<Object> get props => [];
}
