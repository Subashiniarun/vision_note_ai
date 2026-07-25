import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/widgets/app_widgets.dart';
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
    final args =
        context.router.current?.args as Map<String, dynamic>?;
    final scan = args?['scan'] as Scan?;
    if (scan != null) {
      _exportBloc.add(SetExportScan(scan));
    }
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
                SnackBar(
                  content:
                      Text('Exported as ${state.format}'),
                ),
              );
            }
            if (state is CopiedToClipboard) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Choose Export Format',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  _buildFormatCard(
                    context,
                    icon: Icons.description,
                    title: 'Markdown',
                    subtitle: '.md — Rich text format',
                    onTap: () => _exportBloc.add(const ExportMarkdown()),
                  ),
                  const SizedBox(height: 8),
                  _buildFormatCard(
                    context,
                    icon: Icons.text_snippet,
                    title: 'Plain Text',
                    subtitle: '.txt — Universal format',
                    onTap: () => _exportBloc.add(const ExportTXT()),
                  ),
                  const SizedBox(height: 8),
                  _buildFormatCard(
                    context,
                    icon: Icons.picture_as_pdf,
                    title: 'PDF',
                    subtitle: '.pdf — Formatted document',
                    onTap: () => _exportBloc.add(const ExportPDF()),
                  ),
                  const SizedBox(height: 8),
                  _buildFormatCard(
                    context,
                    icon: Icons.data_object,
                    title: 'JSON',
                    subtitle: '.json — Structured data',
                    onTap: () => _exportBloc.add(const ExportJSON()),
                  ),
                  const SizedBox(height: 8),
                  _buildFormatCard(
                    context,
                    icon: Icons.content_copy,
                    title: 'Copy to Clipboard',
                    subtitle: 'Copy text directly',
                    onTap: () => _exportBloc.add(const CopyToClipboard()),
                  ),
                  const Spacer(),
                  if (state is Exporting)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32,
            color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
