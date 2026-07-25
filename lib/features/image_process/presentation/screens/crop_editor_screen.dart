import 'dart:io';
import 'dart:typed_data';
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

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ImageProcessBloc>();
    final args =
        context.router.current?.args as Map<String, dynamic>?;
    final imagePath = args?['imagePath'] as String?;
    if (imagePath != null) {
      _bloc.add(LoadImage(imagePath));
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
              context.pushRoute(PageRouteInfo.named('EnhancementRoute', args: {'croppedImage': state.cropped}));
            }
          },
          builder: (context, state) {
            return switch (state) {
              ImageProcessInitial() => const Center(
                  child: Text('Loading image...')),
              ImageLoaded(original: final img) =>
                _buildEditor(context, img, state.corners),
              CropProcessing() =>
                const Center(child: CircularProgressIndicator()),
              ImageProcessError(message: final msg) =>
                VNAErrorState(message: msg),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildEditor(
    BuildContext context,
    Uint8List image,
    List<Offset>? corners,
  ) {
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
                  onPressed: () => _bloc.add(const ApplyCrop()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
