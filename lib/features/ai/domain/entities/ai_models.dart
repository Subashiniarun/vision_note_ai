import 'package:equatable/equatable.dart';
import '../../../scan/domain/entities/scan.dart';

class AISummary extends Equatable {
  final String summary;
  final List<String>? keyPoints;

  const AISummary({required this.summary, this.keyPoints});

  AISummaryData toData() =>
      AISummaryData(summary: summary, keyPoints: keyPoints);

  @override
  List<Object?> get props => [summary, keyPoints];
}

class AIActionItem extends Equatable {
  final String task;
  final String? assignee;
  final String priority;

  const AIActionItem({
    required this.task,
    this.assignee,
    this.priority = 'Medium',
  });

  AIActionItemData toData() =>
      AIActionItemData(task: task, assignee: assignee, priority: priority);

  @override
  List<Object?> get props => [task, assignee, priority];
}

class AIFlashcard extends Equatable {
  final String question;
  final String answer;

  const AIFlashcard({required this.question, required this.answer});

  AIFlashcardData toData() =>
      AIFlashcardData(question: question, answer: answer);

  @override
  List<Object?> get props => [question, answer];
}

class ChatMessage extends Equatable {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
  bool get isAI => role == 'ai';

  @override
  List<Object?> get props => [role, content, timestamp];
}
