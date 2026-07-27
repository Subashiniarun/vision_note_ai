import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
              ImageProcessInitial() => Center(child: Text('Loading image...', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant))),
              ImageLoaded(original: final img) => _buildEditor(context, img, state.corners),
              CropProcessing() => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
    return _InteractiveCropOverlay(
      image: image,
      initialCorners: corners,
      imgSize: _imgSize!,
      onCornersUpdated: (newCorners) {
        // We'd ideally update bloc here or just keep local state until confirmed
        _bloc.add(UpdateCorners(newCorners));
      },
    );
  }
}

class _InteractiveCropOverlay extends StatefulWidget {
  final Uint8List image;
  final List<Offset>? initialCorners;
  final Size imgSize;
  final ValueChanged<List<Offset>> onCornersUpdated;

  const _InteractiveCropOverlay({
    required this.image,
    required this.initialCorners,
    required this.imgSize,
    required this.onCornersUpdated,
  });

  @override
  State<_InteractiveCropOverlay> createState() => _InteractiveCropOverlayState();
}

class _InteractiveCropOverlayState extends State<_InteractiveCropOverlay> {
  late List<Offset> _corners;
  int? _activeCornerIndex;
  Offset? _dragPosition;

  @override
  void initState() {
    super.initState();
    _corners = widget.initialCorners ?? [
      const Offset(0, 0),
      Offset(widget.imgSize.width, 0),
      Offset(widget.imgSize.width, widget.imgSize.height),
      Offset(0, widget.imgSize.height),
    ];
  }
  
  @override
  void didUpdateWidget(covariant _InteractiveCropOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCorners != null && widget.initialCorners != oldWidget.initialCorners) {
      setState(() => _corners = List.from(widget.initialCorners!));
    }
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    final scale = math.min(constraints.maxWidth / widget.imgSize.width, constraints.maxHeight / widget.imgSize.height);
    final renderW = widget.imgSize.width * scale;
    final renderH = widget.imgSize.height * scale;
    final offsetX = (constraints.maxWidth - renderW) / 2;
    final offsetY = (constraints.maxHeight - renderH) / 2;

    for (int i = 0; i < 4; i++) {
      final cornerX = offsetX + _corners[i].dx * scale;
      final cornerY = offsetY + _corners[i].dy * scale;
      final distance = (Offset(cornerX, cornerY) - details.localPosition).distance;
      if (distance < 40) {
        _activeCornerIndex = i;
        HapticFeedback.lightImpact();
        setState(() => _dragPosition = details.localPosition);
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_activeCornerIndex == null) return;

    final scale = math.min(constraints.maxWidth / widget.imgSize.width, constraints.maxHeight / widget.imgSize.height);
    final renderW = widget.imgSize.width * scale;
    final renderH = widget.imgSize.height * scale;
    final offsetX = (constraints.maxWidth - renderW) / 2;
    final offsetY = (constraints.maxHeight - renderH) / 2;

    final localPos = details.localPosition;
    double imgX = (localPos.dx - offsetX) / scale;
    double imgY = (localPos.dy - offsetY) / scale;

    imgX = imgX.clamp(0.0, widget.imgSize.width);
    imgY = imgY.clamp(0.0, widget.imgSize.height);

    setState(() {
      _corners[_activeCornerIndex!] = Offset(imgX, imgY);
      _dragPosition = localPos;
    });
    
    // Throttle haptic feedback during drag could be added here
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeCornerIndex != null) {
      widget.onCornersUpdated(_corners);
      setState(() {
        _activeCornerIndex = null;
        _dragPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (d) => _onPanStart(d, constraints),
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: Stack(
            children: [
              Image.memory(
                widget.image,
                fit: BoxFit.contain,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _CropOverlayPainter(
                  _corners,
                  widget.imgSize.width,
                  widget.imgSize.height,
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
              ),
              if (_dragPosition != null)
                Positioned(
                  left: _dragPosition!.dx - 40,
                  top: _dragPosition!.dy - 100,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          Positioned(
                            left: -(_dragPosition!.dx * 1.5) + 40,
                            top: -(_dragPosition!.dy * 1.5) + 40,
                            child: Transform.scale(
                              scale: 1.5,
                              alignment: Alignment.topLeft,
                              child: Image.memory(
                                widget.image,
                                fit: BoxFit.contain,
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
      ..color = AppColors.primary.withOpacity(0.12)
      ..style = PaintingStyle.fill);

    canvas.drawPath(path, Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);

    for (int i = 0; i < 4; i++) {
      final x = offsetX + corners[i].dx * scale;
      final y = offsetY + corners[i].dy * scale;
      
      // Outer glow for corner
      canvas.drawCircle(Offset(x, y), 12, Paint()..color = AppColors.primary.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 8, Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
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
