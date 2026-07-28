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
  String _selectedTag = 'All';

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

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1 day ago';
    return '${diff.inDays} days ago';
  }

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scanDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(scanDay).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Scan> _filterByTag(List<Scan> scans) {
    if (_selectedTag == 'All') return scans;
    return scans.where((s) => s.tags.contains(_selectedTag)).toList();
  }

  List<String> _collectAllTags(List<Scan> scans) {
    final tags = <String>{};
    for (final scan in scans) {
      tags.addAll(scan.tags);
    }
    return ['All', ...tags.toList()..sort()];
  }

  Map<String, List<Scan>> _groupByDate(List<Scan> scans) {
    final groups = <String, List<Scan>>{};
    for (final scan in scans) {
      final key = _dateGroupLabel(scan.createdAt);
      groups.putIfAbsent(key, () => []).add(scan);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _historyBloc,
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
            'History',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.onSurface),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.onSurface),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: const Icon(Icons.person, size: 18, color: AppColors.onPrimaryContainer),
              ),
            ),
          ],
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            final scans = switch (state) {
              HistoryLoaded(scans: final s) => s,
              HistorySearchResults(scans: final s) => s,
              _ => <Scan>[],
            };
            final isLoading = state is HistoryLoading || state is HistoryInitial;
            final allTags = _collectAllTags(scans);
            final filtered = _filterByTag(scans);
            final grouped = _groupByDate(filtered);

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                  child: VNASearchBar(
                    controller: _searchController,
                    hintText: 'Search notes, text, or tags...',
                    onChanged: (q) => _debouncer(() {
                      _historyBloc.add(SearchHistoryRequest(q));
                    }),
                  ),
                ),
                // Filter chips
                if (scans.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: allTags.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final tag = allTags[index];
                        final isSelected = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTag = tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.labelMd.copyWith(
                                color: isSelected ? Colors.white : AppColors.onSurface,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                // List
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : state is HistoryError
                          ? VNAErrorState(message: (state as HistoryError).message)
                          : filtered.isEmpty
                              ? const VNAEmptyState(
                                  icon: Icons.history_outlined,
                                  title: 'No scans found',
                                  description: 'Your scanned documents will appear here',
                                )
                              : RefreshIndicator(
                                  onRefresh: () async => _historyBloc.add(const LoadHistory()),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                    itemCount: _countItems(grouped),
                                    itemBuilder: (context, index) =>
                                        _buildGroupedItem(context, grouped, index),
                                  ),
                                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _countItems(Map<String, List<Scan>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      count += 1 + entry.value.length; // 1 header + items
    }
    return count;
  }

  Widget _buildGroupedItem(BuildContext context, Map<String, List<Scan>> grouped, int index) {
    // Flatten the grouped map into a list of [header | scan] items
    final items = <Object>[];
    for (final entry in grouped.entries) {
      items.add(entry.key); // header string
      items.addAll(entry.value); // scan items
    }
    final item = items[index];
    if (item is String) {
      // Section header
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
        child: Text(
          item,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );
    }
    final scan = item as Scan;
    final itemIndex = index;
    return _buildScanTile(context, scan, itemIndex);
  }

  Widget _buildScanTile(BuildContext context, Scan scan, int index) {
    final imagePath = scan.enhancedImagePath ?? scan.originalImagePath;
    final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();

    return GestureDetector(
      onTap: () => context.pushRoute(PageRouteInfo.named('ScanDetailRoute', args: {'scanId': scan.id})),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                bottomLeft: Radius.circular(AppRadius.xl),
              ),
              child: SizedBox(
                width: 72,
                height: 72,
                child: hasImage
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Container(
                        color: AppColors.primaryContainer.withOpacity(0.3),
                        child: const Center(child: Icon(Icons.description_outlined, color: AppColors.primary, size: 28)),
                      ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface),
                    ),
                    if ((scan.ocrText ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        scan.ocrText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(_timeAgo(scan.createdAt), style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                        if (scan.tags.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          ...scan.tags.take(2).map((tag) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.xs),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(tag.toUpperCase(), style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 10)),
                            ),
                          )),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Three-dot menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant, size: 20),
              onSelected: (v) {
                if (v == 'delete' && scan.id != null) {
                  _historyBloc.add(DeleteScanById(scan.id!));
                }
                if (v == 'view') {
                  context.pushRoute(PageRouteInfo.named('ScanDetailRoute', args: {'scanId': scan.id}));
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'view', child: Text('View')),
                PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms)
        .slideX(begin: 0.03, end: 0, duration: 300.ms, delay: (index * 40).ms, curve: Curves.easeOutCubic),
    );
  }
}
