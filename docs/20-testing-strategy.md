# VisionNote AI — Testing Strategy

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Senior QA Engineer

---

## 1. Testing Pyramid

```
        ╱╲
       ╱  ╲          E2E / Integration Tests (10%)
      ╱    ╲         - Critical user flows
     ╱      ╲        - Camera → Crop → Enhance → OCR → Export
    ╱────────╲
   ╱          ╲      Widget Tests (20%)
  ╱            ╲    - Screen builds, widget interactions
 ╱──────────────╲   - Accessibility checks
╱                  ╲
╱────────────────────╲  Unit Tests (70%)
╱                      ╲ - BLoC events/states
╱───────────────────────╲ - Use cases & entities
╱────────────────────────╲ - Repository & data source
╱─────────────────────────╲ - FFI bindings (mocked)
╱──────────────────────────╲ - AI prompts & response parsing
```

---

## 2. Unit Tests

### 2.1 Coverage Targets

| Module | Target |
|---|---|
| Domain entities | 100% |
| Use cases | 100% |
| Repository interfaces | 100% (mock verification) |
| BLoC | 100% (via blocTest) |
| Data sources | 90% |
| FFI bindings | 90% (with mocked native calls) |
| Utility functions | 100% |
| AI prompt templates | 100% |

### 2.2 BLoC Testing

```dart
// test/features/camera/bloc/camera_bloc_test.dart
void main() {
  late CameraBloc bloc;
  late MockOpenCVService mockOpenCV;
  late MockCameraController mockCameraController;

  setUp(() {
    mockOpenCV = MockOpenCVService();
    mockCameraController = MockCameraController();
    bloc = CameraBloc(mockOpenCV, mockCameraController);
  });

  group('CameraBloc', () {
    blocTest<CameraBloc, CameraState>(
      'emits [CameraReady] when initialized successfully',
      build: () {
        when(() => mockCameraController.initialize())
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const InitializeCamera()),
      expect: () => [
        const CameraInitializing(),
        isA<CameraReady>(),
      ],
    );

    blocTest<CameraBloc, CameraState>(
      'emits [CameraDetecting] when corners are found',
      build: () => bloc,
      seed: () => CameraReady(mockCameraController),
      act: (bloc) => bloc.add(const ProcessFrame(mockFrame)),
      expect: () => [
        isA<CameraDetecting>(),
      ],
    );

    blocTest<CameraBloc, CameraState>(
      'emits [CameraCaptured] on manual capture',
      build: () {
        when(() => mockCameraController.takePicture())
            .thenAnswer((_) async => 'path/to/image.jpg');
        return bloc;
      },
      seed: () => CameraReady(mockCameraController),
      act: (bloc) => bloc.add(const CaptureFrame()),
      expect: () => [
        isA<CameraCaptured>(),
      ],
    );
  });
}
```

### 2.3 Use Case Testing

```dart
// test/features/scan/domain/usecases/get_recent_scans_test.dart
void main() {
  late GetRecentScans useCase;
  late MockIScanRepository mockRepository;

  setUp(() {
    mockRepository = MockIScanRepository();
    useCase = GetRecentScans(mockRepository);
  });

  test('should return list of scans from repository', () async {
    final scans = [testScan];
    when(() => mockRepository.getRecent(10))
        .thenAnswer((_) async => scans);

    final result = await useCase(10);

    expect(result, scans);
    verify(() => mockRepository.getRecent(10)).called(1);
  });

  test('should throw when repository throws', () async {
    when(() => mockRepository.getRecent(10))
        .thenThrow(Exception('DB error'));

    expect(() => useCase(10), throwsA(isA<Exception>()));
  });
}
```

### 2.4 Repository Testing

```dart
// test/features/scan/data/repositories/scan_repository_test.dart
void main() {
  late ScanRepository repository;
  late MockDriftDatabase mockDb;
  late MockFileStorage mockFileStorage;

  setUp(() {
    mockDb = MockDriftDatabase();
    mockFileStorage = MockFileStorage();
    repository = ScanRepository(mockDb, mockFileStorage);
  });

  group('save', () {
    test('should insert scan into database and return saved scan with id', () async {
      when(() => mockDb.scansDao.insertScan(any()))
          .thenAnswer((_) async => 1);

      final result = await repository.save(testScan);

      expect(result.id, 1);
      verify(() => mockDb.scansDao.insertScan(any())).called(1);
    });
  });

  group('search', () {
    test('should return matching scans for query', () async {
      when(() => mockDb.scansDao.searchByText('biology'))
          .thenAnswer((_) async => [testScanDto]);

      final results = await repository.search('biology');

      expect(results.length, 1);
      expect(results.first.title, contains('biology'));
    });
  });
}
```

---

## 3. Widget Tests

### 3.1 Coverage Targets

| Component | Target |
|---|---|
| All screens (render) | 100% |
| All custom widgets | 100% |
| Empty / Error / Loading states | 100% |
| Navigation flows | 80% |

### 3.2 Widget Test Example

```dart
// test/features/scan/presentation/widgets/scan_card_test.dart
void main() {
  testWidgets('ScanCard displays title, date, and tags', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ScanCard(
        scan: testScan,
        onTap: () {},
      ),
    ));

    expect(find.text('Biology Notes'), findsOneWidget);
    expect(find.text('Jul 25, 2026'), findsOneWidget);
    expect(find.text('biology'), findsOneWidget);
    expect(find.text('lecture'), findsOneWidget);
  });

  testWidgets('ScanCard triggers onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: ScanCard(
        scan: testScan,
        onTap: () => tapped = true,
      ),
    ));

    await tester.tap(find.byType(ScanCard));
    expect(tapped, isTrue);
  });
}
```

### 3.3 Screen Test Example

```dart
// test/features/scan/presentation/screens/home_screen_test.dart
void main() {
  late MockScanBloc mockBloc;

  setUp(() {
    mockBloc = MockScanBloc();
    when(() => mockBloc.state).thenReturn(const ScanLoaded([testScan]));
  });

  testWidgets('HomeScreen shows recent scans grid', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<ScanBloc>.value(
        value: mockBloc,
        child: const HomeScreen(),
      ),
    ));

    expect(find.text('Recent Scans'), findsOneWidget);
    expect(find.byType(ScanCard), findsOneWidget);
  });

  testWidgets('HomeScreen shows empty state when no scans', (tester) async {
    when(() => mockBloc.state).thenReturn(const ScanLoaded([]));

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<ScanBloc>.value(
        value: mockBloc,
        child: const HomeScreen(),
      ),
    ));

    expect(find.text('No scans yet'), findsOneWidget);
  });
}
```

---

## 4. Integration Tests

### 4.1 Critical User Flows

```dart
// integration_test/scan_to_export_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete scan → process → OCR → export flow', (tester) async {
    // 1. Launch app
    await tester.pumpWidget(const VisionNoteAIApp());
    await tester.pumpAndSettle();

    // 2. Skip onboarding (or complete it)
    await tester.tap(find.text('Skip'));

    // 3. Tap camera FAB
    await tester.tap(find.byType(VNAFab));
    await tester.pumpAndSettle();

    // 4. Grant camera permission (platform-specific)
    // Note: Requires real device or emulator with camera

    // 5. Take photo
    await tester.tap(find.byType(ShutterButton));
    await tester.pumpAndSettle();

    // 6. Crop editor → confirm
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // 7. Auto enhance → continue
    await tester.tap(find.text('Auto Enhance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // 8. Extract text
    await tester.tap(find.text('Extract Text'));
    await tester.pumpAndSettle();

    // 9. Verify OCR text is displayed
    expect(find.byType(VNAEditableText), findsOneWidget);

    // 10. Export
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    // 11. Select Markdown
    await tester.tap(find.text('Markdown'));
    await tester.pumpAndSettle();

    // 12. Verify share sheet opened (platform-specific)
    // On CI, this may fail — mark as skip on CI
  });
}
```

### 4.2 Key Integration Scenarios

| Scenario | Coverage |
|---|---|
| Fresh install → Onboarding → Home | Yes |
| Camera → Auto-capture → Crop | Yes |
| Camera → Manual capture → Crop | Yes |
| Crop → Adjust corners → Enhance | Yes |
| Enhance → Auto → OCR | Yes |
| OCR → Edit text → AI Summary | Yes |
| AI → Action Items → Export Markdown | Yes |
| History → Search → View scan | Yes |
| Settings → Change theme → Verify | Yes |
| Settings → Change OCR language → Retest | Yes |

---

## 5. Test Infrastructure

### 5.1 Mocking

```yaml
# pubspec.yaml
dev_dependencies:
  mocktail: ^1.0.0
  bloc_test: ^9.1.0
  mocktail_image_network: ^1.0.0
```

### 5.2 Test Organization

```
test/
├── core/
│   ├── database/
│   ├── theme/
│   ├── router/
│   └── utils/
├── features/
│   ├── scan/
│   │   ├── bloc/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── camera/
│   ├── image_process/
│   ├── ocr/
│   ├── ai/
│   ├── export/
│   ├── history/
│   └── settings/
└── native/
    └── ffi/
```

### 5.3 CI Commands

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: dart analyze --fatal-infos --fatal-warnings .
      - run: flutter test --coverage --test-randomize-ordering-seed random
      - run: flutter test integration_test/
```

---

## 6. Performance Testing

### 6.1 Benchmarks

```dart
// test/native/ffi/opencv_benchmark_test.dart
void main() {
  late OpenCVService openCV;
  final testImage = Uint8List.fromList(...); // Preloaded test image

  setUp(() {
    openCV = OpenCVService();
  });

  test('edge detection completes within 50ms', () {
    final sw = Stopwatch()..start();
    final corners = openCV.detectEdges(testImage, 1920, 1080);
    sw.stop();

    expect(sw.elapsedMilliseconds, lessThan(50));
    expect(corners.length, 4);
  });

  test('full enhancement pipeline completes within 500ms', () {
    final sw = Stopwatch()..start();
    final enhanced = openCV.autoEnhance(testImage, 1920, 1080, 4);
    sw.stop();

    expect(sw.elapsedMilliseconds, lessThan(500));
    expect(enhanced.length, greaterThan(0));
  });

  test('perspective correction completes within 100ms', () {
    final corners = [
      Offset(10, 20), Offset(1850, 30),
      Offset(1890, 1050), Offset(5, 1040),
    ];
    final sw = Stopwatch()..start();
    final corrected = openCV.correctPerspective(testImage, 1920, 1080, corners);
    sw.stop();

    expect(sw.elapsedMilliseconds, lessThan(100));
  });
}
```

### 6.2 Memory Tests

```dart
test('processing pipeline does not leak memory', () {
  final before = ProcessInfo.currentRss;
  for (int i = 0; i < 100; i++) {
    openCV.autoEnhance(testImage, 1920, 1080, 4);
  }
  final after = ProcessInfo.currentRss;
  final leakPerIteration = (after - before) / 100;

  // Allow 10KB per iteration max
  expect(leakPerIteration, lessThan(1024 * 10));
});
```

---

## 7. Accessibility Tests

```dart
testWidgets('all interactive elements meet minimum touch target', (tester) async {
  await tester.pumpWidget(const HomeScreen());
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
});

testWidgets('text contrast meets WCAG AA', (tester) async {
  await tester.pumpWidget(const HomeScreen());
  await expectLater(tester, meetsGuideline(textContrastGuideline));
});
```
