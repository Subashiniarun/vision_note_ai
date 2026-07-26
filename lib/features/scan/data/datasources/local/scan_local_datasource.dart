import 'package:injectable/injectable.dart';
import '../../../../../core/database/app_database.dart';
import '../../models/scan_mapper.dart';
import '../../../domain/entities/scan.dart';

@Injectable()
class ScanLocalDataSource {
  final AppDatabase _appDatabase;

  ScanLocalDataSource(this._appDatabase);

  int insertScan(Scan scan) {
    final row = ScanMapper.toDbRow(scan);
    final stmt = _appDatabase.db.execute('''
      INSERT INTO scans (title, original_image_path, enhanced_image_path,
        ocr_text, ocr_language, ocr_confidence, ai_summary_json,
        ai_action_items_json, ai_flashcards_json, ai_mind_map,
        tags_json, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      row['title'],
      row['original_image_path'],
      row['enhanced_image_path'],
      row['ocr_text'],
      row['ocr_language'],
      row['ocr_confidence'],
      row['ai_summary_json'],
      row['ai_action_items_json'],
      row['ai_flashcards_json'],
      row['ai_mind_map'],
      row['tags_json'],
      row['created_at'],
      row['updated_at'],
    ]);
    return _appDatabase.db.lastInsertRowId;
  }

  Scan? getScanById(int id) {
    final result = _appDatabase.db.select('SELECT * FROM scans WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    return ScanMapper.fromDbRow(result.first);
  }

  List<Scan> getRecentScans(int limit) {
    final result = _appDatabase.db.select(
      'SELECT * FROM scans ORDER BY created_at DESC LIMIT ?',
      [limit],
    );
    return result.map((r) => ScanMapper.fromDbRow(r)).toList();
  }

  List<Scan> searchByText(String query) {
    final result = _appDatabase.db.select(
      'SELECT s.* FROM scans s JOIN scans_fts f ON s.id = f.rowid '
      'WHERE scans_fts MATCH ? ORDER BY rank',
      [query],
    );
    return result.map((r) => ScanMapper.fromDbRow(r)).toList();
  }

  void updateScan(Scan scan) {
    final row = ScanMapper.toDbRow(scan);
    _appDatabase.db.execute('''
      UPDATE scans SET title=?, enhanced_image_path=?, ocr_text=?,
        ocr_confidence=?, ai_summary_json=?, ai_action_items_json=?,
        ai_flashcards_json=?, ai_mind_map=?, tags_json=?, updated_at=?
      WHERE id=?
    ''', [
      row['title'],
      row['enhanced_image_path'],
      row['ocr_text'],
      row['ocr_confidence'],
      row['ai_summary_json'],
      row['ai_action_items_json'],
      row['ai_flashcards_json'],
      row['ai_mind_map'],
      row['tags_json'],
      row['updated_at'],
      scan.id,
    ]);
  }

  void deleteScan(int id) {
    _appDatabase.db.execute('DELETE FROM scans WHERE id = ?', [id]);
  }

  Stream<List<Scan>> watchRecentScans() {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getRecentScans(50);
    });
  }
}
