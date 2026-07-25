# VisionNote AI — BLoC Design

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. BLoC Selection Rationale

**BLoC** (Business Logic Component) was chosen over alternatives for these reasons:

| Factor | BLoC | Provider | Riverpod | GetX |
|---|---|---|---|---|
| Formal state machine | ✅ Yes | ❌ No | ❌ No | ❌ No |
| Testability | ✅ Excellent | ✅ Good | ✅ Good | ❌ Poor |
| Stream-based events | ✅ Native | ⚠️ Manual | ✅ Yes | ⚠️ Partial |
| Clean Architecture fit | ✅ Natural | ⚠️ Requires pattern | ✅ Good | ❌ Tight coupling |
| Team scalability | ✅ Excellent | ✅ Good | ✅ Good | ⚠️ Can encourage bad practices |
| Boilerplate | ⚠️ Moderate | ✅ Low | ✅ Low | ✅ Low |

**Decision:** BLoC's formal event→state model provides the clearest state machine for complex workflows (camera auto-capture, image processing pipeline, OCR → AI → Export). It enforces the Clean Architecture dependency rule by keeping business logic out of widgets.

---

## 2. BLoC Architecture Overview

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────┐
│    Event     │ ──▶ │      BLoC        │ ──▶ │    State     │
│  (User/      │     │  (Business       │     │  (UI State)  │
│   System     │     │   Logic)         │     │              │
│   Action)    │     │                  │     │              │
└─────────────┘     └──────┬───────────┘     └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Use Cases  │
                    │  (Domain)    │
                    └──────────────┘
```

**Rules:**
1. BLoC never imports Flutter widgets or Material packages.
2. BLoC never directly accesses data sources — it goes through Use Cases.
3. BLoC emits immutable State objects.
4. Events are typed sealed classes.
5. Each BLoC has a clear lifecycle matching its screen.

---

## 3. BLoC Catalog

### 3.1 ScannerBloc

**File:** `lib/features/scan/presentation/bloc/scan_bloc.dart`

**Purpose:** Manage the home dashboard — recent scans, quick actions.

| Event | Description |
|---|---|
| `LoadRecentScans(int limit)` | Load N most recent scans |
| `RefreshScans` | Pull-to-refresh |
| `DeleteScan(int id)` | Remove a scan |
| `SearchScans(String query)` | Search by title/OCR text |

| State | Fields |
|---|---|
| `ScanInitial` | — |
| `ScanLoading` | — |
| `ScanLoaded` | `List<Scan> scans` |
| `ScanSearchResults` | `List<Scan> results, String query` |
| `ScanError` | `String message` |

### 3.2 CameraBloc

**File:** `lib/features/camera/presentation/bloc/camera_bloc.dart`

**Purpose:** Manage camera lifecycle, frame streaming, auto-capture logic.

| Event | Description |
|---|---|
| `InitializeCamera` | Open camera, start preview |
| `DisposeCamera` | Release camera resources |
| `ProcessFrame(CameraImage frame)` | Send frame to edge detection |
| `CornersDetected(List<Offset> corners)` | Quadrilateral corners from FFI |
| `AutoCaptureTriggered` | Frame stable + well-framed for 500ms |
| `CaptureFrame` | Manual shutter press |
| `ToggleFlash` | Toggle torch on/off |

| State | Fields |
|---|---|
| `CameraInitializing` | — |
| `CameraReady` | `CameraController controller` |
| `CameraDetecting` | `CameraController controller, List<Offset>? corners` |
| `CameraAutoCaptureCountdown` | `int millisecondsRemaining` |
| `CameraCaptured` | `String imagePath` |
| `CameraError` | `String message` |

### 3.3 ImageProcessBloc

**File:** `lib/features/image_process/presentation/bloc/image_process_bloc.dart`

**Purpose:** Manage crop editor and enhancement screen.

| Event | Description |
|---|---|
| `LoadImage(String path)` | Load captured image |
| `AutoDetectCorners` | Re-run corner detection |
| `UpdateCorner(int index, Offset position)` | Drag corner handle |
| `ApplyCrop` | Apply perspective correction |
| `AutoEnhance` | Run full enhancement pipeline |
| `UpdateBrightness(int value)` | Brightness slider |
| `UpdateContrast(double value)` | Contrast slider |
| `UpdateSaturation(double value)` | Saturation slider |
| `UpdateSharpness(double value)` | Sharpness slider |
| `ApplyEnhancement` | Save enhanced image |
| `ResetEnhancement` | Back to original |

| State | Fields |
|---|---|
| `ImageProcessInitial` | — |
| `ImageLoaded` | `Uint8List original, List<Offset>? corners` |
| `CropProcessing` | — |
| `CropReady` | `Uint8List cropped` |
| `EnhanceIdle` | `Uint8List current, Uint8List? original` |
| `EnhanceProcessing` | — |
| `EnhanceComplete` | `Uint8List enhanced` |
| `ImageProcessError` | `String message` |

### 3.4 OCRBloc

**File:** `lib/features/ocr/presentation/bloc/ocr_bloc.dart`

**Purpose:** Manage OCR extraction and text editing.

| Event | Description |
|---|---|
| `SetImage(Uint8List image, String language)` | Provide enhanced image |
| `ExtractText` | Run OCR |
| `SelectLanguage(String languageCode)` | Change OCR language |
| `EditText(String newText)` | User edits OCR result |
| `RequestReExtract` | Run OCR again (after editing) |

| State | Fields |
|---|---|
| `OCRInitial` | — |
| `OCRExtracting` | — |
| `OCRComplete` | `String text, List<TextBlock>? blocks, double confidence` |
| `OCREditing` | `String text` |
| `OCRError` | `String message` |

### 3.5 AIBloc

**File:** `lib/features/ai/presentation/bloc/ai_bloc.dart`

**Purpose:** Manage all AI interactions.

| Event | Description |
|---|---|
| `SetText(String text)` | Provide extracted text |
| `GenerateSummary` | AI summary |
| `GenerateActionItems` | Extract action items |
| `GenerateFlashcards` | Generate study cards |
| `GenerateMindMap` | Generate Mermaid mind map |
| `TranslateText(String targetLanguage)` | Translate |
| `FixGrammar` | Correct OCR/grammar errors |
| `AskQuestion(String question)` | Chat Q&A |
| `ClearChat` | Reset chat history |

| State | Fields |
|---|---|
| `AIInitial` | — |
| `AILoading` | `AIType type` (which AI operation) |
| `AISummaryReady` | `AISummary summary` |
| `AIActionItemsReady` | `List<ActionItem> items` |
| `AIFlashcardsReady` | `List<Flashcard> flashcards` |
| `AIMindMapReady` | `String mermaidCode` |
| `AITranslationReady` | `String translatedText` |
| `AIGrammarFixed` | `String correctedText` |
| `ChatResponse` | `List<ChatMessage> messages` |
| `AIError` | `String message` |

### 3.6 NotesBloc

**File:** `lib/features/scan/presentation/bloc/notes_bloc.dart`

**Purpose:** Manage a single scan's full lifecycle (crop → enhance → OCR → AI → history).

| Event | Description |
|---|---|
| `StartNewScan` | Begin new capture workflow |
| `SaveCurrentScan` | Persist current scan |
| `UpdateTitle(String title)` | Set scan title |
| `AddTag(String tag)` | Add tag |
| `RemoveTag(String tag)` | Remove tag |

| State | Fields |
|---|---|
| `NotesInitial` | — |
| `NotesEditing` | `Scan current` |
| `NotesSaved` | `Scan saved` |
| `NotesError` | `String message` |

### 3.7 ExportBloc

**File:** `lib/features/export/presentation/bloc/export_bloc.dart`

**Purpose:** Manage export formatting and sharing.

| Event | Description |
|---|---|
| `SetScan(Scan scan)` | Provide scan to export |
| `ExportMarkdown` | Export as .md |
| `ExportTXT` | Export as .txt |
| `ExportPDF` | Export as .pdf |
| `ExportJSON` | Export as .json |
| `CopyToClipboard` | Copy text |
| `SetIncludeAI(bool include)` | Toggle AI content in export |

| State | Fields |
|---|---|
| `ExportInitial` | — |
| `Exporting` | `ExportFormat format` |
| `ExportSuccess` | `ExportFormat format, String filePath` |
| `CopiedToClipboard` | — |
| `ExportError` | `String message` |

### 3.8 SettingsBloc

**File:** `lib/features/settings/presentation/bloc/settings_bloc.dart`

**Purpose:** Manage all settings.

| Event | Description |
|---|---|
| `LoadSettings` | Load from Hive |
| `UpdateTheme(ThemeMode mode)` | Switch theme |
| `UpdateOCRLanguage(String code)` | Change OCR language |
| `UpdateAIProvider(String provider)` | Gemini / OpenAI |
| `UpdateAIKey(String key)` | Save API key |
| `UpdateAIModel(String model)` | Select model |
| `UpdateImageQuality(int quality)` | JPEG quality 1-100 |
| `UpdateCompression(bool enabled)` | Toggle compression |
| `UpdateDefaultExport(String format)` | Default export format |
| `UpdateAutoCapture(bool enabled)` | Toggle auto-capture |
| `UpdateAutoEnhance(bool enabled)` | Toggle auto-enhance |

| State | Fields |
|---|---|
| `SettingsLoading` | — |
| `SettingsLoaded` | `AppSettings settings` |
| `SettingsSaving` | — |
| `SettingsSaved` | `AppSettings settings` |
| `SettingsError` | `String message` |

### 3.9 HistoryBloc

**File:** `lib/features/history/presentation/bloc/history_bloc.dart`

**Purpose:** Manage scan history list and search.

| Event | Description |
|---|---|
| `LoadHistory` | Load all scans |
| `SearchHistory(String query)` | Search |
| `DeleteScan(int id)` | Remove scan |
| `ClearAllHistory` | Delete all |
| `AddTag(int scanId, String tag)` | Add tag |
| `RemoveTag(int scanId, String tag)` | Remove tag |

| State | Fields |
|---|---|
| `HistoryLoading` | — |
| `HistoryLoaded` | `List<Scan> scans` |
| `HistorySearchResults` | `List<Scan> results, String query` |
| `HistoryError` | `String message` |

### 3.10 ThemeBloc

**File:** `lib/core/theme/bloc/theme_bloc.dart`

**Purpose:** Reactive theme management.

| Event | Description |
|---|---|
| `SetTheme(ThemeMode mode)` | Change theme |
| `ToggleTheme` | Light ↔ Dark toggle |

| State | Fields |
|---|---|
| `ThemeInitial` | — |
| `ThemeReady` | `ThemeMode mode, ThemeData light, ThemeData dark` |

---

## 4. BLoC State Base Class Pattern

```dart
// Base state pattern for all BLoCs
sealed class BaseState {}

class Initial extends BaseState {}
class Loading extends BaseState {}
class Success<T> extends BaseState {
  final T data;
  Success(this.data);
}
class Failure extends BaseState {
  final String message;
  Failure(this.message);
}
```

---

## 5. Testing BLoCs

```dart
void main() {
  late ScannerBloc bloc;
  late MockGetRecentScans mockGetRecentScans;
  late MockSaveScan mockSaveScan;
  late MockDeleteScan mockDeleteScan;

  setUp(() {
    mockGetRecentScans = MockGetRecentScans();
    mockSaveScan = MockSaveScan();
    mockDeleteScan = MockDeleteScan();
    bloc = ScannerBloc(mockGetRecentScans, mockSaveScan, mockDeleteScan);
  });

  blocTest<ScannerBloc, ScannerState>(
    'emits [Loading, Loaded] when LoadRecentScans is added',
    build: () {
      when(() => mockGetRecentScans(10))
          .thenAnswer((_) async => [testScan]);
      return bloc;
    },
    act: (bloc) => bloc.add(LoadRecentScans(10)),
    expect: () => [
      ScannerLoading(),
      ScannerLoaded([testScan]),
    ],
  );

  blocTest<ScannerBloc, ScannerState>(
    'emits [Loading, Error] when repository throws',
    build: () {
      when(() => mockGetRecentScans(10)).thenThrow(Exception('DB error'));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadRecentScans(10)),
    expect: () => [
      ScannerLoading(),
      ScannerError('Exception: DB error'),
    ],
  );
}
```
