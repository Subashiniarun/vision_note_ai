import 'package:injectable/injectable.dart';
import '../repositories/i_scan_repository.dart';
import '../entities/scan.dart';

@injectable
class SaveScan {
  final IScanRepository _repository;
  SaveScan(this._repository);

  Future<Scan> call(Scan scan) => _repository.save(scan);
}
