import 'package:equatable/equatable.dart';

class ExportOptions extends Equatable {
  final bool markdown;
  final bool plainText;
  final bool pdf;
  final bool json;
  final bool copyToClipboard;
  final bool includeAI;

  const ExportOptions({
    this.markdown = false,
    this.plainText = false,
    this.pdf = false,
    this.json = false,
    this.copyToClipboard = false,
    this.includeAI = true,
  });

  bool get any => markdown || plainText || pdf || json || copyToClipboard;

  ExportOptions copyWith({
    bool? markdown,
    bool? plainText,
    bool? pdf,
    bool? json,
    bool? copyToClipboard,
    bool? includeAI,
  }) {
    return ExportOptions(
      markdown: markdown ?? this.markdown,
      plainText: plainText ?? this.plainText,
      pdf: pdf ?? this.pdf,
      json: json ?? this.json,
      copyToClipboard: copyToClipboard ?? this.copyToClipboard,
      includeAI: includeAI ?? this.includeAI,
    );
  }

  @override
  List<Object?> get props =>
      [markdown, plainText, pdf, json, copyToClipboard, includeAI];
}

enum ExportFormat {
  markdown('md', 'text/markdown'),
  txt('txt', 'text/plain'),
  pdf('pdf', 'application/pdf'),
  json('json', 'application/json');

  final String extension;
  final String mimeType;
  const ExportFormat(this.extension, this.mimeType);
}
