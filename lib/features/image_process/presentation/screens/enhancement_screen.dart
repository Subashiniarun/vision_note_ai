import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/widgets/app_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ImageProcessBloc>();
    final args =
        context.router.current?.args as Map<String, dynamic>?;
    final croppedImage = args?['croppedImage'] as Uint8List?;
    if (croppedImage != null) {
      _bloc.add(LoadImage(''));
    }
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
              context.pushRoute(PageRouteInfo.named('OCRPreviewRoute', args: {'enhancedImage': state.enhanced}));
            }
          },
          builder: (context, state) {
            return switch (state) {
              EnhanceReady(current: final img) =>
                _buildEnhanceView(context, img),
              EnhanceProcessing() =>
                const Center(child: CircularProgressIndicator()),
              ImageProcessError(message: final msg) =>
                VNAErrorState(message: msg),
              _ => const Center(child: Text('Processing...')),
            };
          },
        ),
      ),
    );
  }

  Widget _buildEnhanceView(BuildContext context, Uint8List image) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(image, fit: BoxFit.contain),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
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
