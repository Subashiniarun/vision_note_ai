import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/i_ocr_repository.dart';

part 'ocr_event.dart';
part 'ocr_state.dart';

@injectable
class OCRBloc extends Bloc<OCREvent, OCRState> {
  final IOCRRepository _ocrRepository;

  OCRBloc(this._ocrRepository) : super(OCRInitial()) {
    on<SetOCRImage>(_onSetImage);
    on<ExtractTextRequest>(_onExtractText);
    on<SelectLanguage>(_onSelectLanguage);
    on<EditText>(_onEditText);
  }

  String _language = 'en';

  void _onSetImage(SetOCRImage event, Emitter<OCRState> emit) {
    emit(OCRImageReady(event.imageBytes, event.language, useCloudOCR: event.useCloudOCR));
    _language = event.language;
  }

  Future<void> _onExtractText(
    ExtractTextRequest event,
    Emitter<OCRState> emit,
  ) async {
    final current = state;
    if (current is! OCRImageReady) return;
    emit(OCRExtracting());
    try {
      final result =
          await _ocrRepository.extractText(current.imageBytes, _language, useCloudOCR: current.useCloudOCR);
      emit(OCRComplete(result));
    } catch (e) {
      emit(OCRError(e.toString()));
    }
  }

  void _onSelectLanguage(SelectLanguage event, Emitter<OCRState> emit) {
    _language = event.languageCode;
    final current = state;
    if (current is OCRImageReady) {
      emit(OCRImageReady(current.imageBytes, _language));
    }
  }

  void _onEditText(EditText event, Emitter<OCRState> emit) {
    emit(OCREditing(event.newText));
  }
}
