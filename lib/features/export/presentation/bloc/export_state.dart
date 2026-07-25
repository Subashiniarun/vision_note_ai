part of 'export_bloc.dart';

abstract class ExportState extends Equatable {
  const ExportState();
}

class ExportInitial extends ExportState {
  const ExportInitial();
  @override
  List<Object> get props => [];
}

class Exporting extends ExportState {
  final String format;
  const Exporting(this.format);
  @override
  List<Object> get props => [format];
}

class ExportSuccess extends ExportState {
  final String format;
  const ExportSuccess(this.format);
  @override
  List<Object> get props => [format];
}

class CopiedToClipboard extends ExportState {
  const CopiedToClipboard();
  @override
  List<Object> get props => [];
}

class ExportError extends ExportState {
  final String message;
  const ExportError(this.message);
  @override
  List<Object> get props => [message];
}
