import 'package:equatable/equatable.dart';

class Scan extends Equatable {
  final int? id;
  final String title;
  final String originalImagePath;
  final String? enhancedImagePath;
  final String? ocrText;
  final String ocrLanguage;
  final double? ocrConfidence;
  final AISummaryData? aiSummary;
  final List<AIActionItemData>? aiActionItems;
  final List<AIFlashcardData>? aiFlashcards;
  final String? aiMindMap;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Scan({
    this.id,
    this.title = 'Untitled',
    required this.originalImagePath,
    this.enhancedImagePath,
    this.ocrText,
    this.ocrLanguage = 'en',
    this.ocrConfidence,
    this.aiSummary,
    this.aiActionItems,
    this.aiFlashcards,
    this.aiMindMap,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Scan copyWith({
    int? id,
    String? title,
    String? originalImagePath,
    String? enhancedImagePath,
    String? ocrText,
    String? ocrLanguage,
    double? ocrConfidence,
    AISummaryData? aiSummary,
    List<AIActionItemData>? aiActionItems,
    List<AIFlashcardData>? aiFlashcards,
    String? aiMindMap,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearAiSummary = false,
    bool clearActionItems = false,
    bool clearFlashcards = false,
    bool clearMindMap = false,
  }) {
    return Scan(
      id: id ?? this.id,
      title: title ?? this.title,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      enhancedImagePath: enhancedImagePath ?? this.enhancedImagePath,
      ocrText: ocrText ?? this.ocrText,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      aiSummary: clearAiSummary ? null : (aiSummary ?? this.aiSummary),
      aiActionItems:
          clearActionItems ? null : (aiActionItems ?? this.aiActionItems),
      aiFlashcards: clearFlashcards ? null : (aiFlashcards ?? this.aiFlashcards),
      aiMindMap: clearMindMap ? null : (aiMindMap ?? this.aiMindMap),
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        originalImagePath,
        enhancedImagePath,
        ocrText,
        ocrLanguage,
        ocrConfidence,
        aiSummary,
        aiActionItems,
        aiFlashcards,
        aiMindMap,
        tags,
        createdAt,
        updatedAt,
      ];
}

class AISummaryData extends Equatable {
  final String summary;
  final List<String>? keyPoints;

  const AISummaryData({required this.summary, this.keyPoints});

  @override
  List<Object?> get props => [summary, keyPoints];
}

class AIActionItemData extends Equatable {
  final String task;
  final String? assignee;
  final String priority;

  const AIActionItemData({
    required this.task,
    this.assignee,
    this.priority = 'Medium',
  });

  @override
  List<Object?> get props => [task, assignee, priority];
}

class AIFlashcardData extends Equatable {
  final String question;
  final String answer;

  const AIFlashcardData({required this.question, required this.answer});

  @override
  List<Object?> get props => [question, answer];
}
