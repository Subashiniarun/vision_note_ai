import '../../../scan/domain/entities/scan.dart';
import '../entities/export_options.dart';

abstract class IExportRepository {
  Future<String> exportMarkdown(Scan scan, bool includeAI);
  Future<String> exportPlainText(Scan scan, bool includeAI);
  Future<String> exportPdf(Scan scan, bool includeAI);
  Future<String> exportJson(Scan scan, bool includeAI);
  Future<void> copyToClipboard(String text);
}
