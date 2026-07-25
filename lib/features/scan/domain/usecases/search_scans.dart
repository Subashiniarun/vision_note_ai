import 'package:injectable/injectable.dart';
import '../repositories/i_scan_repository.dart';
import '../entities/scan.dart';

@injectable
class SearchScans {
  final IScanRepository _repository;
  SearchScans(this._repository);

  Future<List<Scan>> call(String query) => _repository.search(query);
}
