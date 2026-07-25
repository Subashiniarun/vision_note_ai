# VisionNote AI — Local Database Design

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. Storage Strategy Overview

| Data Type | Storage | Rationale |
|---|---|---|
| Scans (structured metadata) | Drift (SQLite) | Relational, queryable, supports FTS5 search |
| Settings & cache | Hive | Extremely fast key-value, < 1ms reads |
| API keys & secrets | flutter_secure_storage | Encrypted at rest |
| Images (original + processed) | File system | Binary blobs don't belong in DB; referenced by path |
| AI results (cached) | Drift (JSON columns) | Always associated with a scan |

---

## 2. Drift Database Schema

### 2.1 Tables

```dart
// lib/core/database/tables/scans.dart
import 'package:drift/drift.dart';

class Scans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Untitled'))();
  TextColumn get originalImagePath => text()();
  TextColumn? get enhancedImagePath => text().nullable()();
  TextColumn? get ocrText => text().nullable()();
  TextColumn get ocrLanguage => text().withDefault(const Constant('en'))();
  RealColumn? get ocrConfidence => real().nullable()();
  TextColumn? get aiSummaryJson => text().nullable()();
  TextColumn? get aiActionItemsJson => text().nullable()();
  TextColumn? get aiFlashcardsJson => text().nullable()();
  TextColumn? get aiMindMap => text().nullable()();
  TextColumn? get tagsJson => text().nullable()();
  TextColumn get createdAt => text()(); // ISO 8601
  TextColumn get updatedAt => text()(); // ISO 8601

  @override
  Set<Column> get primaryKey => {id};
}
```

```dart
// lib/core/database/tables/tags.dart
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scanId => integer().references(Scans, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'UNIQUE(scan_id, name)',
  ];
}
```

### 2.2 Database Class

```dart
// lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables/scans.dart';
import 'tables/tags.dart';
import 'daos/scans_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Scans, Tags], daos: [ScansDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();

        // Create FTS5 virtual table for full-text search
        await customStatement('''
          CREATE VIRTUAL TABLE IF NOT EXISTS scans_fts USING fts5(
            title, ocr_text, tags_json,
            content='scans',
            content_rowid='id'
          )
        ''');

        // Triggers to keep FTS index in sync
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS scans_ai AFTER INSERT ON scans BEGIN
            INSERT INTO scans_fts(rowid, title, ocr_text, tags_json)
            VALUES (new.id, new.title, new.ocr_text, new.tags_json);
          END
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS scans_ad AFTER DELETE ON scans BEGIN
            INSERT INTO scans_fts(scans_fts, rowid, title, ocr_text, tags_json)
            VALUES ('delete', old.id, old.title, old.ocr_text, old.tags_json);
          END
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS scans_au AFTER UPDATE ON scans BEGIN
            INSERT INTO scans_fts(scans_fts, rowid, title, ocr_text, tags_json)
            VALUES ('delete', old.id, old.title, old.ocr_text, old.tags_json);
            INSERT INTO scans_fts(rowid, title, ocr_text, tags_json)
            VALUES (new.id, new.title, new.ocr_text, new.tags_json);
          END
        ''');
      },
      onUpgrade: (m, from, to) async {
        // Handle future migrations
      },
    );
  }
}
```

### 2.3 Data Access Object

```dart
// lib/core/database/daos/scans_dao.dart
@DriftAccessor(tables: [Scans, Tags])
class ScansDao extends DatabaseAccessor<AppDatabase> {
  ScansDao(AppDatabase db) : super(db);

  Future<int> insertScan(ScansCompanion scan) {
    return into(scans).insert(scan);
  }

  Future<Scan?> getScanById(int id) {
    return (select(scans)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<List<Scan>> getRecentScans(int limit) {
    return (select(scans)
      ..orderBy([(s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc)])
      ..limit(limit)
    ).get();
  }

  Future<List<Scan>> searchByText(String query) {
    return customSelect(
      'SELECT * FROM scans_fts WHERE scans_fts MATCH ?',
      variables: [StringVariable(query)],
      readsFrom: {scans},
    ).get().then((rows) => rows.map((r) => r.data).map(ScanMapper.fromDbRow).toList());
  }

  Future<List<Scan>> getScansByTag(String tagName) {
    return (select(scans)
      ..where((s) => s.tagsJson.like('%$tagName%'))
      ..orderBy([(s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc)])
    ).get();
  }

  Future<int> updateScan(Scan scan) {
    return (update(scans)..where((s) => s.id.equals(scan.id!)))
      .write(ScansCompanion(
        title: Value(scan.title),
        enhancedImagePath: Value(scan.enhancedImagePath),
        ocrText: Value(scan.ocrText),
        ocrConfidence: Value(scan.ocrConfidence),
        aiSummaryJson: Value(scan.aiSummaryJson),
        aiActionItemsJson: Value(scan.aiActionItemsJson),
        aiFlashcardsJson: Value(scan.aiFlashcardsJson),
        aiMindMap: Value(scan.aiMindMap),
        tagsJson: Value(scan.tagsJson),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ));
  }

  Future<int> deleteScan(int id) {
    return (delete(scans)..where((s) => s.id.equals(id))).go();
  }

  Stream<List<Scan>> watchRecentScans() {
    return (select(scans)
      ..orderBy([(s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc)])
    ).watch().map((rows) => rows.map((r) => r as Scan).toList());
  }
}
```

---

## 3. Hive Settings Schema

```dart
// lib/core/settings/settings_cache.dart
@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  String themeMode; // 'system', 'light', 'dark'

  @HiveField(1)
  String ocrLanguage; // ISO code, default 'en'

  @HiveField(2)
  String aiProvider; // 'gemini' or 'openai'

  @HiveField(3)
  String aiModel; // model name

  @HiveField(4)
  int imageQuality; // 1-100, default 90

  @HiveField(5)
  bool compressionEnabled; // default true

  @HiveField(6)
  String defaultExportFormat; // 'markdown', 'txt', 'pdf', 'json'

  @HiveField(7)
  bool autoCapture; // default true

  @HiveField(8)
  bool autoEnhance; // default true

  @HiveField(9)
  bool useJsonMode; // AI response format, default false

  @HiveField(10)
  bool onboardingComplete; // default false

  @HiveField(11)
  int recentScanCount; // default 10
}
```

---

## 4. Secure Storage

```dart
// lib/core/secure_storage/secure_storage_service.dart
class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const _geminiKeyKey = 'gemini_api_key';
  static const _openaiKeyKey = 'openai_api_key';

  SecureStorageService(this._storage);

  Future<void> saveGeminiKey(String key) =>
      _storage.write(key: _geminiKeyKey, value: key);

  Future<String?> getGeminiKey() =>
      _storage.read(key: _geminiKeyKey);

  Future<void> saveOpenAIKey(String key) =>
      _storage.write(key: _openaiKeyKey, value: key);

  Future<String?> getOpenAIKey() =>
      _storage.read(key: _openaiKeyKey);

  Future<void> clearAllKeys() async {
    await _storage.delete(key: _geminiKeyKey);
    await _storage.delete(key: _openaiKeyKey);
  }
}
```

---

## 5. File System Storage

```dart
// lib/core/storage/file_storage.dart
class FileStorage {
  Directory get _appDir => getApplicationDocumentsDirectory() as Directory;

  Future<String> saveOriginalImage(Uint8List bytes, String scanId) async {
    final dir = Directory('${_appDir.path}/scans/$scanId/original');
    await dir.create(recursive: true);
    final file = File('${dir.path}/original.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> saveEnhancedImage(Uint8List bytes, String scanId) async {
    final dir = Directory('${_appDir.path}/scans/$scanId/enhanced');
    await dir.create(recursive: true);
    final file = File('${dir.path}/enhanced.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> deleteScanFiles(String scanId) async {
    final dir = Directory('${_appDir.path}/scans/$scanId');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<String> exportToFile(String content, String fileName) async {
    final dir = Directory('${_appDir.path}/exports');
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }
}
```

---

## 6. Database Indexes

```sql
-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_scans_created_at ON scans(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_scans_title ON scans(title);
CREATE INDEX IF NOT EXISTS idx_tags_scan_id ON tags(scan_id);
CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);
```

---

## 7. Data Flow Diagram

```
Save Scan Flow:

[User taps Save]
  → NotesBloc emits SaveRequest
  → SaveScan use case
  → ScanRepository.save()
    → Compress & save image → FileStorage
    → Insert scan record → Drift DB (auto-trigger → FTS5 update)
    → Emit success → UI shows confirmation

Load History Flow:

[HistoryScreen opens]
  → HistoryBloc emits LoadHistory
  → GetRecentScans use case
  → ScanRepository.getRecent()
    → SELECT * FROM scans ORDER BY created_at DESC LIMIT 50
    → Map rows → Scan entities
  → Emit HistoryLoaded → UI renders list

Search Flow:

[User types in search bar]
  → HistoryBloc emits SearchHistory(query)
  → SearchScans use case
  → ScanRepository.search()
    → SELECT * FROM scans_fts WHERE scans_fts MATCH ? ORDER BY rank
    → Map rows → Scan entities
  → Emit HistorySearchResults → UI updates
```
