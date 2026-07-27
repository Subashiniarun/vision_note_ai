import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../image_process/domain/repositories/i_image_processor.dart';
import '../../../ocr/domain/repositories/i_ocr_repository.dart';
import '../../../ocr/domain/entities/ocr_result.dart';
import '../../domain/entities/scan.dart';
import '../../domain/usecases/save_scan.dart';
import 'package:path_provider/path_provider.dart';

@RoutePage()
class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  final _topicController = TextEditingController();
  final List<_PageItem> _pages = [];
  final _picker = ImagePicker();
  bool _isProcessing = false;
  int _processedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final paths = args?['imagePaths'] as List<String>? ?? [];
      setState(() {
        _pages.addAll(paths.map((p) => _PageItem(path: p)));
      });
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _addMoreFromGallery() async {
    final xFiles = await _picker.pickMultiImage();
    if (xFiles.isEmpty) return;
    setState(() {
      _pages.addAll(xFiles.map((f) => _PageItem(path: f.path)));
    });
  }

  void _removePage(int index) {
    setState(() => _pages.removeAt(index));
  }

  void _retryFailed() {
    for (final page in _pages) {
      if (page.status == PageStatus.error) {
        page.status = PageStatus.pending;
      }
    }
    setState(() {});
    _processAll();
  }

  Future<void> _processAll() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final processor = getIt<IImageProcessor>();
    final ocrRepo = getIt<IOCRRepository>();
    final saveScan = getIt<SaveScan>();
    final dir = await getApplicationDocumentsDirectory();
    final topic = _topicController.text.trim().isNotEmpty
        ? _topicController.text.trim()
        : 'Untitled Batch';

    for (int i = 0; i < _pages.length; i++) {
      if (_pages[i].status == PageStatus.done) {
        _processedCount++;
        continue;
      }
      _pages[i].status = PageStatus.processing;
      setState(() {});

      try {
        final file = File(_pages[i].path);
        if (!await file.exists()) {
          _pages[i].status = PageStatus.error;
          setState(() {});
          continue;
        }
        final bytes = await file.readAsBytes();

        final corners = await processor.detectDocumentCorners(bytes);
        Uint8List processed = bytes;
        if (corners.length == 4) {
          processed = await processor.correctPerspective(bytes, corners);
        }

        final enhanced = await processor.autoEnhance(processed);

        OCRResult ocrResult;
        try {
          ocrResult = await ocrRepo.extractText(enhanced, 'en');
        } catch (_) {
          ocrResult = const OCRResult(text: '[OCR failed]');
        }

        final ts = DateTime.now().millisecondsSinceEpoch;
        final enhancedPath = '${dir.path}/batch_enhanced_${ts}_$i.jpg';
        await File(enhancedPath).writeAsBytes(enhanced);

        String? originalSaved;
        if (await file.exists()) {
          originalSaved = '${dir.path}/batch_original_${ts}_$i.jpg';
          await file.copy(originalSaved);
        }

        final scan = Scan(
          title: '$topic - Page ${i + 1}',
          originalImagePath: originalSaved ?? '',
          enhancedImagePath: enhancedPath,
          ocrText: ocrResult.text,
          tags: [topic],
        );

        await saveScan(scan);
        _pages[i].status = PageStatus.done;
        _processedCount++;
        setState(() {});
      } catch (e) {
        _pages[i].status = PageStatus.error;
        setState(() {});
      }
    }

    setState(() => _isProcessing = false);
    if (!context.mounted) return;

    final hasErrors = _pages.any((p) => p.status == PageStatus.error);
    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_processedCount / ${_pages.length} done — tap Retry for failed pages'),
          action: SnackBarAction(label: 'Retry', onPressed: _retryFailed),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All $_processedCount pages saved under "$topic"'),
          action: SnackBarAction(
            label: 'View in History',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final failedCount = _pages.where((p) => p.status == PageStatus.error).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Scan (${_pages.length} pages)'),
        actions: [
          if (!_isProcessing)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              tooltip: 'Add from gallery',
              onPressed: _addMoreFromGallery,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic / Subject',
                hintText: 'e.g. Physics Ch 5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
          ),
          Expanded(
            child: _pages.isEmpty
                ? const Center(child: Text('No pages — tap + to add from gallery'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 48, height: 48,
                              child: Image.file(File(page.path), fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                            ),
                          ),
                          title: Text('Page ${index + 1}', style: const TextStyle(fontSize: 14)),
                          subtitle: Text(page.statusLabel, style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isProcessing && page.status == PageStatus.pending)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                                  onPressed: () => _removePage(index),
                                ),
                              _statusIcon(page.status),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                if (_isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _processedCount / (_pages.length > 0 ? _pages.length : 1),
                        ),
                        const SizedBox(height: 4),
                        Text('$_processedCount / ${_pages.length} pages',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    if (failedCount > 0 && !_isProcessing)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: VNAButton(
                          label: 'Retry ($failedCount)',
                          icon: Icons.refresh,
                          onPressed: _retryFailed,
                        ),
                      ),
                    Expanded(
                      child: VNAButton(
                        label: _isProcessing
                            ? 'Processing...'
                            : _pages.where((p) => p.status == PageStatus.done).length == _pages.length && _pages.isNotEmpty
                                ? 'View in History'
                                : 'Process ${_pages.length} Pages',
                        icon: _isProcessing ? Icons.hourglass_top
                            : _pages.where((p) => p.status == PageStatus.done).length == _pages.length && _pages.isNotEmpty
                                ? Icons.history : Icons.auto_fix_high,
                        onPressed: _pages.isEmpty || _isProcessing
                            ? null
                            : _pages.where((p) => p.status == PageStatus.done).length == _pages.length
                                ? () => Navigator.of(context).pop()
                                : _processAll,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(PageStatus status) {
    return switch (status) {
      PageStatus.pending => const Icon(Icons.hourglass_empty, size: 20, color: Colors.grey),
      PageStatus.processing => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      PageStatus.done => const Icon(Icons.check_circle, size: 20, color: Colors.green),
      PageStatus.error => const Icon(Icons.error, size: 20, color: Colors.red),
    };
  }
}

enum PageStatus { pending, processing, done, error }

class _PageItem {
  final String path;
  PageStatus status;
  _PageItem({required this.path, this.status = PageStatus.pending});

  String get statusLabel => switch (status) {
    PageStatus.pending => 'Pending',
    PageStatus.processing => 'Processing...',
    PageStatus.done => 'Done',
    PageStatus.error => 'Error',
  };
}
