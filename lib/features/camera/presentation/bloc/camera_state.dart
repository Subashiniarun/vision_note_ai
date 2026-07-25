part of 'camera_bloc.dart';

abstract class CameraState extends Equatable {
  const CameraState();
}

class CameraInitial extends CameraState {
  const CameraInitial();
  @override
  List<Object> get props => [];
}

class CameraInitializing extends CameraState {
  const CameraInitializing();
  @override
  List<Object> get props => [];
}

class CameraReady extends CameraState {
  final CameraController controller;
  final FlashMode flashMode;
  const CameraReady(this.controller, {this.flashMode = FlashMode.off});
  @override
  List<Object> get props => [controller, flashMode];
}

class CameraCaptured extends CameraState {
  final CameraController controller;
  final String imagePath;
  const CameraCaptured(this.controller, this.imagePath);
  @override
  List<Object> get props => [controller, imagePath];
}

class CameraError extends CameraState {
  final String message;
  const CameraError(this.message);
  @override
  List<Object> get props => [message];
}
