import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/scan.dart';
import '../bloc/scan_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScanBloc _scanBloc;

  @override
  void initState() {
    super.initState();
    _scanBloc = getIt<ScanBloc>()..add(const LoadRecentScans(10));
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scanBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: AppColors.onSurface),
            onPressed: () {},
          ),
          title: Text(
            'VisionNote AI',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            final scans = switch (state) {
              ScanLoaded(scans: final s) => s,
              ScanSearchResults(scans: final s) => s,
              _ => <Scan>[],
            };
            final isLoading = state is ScanLoading;
            return _buildHomeContent(context, scans, isLoading);
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, List<Scan> scans, bool isLoading) {
    return RefreshIndicator(
      onRefresh: () async => _scanBloc.add(const LoadRecentScans(10)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Scan Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
              child: GestureDetector(
                onTap: () => context.pushRoute(PageRouteInfo.named('CameraRoute')),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Scan',
                              style: AppTypography.headlineSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Digitize notes in seconds',
                              style: AppTypography.bodyMd.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.03, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            ),

            // Recent Scans section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Scans', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {},
                    child: Text('View all', style: AppTypography.labelLg.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      ShimmerLoading(width: 140, height: 180, borderRadius: BorderRadius.circular(AppRadius.xl)),
                      const SizedBox(width: AppSpacing.md),
                      ShimmerLoading(width: 140, height: 180, borderRadius: BorderRadius.circular(AppRadius.xl)),
                    ],
                  ),
                ),
              )
            else if (scans.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Center(
                  child: Text(
                    'No scans yet. Tap Quick Scan to begin!',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: scans.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      _buildRecentScanCard(context, scans[index], index),
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),

            // AI Intelligence section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('AI Intelligence', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.6,
                children: [
                  _buildAICard('Summarize', Icons.auto_awesome_outlined, context),
                  _buildAICard('Action Items', Icons.checklist_outlined, context),
                  _buildAICard('Flashcards', Icons.style_outlined, context),
                  _buildAICard('Mind Maps', Icons.hub_outlined, context),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Scanning Activity card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildActivityCard(scans),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Pro Tip card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pro Tip',
                            style: AppTypography.labelLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Use clear lighting for 30% faster AI processing speeds.',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.lightbulb_outline, color: AppColors.primary.withOpacity(0.4), size: 36),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScanCard(BuildContext context, Scan scan, int index) {
    final imagePath = scan.enhancedImagePath ?? scan.originalImagePath;
    final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();

    return GestureDetector(
      onTap: () => context.pushRoute(PageRouteInfo.named('ScanDetailRoute', args: {'scanId': scan.id})),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: AppColors.surfaceContainer,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: hasImage
                  ? Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      color: AppColors.primaryContainer.withOpacity(0.3),
                      child: const Center(child: Icon(Icons.description_outlined, color: AppColors.primary, size: 32)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  Text(_timeAgo(scan.createdAt), style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (150 + 60 * index).ms)
        .slideY(begin: 0.04, end: 0, duration: 300.ms, delay: (150 + 60 * index).ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildAICard(String label, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to AI summary or whichever route fits the label
        // Requires a saved scan; if scans are empty, prompt to scan first
        final state = _scanBloc.state;
        final scans = state is ScanLoaded ? state.scans : <Scan>[];
        if (scans.isNotEmpty) {
          context.pushRoute(PageRouteInfo.named('AISummaryRoute', args: {'scan': scans.first, 'text': scans.first.ocrText ?? ''}));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(List<Scan> scans) {
    // Build a bar chart using scans from the last 7 days
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final counts = days.map((day) {
      return scans.where((s) =>
        s.createdAt.year == day.year &&
        s.createdAt.month == day.month &&
        s.createdAt.day == day.day
      ).length;
    }).toList();
    final maxCount = counts.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final totalThisMonth = scans.where((s) => s.createdAt.month == now.month && s.createdAt.year == now.year).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0FF),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Scanning\nActivity', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('+${counts.last} this week', style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final isToday = i == 6;
                final barHeight = maxCount > 0 ? (counts[i] / maxCount * 60).clamp(6.0, 60.0) : 6.0;
                return Container(
                  width: 28,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : AppColors.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RichText(
            text: TextSpan(
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              children: [
                const TextSpan(text: "You've digitized "),
                TextSpan(text: '$totalThisMonth pages', style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: ' of notes this month. Great progress!'),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}
