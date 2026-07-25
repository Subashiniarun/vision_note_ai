import '../entities/ai_models.dart';

abstract class IAIRepository {
  Future<AISummary> generateSummary(String text);
  Future<List<AIActionItem>> generateActionItems(String text);
  Future<List<AIFlashcard>> generateFlashcards(String text);
  Future<String> generateMindMap(String text);
  Future<String> translate(String text, String targetLanguage);
  Future<String> fixGrammar(String text);
  Future<String> askQuestion(String context, String question);
}
