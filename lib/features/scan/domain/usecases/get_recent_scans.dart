import 'package:injectable/injectable.dart';
import '../repositories/i_scan_repository.dart';
import '../entities/scan.dart';

@injectable
class GetRecentScans {
  final IScanRepository _repository;
  GetRecentScans(this._repository);

  Future<List<Scan>> call(int limit) => _repository.getRecent(limit);
}
