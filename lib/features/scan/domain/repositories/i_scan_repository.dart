import 'dart:async';
import '../entities/scan.dart';

abstract class IScanRepository {
  Future<Scan> save(Scan scan);
  Future<Scan?> getById(int id);
  Future<List<Scan>> getRecent(int limit);
  Future<List<Scan>> search(String query);
  Future<void> delete(int id);
  Future<Scan> update(Scan scan);
  Stream<List<Scan>> watchRecent();
}
