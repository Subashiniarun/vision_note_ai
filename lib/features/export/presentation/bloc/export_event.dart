part of 'export_bloc.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();
}

class SetExportScan extends ExportEvent {
  final Scan scan;
  const SetExportScan(this.scan);
  @override
  List<Object> get props => [scan];
}

class ExportMarkdown extends ExportEvent {
  const ExportMarkdown();
  @override
  List<Object> get props => [];
}

class ExportTXT extends ExportEvent {
  const ExportTXT();
  @override
  List<Object> get props => [];
}

class ExportPDF extends ExportEvent {
  const ExportPDF();
  @override
  List<Object> get props => [];
}

class ExportJSON extends ExportEvent {
  const ExportJSON();
  @override
  List<Object> get props => [];
}

class CopyToClipboard extends ExportEvent {
  const CopyToClipboard();
  @override
  List<Object> get props => [];
}

class SetIncludeAI extends ExportEvent {
  final bool include;
  const SetIncludeAI(this.include);
  @override
  List<Object> get props => [include];
}
