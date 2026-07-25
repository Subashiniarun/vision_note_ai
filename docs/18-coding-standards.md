# VisionNote AI — Coding Standards

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect / Technical Lead

---

## 1. Dart Coding Standards

### 1.1 General Rules

- Follow the [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and [Effective Dart](https://dart.dev/guides/language/effective-dart).
- Use `dart format` with default settings before every commit.
- Run `dart analyze` with zero warnings before opening a PR.

### 1.2 Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case` | `scan_repository.dart` |
| Classes | `PascalCase` | `ScanRepository` |
| Methods | `camelCase` | `getRecentScans()` |
| Variables | `camelCase` | `recentScans` |
| Constants | `camelCase` | `defaultLanguage` |
| Private | prefix `_` | `_processImage()` |
| Enums | `PascalCase` | `ThemeMode` |
| Type aliases | `PascalCase` | `JsonMap` |
| Extensions | `PascalCase` | `ContextExtensions` |

### 1.3 Imports Ordering

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:io';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. External packages (alphabetical)
import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';

// 4. Internal packages (alphabetical by feature)
import 'package:vision_note_ai/core/constants/app_constants.dart';
import 'package:vision_note_ai/features/scan/domain/entities/scan.dart';

// 5. Test imports
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
```

### 1.4 Null Safety

```dart
// Prefer late final for non-nullable fields initialized after construction
late final CameraController _controller;

// Use nullable types only when null is a valid state
final String? _errorMessage;

// Avoid ! operator — use pattern matching or ?.
String displayName = user.name ?? 'Anonymous';

// Use null-aware cascade
widget?..update()..render();
```

### 1.5 Error Handling

```dart
// Use Result type for repository operations
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}

// Repository methods return Result
Future<Result<List<Scan>>> getRecentScans(int limit) async {
  try {
    final scans = await _db.scansDao.getRecentScans(limit);
    return Success(scans);
  } on DatabaseException catch (e) {
    return Failure('Database error', error: e);
  }
}

// BLoC handles Result
final result = await _getRecentScans(10);
switch (result) {
  case Success(data: final scans):
    emit(ScannerLoaded(scans));
  case Failure(message: final message):
    emit(ScannerError(message));
}
```

### 1.6 Async Patterns

```dart
// Prefer async/await over .then()
Future<void> _onLoadScans(LoadScans event, Emitter<ScannerState> emit) async {
  emit(ScannerLoading());
  try {
    final scans = await _repository.getRecentScans(10);
    emit(ScannerLoaded(scans));
  } catch (e) {
    emit(ScannerError(e.toString()));
  }
}

// Use Stream generators for continuous data
Stream<List<Scan>> watchRecentScans() async* {
  yield* _db.scansDao.watchRecentScans();
}

// Use compute/Isolate for heavy work (not FFI — that's already native)
final result = await Isolate.run(() => heavyCalculation(data));
```

---

## 2. Flutter Widget Standards

### 2.1 Widget Structure

```dart
@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ScanBloc>()..add(const LoadRecentScans()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<ScanBloc, ScanState>(
        builder: (context, state) => switch (state) {
          ScanLoading() => const VNASkeletonList(),
          ScanLoaded(scans: final scans) => RecentScansGrid(scans: scans),
          ScanError(message: final msg) => VNAErrorState(message: msg),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
```

### 2.2 Widget Rules

- Every screen is a `const` widget with `super.key`.
- Separate presentation logic into `_View` widgets (private).
- Use `switch` expressions in `BlocBuilder` for exhaustive pattern matching.
- Avoid nested `Builder` callbacks — extract to methods or widgets.
- Prefer `ListView.builder` over `ListView` for lists.
- All interactive widgets must have `minSize: 48` for accessibility.

### 2.3 Custom Widgets

```dart
// Always accept width/height as optional overrides
class VNAButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const VNAButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height,
  });
  // ...
}
```

---

## 3. Dart Analysis Rules

```yaml
# analysis_options.yaml
analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.config.dart"

linter:
  rules:
    - always_declare_return_types
    - always_use_package_imports
    - annotate_overrides
    - avoid_dynamic_calls
    - avoid_print
    - avoid_redundant_argument_values
    - avoid_unused_constructor_parameters
    - await_only_futures
    - camel_case_types
    - cancel_subscriptions
    - constant_identifier_names
    - directives_ordering
    - empty_constructor_bodies
    - exhaustive_cases
    - file_names
    - join_return_with_assignment
    - leading_newlines_in_multiline_strings
    - lines_longer_than_100_chars
    - no_duplicate_case_values
    - no_leading_underscores_for_local_identifiers
    - null_closures
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_foreach
    - prefer_single_quotes
    - require_trailing_commas
    - sort_child_properties_last
    - type_init_formals
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_new
    - unnecessary_null_checks
    - unnecessary_string_escapes
    - use_super_parameters
```

---

## 4. Git Commit Conventions

### 4.1 Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### 4.2 Types

| Type | Usage |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, missing semicolons, etc. |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `chore` | Build process, dependencies, etc. |
| `ci` | CI configuration |

### 4.3 Examples

```
feat(camera): add auto-capture when document is stable

Add 500ms stability check before auto-capturing. Uses FFI edge detection
on downscaled frames (720p) for performance.

Closes #42
```

```
fix(ocr): handle empty text result gracefully

Prevents crash when OCR returns empty string for blank page.
Now shows appropriate empty state message.
```

---

## 5. Code Review Checklist

| Check | Category |
|---|---|
| Does the code follow Clean Architecture layer rules? | Architecture |
| Are there no circular dependencies? | Architecture |
| Are all repository methods returning `Result<T>`? | Error handling |
| Are there no `print()` statements? | Debugging |
| Are all strings localized (future)? | i18n |
| Are all async operations properly awaited? | Async |
| Are all BLoC states handled in UI? | UI |
| Are there no magic numbers / string literals? | Constants |
| Are FFI pointers freed after use? | Memory |
| Do tests cover success and error paths? | Testing |
