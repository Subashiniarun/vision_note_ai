part of 'ocr_bloc.dart';

abstract class OCREvent extends Equatable {
  const OCREvent();
}

class SetOCRImage extends OCREvent {
  final Uint8List imageBytes;
  final String language;
  const SetOCRImage(this.imageBytes, this.language);
  @override
  List<Object> get props => [imageBytes, language];
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
