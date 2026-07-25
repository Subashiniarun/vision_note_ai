import 'package:equatable/equatable.dart';
import 'dart:ui';

class OCRResult extends Equatable {
  final String text;
  final List<TextBlock> blocks;
  final String language;
  final double confidence;
  final Duration processingTime;

  const OCRResult({
    required this.text,
    this.blocks = const [],
    this.language = 'en',
    this.confidence = 0.0,
    this.processingTime = Duration.zero,
  });

  @override
  List<Object?> get props =>
      [text, blocks, language, confidence, processingTime];
}

class TextBlock extends Equatable {
  final String text;
  final Rect boundingBox;
  final List<TextLine> lines;

  const TextBlock({
    required this.text,
    required this.boundingBox,
    this.lines = const [],
  });

  @override
  List<Object?> get props => [text, boundingBox, lines];
}

class TextLine extends Equatable {
  final String text;
  final Rect boundingBox;
  final List<TextWord> words;

  const TextLine({
    required this.text,
    required this.boundingBox,
    this.words = const [],
  });

  @override
  List<Object?> get props => [text, boundingBox, words];
}

class TextWord extends Equatable {
  final String text;
  final Rect boundingBox;
  final double confidence;

  const TextWord({
    required this.text,
    required this.boundingBox,
    this.confidence = 0.0,
  });

  @override
  List<Object?> get props => [text, boundingBox, confidence];
}
