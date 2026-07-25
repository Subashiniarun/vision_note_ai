part of 'image_process_bloc.dart';

abstract class ImageProcessState extends Equatable {
  const ImageProcessState();
}

class ImageProcessInitial extends ImageProcessState {
  const ImageProcessInitial();
  @override
  List<Object> get props => [];
}

class ImageLoaded extends ImageProcessState {
  final Uint8List original;
  final List<Offset>? corners;
  const ImageLoaded(this.original, {this.corners});
  @override
  List<Object> get props => [original, corners ?? []];
}

class CropProcessing extends ImageProcessState {
  const CropProcessing();
  @override
  List<Object> get props => [];
}

class CropReady extends ImageProcessState {
  final Uint8List cropped;
  const CropReady(this.cropped);
  @override
  List<Object> get props => [cropped];
}

class EnhanceProcessing extends ImageProcessState {
  const EnhanceProcessing();
  @override
  List<Object> get props => [];
}

class EnhanceReady extends ImageProcessState {
  final Uint8List current;
  final Uint8List original;
  const EnhanceReady(this.current, this.original);
  @override
  List<Object> get props => [current, original];
}

class EnhanceComplete extends ImageProcessState {
  final Uint8List enhanced;
  const EnhanceComplete(this.enhanced);
  @override
  List<Object> get props => [enhanced];
}

class ImageProcessError extends ImageProcessState {
  final String message;
  const ImageProcessError(this.message);
  @override
  List<Object> get props => [message];
}
