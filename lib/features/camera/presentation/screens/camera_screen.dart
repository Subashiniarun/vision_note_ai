import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/permission_utils.dart';
import '../bloc/camera_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraBloc _cameraBloc;

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
            if (state is CameraCaptured) {
              context.pushRoute(PageRouteInfo.named('CropEditorRoute', args: {'imagePath': state.imagePath}));
            }
          },
          builder: (context, state) {
            return switch (state) {
              CameraInitial() => _buildPermissionRequest(),
              CameraInitializing() => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing camera...'),
                    ],
                  ),
                ),
              CameraReady(controller: final c, flashMode: final f) =>
                _buildCameraPreview(context, c, f),
              CameraError(message: final msg) =>
                VNAErrorState(message: msg, actionLabel: 'Retry', onAction: _initCamera),
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
          const Icon(Icons.camera_alt, size: 64),
          const SizedBox(height: 16),
          const Text('Camera access required for scanning'),
          const SizedBox(height: 16),
          VNAButton(
            label: 'Grant Permission',
            onPressed: _initCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(
    BuildContext context,
    CameraController controller,
    FlashMode flashMode,
  ) {
    return Stack(
      children: [
        CameraPreview(controller),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: VNAIconButton(
            icon: flashMode == FlashMode.always
                ? Icons.flash_on
                : Icons.flash_off,
            onPressed: () => _cameraBloc.add(const ToggleFlash()),
          ),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                final image = await controller.takePicture();
                final bytes = await image.readAsBytes();
                _cameraBloc.add(CaptureFrame(
                  frame: null!,
                  imageBytes: bytes,
                ));
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
