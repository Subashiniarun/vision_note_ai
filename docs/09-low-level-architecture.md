# VisionNote AI — Low-Level Architecture (LLD)

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. Presentation Layer Details

### 1.1 Screen → BLoC Mapping

| Screen | BLoC | Events | States |
|---|---|---|---|
| SplashScreen | — | — | — |
| OnboardingScreen | — | — | — |
| HomeScreen | ScannerBloc | LoadRecentScans | HomeInitial, HomeLoading, HomeLoaded, HomeError |
| CameraScreen | CameraBloc | InitializeCamera, StartStream, StopStream, CaptureFrame, ToggleFlash, AutoDetectCorners | CameraInitializing, CameraReady, CameraDetecting, CameraCaptured, CameraError |
| CropEditorScreen | ImageProcessBloc | CropImage, AutoDetectCorners, AdjustCorner | CropIdle, CropProcessing, CropDone, CropError |
| EnhancementScreen | ImageProcessBloc | AutoEnhance, AdjustBrightness, AdjustContrast, AdjustSaturation, AdjustSharpness, ApplyEnhancement | EnhanceIdle, EnhanceProcessing, EnhancePreview, EnhanceError |
| OCRPreviewScreen | OCRBloc | ExtractText, EditText, SetLanguage | OCRIdle, OCRExtracting, OCRComplete, OCRError |
| AISummaryScreen | AIBloc | GenerateSummary, GenerateActionItems, GenerateFlashcards, GenerateMindMap, TranslateText, FixGrammar | AIIdle, AILoading, AISuccess, AIError |
| ChatScreen | AIBloc | AskQuestion, ClearChat | ChatIdle, ChatLoading, ChatResponse, ChatError |
| ExportScreen | ExportBloc | ExportMarkdown, ExportTXT, ExportPDF, ExportJSON, CopyToClipboard | ExportIdle, Exporting, ExportSuccess, ExportError |
| HistoryScreen | HistoryBloc | LoadHistory, SearchHistory, DeleteScan, AddTag, RemoveTag | HistoryLoading, HistoryLoaded, HistoryError |
| SettingsScreen | SettingsBloc | LoadSettings, UpdateTheme, UpdateOCRLanguage, UpdateAIProvider, UpdateAIKey, UpdateImageQuality, UpdateCompression, UpdateDefaultExport | SettingsLoaded, SettingsSaving, SettingsSaved |
| AboutScreen | — | — | — |

### 1.2 BLoC Base Structure

```dart
// Example: ScannerBloc
@injectable
class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final IScanRepository _scanRepository;
  final GetRecentScans _getRecentScans;

  ScannerBloc(this._scanRepository, this._getRecentScans)
      : super(ScannerInitial()) {
    on<LoadRecentScans>(_onLoadRecentScans);
    on<DeleteScan>(_onDeleteScan);
  }

  Future<void> _onLoadRecentScans(
    LoadRecentScans event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerLoading());
    try {
      final scans = await _getRecentScans(10);
      emit(ScannerLoaded(scans));
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }
}
```

---

## 2. Domain Layer Details

### 2.1 Core Entities

```dart
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

class OCRResult {
  final String text;
  final List<TextBlock> blocks;
  final String language;
  final double confidence;
  final Duration processingTime;
}

class AISummary {
  final String summary;
  final List<ActionItem>? actionItems;
  final List<Flashcard>? flashcards;
  final String? mindMap;
}

class ActionItem {
  final String task;
  final String? assignee;
  final String priority; // High, Medium, Low
}

class Flashcard {
  final String question;
  final String answer;
}

class ExportOptions {
  final bool markdown;
  final bool plainText;
  final bool pdf;
  final bool json;
  final bool includeAI;
}
```

### 2.2 Use Cases

```dart
// Input: camera image file path
// Output: processed image with corrected perspective
class ProcessImage {
  final IImageProcessor _imageProcessor;
  Future<ProcessedImage> call(String imagePath, CropRect? crop);
}

// Input: processed image bytes
// Output: OCRResult with text and blocks
class ExtractText {
  final IImageProcessor _imageProcessor;
  final IScanRepository _scanRepository;
  Future<OCRResult> call(Uint8List imageBytes, String language);
}

// Input: text
// Output: AI-generated summary
class GenerateAISummary {
  final IAIRepository _aiRepository;
  Future<AISummary> call(String text, AIType type);
}

// Input: scan + ExportOptions
// Output: file path(s)
class ExportDocument {
  final IExportRepository _exportRepository;
  Future<List<String>> call(Scan scan, ExportOptions options);
}

// Input: search query
// Output: matching scans
class SearchScans {
  final IScanRepository _scanRepository;
  Future<List<Scan>> call(String query);
}
```

### 2.3 Repository Interfaces

```dart
abstract class IScanRepository {
  Future<Scan> save(Scan scan);
  Future<Scan?> getById(int id);
  Future<List<Scan>> getRecent(int limit);
  Future<List<Scan>> search(String query);
  Future<void> delete(int id);
  Future<Scan> update(Scan scan);
  Stream<Scan> watchRecent();
}

abstract class IAIRepository {
  Future<AISummary> generateSummary(String text);
  Future<List<ActionItem>> generateActionItems(String text);
  Future<List<Flashcard>> generateFlashcards(String text);
  Future<String> generateMindMap(String text);
  Future<String> translate(String text, String targetLanguage);
  Future<String> fixGrammar(String text);
  Future<String> askQuestion(String context, String question);
}

abstract class IExportRepository {
  Future<String> exportMarkdown(Scan scan, ExportOptions options);
  Future<String> exportPlainText(Scan scan, ExportOptions options);
  Future<String> exportPdf(Scan scan, ExportOptions options);
  Future<String> exportJson(Scan scan, ExportOptions options);
  Future<void> copyToClipboard(String text);
}

abstract class IImageProcessor {
  Future<Uint8List> detectEdges(Uint8List image);
  Future<Uint8List> correctPerspective(Uint8List image, List<Offset> corners);
  Future<Uint8List> autoEnhance(Uint8List image);
  Future<Uint8List> adjustBrightness(Uint8List image, int value);
  Future<Uint8List> adjustContrast(Uint8List image, double value);
  Future<Uint8List> adjustSaturation(Uint8List image, double value);
  Future<Uint8List> deskew(Uint8List image);
  Future<List<Offset>> detectDocumentCorners(Uint8List image);
}
```

---

## 3. Data Layer Details

### 3.1 Repository Implementations

```dart
@Injectable(as: IScanRepository)
class ScanRepository implements IScanRepository {
  final DriftDatabase _db;
  final HiveCache _cache;
  final SecureStorage _secureStorage;

  ScanRepository(this._db, this._cache, this._secureStorage);

  @override
  Future<Scan> save(Scan scan) async {
    final dto = ScanDTO.fromDomain(scan);
    final id = await _db.scansDao.insertScan(dto);
    return scan.copyWith(id: id);
  }

  @override
  Future<List<Scan>> search(String query) async {
    final dtos = await _db.scansDao.searchByText(query);
    return dtos.map((d) => d.toDomain()).toList();
  }

  // ... other implementations
}
```

### 3.2 Data Sources

```dart
// Drift Database
@DriftDatabase(tables: [Scans, Tags])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => ...;
}

// Hive Cache
@HiveType(typeId: 0)
class SettingsCache extends HiveObject {
  @HiveField(0)
  String themeMode;
  @HiveField(1)
  String ocrLanguage;
  // ...
}
```

### 3.3 DTOs

```dart
class ScanDTO {
  final int? id;
  final String title;
  final String originalImagePath;
  final String? enhancedImagePath;
  final String? ocrText;
  final String ocrLanguage;
  final String? aiSummaryJson;
  final String? tagsJson;
  final String createdAt;
  final String updatedAt;

  Scan toDomain() => Scan(
    id: id,
    title: title,
    originalImagePath: originalImagePath,
    enhancedImagePath: enhancedImagePath,
    ocrText: ocrText,
    ocrLanguage: ocrLanguage,
    aiSummary: aiSummaryJson != null
        ? AISummaryDTO.fromJson(aiSummaryJson!).toDomain()
        : null,
    tags: tagsJson != null ? List<String>.from(jsonDecode(tagsJson!)) : [],
    createdAt: DateTime.parse(createdAt),
    updatedAt: DateTime.parse(updatedAt),
  );

  static ScanDTO fromDomain(Scan scan) => ScanDTO(
    id: scan.id,
    title: scan.title,
    originalImagePath: scan.originalImagePath,
    enhancedImagePath: scan.enhancedImagePath,
    ocrText: scan.ocrText,
    ocrLanguage: scan.ocrLanguage,
    aiSummaryJson: scan.aiSummary != null
        ? jsonEncode(AISummaryDTO.fromDomain(scan.aiSummary!))
        : null,
    tagsJson: jsonEncode(scan.tags),
    createdAt: scan.createdAt.toIso8601String(),
    updatedAt: scan.updatedAt.toIso8601String(),
  );
}
```

---

## 4. FFI Native Bridge Details

### 4.1 C Function Exports

```cpp
extern "C" {

// Edge detection: returns corner coordinates as JSON string
__attribute__((visibility("default")))
const char* detect_edges(const unsigned char* image_data, int width, int height, int channels);

// Perspective correction: returns warped image bytes as base64
__attribute__((visibility("default")))
const char* correct_perspective(const unsigned char* image_data, int width, int height,
                                 float x1, float y1, float x2, float y2,
                                 float x3, float y3, float x4, float y4);

// Auto enhance: returns enhanced image bytes as base64
__attribute__((visibility("default")))
const char* auto_enhance(const unsigned char* image_data, int width, int height, int channels);

// Denoise: returns denoised image bytes
__attribute__((visibility("default")))
const char* denoise(const unsigned char* image_data, int width, int height, int channels);

// Adaptive threshold: returns thresholded image bytes
__attribute__((visibility("default")))
const char* adaptive_threshold(const unsigned char* image_data, int width, int height);

// Deskew: returns deskewed image bytes
__attribute__((visibility("default")))
const char* deskew(const unsigned char* image_data, int width, int height, int channels);

}
```

### 4.2 Dart FFI Bindings

```dart
typedef DetectEdgesNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData, Int32 width, Int32 height, Int32 channels);

typedef DetectEdgesDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData, int width, int height, int channels);

class OpenCVNative {
  late final DynamicLibrary _lib;
  late final DetectEdgesDart _detectEdges;
  // ...

  OpenCVNative() {
    _lib = Platform.isAndroid
        ? DynamicLibrary.open('libopencv_processor.so')
        : DynamicLibrary.process();
    _detectEdges = _lib.lookupFunction<DetectEdgesNative, DetectEdgesDart>('detect_edges');
  }

  Future<List<Offset>> detectDocumentCorners(Uint8List imageData, int width, int height) async {
    final ptr = _allocateImageData(imageData);
    final resultPtr = _detectEdges(ptr, width, height, 4);
    final json = resultPtr.toDartString();
    _freeImageData(ptr);
    _freeString(resultPtr);
    return _parseCornersFromJson(json);
  }
}
```

### 4.3 ImageProcessor Implementation

```dart
@Injectable(as: IImageProcessor)
class OpenCVImageProcessor implements IImageProcessor {
  final OpenCVNative _native;

  OpenCVImageProcessor(this._native);

  @override
  Future<Uint8List> autoEnhance(Uint8List image) async {
    final (width, height) = _decodeDimensions(image);
    final resultBase64 = _native.autoEnhance(image, width, height, 4);
    return base64Decode(resultBase64);
  }

  // ... other implementations
}
```

---

## 5. Dependency Injection

### 5.1 Module Registration

```dart
@module
abstract class AppModule {
  @lazySingleton
  AppDatabase get db => AppDatabase(openConnection());

  @lazySingleton
  HiveCache get cache => HiveCache();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  OpenCVNative get openCV => OpenCVNative();

  @Named('gemini')
  @lazySingleton
  IAIClient get geminiClient => GeminiClient();

  @Named('openai')
  @lazySingleton
  IAIClient get openAIClient => OpenAIClient();
}
```

---

## 6. Error Handling Strategy

| Layer | Error Type | Handling |
|---|---|---|
| Presentation | BlocException | Show SnackBar / Error screen |
| Domain | Failure sealed class | Return Result<T> type (Success/Failure) |
| Data | RepositoryException | Catch, log, wrap in Failure |
| FFI | NativeException | Catch, return null/error bytes, log |
| Network | NetworkException | Retry logic, offline fallback |
