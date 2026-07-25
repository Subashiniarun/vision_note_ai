part of 'image_process_bloc.dart';

abstract class ImageProcessEvent extends Equatable {
  const ImageProcessEvent();
}

class LoadImage extends ImageProcessEvent {
  final String imagePath;
  const LoadImage(this.imagePath);
  @override
  List<Object> get props => [imagePath];
}

class AutoDetectCorners extends ImageProcessEvent {
  const AutoDetectCorners();
  @override
  List<Object> get props => [];
}

class UpdateCorner extends ImageProcessEvent {
  final int index;
  final Offset position;
  const UpdateCorner(this.index, this.position);
  @override
  List<Object> get props => [index, position];
}

class ApplyCrop extends ImageProcessEvent {
  const ApplyCrop();
  @override
  List<Object> get props => [];
}

class AutoEnhance extends ImageProcessEvent {
  const AutoEnhance();
  @override
  List<Object> get props => [];
}

class UpdateBrightness extends ImageProcessEvent {
  final int value;
  const UpdateBrightness(this.value);
  @override
  List<Object> get props => [value];
}

class UpdateContrast extends ImageProcessEvent {
  final double value;
  const UpdateContrast(this.value);
  @override
  List<Object> get props => [value];
}

class UpdateSaturation extends ImageProcessEvent {
  final double value;
  const UpdateSaturation(this.value);
  @override
  List<Object> get props => [value];
}

class ApplyEnhancement extends ImageProcessEvent {
  const ApplyEnhancement();
  @override
  List<Object> get props => [];
}

class ResetEnhancement extends ImageProcessEvent {
  const ResetEnhancement();
  @override
  List<Object> get props => [];
}
