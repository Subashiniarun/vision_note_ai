import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scanBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('VisionNote AI')),
        body: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            return switch (state) {
              ScanLoading() => const Center(child: CircularProgressIndicator()),
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
      onRefresh: () async =>
          _scanBloc.add(const LoadRecentScans(10)),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Scans',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${scans.length} documents',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (scans.isEmpty)
            SliverFillRemaining(
              child: VNAEmptyState(
                icon: Icons.document_scanner_outlined,
                title: 'No scans yet',
                description:
                    'Tap the camera button to scan your first document',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildScanCard(context, scans[index]),
                  childCount: scans.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanCard(BuildContext context, Scan scan) {
    return VNACard(
      title: scan.title,
      subtitle:
          '${scan.createdAt.day}/${scan.createdAt.month}/${scan.createdAt.year}',
      tags: scan.tags.isNotEmpty ? scan.tags : null,
      onTap: () => context.navigateToPath('/scan/${scan.id}'),
    );
  }
}
