import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/file_storage.dart';
import '../../../scan/domain/entities/scan.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/repositories/i_export_repository.dart';

@Injectable(as: IExportRepository)
class ExportRepository implements IExportRepository {
  final FileStorage _fileStorage;

  ExportRepository(this._fileStorage);

  @override
  Future<String> exportMarkdown(Scan scan, bool includeAI) async {
    final content = _buildMarkdown(scan, includeAI);
    final fileName =
        '${scan.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.md';
    return await _fileStorage.exportToFile(content, fileName);
  }

  @override
  Future<String> exportPlainText(Scan scan, bool includeAI) async {
    final content = _buildPlainText(scan, includeAI);
    final fileName =
        '${scan.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt';
    return await _fileStorage.exportToFile(content, fileName);
  }

  @override
  Future<String> exportPdf(Scan scan, bool includeAI) async {
    final content = _buildPlainText(scan, includeAI);
    final fileName =
        '${scan.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt';
    return await _fileStorage.exportToFile(content, fileName);
  }

  @override
  Future<String> exportJson(Scan scan, bool includeAI) async {
    final data = _buildJson(scan, includeAI);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final fileName =
        '${scan.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.json';
    return await _fileStorage.exportToFile(jsonStr, fileName);
  }

  @override
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  String _buildMarkdown(Scan scan, bool includeAI) {
    final buffer = StringBuffer();
    buffer.writeln('# ${scan.title}');
    buffer.writeln();
    buffer.writeln('*Scanned on: ${_formatDate(scan.createdAt)}*');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    if (scan.ocrText != null && scan.ocrText!.isNotEmpty) {
      buffer.writeln(scan.ocrText);
      buffer.writeln();
    }

    if (includeAI && scan.aiSummary != null) {
      buffer.writeln('## AI Summary');
      buffer.writeln();
      buffer.writeln(scan.aiSummary!.summary);
      buffer.writeln();
    }

    if (includeAI &&
        scan.aiActionItems != null &&
        scan.aiActionItems!.isNotEmpty) {
      buffer.writeln('## Action Items');
      buffer.writeln();
      buffer.writeln('| Task | Assignee | Priority |');
      buffer.writeln('|------|----------|----------|');
      for (final item in scan.aiActionItems!) {
        buffer.writeln(
            '| ${item.task} | ${item.assignee ?? "Unassigned"} | ${item.priority} |');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _buildPlainText(Scan scan, bool includeAI) {
    final buffer = StringBuffer();
    buffer.writeln(scan.title);
    buffer.writeln('='.padRight(scan.title.length, '='));
    buffer.writeln('Scanned on: ${_formatDate(scan.createdAt)}');
    buffer.writeln();

    if (scan.ocrText != null && scan.ocrText!.isNotEmpty) {
      buffer.writeln(scan.ocrText);
      buffer.writeln();
    }

    if (includeAI && scan.aiSummary != null) {
      buffer.writeln('AI Summary:');
      buffer.writeln(scan.aiSummary!.summary);
      buffer.writeln();
    }

    return buffer.toString();
  }

  Map<String, dynamic> _buildJson(Scan scan, bool includeAI) {
    return {
      'title': scan.title,
      'scanned_at': scan.createdAt.toIso8601String(),
      'ocr_language': scan.ocrLanguage,
      'ocr_text': scan.ocrText,
      if (includeAI && scan.aiSummary != null)
        'ai_summary': {
          'summary': scan.aiSummary!.summary,
          'key_points': scan.aiSummary!.keyPoints,
        },
      if (includeAI && scan.aiActionItems != null)
        'action_items': scan.aiActionItems!
            .map((a) => {
                  'task': a.task,
                  'assignee': a.assignee,
                  'priority': a.priority,
                })
            .toList(),
      if (includeAI && scan.aiFlashcards != null)
        'flashcards': scan.aiFlashcards!
            .map((f) => {'question': f.question, 'answer': f.answer})
            .toList(),
      'tags': scan.tags,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
