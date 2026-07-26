import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/image_process_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class CropEditorScreen extends StatefulWidget {
  const CropEditorScreen({super.key});

  @override
  State<CropEditorScreen> createState() => _CropEditorScreenState();
}

class _CropEditorScreenState extends State<CropEditorScreen> {
  late ImageProcessBloc _bloc;
  Size? _imgSize;
  bool _loadingSize = false;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ImageProcessBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final imagePath = args?['imagePath'] as String?;
      if (imagePath != null) {
        _bloc.add(LoadImage(imagePath));
      }
    });
  }

  Future<void> _loadImageSize(Uint8List bytes) async {
    if (_loadingSize) return;
    _loadingSize = true;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _imgSize = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
        });
      }
    } catch (_) {
      _loadingSize = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Crop Editor')),
        body: BlocConsumer<ImageProcessBloc, ImageProcessState>(
          listener: (context, state) {
            if (state is CropReady) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              context.pushRoute(PageRouteInfo.named('EnhancementRoute', args: {
                'croppedImage': state.cropped,
                'imagePath': args?['imagePath'],
              }));
            }
          },
          builder: (context, state) {
            return switch (state) {
              ImageProcessInitial() => const Center(child: Text('Loading image...')),
              ImageLoaded(original: final img) => _buildEditor(context, img, state.corners),
              CropProcessing() => const Center(child: CircularProgressIndicator()),
              ImageProcessError(message: final msg) => VNAErrorState(message: msg),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context, Uint8List image, List<Offset>? corners) {
    if (_imgSize == null) {
      _loadImageSize(image);
    }
    final hasCorners = corners != null && corners.length == 4;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _imgSize != null
                  ? _buildCropView(image, corners)
                  : Image.memory(image, fit: BoxFit.contain),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Row(
            children: [
              Expanded(
                child: VNAOutlinedButton(
                  label: 'Auto Detect',
                  icon: Icons.auto_fix_high,
                  onPressed: () => _bloc.add(const AutoDetectCorners()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VNAButton(
                  label: 'Confirm Crop',
                  icon: Icons.check,
                  onPressed: hasCorners ? () => _bloc.add(const ApplyCrop()) : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropView(Uint8List image, List<Offset>? corners) {
    final imgW = _imgSize!.width;
    final imgH = _imgSize!.height;
    final hasCorners = corners != null && corners.length == 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Image.memory(
              image,
              fit: BoxFit.contain,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            if (hasCorners)
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _CropOverlayPainter(
                  corners,
                  imgW,
                  imgH,
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final List<Offset> corners;
  final double imgW;
  final double imgH;
  final double containerW;
  final double containerH;

  _CropOverlayPainter(this.corners, this.imgW, this.imgH, this.containerW, this.containerH);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(containerW / imgW, containerH / imgH);
    final renderW = imgW * scale;
    final renderH = imgH * scale;
    final offsetX = (containerW - renderW) / 2;
    final offsetY = (containerH - renderH) / 2;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final x = offsetX + corners[i].dx * scale;
      final y = offsetY + corners[i].dy * scale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()
      ..color = Colors.blue.withOpacity(0.12)
      ..style = PaintingStyle.fill);

    canvas.drawPath(path, Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    for (int i = 0; i < 4; i++) {
      final x = offsetX + corners[i].dx * scale;
      final y = offsetY + corners[i].dy * scale;
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 6, Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) =>
      oldDelegate.corners != corners ||
      oldDelegate.imgW != imgW ||
      oldDelegate.imgH != imgH ||
      oldDelegate.containerW != containerW ||
      oldDelegate.containerH != containerH;
}
