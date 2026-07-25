import 'package:equatable/equatable.dart';
import 'dart:ui';

class CropRect extends Equatable {
  final List<Offset> corners;

  const CropRect(this.corners);

  Offset get topLeft => corners[0];
  Offset get topRight => corners[1];
  Offset get bottomRight => corners[2];
  Offset get bottomLeft => corners[3];

  bool get isValid =>
      corners.length == 4 &&
      corners.every((c) => c.dx >= 0 && c.dy >= 0);

  @override
  List<Object?> get props => corners;
}

class EnhancementParams extends Equatable {
  final int brightness;
  final double contrast;
  final double saturation;
  final double sharpness;

  const EnhancementParams({
    this.brightness = 0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.sharpness = 1.0,
  });

  EnhancementParams copyWith({
    int? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
  }) {
    return EnhancementParams(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      sharpness: sharpness ?? this.sharpness,
    );
  }

  @override
  List<Object?> get props => [brightness, contrast, saturation, sharpness];
}

enum EnhancementPreset { auto, document, photo, lowLight }
