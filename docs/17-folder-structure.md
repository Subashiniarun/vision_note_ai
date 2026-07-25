# VisionNote AI — Folder Structure Convention

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. Top-Level Structure

```
vision_note_ai/
├── android/                         # Android platform files
├── ios/                             # iOS platform files
├── lib/
│   ├── core/                        # Shared kernel
│   │   ├── constants/
│   │   ├── database/
│   │   ├── di/
│   │   ├── error/
│   │   ├── extensions/
│   │   ├── network/
│   │   ├── router/
│   │   ├── storage/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   ├── about/
│   │   ├── ai/
│   │   ├── camera/
│   │   ├── export/
│   │   ├── history/
│   │   ├── image_process/
│   │   ├── onboarding/
│   │   ├── ocr/
│   │   ├── scan/
│   │   └── settings/
│   └── native/
│       ├── ffi/
│       └── opencv/
├── native/                          # C++ native source
│   └── opencv_processor/
│       ├── android/
│       ├── ios/
│       └── src/
├── test/
│   ├── core/
│   ├── features/
│   │   ├── scan/
│   │   ├── camera/
│   │   ├── ocr/
│   │   ├── ai/
│   │   ├── export/
│   │   └── settings/
│   └── native/
├── integration_test/
├── assets/
│   ├── fonts/
│   ├── images/
│   └── onboarding/
├── docs/                            # Documentation suite
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 2. Feature Structure (Feature-First)

Each feature follows consistent Clean Architecture layers:

```
features/
└── <feature_name>/
    ├── presentation/
    │   ├── bloc/
    │   │   ├── <feature>_bloc.dart
    │   │   ├── <feature>_event.dart
    │   │   └── <feature>_state.dart
    │   ├── screens/
    │   │   └── <feature>_screen.dart
    │   └── widgets/
    │       ├── <widget1>.dart
    │       └── <widget2>.dart
    ├── domain/
    │   ├── entities/
    │   │   └── <entity>.dart
    │   ├── repositories/
    │   │   └── i_<feature>_repository.dart
    │   └── usecases/
    │       ├── <usecase_1>.dart
    │       └── <usecase_2>.dart
    └── data/
        ├── datasources/
        │   ├── local/
        │   │   └── <feature>_local_datasource.dart
        │   └── remote/
        │       └── <feature>_remote_datasource.dart  # Future
        ├── models/
        │   └── <model>_dto.dart
        └── repositories/
            └── <feature>_repository.dart
```

---

## 3. Detailed Directory Map

### 3.1 Core Layer

```
lib/core/
├── constants/
│   ├── app_constants.dart           # App-wide constants (app name, version)
│   ├── asset_paths.dart             # Asset string constants
│   └── api_constants.dart           # API URLs, endpoints
├── database/
│   ├── app_database.dart            # Drift DB definition
│   ├── tables/
│   │   ├── scans.dart               # Scans table
│   │   └── tags.dart                # Tags table
│   └── daos/
│       └── scans_dao.dart           # Scans data access object
├── di/
│   ├── injection.dart               # get_it + injectable init
│   └── modules/
│       ├── app_module.dart           # Core dependencies
│       ├── ai_module.dart            # AI provider bindings
│       └── native_module.dart        # FFI bindings
├── error/
│   ├── exceptions.dart              # Custom exception classes
│   └── failures.dart                # Failure sealed class
├── extensions/
│   ├── context_extensions.dart      # BuildContext helpers
│   ├── datetime_extensions.dart     # DateTime formatting
│   └── string_extensions.dart       # String utilities
├── network/
│   ├── api_client.dart              # HTTP client wrapper
│   └── connectivity_service.dart    # Network state observer
├── router/
│   ├── app_router.dart              # auto_route config
│   └── guards/
│       └── onboarding_guard.dart
├── storage/
│   ├── file_storage.dart            # File system operations
│   └── secure_storage_service.dart  # flutter_secure_storage
├── theme/
│   ├── bloc/
│   │   ├── theme_bloc.dart
│   │   ├── theme_event.dart
│   │   └── theme_state.dart
│   ├── app_theme.dart               # Light/dark theme definitions
│   ├── colors.dart                  # Color palette
│   └── typography.dart              # Text styles
└── utils/
    ├── debouncer.dart               # Search debouncing
    ├── image_utils.dart             # Image helper functions
    └── permission_utils.dart        # Permission request helpers
```

### 3.2 Feature — Scan

```
lib/features/scan/
├── presentation/
│   ├── bloc/
│   │   ├── scan_bloc.dart
│   │   ├── scan_event.dart
│   │   └── scan_state.dart
│   ├── screens/
│   │   ├── home_screen.dart         # Dashboard with recent scans
│   │   └── scan_detail_screen.dart  # Single scan view
│   └── widgets/
│       ├── scan_card.dart           # History card widget
│       ├── recent_scans_grid.dart   # Grid of recent scans
│       └── scan_app_bar.dart        # Dynamic app bar
├── domain/
│   ├── entities/
│   │   └── scan.dart                # Core Scan entity
│   ├── repositories/
│   │   └── i_scan_repository.dart
│   └── usecases/
│       ├── get_recent_scans.dart
│       ├── save_scan.dart
│       ├── delete_scan.dart
│       ├── update_scan.dart
│       └── search_scans.dart
└── data/
    ├── datasources/
    │   └── local/
    │       └── scan_local_datasource.dart
    ├── models/
    │   └── scan_dto.dart
    └── repositories/
        └── scan_repository.dart
```

### 3.3 Feature — Camera

```
lib/features/camera/
├── presentation/
│   ├── bloc/
│   │   ├── camera_bloc.dart
│   │   ├── camera_event.dart
│   │   └── camera_state.dart
│   ├── screens/
│   │   └── camera_screen.dart
│   └── widgets/
│       ├── camera_viewfinder.dart
│       ├── edge_overlay.dart         # Custom painter for edges
│       ├── shutter_button.dart
│       └── guide_frame.dart
├── domain/
│   ├── entities/
│   │   └── camera_config.dart
│   └── repositories/
│       └── i_camera_repository.dart   # If needed
└── data/
    └── repositories/
        └── camera_repository.dart
```

### 3.4 Feature — Image Process

```
lib/features/image_process/
├── presentation/
│   ├── bloc/
│   │   ├── image_process_bloc.dart
│   │   ├── image_process_event.dart
│   │   └── image_process_state.dart
│   ├── screens/
│   │   ├── crop_editor_screen.dart
│   │   └── enhancement_screen.dart
│   └── widgets/
│       ├── crop_canvas.dart           # Interactive viewer with handles
│       ├── corner_handle.dart         # Draggable corner widget
│       ├── enhancement_sliders.dart   # Slider panel
│       └── before_after_toggle.dart   # Comparison widget
├── domain/
│   ├── entities/
│   │   ├── crop_rect.dart
│   │   └── enhancement_params.dart
│   └── repositories/
│       └── i_image_processor.dart
└── data/
    └── repositories/
        └── opencv_image_processor.dart
```

### 3.5 Feature — OCR

```
lib/features/ocr/
├── presentation/
│   ├── bloc/
│   │   ├── ocr_bloc.dart
│   │   ├── ocr_event.dart
│   │   └── ocr_state.dart
│   ├── screens/
│   │   └── ocr_preview_screen.dart
│   └── widgets/
│       ├── ocr_text_view.dart         # Scrollable text
│       ├── ocr_confidence_indicator.dart
│       └── language_selector.dart
├── domain/
│   ├── entities/
│   │   └── ocr_result.dart
│   └── repositories/
│       └── i_ocr_repository.dart
└── data/
    ├── datasources/
    │   └── local/
    │       └── ocr_engine.dart          # ML Kit / Tesseract wrapper
    └── repositories/
        └── ocr_repository.dart
```

### 3.6 Feature — AI

```
lib/features/ai/
├── presentation/
│   ├── bloc/
│   │   ├── ai_bloc.dart
│   │   ├── ai_event.dart
│   │   └── ai_state.dart
│   ├── screens/
│   │   ├── ai_summary_screen.dart
│   │   └── chat_screen.dart
│   └── widgets/
│       ├── ai_result_card.dart
│       ├── action_item_tile.dart
│       ├── flashcard_widget.dart
│       ├── mind_map_viewer.dart
│       └── chat_bubble.dart
├── domain/
│   ├── entities/
│   │   ├── ai_summary.dart
│   │   ├── action_item.dart
│   │   ├── flashcard.dart
│   │   └── chat_message.dart
│   └── repositories/
│       └── i_ai_repository.dart
└── data/
    ├── datasources/
    │   └── remote/
    │       ├── gemini_client.dart
    │       └── openai_client.dart
    ├── models/
    │   └── prompt_templates.dart
    └── repositories/
        └── ai_repository.dart
```

### 3.7 Feature — Export

```
lib/features/export/
├── presentation/
│   ├── bloc/
│   │   ├── export_bloc.dart
│   │   ├── export_event.dart
│   │   └── export_state.dart
│   ├── screens/
│   │   └── export_screen.dart
│   └── widgets/
│       ├── format_card.dart          # Markdown, PDF, TXT, JSON
│       └── ai_toggle.dart            # Include AI content toggle
├── domain/
│   ├── entities/
│   │   └── export_options.dart
│   └── repositories/
│       └── i_export_repository.dart
└── data/
    └── repositories/
        └── export_repository.dart
```

### 3.8 Feature — History

```
lib/features/history/
├── presentation/
│   ├── bloc/
│   │   ├── history_bloc.dart
│   │   ├── history_event.dart
│   │   └── history_state.dart
│   ├── screens/
│   │   └── history_screen.dart
│   └── widgets/
│       ├── history_list.dart
│       ├── history_search_bar.dart
│       └── tag_chip.dart
├── domain/
│   └── repositories/
│       └── i_history_repository.dart   # Could reuse IScanRepository
└── data/
    └── repositories/
        └── history_repository.dart
```

### 3.9 Feature — Settings

```
lib/features/settings/
├── presentation/
│   ├── bloc/
│   │   ├── settings_bloc.dart
│   │   ├── settings_event.dart
│   │   └── settings_state.dart
│   ├── screens/
│   │   └── settings_screen.dart
│   └── widgets/
│       ├── settings_section.dart
│       ├── settings_tile.dart
│       └── api_key_field.dart
├── domain/
│   ├── entities/
│   │   └── app_settings.dart
│   └── repositories/
│       └── i_settings_repository.dart
└── data/
    ├── datasources/
    │   └── local/
    │       └── settings_cache.dart      # Hive-backed
    └── repositories/
        └── settings_repository.dart
```

### 3.10 Native / FFI

```
lib/native/
├── ffi/
│   ├── opencv_bindings.dart          # All FFI function typedefs
│   ├── opencv_library.dart           # DynamicLibrary loader
│   └── opencv_service.dart           # High-level FFI service
└── opencv/                           # (Reference, actual C++ in /native/)
    └── README.md

native/
└── opencv_processor/
    ├── CMakeLists.txt                # Android build config
    ├── opencv_processor.xcodeproj/   # iOS Xcode project
    ├── android/
    │   └── src/main/cpp/
    │       ├── process.cpp
    │       ├── process.h
    │       ├── enhance.cpp
    │       ├── enhance.h
    │       ├── utils.cpp
    │       └── utils.h
    ├── ios/
    │   └── Classes/
    │       ├── process.cpp
    │       ├── process.h
    │       ├── enhance.cpp
    │       └── enhance.h
    └── src/
        ├── edge_detection.cpp
        ├── perspective_correction.cpp
        ├── enhancement_pipeline.cpp
        ├── deskew.cpp
        └── image_utils.cpp
```

---

## 4. File Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Screen files | `snake_case_screen.dart` | `home_screen.dart` |
| BLoC files | `snake_case_bloc.dart` | `camera_bloc.dart` |
| Event files | `snake_case_event.dart` | `camera_event.dart` |
| State files | `snake_case_state.dart` | `camera_state.dart` |
| Use cases | `snake_case.dart` | `get_recent_scans.dart` |
| Entities | `snake_case.dart` | `ocr_result.dart` |
| Repository interfaces | `i_snake_case_repository.dart` | `i_scan_repository.dart` |
| Repository implementations | `snake_case_repository.dart` | `scan_repository.dart` |
| DTOs / Models | `snake_case_dto.dart` | `scan_dto.dart` |
| Widgets | `snake_case_widget.dart` | `scan_card.dart` |
| C++ files | `snake_case.cpp` | `edge_detection.cpp` |

---

## 5. Import Rules

```yaml
# analysis_options.yaml
linter:
  rules:
    - always_use_package_imports: true
    - avoid_relative_lib_imports: true
```

- Use package imports only: `import 'package:vision_note_ai/features/...'`
- Dart files never import from a higher layer
- Presentation imports Domain only
- Data imports Domain and core utilities
- Domain imports nothing outside Domain
