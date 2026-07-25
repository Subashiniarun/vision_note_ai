import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../scan/domain/entities/scan.dart';
import '../../../scan/domain/usecases/get_recent_scans.dart';
import '../../../scan/domain/usecases/delete_scan.dart';
import '../../../scan/domain/usecases/search_scans.dart';
import '../../../scan/domain/usecases/save_scan.dart';

part 'history_event.dart';
part 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetRecentScans _getRecentScans;
  final DeleteScan _deleteScan;
  final SearchScans _searchScans;
  final SaveScan _saveScan;

  HistoryBloc(
    this._getRecentScans,
    this._deleteScan,
    this._searchScans,
    this._saveScan,
  ) : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SearchHistoryRequest>(_onSearch);
    on<DeleteScanById>(_onDelete);
    on<ClearAllHistory>(_onClearAll);
    on<AddTagToScan>(_onAddTag);
    on<RemoveTagFromScan>(_onRemoveTag);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final scans = await _getRecentScans(50);
      emit(HistoryLoaded(scans));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onSearch(
    SearchHistoryRequest event,
    Emitter<HistoryState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadHistory());
      return;
    }
    try {
      final results = await _searchScans(event.query);
      emit(HistorySearchResults(results, event.query));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteScanById event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _deleteScan(event.id);
      add(const LoadHistory());
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onClearAll(
    ClearAllHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final current = state;
      if (current is HistoryLoaded) {
        for (final scan in current.scans) {
          if (scan.id != null) await _deleteScan(scan.id!);
        }
      }
      emit(const HistoryLoaded([]));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onAddTag(
    AddTagToScan event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final current = state;
      if (current is HistoryLoaded) {
        final idx = current.scans.indexWhere((s) => s.id == event.scanId);
        if (idx >= 0) {
          final scan = current.scans[idx];
          final newTags = List<String>.from(scan.tags)..add(event.tag);
          await _saveScan(scan.copyWith(tags: newTags));
          add(const LoadHistory());
        }
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onRemoveTag(
    RemoveTagFromScan event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final current = state;
      if (current is HistoryLoaded) {
        final idx = current.scans.indexWhere((s) => s.id == event.scanId);
        if (idx >= 0) {
          final scan = current.scans[idx];
          final newTags = List<String>.from(scan.tags)..remove(event.tag);
          await _saveScan(scan.copyWith(tags: newTags));
          add(const LoadHistory());
        }
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
