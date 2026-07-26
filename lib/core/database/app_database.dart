import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  late final Database _db;

  Database get db => _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'visionnote.db');
    _db = sqlite3.open(path);
    _migrate();
  }

  void _migrate() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL DEFAULT 'Untitled',
        original_image_path TEXT NOT NULL,
        enhanced_image_path TEXT,
        ocr_text TEXT,
        ocr_language TEXT DEFAULT 'en',
        ocr_confidence REAL,
        ai_summary_json TEXT,
        ai_action_items_json TEXT,
        ai_flashcards_json TEXT,
        ai_mind_map TEXT,
        tags_json TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scan_id INTEGER NOT NULL REFERENCES scans(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        UNIQUE(scan_id, name)
      )
    ''');

    _db.execute('''
      CREATE INDEX IF NOT EXISTS idx_scans_created_at ON scans(created_at DESC)
    ''');

    _db.execute('''
      CREATE INDEX IF NOT EXISTS idx_tags_scan_id ON tags(scan_id)
    ''');

    _db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS scans_fts USING fts5(
        title, ocr_text, tags_json, content='scans', content_rowid='id'
      )
    ''');

    _createTriggers();
  }

  void _createTriggers() {
    _db.execute('''
      CREATE TRIGGER IF NOT EXISTS scans_ai AFTER INSERT ON scans BEGIN
        INSERT INTO scans_fts(rowid, title, ocr_text, tags_json)
        VALUES (new.id, new.title, new.ocr_text, new.tags_json);
      END
    ''');

    _db.execute('''
      CREATE TRIGGER IF NOT EXISTS scans_ad AFTER DELETE ON scans BEGIN
        INSERT INTO scans_fts(scans_fts, rowid, title, ocr_text, tags_json)
        VALUES ('delete', old.id, old.title, old.ocr_text, old.tags_json);
      END
    ''');

    _db.execute('''
      CREATE TRIGGER IF NOT EXISTS scans_au AFTER UPDATE ON scans BEGIN
        INSERT INTO scans_fts(scans_fts, rowid, title, ocr_text, tags_json)
        VALUES ('delete', old.id, old.title, old.ocr_text, old.tags_json);
        INSERT INTO scans_fts(rowid, title, ocr_text, tags_json)
        VALUES (new.id, new.title, new.ocr_text, new.tags_json);
      END
    ''');
  }

  void close() {
    _db.dispose();
  }
}
