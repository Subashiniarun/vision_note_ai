import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';
import '../../../scan/domain/entities/scan.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/repositories/i_export_repository.dart';

part 'export_event.dart';
part 'export_state.dart';

@injectable
class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final IExportRepository _exportRepository;

  ExportBloc(this._exportRepository) : super(ExportInitial()) {
    on<SetExportScan>(_onSetScan);
    on<ExportMarkdown>(_onExportMarkdown);
    on<ExportTXT>(_onExportTXT);
    on<ExportPDF>(_onExportPDF);
    on<ExportJSON>(_onExportJSON);
    on<CopyToClipboard>(_onCopyToClipboard);
    on<SetIncludeAI>(_onSetIncludeAI);
  }

  Scan? _scan;
  bool _includeAI = true;

  void _onSetScan(SetExportScan event, Emitter<ExportState> emit) {
    _scan = event.scan;
  }

  Future<void> _onExportMarkdown(
    ExportMarkdown event,
    Emitter<ExportState> emit,
  ) async {
    if (_scan == null) return;
    emit(Exporting('Markdown'));
    try {
      final path = await _exportRepository.exportMarkdown(_scan!, _includeAI);
      await Share.shareXFiles([XFile(path)], text: '${_scan!.title}.md');
      emit(ExportSuccess('Markdown'));
    } catch (e) {
      emit(ExportError(e.toString()));
    }
  }

  Future<void> _onExportTXT(
    ExportTXT event,
    Emitter<ExportState> emit,
  ) async {
    if (_scan == null) return;
    emit(Exporting('TXT'));
    try {
      final path = await _exportRepository.exportPlainText(_scan!, _includeAI);
      await Share.shareXFiles([XFile(path)], text: '${_scan!.title}.txt');
      emit(ExportSuccess('TXT'));
    } catch (e) {
      emit(ExportError(e.toString()));
    }
  }

  Future<void> _onExportPDF(
    ExportPDF event,
    Emitter<ExportState> emit,
  ) async {
    if (_scan == null) return;
    emit(Exporting('PDF'));
    try {
      final path = await _exportRepository.exportPdf(_scan!, _includeAI);
      await Share.shareXFiles([XFile(path)], text: '${_scan!.title}.pdf');
      emit(ExportSuccess('PDF'));
    } catch (e) {
      emit(ExportError(e.toString()));
    }
  }

  Future<void> _onExportJSON(
    ExportJSON event,
    Emitter<ExportState> emit,
  ) async {
    if (_scan == null) return;
    emit(Exporting('JSON'));
    try {
      final path = await _exportRepository.exportJson(_scan!, _includeAI);
      await Share.shareXFiles([XFile(path)], text: '${_scan!.title}.json');
      emit(ExportSuccess('JSON'));
    } catch (e) {
      emit(ExportError(e.toString()));
    }
  }

  Future<void> _onCopyToClipboard(
    CopyToClipboard event,
    Emitter<ExportState> emit,
  ) async {
    if (_scan?.ocrText == null) return;
    try {
      await _exportRepository.copyToClipboard(_scan!.ocrText!);
      emit(CopiedToClipboard());
    } catch (e) {
      emit(ExportError(e.toString()));
    }
  }

  void _onSetIncludeAI(
    SetIncludeAI event,
    Emitter<ExportState> emit,
  ) {
    _includeAI = event.include;
  }
}
