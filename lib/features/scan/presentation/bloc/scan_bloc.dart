import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/scan.dart';
import '../../domain/usecases/get_recent_scans.dart';
import '../../domain/usecases/save_scan.dart';
import '../../domain/usecases/delete_scan.dart';
import '../../domain/usecases/search_scans.dart';

part 'scan_event.dart';
part 'scan_state.dart';

@injectable
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final GetRecentScans _getRecentScans;
  final SaveScan _saveScan;
  final DeleteScan _deleteScan;
  final SearchScans _searchScans;

  ScanBloc(
    this._getRecentScans,
    this._saveScan,
    this._deleteScan,
    this._searchScans,
  ) : super(ScanInitial()) {
    on<LoadRecentScans>(_onLoadRecentScans);
    on<SaveScanRequest>(_onSaveScan);
    on<DeleteScanRequest>(_onDeleteScan);
    on<SearchScanRequest>(_onSearch);
  }

  Future<void> _onLoadRecentScans(
    LoadRecentScans event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      final scans = await _getRecentScans(event.limit);
      emit(ScanLoaded(scans));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onSaveScan(
    SaveScanRequest event,
    Emitter<ScanState> emit,
  ) async {
    try {
      final saved = await _saveScan(event.scan);
      emit(ScanSaved(saved));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onDeleteScan(
    DeleteScanRequest event,
    Emitter<ScanState> emit,
  ) async {
    try {
      await _deleteScan(event.id);
      add(const LoadRecentScans(10));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onSearch(
    SearchScanRequest event,
    Emitter<ScanState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadRecentScans(10));
      return;
    }
    try {
      final results = await _searchScans(event.query);
      emit(ScanSearchResults(results, event.query));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }
}
