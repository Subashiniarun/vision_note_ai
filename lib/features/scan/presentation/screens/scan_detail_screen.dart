import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/di/injection.dart';
import '../../../settings/data/datasources/local/settings_cache.dart';
import '../../domain/entities/scan.dart';
import '../../data/datasources/local/scan_local_datasource.dart';

@RoutePage()
class ScanDetailScreen extends StatefulWidget {
  const ScanDetailScreen({super.key});

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  Scan? _scan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final scanId = args?['scanId'] as int?;
      if (scanId == null) {
        setState(() { _error = 'Scan ID not found'; _loading = false; });
        return;
      }
      _loadScan(scanId);
    });
  }

  void _loadScan(int id) async {
    try {
      final ds = getIt<ScanLocalDataSource>();
      final scan = ds.getScanById(id);
      setState(() { _scan = scan; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_scan?.title ?? 'Scan Detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _scan == null
                  ? const Center(child: Text('Scan not found'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final scan = _scan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scan.originalImagePath.isNotEmpty && File(scan.originalImagePath).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(scan.originalImagePath), fit: BoxFit.contain),
            ),
          const SizedBox(height: 16),
          if (scan.ocrText != null && scan.ocrText!.isNotEmpty) ...[
            Text('OCR Text', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(scan.ocrText!),
            ),
            const SizedBox(height: 16),
          ],
          if (scan.aiSummary != null) ...[
            Text('AI Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(scan.aiSummary!.summary),
            const SizedBox(height: 16),
          ],
          if (scan.aiMindMap != null && scan.aiMindMap!.isNotEmpty) ...[
            Text('Mind Map', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(scan.aiMindMap!),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
