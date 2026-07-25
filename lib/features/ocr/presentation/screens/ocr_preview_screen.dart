import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/ocr_bloc.dart';
import '../../domain/entities/ocr_result.dart';
import '../../../../core/di/injection.dart';
import '../../../scan/domain/entities/scan.dart';

@RoutePage()
class OCRPreviewScreen extends StatefulWidget {
  const OCRPreviewScreen({super.key});

  @override
  State<OCRPreviewScreen> createState() => _OCRPreviewScreenState();
}

class _OCRPreviewScreenState extends State<OCRPreviewScreen> {
  late OCRBloc _ocrBloc;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ocrBloc = getIt<OCRBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final enhancedImage = args?['enhancedImage'] as Uint8List?;
      if (enhancedImage != null && enhancedImage.isNotEmpty) {
        _ocrBloc.add(SetOCRImage(enhancedImage, 'en'));
        _ocrBloc.add(const ExtractTextRequest());
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ocrBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('OCR Preview')),
        body: BlocConsumer<OCRBloc, OCRState>(
          listener: (context, state) {
            if (state is OCRComplete) {
              _textController.text = state.result.text;
            }
          },
          builder: (context, state) {
            return switch (state) {
              OCRInitial() || OCRImageReady() =>
                const Center(child: Text('Ready to extract...')),
              OCRExtracting() => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Extracting text...'),
                    ],
                  ),
                ),
              OCRComplete(result: final r) => _buildPreview(context, r),
              OCREditing(text: final t) => _buildPreview(context, null, text: t),
              OCRError(message: final msg) =>
                VNAErrorState(message: msg, actionLabel: 'Retry', onAction: () => _ocrBloc.add(const ExtractTextRequest())),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, OCRResult? result, {String? text}) {
    final displayText = text ?? result?.text ?? '';
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Extracted text appears here...',
              ),
              onChanged: (t) => _ocrBloc.add(EditText(t)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Row(
            children: [
              Expanded(
                child: VNAButton(
                  label: 'AI Summary',
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    final scan = Scan(
                      originalImagePath: '',
                      ocrText: displayText,
                    );
                    context.pushRoute(PageRouteInfo.named('AISummaryRoute', args: {'scan': scan, 'text': displayText}));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VNAButton(
                  label: 'Export',
                  icon: Icons.file_download,
                  onPressed: () {
                    final scan = Scan(
                      originalImagePath: '',
                      ocrText: displayText,
                    );
                    context.pushRoute(PageRouteInfo.named('ExportRoute', args: {'scan': scan}));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
