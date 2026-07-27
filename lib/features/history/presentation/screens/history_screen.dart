import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_animations.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../scan/domain/entities/scan.dart';
import '../bloc/history_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late HistoryBloc _historyBloc;
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  bool _groupByTopic = false;

  @override
  void initState() {
    super.initState();
    _historyBloc = getIt<HistoryBloc>()..add(const LoadHistory());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _historyBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
            IconButton(
              icon: Icon(_groupByTopic ? Icons.folder : Icons.list),
              tooltip: _groupByTopic ? 'Show flat list' : 'Group by topic',
              onPressed: () => setState(() => _groupByTopic = !_groupByTopic),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
              child: VNASearchBar(
                hintText: 'Search your notes...',
                onChanged: (q) => _debouncer(() {
                  _historyBloc.add(SearchHistoryRequest(q));
                }),
              ),
            ),
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  return switch (state) {
                    HistoryInitial() || HistoryLoading() =>
                      const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    HistoryLoaded(scans: final scans) =>
                      _buildHistoryList(context, scans),
                    HistorySearchResults(scans: final scans) =>
                      _buildHistoryList(context, scans),
                    HistoryError(message: final msg) =>
                      VNAErrorState(message: msg),
                    _ => const SizedBox.shrink(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<Scan> scans) {
    if (scans.isEmpty) {
      return const VNAEmptyState(
        icon: Icons.history,
        title: 'No scan history',
        description: 'Your scanned documents will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _historyBloc.add(const LoadHistory()),
      child: _groupByTopic
          ? _buildGroupedList(context, scans)
          : StaggeredFadeList(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: scans.length,
              itemBuilder: (context, index) => _buildScanTile(context, scans[index]),
            ),
    );
  }

  Widget _buildGroupedList(BuildContext context, List<Scan> scans) {
    final groups = <String, List<Scan>>{};
    for (final scan in scans) {
      final topic = scan.tags.isNotEmpty ? scan.tags.first : 'Untitled';
      groups.putIfAbsent(topic, () => []).add(scan);
    }
    final sortedTopics = groups.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        for (final topic in sortedTopics) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
            child: Text(topic, style: AppTypography.labelLg.copyWith(color: AppColors.primary)),
          ),
          for (final scan in groups[topic]!)
            _buildScanTile(context, scan, indent: true),
        ],
      ],
    );
  }

  Widget _buildScanTile(BuildContext context, Scan scan, {bool indent = false, int index = 0}) {
    return Card(
      margin: indent
          ? const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.lg)
          : const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.description, color: AppColors.onPrimaryContainer),
        ),
        title: Text(scan.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
        subtitle: Text(
          '${scan.createdAt.day}/${scan.createdAt.month}/${scan.createdAt.year}'
          '${scan.tags.isNotEmpty ? ' \u2022 ${scan.tags.join(", ")}' : ''}',
          maxLines: 1,
          style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'delete' && scan.id != null) {
              _historyBloc.add(DeleteScanById(scan.id!));
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => context.pushRoute(PageRouteInfo.named('ScanDetailRoute', args: {'scanId': scan.id})),
      ),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: (index * 50).ms,
      curve: Curves.easeOut,
    ).slideX(
      begin: 0.04,
      end: 0,
      duration: 300.ms,
      delay: (index * 50).ms,
      curve: Curves.easeOutCubic,
    );
  }
}
