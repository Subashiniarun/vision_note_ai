import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_widgets.dart';
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionButtons(context, state),
                  const SizedBox(height: AppSpacing.xxl),
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
            Expanded(child: _buildAICard(context, Icons.summarize, 'Summary', isLoading, () => _aiBloc.add(const GenerateSummary()))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildAICard(context, Icons.checklist, 'Actions', isLoading, () => _aiBloc.add(const GenerateActionItems()))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildAICard(context, Icons.style, 'Flashcards', isLoading, () => _aiBloc.add(const GenerateFlashcards()))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildAICard(context, Icons.account_tree, 'Mind Map', isLoading, () => _aiBloc.add(const GenerateMindMap()))),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildAICard(context, Icons.translate, 'Translate', isLoading, () => _showTranslatePicker(context))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildAICard(context, Icons.spellcheck, 'Fix Grammar', isLoading, () => _aiBloc.add(const FixGrammar()))),
          ],
        ),
      ],
    );
  }

  void _showTranslatePicker(BuildContext context) {
    final languages = {
      'en': 'English', 'es': 'Spanish', 'fr': 'French',
      'de': 'German', 'it': 'Italian', 'pt': 'Portuguese',
      'nl': 'Dutch', 'ru': 'Russian', 'ja': 'Japanese', 'ko': 'Korean', 'zh': 'Chinese',
    };
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Translate to'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((e) => ListTile(
            title: Text(e.value),
            onTap: () {
              Navigator.pop(context);
              _aiBloc.add(TranslateText(e.key));
            },
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildAICard(
    BuildContext context,
    IconData icon,
    String label,
    bool isLoading,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AppColors.surface,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AIState state) {
    return switch (state) {
      AILoading(message: final msg) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg, style: AppTypography.headlineSm.copyWith(color: AppColors.primary)),
            const SizedBox(height: AppSpacing.xl),
            const SkeletonTextLines(lines: 4),
          ],
        ),
      AISummaryReady(summary: final s) => _buildSection(
          'Summary',
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: MarkdownBody(
              data: s.summary,
              styleSheet: MarkdownStyleSheet(
                p: AppTypography.bodyMd.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      AIActionItemsReady(items: final items) => _buildSection(
          'Action Items',
          Column(
            children: items.map((i) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    i.priority == 'High' ? Icons.arrow_upward : Icons.remove,
                    color: i.priority == 'High' ? AppColors.error : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.task, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
                        if (i.assignee != null)
                          Text(i.assignee!, style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      AIFlashcardsReady(flashcards: final cards) => _buildSection(
          'Flashcards',
          Column(
            children: cards.map((c) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Q: ${c.question}', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('A: ${c.answer}', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            )).toList(),
          ),
        ),
      AIMindMapReady(mermaidCode: final code) => _buildSection(
          'Mind Map',
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: SelectableText(code, style: AppTypography.codeMd.copyWith(color: AppColors.onSurface)),
          ),
        ),
      AITranslationReady(translatedText: final t) => _buildSection(
          'Translation',
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: MarkdownBody(
              data: t,
              styleSheet: MarkdownStyleSheet(
                p: AppTypography.bodyMd.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      AIGrammarFixed(correctedText: final t) => _buildSection(
          'Corrected Text',
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(t, style: AppTypography.bodyMd.copyWith(color: Colors.white)),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
        const SizedBox(height: AppSpacing.md),
        content,
      ],
    );
  }
}
