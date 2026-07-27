import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/vna_fab.dart';
import '../../../../core/widgets/app_animations.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scanBloc,
      child: Scaffold(
        floatingActionButton: VNAFAB(
          icon: Icons.document_scanner,
          onPressed: () => context.pushRoute(PageRouteInfo.named('CameraRoute')),
        ),
        body: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            return switch (state) {
              ScanLoading() => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ScanLoaded(scans: final scans) => _buildHomeContent(context, scans),
              ScanSearchResults(scans: final scans) => _buildHomeContent(context, scans),
              ScanError(message: final msg) => VNAErrorState(
                  message: msg,
                  actionLabel: 'Retry',
                  onAction: () => _scanBloc.add(const LoadRecentScans(10)),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, List<Scan> scans) {
    return RefreshIndicator(
      onRefresh: () async => _scanBloc.add(const LoadRecentScans(10)),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: VNAGradientHeader(
              title: 'VisionNote AI',
              subtitle: '${scans.length} documents scanned',
            ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: -0.03, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          ),
          SliverToBoxAdapter(
            child: FadeInContainer(
              delayMs: 100,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgBorder,
                        boxShadow: AppElevation.level1,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.mdBorder,
                            ),
                            child: const Icon(Icons.description, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${scans.length}', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                              Text('Documents', style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (scans.isEmpty)
            SliverFillRemaining(
              child: VNAEmptyState(
                icon: Icons.document_scanner_outlined,
                title: 'No scans yet',
                description: 'Tap the scan button to capture your first document',
                actionLabel: 'Scan a Document',
                onAction: () => context.pushRoute(PageRouteInfo.named('CameraRoute')),
              ),
            )
          else
            SliverToBoxAdapter(
              child: FadeInContainer(
                delayMs: 150,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text('Recent Scans', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                ),
              ),
            ),
          if (scans.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildScanCard(context, scans[index], index),
                  childCount: scans.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanCard(BuildContext context, Scan scan, int index) {
    return VNACard(
      title: scan.title,
      subtitle: '${scan.createdAt.day}/${scan.createdAt.month}/${scan.createdAt.year}',
      tags: scan.tags.isNotEmpty ? scan.tags : null,
      onTap: () => context.pushRoute(PageRouteInfo.named('ScanDetailRoute', args: {'scanId': scan.id})),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: (200 + 60 * index).ms,
      curve: Curves.easeOut,
    ).slideY(
      begin: 0.04,
      end: 0,
      duration: 300.ms,
      delay: (200 + 60 * index).ms,
      curve: Curves.easeOutCubic,
    );
  }
}
