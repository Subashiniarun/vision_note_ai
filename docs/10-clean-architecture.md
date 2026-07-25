# VisionNote AI — Clean Architecture Design

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. Principles

This project follows **Clean Architecture** as defined by Robert C. Martin, adapted for Flutter:

1. **Independent of Frameworks:** Flutter is a delivery mechanism, not the architecture.
2. **Testable:** Business logic can be tested without UI, database, or network.
3. **Independent of UI:** The UI can change (e.g., phone → tablet → web) without changing business rules.
4. **Independent of Database:** Drift can be replaced with a different storage solution.
5. **Independent of External Agency:** AI providers are pluggable behind interfaces.

## 2. Layer Rules

```
┌──────────────────────────────────────────────────────┐
│                    PRESENTATION                       │
│  Depends on: Domain                                  │
│  Contains: Screens, Widgets, BLoCs                   │
│  Knows about: Flutter, BLoC, get_it                  │
├──────────────────────────────────────────────────────┤
│                       DOMAIN                         │
│  Depends on: Nothing (pure Dart)                     │
│  Contains: Entities, Use Cases, Repository Interfaces│
│  Knows about: dart:async (Future/Stream)              │
├──────────────────────────────────────────────────────┤
│                        DATA                          │
│  Depends on: Domain                                  │
│  Contains: Repository Impl, Data Sources, DTOs       │
│  Knows about: Drift, Hive, FFI, HTTP, JSON           │
└──────────────────────────────────────────────────────┘
```

**Dependency Rule:** Source code dependencies can only point **inward** — from Presentation → Domain, from Data → Domain. Nothing in Domain depends on anything outside Domain.

## 3. Package/Module Organization

```
lib/
├── core/                      # Shared kernel
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── utils/
│   └── theme/
├── features/
│   ├── scan/
│   │   ├── presentation/      # BLoC, widgets, screens
│   │   ├── domain/            # Entities, use cases, repo interfaces
│   │   └── data/              # Repository impl, DTOs, data sources
│   ├── camera/
│   ├── image_process/
│   ├── ocr/
│   ├── ai/
│   ├── export/
│   ├── history/
│   └── settings/
└── native/
    ├── ffi/                   # Dart FFI bindings
    └── opencv/                # C++ source (separate build)
```

## 4. Domain Layer — Detailed

### 4.1 Entities (no dependencies, pure Dart)

```dart
// lib/features/scan/domain/entities/scan.dart
class Scan {
  final int? id;
  final String title;
  final String originalImagePath;
  final String? enhancedImagePath;
  final String? ocrText;
  final String ocrLanguage;
  final AISummary? aiSummary;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// lib/features/ai/domain/entities/ai_summary.dart
class AISummary {
  final String summary;
  final List<ActionItem>? actionItems;
  final List<Flashcard>? flashcards;
  final String? mindMap;
}

// lib/features/ocr/domain/entities/ocr_result.dart
class OCRResult {
  final String text;
  final List<TextBlock> blocks;
  final String language;
  final double confidence;
}
```

### 4.2 Use Cases (single responsibility)

```dart
// lib/features/scan/domain/usecases/save_scan.dart
@injectable
class SaveScan {
  final IScanRepository _repository;

  SaveScan(this._repository);

  Future<Scan> call(Scan scan) => _repository.save(scan);
}

// lib/features/scan/domain/usecases/get_recent_scans.dart
@injectable
class GetRecentScans {
  final IScanRepository _repository;

  GetRecentScans(this._repository);

  Future<List<Scan>> call(int limit) => _repository.getRecent(limit);
}
```

### 4.3 Repository Interfaces

```dart
// lib/features/scan/domain/repositories/i_scan_repository.dart
abstract class IScanRepository {
  Future<Scan> save(Scan scan);
  Future<Scan?> getById(int id);
  Future<List<Scan>> getRecent(int limit);
  Future<List<Scan>> search(String query);
  Future<void> delete(int id);
  Future<Scan> update(Scan scan);
  Stream<Scan> watchRecent();
}
```

## 5. Data Layer — Detailed

### 5.1 Repository Implementation

```dart
// lib/features/scan/data/repositories/scan_repository.dart
@Injectable(as: IScanRepository)
class ScanRepository implements IScanRepository {
  final AppDatabase _db;
  final FileSystemStorage _fileStorage;

  ScanRepository(this._db, this._fileStorage);

  @override
  Future<Scan> save(Scan scan) async {
    final dto = ScanTableCompanion(
      title: Value(scan.title),
      originalImagePath: Value(scan.originalImagePath),
      enhancedImagePath: Value(scan.enhancedImagePath),
      ocrText: Value(scan.ocrText),
      ocrLanguage: Value(scan.ocrLanguage),
      aiSummaryJson: Value(scan.aiSummary != null
          ? jsonEncode(AISummarySerializer.toMap(scan.aiSummary!))
          : null),
      tagsJson: Value(jsonEncode(scan.tags)),
      createdAt: Value(scan.createdAt.toIso8601String()),
      updatedAt: Value(scan.updatedAt.toIso8601String()),
    );
    final id = await _db.into(_db.scans).insert(dto);
    return scan.copyWith(id: id);
  }

  @override
  Future<List<Scan>> search(String query) async {
    final rows = await _db.customSelect(
      'SELECT * FROM scans WHERE ocr_text LIKE ? OR title LIKE ?',
      variables: [StringParameter('%$query%'), StringParameter('%$query%')],
    ).get();
    return rows.map((row) => ScanMapper.fromDbRow(row.data)).toList();
  }
  // ...
}
```

### 5.2 Data Sources

```dart
// lib/features/scan/data/datasources/local/scan_database.dart
@DriftDatabase(tables: [Scans, Tags])
class ScanDatabase extends _$ScanDatabase {
  ScanDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<List<ScanTableData>> searchByText(String query) {
    return (select(scans)..where((s) => s.ocrText.contains(query))).get();
  }
}
```

### 5.3 DTOs / Mappers

```dart
// lib/features/scan/data/models/scan_mapper.dart
class ScanMapper {
  static Scan fromDbRow(Map<String, dynamic> row) {
    return Scan(
      id: row['id'] as int?,
      title: row['title'] as String,
      originalImagePath: row['original_image_path'] as String,
      enhancedImagePath: row['enhanced_image_path'] as String?,
      ocrText: row['ocr_text'] as String?,
      ocrLanguage: row['ocr_language'] as String,
      aiSummary: row['ai_summary_json'] != null
          ? AISummaryMapper.fromJson(row['ai_summary_json'] as String)
          : null,
      tags: row['tags_json'] != null
          ? List<String>.from(jsonDecode(row['tags_json'] as String))
          : [],
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
```

## 6. Presentation Layer — Detailed

### 6.1 BLoC

```dart
// lib/features/scan/presentation/bloc/scan_bloc.dart
@injectable
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final GetRecentScans _getRecentScans;
  final SaveScan _saveScan;
  final DeleteScan _deleteScan;

  ScanBloc(this._getRecentScans, this._saveScan, this._deleteScan)
      : super(ScanInitial()) {
    on<LoadRecentScans>(_onLoadRecentScans);
    on<SaveScanRequest>(_onSaveScan);
    on<DeleteScanRequest>(_onDeleteScan);
  }

  void _onLoadRecentScans(LoadRecentScans event, Emitter<ScanState> emit) async {
    emit(ScanLoading());
    try {
      final scans = await _getRecentScans(event.limit);
      emit(ScanLoaded(scans));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }
  // ...
}
```

### 6.2 Screen

```dart
// lib/features/scan/presentation/screens/home_screen.dart
@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ScanBloc>()..add(LoadRecentScans(10)),
      child: _HomeView(),
    );
  }
}
```

## 7. Dependency Injection Wiring

```dart
// lib/core/di/injection.dart
@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() => $initGetIt(getIt);
```

## 8. Why Clean Architecture for This Project

| Benefit | How VisionNote AI Uses It |
|---|---|
| **Testability** | Use cases and entities are pure Dart, testable without Flutter |
| **Swappable AI** | IAIRepository interface allows Gemini ↔ OpenAI swap without touching business logic |
| **Offline-first** | Repository pattern hides data source — add remote data source later without changing anything else |
| **Parallel development** | Multiple developers can work on presentation, domain, and data layers simultaneously |
| **Framework independence** | If Flutter becomes obsolete, domain layer can be reused with a different framework |
