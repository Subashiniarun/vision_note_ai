import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_widgets.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      imageAsset: 'assets/screenshots/02-onboarding-1.png',
      title: 'Capture Any Document',
      description: 'Whiteboards, handwritten notes, receipts, books — frame and capture in one tap',
    ),
    _OnboardingPage(
      imageAsset: 'assets/screenshots/03-onboarding-2.png',
      title: 'AI-Powered Enhancement',
      description: 'Auto-detect edges, correct perspective, remove shadows, and enhance readability instantly.',
    ),
    _OnboardingPage(
      imageAsset: 'assets/screenshots/04-onboarding-3.png',
      title: 'Extract & Export',
      description: 'Extract text with offline OCR, generate AI summaries, and export to Markdown or PDF.',
    ),
    _OnboardingPage(
      imageAsset: 'assets/screenshots/05-onboarding-4.png',
      title: 'Batch Scan & Organize',
      description: 'Scan multiple pages at once, group by topic, and keep your notes organized by subject.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: TextButton(
                  onPressed: () => context.replaceRoute(PageRouteInfo.named('HomeRoute')),
                  child: Text(
                    'Skip',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    width: _currentPage == i ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl).copyWith(bottom: AppSpacing.xxxxl),
              child: VNAButton(
                label: isLastPage ? 'Get Started' : 'Next',
                trailingIcon: isLastPage ? null : Icons.arrow_forward,
                onPressed: () {
                  if (isLastPage) {
                    context.replaceRoute(PageRouteInfo.named('HomeRoute'));
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 6,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320, maxHeight: 600),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 40,
                      spreadRadius: 10,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(31),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  title,
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    description,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
