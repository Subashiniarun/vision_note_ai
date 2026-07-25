part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
  @override
  List<Object> get props => [];
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
  @override
  List<Object> get props => [];
}

class HistoryLoaded extends HistoryState {
  final List<Scan> scans;
  const HistoryLoaded(this.scans);
  @override
  List<Object> get props => [scans];
}

class HistorySearchResults extends HistoryState {
  final List<Scan> scans;
  final String query;
  const HistorySearchResults(this.scans, this.query);
  @override
  List<Object> get props => [scans, query];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object> get props => [message];
}
