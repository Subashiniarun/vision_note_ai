import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../domain/entities/scan.dart';
import '../../domain/repositories/i_scan_repository.dart';
import '../datasources/local/scan_local_datasource.dart';

@Injectable(as: IScanRepository)
class ScanRepository implements IScanRepository {
  final ScanLocalDataSource _dataSource;

  ScanRepository(this._dataSource);

  @override
  Future<Scan> save(Scan scan) async {
    final id = _dataSource.insertScan(scan);
    return scan.copyWith(id: id);
  }

  @override
  Future<Scan?> getById(int id) async {
    return _dataSource.getScanById(id);
  }

  @override
  Future<List<Scan>> getRecent(int limit) async {
    return _dataSource.getRecentScans(limit);
  }

  @override
  Future<List<Scan>> search(String query) async {
    return _dataSource.searchByText(query);
  }

  @override
  Future<void> delete(int id) async {
    _dataSource.deleteScan(id);
  }

  @override
  Future<Scan> update(Scan scan) async {
    _dataSource.updateScan(scan);
    return scan;
  }

  @override
  Stream<List<Scan>> watchRecent() {
    return _dataSource.watchRecentScans();
  }
}
