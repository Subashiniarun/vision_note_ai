import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/ocr_bloc.dart';
import '../../domain/entities/ocr_result.dart';
import '../../../../core/di/injection.dart';
import '../../../scan/domain/entities/scan.dart';
import '../../../scan/domain/usecases/save_scan.dart';

@RoutePage()
class OCRPreviewScreen extends StatefulWidget {
  const OCRPreviewScreen({super.key});

  @override
  State<OCRPreviewScreen> createState() => _OCRPreviewScreenState();
}

class _OCRPreviewScreenState extends State<OCRPreviewScreen> {
  late OCRBloc _ocrBloc;
  final _textController = TextEditingController();
  Uint8List? _enhancedImage;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _ocrBloc = getIt<OCRBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _imagePath = args?['imagePath'] as String?;
      _enhancedImage = args?['enhancedImage'] as Uint8List?;
      if (_enhancedImage != null && _enhancedImage!.isNotEmpty) {
        _ocrBloc.add(SetOCRImage(_enhancedImage!, 'en'));
        _ocrBloc.add(const ExtractTextRequest());
      }
    });
  }

  Future<Scan> _saveScan(String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    String? savedOriginalPath;
    if (_imagePath != null && await File(_imagePath!).exists()) {
      final dest = '${dir.path}/original_$ts.jpg';
      await File(_imagePath!).copy(dest);
      savedOriginalPath = dest;
    }

    String? savedEnhancedPath;
    if (_enhancedImage != null && _enhancedImage!.isNotEmpty) {
      final dest = '${dir.path}/enhanced_$ts.jpg';
      await File(dest).writeAsBytes(_enhancedImage!);
      savedEnhancedPath = dest;
    }

    final scan = Scan(
      originalImagePath: savedOriginalPath ?? '',
      enhancedImagePath: savedEnhancedPath,
      ocrText: text,
    );

    final saveScan = getIt<SaveScan>();
    return saveScan(scan);
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
                  onPressed: () async {
                    final saved = await _saveScan(displayText);
                    if (!context.mounted) return;
                    context.pushRoute(PageRouteInfo.named('AISummaryRoute', args: {'scan': saved, 'text': displayText}));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VNAButton(
                  label: 'Export',
                  icon: Icons.file_download,
                  onPressed: () async {
                    final saved = await _saveScan(displayText);
                    if (!context.mounted) return;
                    context.pushRoute(PageRouteInfo.named('ExportRoute', args: {'scan': saved}));
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
