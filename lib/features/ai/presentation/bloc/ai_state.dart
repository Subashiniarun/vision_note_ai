part of 'ai_bloc.dart';

abstract class AIState extends Equatable {
  const AIState();
}

class AIInitial extends AIState {
  const AIInitial();
  @override
  List<Object> get props => [];
}

class AITextReady extends AIState {
  final String text;
  const AITextReady(this.text);
  @override
  List<Object> get props => [text];
}

class AILoading extends AIState {
  final String message;
  const AILoading(this.message);
  @override
  List<Object> get props => [message];
}

class AISummaryReady extends AIState {
  final AISummary summary;
  const AISummaryReady(this.summary);
  @override
  List<Object> get props => [summary];
}

class AIActionItemsReady extends AIState {
  final List<AIActionItem> items;
  const AIActionItemsReady(this.items);
  @override
  List<Object> get props => [items];
}

class AIFlashcardsReady extends AIState {
  final List<AIFlashcard> flashcards;
  const AIFlashcardsReady(this.flashcards);
  @override
  List<Object> get props => [flashcards];
}

class AIMindMapReady extends AIState {
  final String mermaidCode;
  const AIMindMapReady(this.mermaidCode);
  @override
  List<Object> get props => [mermaidCode];
}

class AITranslationReady extends AIState {
  final String translatedText;
  const AITranslationReady(this.translatedText);
  @override
  List<Object> get props => [translatedText];
}

class AIGrammarFixed extends AIState {
  final String correctedText;
  const AIGrammarFixed(this.correctedText);
  @override
  List<Object> get props => [correctedText];
}

class ChatActive extends AIState {
  final List<ChatMessage> messages;
  const ChatActive(this.messages);
  @override
  List<Object> get props => [messages];
}

class AIError extends AIState {
  final String message;
  const AIError(this.message);
  @override
  List<Object> get props => [message];
}
