import 'package:injectable/injectable.dart';
import '../repositories/i_scan_repository.dart';

@injectable
class DeleteScan {
  final IScanRepository _repository;
  DeleteScan(this._repository);

  Future<void> call(int id) => _repository.delete(id);
}
