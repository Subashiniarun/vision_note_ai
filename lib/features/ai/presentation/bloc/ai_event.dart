part of 'ai_bloc.dart';

abstract class AIEvent extends Equatable {
  const AIEvent();
}

class SetAIText extends AIEvent {
  final String text;
  const SetAIText(this.text);
  @override
  List<Object> get props => [text];
}

class GenerateSummary extends AIEvent {
  const GenerateSummary();
  @override
  List<Object> get props => [];
}

class GenerateActionItems extends AIEvent {
  const GenerateActionItems();
  @override
  List<Object> get props => [];
}

class GenerateFlashcards extends AIEvent {
  const GenerateFlashcards();
  @override
  List<Object> get props => [];
}

class GenerateMindMap extends AIEvent {
  const GenerateMindMap();
  @override
  List<Object> get props => [];
}

class TranslateText extends AIEvent {
  final String targetLanguage;
  const TranslateText(this.targetLanguage);
  @override
  List<Object> get props => [targetLanguage];
}

class FixGrammar extends AIEvent {
  const FixGrammar();
  @override
  List<Object> get props => [];
}

class AskAIQuestion extends AIEvent {
  final String question;
  const AskAIQuestion(this.question);
  @override
  List<Object> get props => [question];
}

class ClearChat extends AIEvent {
  const ClearChat();
  @override
  List<Object> get props => [];
}
