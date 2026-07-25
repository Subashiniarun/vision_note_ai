import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/ai_models.dart';
import '../../domain/repositories/i_ai_repository.dart';
import '../datasources/remote/gemini_client.dart';
import '../datasources/remote/openai_client.dart';
import '../models/prompt_templates.dart';
import '../../../settings/domain/repositories/i_settings_repository.dart';

@Injectable(as: IAIRepository)
class AIRepository implements IAIRepository {
  final GeminiClient _geminiClient;
  final OpenAIClient _openAIClient;
  final ISettingsRepository _settingsRepository;
  final ConnectivityService _connectivity;

  AIRepository(
    this._geminiClient,
    this._openAIClient,
    this._settingsRepository,
    this._connectivity,
  );

  Future<String> _callAI({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.3,
    int maxTokens = 2048,
  }) async {
    if (!_connectivity.currentStatus) {
      throw AIOfflineException();
    }

    final settings = await _settingsRepository.load();
    if (settings.aiProvider == 'openai') {
      return await _openAIClient.sendPrompt(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        model: settings.aiModel.isNotEmpty ? settings.aiModel : null,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    }
    return await _geminiClient.sendPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      model: settings.aiModel.isNotEmpty ? settings.aiModel : null,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  @override
  Future<AISummary> generateSummary(String text) async {
    final response = await _callAI(
      systemPrompt: PromptTemplates.summary,
      userPrompt: text,
      temperature: 0.3,
    );
    return AISummary(summary: response.trim());
  }

  @override
  Future<List<AIActionItem>> generateActionItems(String text) async {
    final response = await _callAI(
      systemPrompt: PromptTemplates.actionItems,
      userPrompt: text,
      temperature: 0.2,
    );
    return _parseActionItems(response);
  }

  @override
  Future<List<AIFlashcard>> generateFlashcards(String text) async {
    final response = await _callAI(
      systemPrompt: PromptTemplates.flashcards,
      userPrompt: text,
      temperature: 0.4,
    );
    return _parseFlashcards(response);
  }

  @override
  Future<String> generateMindMap(String text) async {
    final response = await _callAI(
      systemPrompt: PromptTemplates.mindMap,
      userPrompt: text,
      temperature: 0.3,
    );
    return response.trim();
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    final response = await _callAI(
      systemPrompt: PromptTemplates.translation
          .replaceAll('{source_language}', 'auto')
          .replaceAll('{target_language}', targetLanguage),
      userPrompt: text,
      temperature: 0.1,
    );
    return response.trim();
  }

  @override
  Future<String> fixGrammar(String text) async {
    final response = await _callAI(
      systemPrompt: PromptTemplates.grammarFix,
      userPrompt: text,
      temperature: 0.1,
    );
    return response.trim();
  }

  @override
  Future<String> askQuestion(String context, String question) async {
    final response = await _callAI(
      systemPrompt: PromptTemplates.qaSystemPrompt
          .replaceAll('{document_text}', context),
      userPrompt: question,
      temperature: 0.2,
    );
    return response.trim();
  }

  List<AIActionItem> _parseActionItems(String text) {
    final items = <AIActionItem>[];
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.contains('|') && !line.startsWith('|')) {
        final parts = line.split('|').map((s) => s.trim()).toList();
        if (parts.length >= 3) {
          items.add(AIActionItem(
            task: parts[0],
            assignee: parts[1] != 'Unassigned' ? parts[1] : null,
            priority: parts[2],
          ));
        }
      }
    }
    return items;
  }

  List<AIFlashcard> _parseFlashcards(String text) {
    final flashcards = <AIFlashcard>[];
    final lines = text.split('\n');
    String? currentQuestion;
    String? currentAnswer;

    for (final line in lines) {
      if (line.startsWith('**Q:**')) {
        currentQuestion = line.replaceAll('**Q:**', '').trim();
      } else if (line.startsWith('**A:**')) {
        currentAnswer = line.replaceAll('**A:**', '').trim();
        if (currentQuestion != null && currentAnswer != null) {
          flashcards.add(AIFlashcard(
            question: currentQuestion,
            answer: currentAnswer,
          ));
          currentQuestion = null;
          currentAnswer = null;
        }
      }
    }
    return flashcards;
  }
}
