import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_widgets.dart';

@RoutePage()
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(AppSpacing.xxl),
              ),
              child: const Icon(Icons.document_scanner, size: 80, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('VisionNote AI', style: AppTypography.headlineLg.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Text('Version 1.0.0', style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Transform whiteboards, handwritten notes, and documents\ninto structured, AI-powered knowledge.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xxl),
            VNACard(
              title: 'Developer',
              subtitle: 'VisionNote Team',
            ),
            const SizedBox(height: AppSpacing.sm),
            VNACard(
              title: 'Architecture',
              subtitle: 'Clean Architecture + BLoC',
            ),
            const SizedBox(height: AppSpacing.sm),
            VNACard(
              title: 'Image Processing',
              subtitle: 'OpenCV via FFI',
            ),
            const SizedBox(height: AppSpacing.sm),
            VNACard(
              title: 'OCR',
              subtitle: 'Google ML Kit / Tesseract',
            ),
            const SizedBox(height: AppSpacing.sm),
            VNACard(
              title: 'AI',
              subtitle: 'Gemini / OpenAI (Pluggable)',
            ),
            const Spacer(),
            Text(
              '\u00a9 2026 VisionNote AI. All rights reserved.',
              style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
