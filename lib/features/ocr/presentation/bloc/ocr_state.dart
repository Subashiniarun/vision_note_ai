part of 'ocr_bloc.dart';

abstract class OCRState extends Equatable {
  const OCRState();
}

class OCRInitial extends OCRState {
  const OCRInitial();
  @override
  List<Object> get props => [];
}

class OCRImageReady extends OCRState {
  final Uint8List imageBytes;
  final String language;
  const OCRImageReady(this.imageBytes, this.language);
  @override
  List<Object> get props => [imageBytes, language];
}

class OCRExtracting extends OCRState {
  const OCRExtracting();
  @override
  List<Object> get props => [];
}

class OCRComplete extends OCRState {
  final OCRResult result;
  const OCRComplete(this.result);
  @override
  List<Object> get props => [result];
}

class OCREditing extends OCRState {
  final String text;
  const OCREditing(this.text);
  @override
  List<Object> get props => [text];
}

class OCRError extends OCRState {
  final String message;
  const OCRError(this.message);
  @override
  List<Object> get props => [message];
}
