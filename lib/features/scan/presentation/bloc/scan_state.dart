part of 'scan_bloc.dart';

abstract class ScanState extends Equatable {
  const ScanState();
}

class ScanInitial extends ScanState {
  const ScanInitial();
  @override
  List<Object> get props => [];
}

class ScanLoading extends ScanState {
  const ScanLoading();
  @override
  List<Object> get props => [];
}

class ScanLoaded extends ScanState {
  final List<Scan> scans;
  const ScanLoaded(this.scans);
  @override
  List<Object> get props => [scans];
}

class ScanSearchResults extends ScanState {
  final List<Scan> scans;
  final String query;
  const ScanSearchResults(this.scans, this.query);
  @override
  List<Object> get props => [scans, query];
}

class ScanSaved extends ScanState {
  final Scan scan;
  const ScanSaved(this.scan);
  @override
  List<Object> get props => [scan];
}

class ScanError extends ScanState {
  final String message;
  const ScanError(this.message);
  @override
  List<Object> get props => [message];
}
