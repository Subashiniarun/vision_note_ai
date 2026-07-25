# VisionNote AI — High-Level Architecture (HLD)

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. System Overview

VisionNote AI follows **Clean Architecture** with a **feature-first** folder structure. The application is divided into three main layers:

```
┌─────────────────────────────────────────────────────┐
│                    PRESENTATION                      │
│  (Flutter UI / BLoC / Widgets / Screens)             │
├─────────────────────────────────────────────────────┤
│                      DOMAIN                          │
│  (Entities / Use Cases / Repository Interfaces)      │
├─────────────────────────────────────────────────────┤
│                       DATA                           │
│  (Repository Implementations / Data Sources / DTOs)  │
├─────────────────────────────────────────────────────┤
│                   NATIVE / FFI                        │
│  (OpenCV C++ / Tesseract / ML Kit / AI Clients)      │
└─────────────────────────────────────────────────────┘
```

## 2. Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                          │
│                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  Screens │  │ Widgets  │  │   BLoCs  │  │  Events  │         │
│  │          │  │          │  │          │  │ /States  │         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘         │
│       │              │             │             │                │
│       └──────────────┴─────────────┴─────────────┘                │
│                             │                                     │
│                             ▼                                     │
│                    ┌────────────────┐                             │
│                    │  DI Container  │  (get_it + injectable)      │
│                    └────────────────┘                             │
└──────────────────────────┬───────────────────────────────────────┘
                           │  injects Use Cases
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                               │
│                                                                   │
│  ┌────────────┐    ┌──────────────┐    ┌─────────────────────┐   │
│  │  Entities  │    │   Use Cases  │    │  Repository          │   │
│  │            │    │              │    │  Interfaces          │   │
│  │  Scan      │    │  ScanDoc     │    │                     │   │
│  │  OCRResult │    │  ProcessImage│    │  IScanRepository     │   │
│  │  AISummary │    │  ExportDoc   │    │  IAIRepository       │   │
│  │            │    │  ...         │    │  IExportRepository   │   │
│  └────────────┘    └──────────────┘    └─────────────────────┘   │
└──────────────────────────┬───────────────────────────────────────┘
                           │  implements
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                                │
│                                                                   │
│  ┌──────────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │  Repository Impl │  │  Data Sources│  │      DTOs        │    │
│  │                  │  │              │  │                  │    │
│  │  ScanRepository  │  │  DriftDB     │  │  ScanDTO         │    │
│  │  AIRepository    │  │  HiveCache   │  │  AISummaryDTO    │    │
│  │  ExportRepository│  │  SecureStore │  │  ExportDTO       │    │
│  └──────────────────┘  └──────┬───────┘  └──────────────────┘    │
│                               │                                    │
│                               ▼                                    │
│                    ┌──────────────────────┐                       │
│                    │    Native Bridge     │                       │
│                    │    (FFI Service)      │                       │
│                    └──────────────────────┘                       │
└──────────────────────────┬───────────────────────────────────────┘
                           │  dart:ffi
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│                       NATIVE LAYER (C++)                          │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐    │
│  │  OpenCV      │  │  OCR Engine  │  │  Image Enhancement   │    │
│  │  Processor   │  │  (Tesseract  │  │  Pipeline            │    │
│  │              │  │   /ML Kit)   │  │                      │    │
│  │  Edge Detect │  │              │  │  Denoise             │    │
│  │  Perspective │  │  Text        │  │  Adaptive Threshold  │    │
│  │  Correction  │  │  Recognition │  │  Deskew              │    │
│  └──────────────┘  └──────────────┘  └──────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘

                           NETWORK
┌──────────────────────────────────────────────────────────────────┐
│                      AI PROVIDER LAYER                            │
│                                                                   │
│  ┌──────────────────┐    ┌──────────────────┐                    │
│  │  Gemini Client   │    │  OpenAI Client   │                    │
│  │  (REST / HTTP)   │    │  (REST / HTTP)   │                    │
│  └──────────────────┘    └──────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

## 3. Component Responsibilities

| Component | Responsibility |
|---|---|
| **Screens** | Flutter `Scaffold` pages, route destinations, compose widgets |
| **Widgets** | Reusable UI components (buttons, cards, sliders, overlays) |
| **BLoCs** | State management, business logic orchestration, event→state mapping |
| **Use Cases** | Single-responsibility business operations |
| **Entities** | Core business objects with no framework dependencies |
| **Repository Interfaces** | Abstract contracts for data operations |
| **Repository Implementations** | Concrete data operations combining local + native sources |
| **Data Sources** | Drift (SQLite), Hive, flutter_secure_storage |
| **DTOs** | Data transfer objects for serialization |
| **Native Bridge (FFI)** | Dart FFI bindings to C++ OpenCV functions |
| **OpenCV Processor** | C++ image processing functions compiled per-platform |
| **OCR Engine** | Tesseract/ML Kit integration for local text recognition |
| **AI Clients** | HTTP clients for Gemini/OpenAI API |

## 4. Key Architectural Decisions

| Decision | Rationale |
|---|---|
| **Clean Architecture** | Separates concerns, enables testability, allows swapping implementations |
| **Feature-first folders** | Groups all layers by feature for developer navigation |
| **BLoC** | Formal state machine, testable, widely adopted in Flutter ecosystem |
| **FFI for image processing** | OpenCV in C++ runs 10-50x faster than pure Dart pixel manipulation |
| **Repository pattern** | Abstracts data sources, enables offline-first with local fallback |
| **Drift for structured data** | Type-safe SQLite ORM with migrations and FTS5 search |
| **Hive for settings** | Extremely fast key-value storage, < 1ms read times |
| **Pluggable AI** | Strategy pattern for AI providers avoids vendor lock-in |

## 5. Data Flow (Scan to Export)

```
User taps Camera FAB
  → CameraScreen displays viewfinder
  → CameraBloc streams frames to FFI edge detector
  → FFI returns corner coordinates
  → EdgeOverlay renders detected quadrilateral
  → Auto-capture triggers (or user taps shutter)
  → Capture image saved as File
  → Navigate to CropEditor with image path

User adjusts corners / confirms
  → CropBloc sends image + corners to FFI perspective correct
  → FFI returns warped image bytes
  → Navigate to EnhancementScreen

User taps Auto Enhance (or adjusts sliders)
  → EnhanceBloc sends image to FFI enhancement pipeline
  → FFI returns enhanced bytes + preview
  → User confirms → navigate to OCRPreview

User taps Extract Text
  → OCRBloc sends enhanced image to OCR engine
  → OCR engine returns text blocks
  → Display editable text preview
  → User can edit, then proceed to AI or Export

User selects AI feature
  → AIBloc sends text to configured provider (Gemini/OpenAI)
  → Provider returns structured output
  → Display AI result (summary, action items, etc.)

User selects Export
  → ExportBloc generates file in chosen format
  → Opens share sheet
  → Scan saved to History (Drift)
```

## 6. Dependency Graph

```
Screens → BLoCs → UseCases → Repository Interfaces
                                ↑
                      Repository Implementations
                                ↑
            ┌───────────────────┴───────────────────┐
            │                                       │
     Data Sources (Drift/Hive)           Native Bridge (FFI)
            │                                       │
            │                              OpenCV C++ / OCR
     SQLite / Hive Storage
```

## 7. Offline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         OFFLINE MODE                             │
│                                                                  │
│  Camera → [FFI: Edge Detect] → [FFI: Perspective] →             │
│  [FFI: Enhance] → [OCR: Local] → [Export: Local] →              │
│  [History: Drift DB]                                             │
│                                                                  │
│  AI Features: Disabled, UI shows "Connect to internet for AI"   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         ONLINE MODE                              │
│                                                                  │
│  Same pipeline + AI features available                           │
│  AI calls go through configured provider (Gemini/OpenAI)         │
└─────────────────────────────────────────────────────────────────┘
```
