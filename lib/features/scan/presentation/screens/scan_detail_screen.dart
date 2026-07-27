import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/di/injection.dart';
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Text(_error!, style: AppTypography.bodyMd.copyWith(color: AppColors.error)))
              : _scan == null
                  ? Center(child: Text('Scan not found', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final scan = _scan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scan.originalImagePath.isNotEmpty && File(scan.originalImagePath).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.file(File(scan.originalImagePath), fit: BoxFit.contain),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (scan.ocrText != null && scan.ocrText!.isNotEmpty) ...[
            Text('OCR Text', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: SelectableText(scan.ocrText!, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (scan.aiSummary != null) ...[
            Text('AI Summary', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(scan.aiSummary!.summary, style: AppTypography.bodyMd.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (scan.aiMindMap != null && scan.aiMindMap!.isNotEmpty) ...[
            Text('Mind Map', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: SelectableText(scan.aiMindMap!, style: AppTypography.codeMd.copyWith(color: AppColors.onSurface)),
            ),
          ],
        ],
      ),
    );
  }
}
