import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/ai_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class AISummaryScreen extends StatefulWidget {
  const AISummaryScreen({super.key});

  @override
  State<AISummaryScreen> createState() => _AISummaryScreenState();
}

class _AISummaryScreenState extends State<AISummaryScreen> {
  late AIBloc _aiBloc;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _aiBloc = getIt<AIBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _text = (args?['text'] as String?) ?? '';
      if (_text.isNotEmpty) {
        _aiBloc.add(SetAIText(_text));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _aiBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Features'),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () => context.pushRoute(PageRouteInfo.named('ChatRoute', args: {'text': _text})),
              tooltip: 'Chat with Notes',
            ),
          ],
        ),
        body: BlocConsumer<AIBloc, AIState>(
          listener: (context, state) {
            if (state is AIError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionButtons(context, state),
                  const SizedBox(height: 24),
                  _buildContent(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AIState state) {
    final isLoading = state is AILoading;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAICard(
                context,
                icon: Icons.summarize,
                label: 'Summary',
                isLoading: isLoading,
                onTap: () => _aiBloc.add(const GenerateSummary()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAICard(
                context,
                icon: Icons.checklist,
                label: 'Actions',
                isLoading: isLoading,
                onTap: () => _aiBloc.add(const GenerateActionItems()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAICard(
                context,
                icon: Icons.style,
                label: 'Flashcards',
                isLoading: isLoading,
                onTap: () => _aiBloc.add(const GenerateFlashcards()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAICard(
                context,
                icon: Icons.account_tree,
                label: 'Mind Map',
                isLoading: isLoading,
                onTap: () => _aiBloc.add(const GenerateMindMap()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildAICard(
                context,
                icon: Icons.translate,
                label: 'Translate',
                isLoading: isLoading,
                onTap: () => _aiBloc.add(const TranslateText('es')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAICard(
                context,
                icon: Icons.spellcheck,
                label: 'Fix Grammar',
                isLoading: isLoading,
                onTap: () => _aiBloc.add(const FixGrammar()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAICard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 28,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AIState state) {
    return switch (state) {
      AILoading(message: final msg) => Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(msg),
          ],
        ),
      AISummaryReady(summary: final s) => _buildSection(
          'Summary',
          Text(s.summary, style: const TextStyle(fontSize: 16)),
        ),
      AIActionItemsReady(items: final items) => _buildSection(
          'Action Items',
          Column(
            children: items
                .map((i) => ListTile(
                      leading: Icon(
                        i.priority == 'High'
                            ? Icons.arrow_upward
                            : Icons.remove,
                        color: i.priority == 'High'
                            ? Colors.red
                            : Colors.orange,
                      ),
                      title: Text(i.task),
                      subtitle: Text(i.assignee ?? 'Unassigned'),
                    ))
                .toList(),
          ),
        ),
      AIFlashcardsReady(flashcards: final cards) => _buildSection(
          'Flashcards',
          Column(
            children: cards
                .map((c) => Card(
                      child: ListTile(
                        title: Text('Q: ${c.question}'),
                        subtitle: Text('A: ${c.answer}'),
                      ),
                    ))
                .toList(),
          ),
        ),
      AIMindMapReady(mermaidCode: final code) => _buildSection(
          'Mind Map',
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      AITranslationReady(translatedText: final t) => _buildSection(
          'Translation',
          Text(t, style: const TextStyle(fontSize: 16)),
        ),
      AIGrammarFixed(correctedText: final t) => _buildSection(
          'Corrected Text',
          Text(t, style: const TextStyle(fontSize: 16)),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
