part of 'ocr_bloc.dart';

abstract class OCREvent extends Equatable {
  const OCREvent();
}

class SetOCRImage extends OCREvent {
  final Uint8List imageBytes;
  final String language;
  final bool useCloudOCR;
  const SetOCRImage(this.imageBytes, this.language, {this.useCloudOCR = false});
  @override
  List<Object> get props => [imageBytes, language, useCloudOCR];
}

class ExtractTextRequest extends OCREvent {
  const ExtractTextRequest();
  @override
  List<Object> get props => [];
}

class SelectLanguage extends OCREvent {
  final String languageCode;
  const SelectLanguage(this.languageCode);
  @override
  List<Object> get props => [languageCode];
}

class EditText extends OCREvent {
  final String newText;
  const EditText(this.newText);
  @override
  List<Object> get props => [newText];
}
