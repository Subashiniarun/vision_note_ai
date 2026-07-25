import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart' hide CameraException;
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../../../image_process/domain/repositories/i_image_processor.dart';
import '../../../../core/error/exceptions.dart';

part 'camera_event.dart';
part 'camera_state.dart';

@injectable
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final IImageProcessor _imageProcessor;

  CameraBloc(this._imageProcessor) : super(CameraInitial()) {
    on<InitializeCamera>(_onInitialize);
    on<CaptureFrame>(_onCapture);
    on<ToggleFlash>(_onToggleFlash);
    on<ResetCapture>(_onResetCapture);
    on<DisposeCamera>(_onDispose);
  }

  Future<void> _onInitialize(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraInitializing());
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('No camera available');
      }
      final controller = CameraController(
        cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.veryHigh,
      );
      await controller.initialize();
      emit(CameraReady(controller));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  Future<void> _onCapture(
    CaptureFrame event,
    Emitter<CameraState> emit,
  ) async {
    final current = state;
    if (current is! CameraReady) return;
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(event.imageBytes);
      emit(CameraCaptured(current.controller, path));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  void _onToggleFlash(
    ToggleFlash event,
    Emitter<CameraState> emit,
  ) {
    final current = state;
    if (current is! CameraReady) return;
    final newFlash = current.flashMode == FlashMode.off
        ? FlashMode.always
        : FlashMode.off;
    current.controller.setFlashMode(newFlash);
    emit(CameraReady(current.controller, flashMode: newFlash));
  }

  void _onResetCapture(
    ResetCapture event,
    Emitter<CameraState> emit,
  ) {
    final current = state;
    if (current is CameraCaptured) {
      emit(CameraReady(current.controller, flashMode: FlashMode.off));
    }
  }

  void _onDispose(
    DisposeCamera event,
    Emitter<CameraState> emit,
  ) {
    final current = state;
    if (current is CameraReady) {
      current.controller.dispose();
    } else if (current is CameraCaptured) {
      current.controller.dispose();
    }
    emit(CameraInitial());
  }
}
