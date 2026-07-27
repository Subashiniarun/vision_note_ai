import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../scan/domain/entities/scan.dart';
import '../bloc/export_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  late ExportBloc _exportBloc;

  @override
  void initState() {
    super.initState();
    _exportBloc = getIt<ExportBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final scan = args?['scan'] as Scan?;
      if (scan != null) {
        _exportBloc.add(SetExportScan(scan));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _exportBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Export')),
        body: BlocConsumer<ExportBloc, ExportState>(
          listener: (context, state) {
            if (state is ExportSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exported as ${state.format}')),
              );
            }
            if (state is CopiedToClipboard) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            }
            if (state is ExportError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export failed: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Stack(
                children: [
                  // Decorative background bubbles for glassmorphism effect
                  Positioned(
                    top: -50,
                    right: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Choose Export Format',
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildFormatCard(
                        icon: Icons.description,
                        title: 'Markdown',
                        subtitle: '.md \u2014 Rich text format',
                        onTap: () => _exportBloc.add(const ExportMarkdown()),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildFormatCard(
                        icon: Icons.text_snippet,
                        title: 'Plain Text',
                        subtitle: '.txt \u2014 Universal format',
                        onTap: () => _exportBloc.add(const ExportTXT()),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildFormatCard(
                        icon: Icons.picture_as_pdf,
                        title: 'PDF',
                        subtitle: '.pdf \u2014 Formatted document',
                        onTap: () => _exportBloc.add(const ExportPDF()),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildFormatCard(
                        icon: Icons.data_object,
                        title: 'JSON',
                        subtitle: '.json \u2014 Structured data',
                        onTap: () => _exportBloc.add(const ExportJSON()),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildFormatCard(
                        icon: Icons.content_copy,
                        title: 'Copy to Clipboard',
                        subtitle: 'Copy text directly',
                        onTap: () => _exportBloc.add(const CopyToClipboard()),
                      ),
                      const Spacer(),
                      if (state is Exporting)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              title: Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
