import 'dart:convert';
import '../../domain/entities/scan.dart';

class ScanMapper {
  static Map<String, dynamic> toDbRow(Scan scan) {
    return {
      'title': scan.title,
      'original_image_path': scan.originalImagePath,
      'enhanced_image_path': scan.enhancedImagePath,
      'ocr_text': scan.ocrText,
      'ocr_language': scan.ocrLanguage,
      'ocr_confidence': scan.ocrConfidence,
      'ai_summary_json': scan.aiSummary != null
          ? jsonEncode({
              'summary': scan.aiSummary!.summary,
              'key_points': scan.aiSummary!.keyPoints,
            })
          : null,
      'ai_action_items_json': scan.aiActionItems != null
          ? jsonEncode(
              scan.aiActionItems!
                  .map((a) => {
                        'task': a.task,
                        'assignee': a.assignee,
                        'priority': a.priority,
                      })
                  .toList())
          : null,
      'ai_flashcards_json': scan.aiFlashcards != null
          ? jsonEncode(
              scan.aiFlashcards!
                  .map((f) => {
                        'question': f.question,
                        'answer': f.answer,
                      })
                  .toList())
          : null,
      'ai_mind_map': scan.aiMindMap,
      'tags_json': jsonEncode(scan.tags),
      'created_at': scan.createdAt.toIso8601String(),
      'updated_at': scan.updatedAt.toIso8601String(),
    };
  }

  static Scan fromDbRow(Map<String, dynamic> row) {
    return Scan(
      id: row['id'] as int?,
      title: row['title'] as String,
      originalImagePath: row['original_image_path'] as String,
      enhancedImagePath: row['enhanced_image_path'] as String?,
      ocrText: row['ocr_text'] as String?,
      ocrLanguage: row['ocr_language'] as String? ?? 'en',
      ocrConfidence: (row['ocr_confidence'] as num?)?.toDouble(),
      aiSummary: _parseSummary(row['ai_summary_json'] as String?),
      aiActionItems: _parseActionItems(row['ai_action_items_json'] as String?),
      aiFlashcards: _parseFlashcards(row['ai_flashcards_json'] as String?),
      aiMindMap: row['ai_mind_map'] as String?,
      tags: _parseTags(row['tags_json'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  static AISummaryData? _parseSummary(String? json) {
    if (json == null) return null;
    final data = jsonDecode(json) as Map<String, dynamic>;
    return AISummaryData(
      summary: data['summary'] as String,
      keyPoints: (data['key_points'] as List?)?.cast<String>(),
    );
  }

  static List<AIActionItemData>? _parseActionItems(String? json) {
    if (json == null) return null;
    final list = jsonDecode(json) as List;
    return list.map((item) {
      final m = item as Map<String, dynamic>;
      return AIActionItemData(
        task: m['task'] as String,
        assignee: m['assignee'] as String?,
        priority: m['priority'] as String? ?? 'Medium',
      );
    }).toList();
  }

  static List<AIFlashcardData>? _parseFlashcards(String? json) {
    if (json == null) return null;
    final list = jsonDecode(json) as List;
    return list.map((item) {
      final m = item as Map<String, dynamic>;
      return AIFlashcardData(
        question: m['question'] as String,
        answer: m['answer'] as String,
      );
    }).toList();
  }

  static List<String> _parseTags(String? json) {
    if (json == null) return [];
    return List<String>.from(jsonDecode(json) as List);
  }
}
