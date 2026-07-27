import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/permission_utils.dart';
import '../bloc/camera_bloc.dart';
import '../../../../core/di/injection.dart';
import '../widgets/scanner_overlay.dart';

@RoutePage()
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraBloc _cameraBloc;
  final _picker = ImagePicker();
  bool _batchMode = false;
  bool _autoCaptureMode = false;
  final List<String> _batchPaths = [];

  @override
  void initState() {
    super.initState();
    _cameraBloc = getIt<CameraBloc>();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final granted = await PermissionUtils.requestCamera();
    if (granted) {
      _cameraBloc.add(const InitializeCamera());
    }
  }

  Future<void> _pickFromGallery() async {
    final xFiles = await _picker.pickMultiImage();
    if (xFiles.isEmpty) return;
    if (_batchMode) {
      setState(() => _batchPaths.addAll(xFiles.map((f) => f.path)));
    } else {
      final bytes = await xFiles.first.readAsBytes();
      _cameraBloc.add(ImportFromGallery(imageBytes: bytes));
    }
  }

  Future<void> _capturePhoto(CameraController controller) async {
    final image = await controller.takePicture();
    if (_batchMode) {
      setState(() => _batchPaths.add(image.path));
      if (_autoCaptureMode) {
        _simulateAutoCapture(controller);
      }
    } else {
      final bytes = await image.readAsBytes();
      _cameraBloc.add(CaptureFrame(imageBytes: bytes));
    }
  }

  void _simulateAutoCapture(CameraController controller) {
    if (!mounted || !_autoCaptureMode) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _autoCaptureMode) {
        _capturePhoto(controller);
      }
    });
  }

  void _goToBatch() {
    if (_batchPaths.isEmpty) return;
    context.pushRoute(PageRouteInfo.named('BatchRoute', args: {'imagePaths': List.from(_batchPaths)}));
    setState(() => _batchPaths.clear());
  }

  @override
  void dispose() {
    _cameraBloc.add(const DisposeCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cameraBloc,
      child: Scaffold(
        body: BlocConsumer<CameraBloc, CameraState>(
          listener: (context, state) {
            if (!_batchMode && state is CameraCaptured) {
              context.pushRoute(PageRouteInfo.named('CropEditorRoute', args: {'imagePath': state.imagePath}));
              _cameraBloc.add(const ResetCapture());
            }
          },
          builder: (context, state) {
            return switch (state) {
              CameraInitial() => _buildPermissionRequest(),
              CameraInitializing() => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              CameraReady(controller: final c, flashMode: final f) => _buildCameraPreview(context, c, f),
              CameraError(message: final msg) => VNAErrorState(message: msg, actionLabel: 'Retry', onAction: _initCamera),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.xlBorder,
            ),
            child: const Icon(Icons.camera_alt, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Camera access required', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.sm),
          Text('Camera access is needed for scanning documents', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: VNAButton(label: 'Grant Permission', onPressed: _initCamera),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context, CameraController controller, FlashMode flashMode) {
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(controller)),
        const Positioned.fill(child: AnimatedScannerOverlay()),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: AppSpacing.lg,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: VNAIconButton(
                  icon: flashMode == FlashMode.always ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  onPressed: () => _cameraBloc.add(const ToggleFlash()),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: VNAIconButton(
                  icon: Icons.photo_library_outlined,
                  color: Colors.white,
                  onPressed: _pickFromGallery,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: _autoCaptureMode ? AppColors.primary : Colors.black38,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: VNAIconButton(
                  icon: Icons.document_scanner_outlined,
                  color: Colors.white,
                  tooltip: 'Auto Capture',
                  onPressed: () {
                    setState(() => _autoCaptureMode = !_autoCaptureMode);
                    if (_autoCaptureMode) {
                      _simulateAutoCapture(controller);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (_batchMode)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('${_batchPaths.length}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        Positioned(
          bottom: _batchMode ? 130 : 48,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => _capturePhoto(controller),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: AppElevation.level5,
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _batchMode = !_batchMode;
                  if (!_batchMode) _batchPaths.clear();
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _batchMode ? AppColors.primary : Colors.black38,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.batch_prediction, size: 18, color: _batchMode ? Colors.white : Colors.white70),
                      const SizedBox(width: 6),
                      Text(_batchMode ? 'Batch ON' : 'Batch', style: TextStyle(color: _batchMode ? Colors.white : Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              if (_batchMode && _batchPaths.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: _goToBatch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: AppElevation.level3,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Done', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
