import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ai_models.dart';
import '../../domain/repositories/i_ai_repository.dart';

part 'ai_event.dart';
part 'ai_state.dart';

@injectable
class AIBloc extends Bloc<AIEvent, AIState> {
  final IAIRepository _aiRepository;

  AIBloc(this._aiRepository) : super(AIInitial()) {
    on<SetAIText>(_onSetText);
    on<GenerateSummary>(_onGenerateSummary);
    on<GenerateActionItems>(_onGenerateActionItems);
    on<GenerateFlashcards>(_onGenerateFlashcards);
    on<GenerateMindMap>(_onGenerateMindMap);
    on<TranslateText>(_onTranslate);
    on<FixGrammar>(_onFixGrammar);
    on<AskAIQuestion>(_onAskQuestion);
    on<ClearChat>(_onClearChat);
  }

  String _text = '';

  void _onSetText(SetAIText event, Emitter<AIState> emit) {
    _text = event.text;
    emit(AITextReady(_text));
  }

  Future<void> _onGenerateSummary(
    GenerateSummary event,
    Emitter<AIState> emit,
  ) async {
    emit(AILoading('Generating summary...'));
    try {
      final summary = await _aiRepository.generateSummary(_text);
      emit(AISummaryReady(summary));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }

  Future<void> _onGenerateActionItems(
    GenerateActionItems event,
    Emitter<AIState> emit,
  ) async {
    emit(AILoading('Extracting action items...'));
    try {
      final items = await _aiRepository.generateActionItems(_text);
      emit(AIActionItemsReady(items));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }

  Future<void> _onGenerateFlashcards(
    GenerateFlashcards event,
    Emitter<AIState> emit,
  ) async {
    emit(AILoading('Generating flashcards...'));
    try {
      final flashcards = await _aiRepository.generateFlashcards(_text);
      emit(AIFlashcardsReady(flashcards));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }

  Future<void> _onGenerateMindMap(
    GenerateMindMap event,
    Emitter<AIState> emit,
  ) async {
    emit(AILoading('Generating mind map...'));
    try {
      final mindMap = await _aiRepository.generateMindMap(_text);
      emit(AIMindMapReady(mindMap));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }

  Future<void> _onTranslate(
    TranslateText event,
    Emitter<AIState> emit,
  ) async {
    emit(AILoading('Translating...'));
    try {
      final result =
          await _aiRepository.translate(_text, event.targetLanguage);
      emit(AITranslationReady(result));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }

  Future<void> _onFixGrammar(
    FixGrammar event,
    Emitter<AIState> emit,
  ) async {
    emit(AILoading('Fixing grammar...'));
    try {
      final result = await _aiRepository.fixGrammar(_text);
      emit(AIGrammarFixed(result));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }

  Future<void> _onAskQuestion(
    AskAIQuestion event,
    Emitter<AIState> emit,
  ) async {
    final current = state;
    final messages = current is ChatActive
        ? List<ChatMessage>.from(current.messages)
        : <ChatMessage>[];

    messages.add(ChatMessage(role: 'user', content: event.question));
    emit(ChatActive(messages));

    try {
      final answer = await _aiRepository.askQuestion(_text, event.question);
      messages.add(ChatMessage(role: 'ai', content: answer));
      emit(ChatActive(List.from(messages)));
    } catch (e) {
      messages.add(ChatMessage(role: 'ai', content: 'Error: ${e.toString()}'));
      emit(ChatActive(List.from(messages)));
    }
  }

  void _onClearChat(ClearChat event, Emitter<AIState> emit) {
    emit(AITextReady(_text));
  }
}
