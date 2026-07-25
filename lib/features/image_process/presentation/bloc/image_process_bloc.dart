import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_image_processor.dart';

part 'image_process_event.dart';
part 'image_process_state.dart';

@injectable
class ImageProcessBloc extends Bloc<ImageProcessEvent, ImageProcessState> {
  final IImageProcessor _imageProcessor;

  ImageProcessBloc(this._imageProcessor) : super(ImageProcessInitial()) {
    on<LoadImage>(_onLoadImage);
    on<AutoDetectCorners>(_onAutoDetectCorners);
    on<UpdateCorner>(_onUpdateCorner);
    on<ApplyCrop>(_onApplyCrop);
    on<AutoEnhance>(_onAutoEnhance);
    on<UpdateBrightness>(_onUpdateBrightness);
    on<UpdateContrast>(_onUpdateContrast);
    on<UpdateSaturation>(_onUpdateSaturation);
    on<ApplyEnhancement>(_onApplyEnhancement);
    on<ResetEnhancement>(_onResetEnhancement);
  }

  Future<void> _onLoadImage(
    LoadImage event,
    Emitter<ImageProcessState> emit,
  ) async {
    try {
      final file = File(event.imagePath);
      final bytes = await file.readAsBytes();
      emit(ImageLoaded(bytes));
    } catch (e) {
      emit(ImageProcessError(e.toString()));
    }
  }

  Future<void> _onAutoDetectCorners(
    AutoDetectCorners event,
    Emitter<ImageProcessState> emit,
  ) async {
    final current = state;
    if (current is! ImageLoaded) return;
    try {
      final corners = await _imageProcessor.detectDocumentCorners(current.original);
      emit(ImageLoaded(current.original, corners: corners));
    } catch (e) {
      emit(ImageProcessError(e.toString()));
    }
  }

  void _onUpdateCorner(
    UpdateCorner event,
    Emitter<ImageProcessState> emit,
  ) {
    final current = state;
    if (current is! ImageLoaded || current.corners == null) return;
    final corners = List.from(current.corners!);
    corners[event.index] = event.position;
    emit(ImageLoaded(current.original, corners: corners.cast()));
  }

  Future<void> _onApplyCrop(
    ApplyCrop event,
    Emitter<ImageProcessState> emit,
  ) async {
    final current = state;
    if (current is! ImageLoaded || current.corners == null) return;
    emit(CropProcessing());
    try {
      final cropped = await _imageProcessor.correctPerspective(
        current.original,
        current.corners!,
      );
      emit(CropReady(cropped));
    } catch (e) {
      emit(ImageProcessError(e.toString()));
    }
  }

  Future<void> _onAutoEnhance(
    AutoEnhance event,
    Emitter<ImageProcessState> emit,
  ) async {
    final current = state;
    if (current is! ImageLoaded && current is! CropReady) return;
    emit(EnhanceProcessing());
    try {
      final image = current is ImageLoaded ? current.original : (current as CropReady).cropped;
      final enhanced = await _imageProcessor.autoEnhance(image);
      emit(EnhanceReady(enhanced, image));
    } catch (e) {
      emit(ImageProcessError(e.toString()));
    }
  }

  Future<void> _onUpdateBrightness(
    UpdateBrightness event,
    Emitter<ImageProcessState> emit,
  ) async {
    final current = state;
    if (current is! EnhanceReady) return;
    try {
      final adjusted = await _imageProcessor
          .adjustBrightness(current.current, event.value);
      emit(EnhanceReady(adjusted, current.original));
    } catch (_) {}
  }

  Future<void> _onUpdateContrast(
    UpdateContrast event,
    Emitter<ImageProcessState> emit,
  ) async {
    final current = state;
    if (current is! EnhanceReady) return;
    try {
      final adjusted =
          await _imageProcessor.adjustContrast(current.current, event.value);
      emit(EnhanceReady(adjusted, current.original));
    } catch (_) {}
  }

  Future<void> _onUpdateSaturation(
    UpdateSaturation event,
    Emitter<ImageProcessState> emit,
  ) async {
    final current = state;
    if (current is! EnhanceReady) return;
    try {
      final adjusted =
          await _imageProcessor.adjustSaturation(current.current, event.value);
      emit(EnhanceReady(adjusted, current.original));
    } catch (_) {}
  }

  void _onApplyEnhancement(
    ApplyEnhancement event,
    Emitter<ImageProcessState> emit,
  ) {
    final current = state;
    if (current is EnhanceReady) {
      emit(EnhanceComplete(current.current));
    } else if (current is ImageLoaded) {
      emit(EnhanceComplete(current.original));
    }
  }

  void _onResetEnhancement(
    ResetEnhancement event,
    Emitter<ImageProcessState> emit,
  ) {
    final current = state;
    if (current is! EnhanceReady) return;
    emit(EnhanceReady(current.original, current.original));
  }
}
