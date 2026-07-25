part of 'scan_bloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();
}

class LoadRecentScans extends ScanEvent {
  final int limit;
  const LoadRecentScans([this.limit = 10]);
  @override
  List<Object> get props => [limit];
}

class SaveScanRequest extends ScanEvent {
  final Scan scan;
  const SaveScanRequest(this.scan);
  @override
  List<Object> get props => [scan];
}

class DeleteScanRequest extends ScanEvent {
  final int id;
  const DeleteScanRequest(this.id);
  @override
  List<Object> get props => [id];
}

class SearchScanRequest extends ScanEvent {
  final String query;
  const SearchScanRequest(this.query);
  @override
  List<Object> get props => [query];
}
