import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
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
        appBar: AppBar(title: const Text('History')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                      const Center(child: CircularProgressIndicator()),
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
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: scans.length,
        itemBuilder: (context, index) => _buildScanTile(context, scans[index]),
      ),
    );
  }

  Widget _buildScanTile(BuildContext context, Scan scan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.description,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(scan.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${scan.createdAt.day}/${scan.createdAt.month}/${scan.createdAt.year}'
          '${scan.tags.isNotEmpty ? ' • ${scan.tags.join(", ")}' : ''}',
          maxLines: 1,
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
        onTap: () => context.navigateToPath('/scan/${scan.id}'),
      ),
    );
  }
}
