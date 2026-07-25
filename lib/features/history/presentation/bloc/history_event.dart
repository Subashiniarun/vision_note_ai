part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
}

class LoadHistory extends HistoryEvent {
  const LoadHistory();
  @override
  List<Object> get props => [];
}

class SearchHistoryRequest extends HistoryEvent {
  final String query;
  const SearchHistoryRequest(this.query);
  @override
  List<Object> get props => [query];
}

class DeleteScanById extends HistoryEvent {
  final int id;
  const DeleteScanById(this.id);
  @override
  List<Object> get props => [id];
}

class ClearAllHistory extends HistoryEvent {
  const ClearAllHistory();
  @override
  List<Object> get props => [];
}

class AddTagToScan extends HistoryEvent {
  final int scanId;
  final String tag;
  const AddTagToScan(this.scanId, this.tag);
  @override
  List<Object> get props => [scanId, tag];
}

class RemoveTagFromScan extends HistoryEvent {
  final int scanId;
  final String tag;
  const RemoveTagFromScan(this.scanId, this.tag);
  @override
  List<Object> get props => [scanId, tag];
}
