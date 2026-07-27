import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/premium_slider.dart';
import '../bloc/image_process_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class EnhancementScreen extends StatefulWidget {
  const EnhancementScreen({super.key});

  @override
  State<EnhancementScreen> createState() => _EnhancementScreenState();
}

class _EnhancementScreenState extends State<EnhancementScreen> {
  late ImageProcessBloc _bloc;
  bool _isHandwriting = false;
  double _brightness = 0.5;
  double _contrast = 0.5;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ImageProcessBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final croppedImage = args?['croppedImage'] as Uint8List?;
        if (croppedImage != null) {
          final dir = await getTemporaryDirectory();
          final path = '${dir.path}/enhance_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await File(path).writeAsBytes(croppedImage);
          _bloc.add(LoadImage(path));
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Enhance Image')),
        body: BlocConsumer<ImageProcessBloc, ImageProcessState>(
          listener: (context, state) {
            if (state is EnhanceComplete) {
              final croppedArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              context.pushRoute(PageRouteInfo.named('OCRPreviewRoute', args: {
                'enhancedImage': state.enhanced,
                'imagePath': croppedArgs?['imagePath'],
                'isHandwriting': _isHandwriting,
              }));
            }
          },
          builder: (context, state) {
            return switch (state) {
              EnhanceReady(current: final img, isHandwriting: final hw) =>
                _buildEnhanceView(context, img, isHandwriting: hw),
              ImageLoaded(original: final img) =>
                _buildEnhanceView(context, img),
              EnhanceProcessing() =>
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ImageProcessError(message: final msg) =>
                VNAErrorState(message: msg),
              _ => Center(child: Text('Processing...', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant))),
            };
          },
        ),
      ),
    );
  }

  Widget _buildEnhanceView(BuildContext context, Uint8List image, {bool isHandwriting = false}) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.memory(image, fit: BoxFit.contain),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Handwriting Mode'),
                subtitle: const Text('Use adaptive thresholding for handwritten text'),
                value: isHandwriting,
                onChanged: (v) {
                  setState(() => _isHandwriting = v);
                  if (v) {
                    _bloc.add(const HandwritingPreprocess());
                  } else {
                    _bloc.add(const AutoEnhance());
                  }
                },
              ),
              const SizedBox(height: 16),
              PremiumSlider(
                label: 'Brightness',
                icon: Icons.light_mode_outlined,
                value: _brightness,
                onChanged: (val) {
                  setState(() => _brightness = val);
                  // Optional: Debounce and add event to bloc
                },
              ),
              const SizedBox(height: 12),
              PremiumSlider(
                label: 'Contrast',
                icon: Icons.contrast,
                value: _contrast,
                onChanged: (val) {
                  setState(() => _contrast = val);
                  // Optional: Debounce and add event to bloc
                },
              ),
              const SizedBox(height: 24),
              VNAButton(
                label: 'Auto Enhance',
                icon: Icons.auto_awesome,
                onPressed: () => _bloc.add(const AutoEnhance()),
              ),
              const SizedBox(height: 12),
              VNAButton(
                label: 'Continue to OCR',
                icon: Icons.arrow_forward,
                onPressed: () => _bloc.add(const ApplyEnhancement()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
