# VisionNote AI — Software Requirements Specification (SRS)

**Version:** 1.0  
**Date:** 2026-07-25  
**Status:** Draft  
**Author:** Technical Lead

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) describes the functional and non-functional requirements for VisionNote AI. It is intended for use by the development team to implement the system.

### 1.2 Document Conventions

- `REQ-F-XXXX` — Functional Requirement
- `REQ-NF-XXXX` — Non-Functional Requirement
- `[MUST]` — Mandatory for release
- `[SHOULD]` — Desirable but not mandatory for MVP
- `[OPTIONAL]` — Future enhancement

### 1.3 Definitions

| Term | Definition |
|---|---|
| FFI | Foreign Function Interface — calling C++ code from Dart |
| OCR | Optical Character Recognition |
| BLoC | Business Logic Component — state management pattern |
| Drift | SQLite ORM for Dart |
| Hive | Key-value storage for settings/cache |
| OpenCV | Open Source Computer Vision Library |

---

## 2. Overall Description

### 2.1 Product Perspective

VisionNote AI is a self-contained mobile application with no server-side dependency for core functionality. The system comprises:

- **Flutter UI Layer** — All screens and widgets
- **BLoC Layer** — Business logic and state management
- **Repository Layer** — Data abstraction over local sources
- **Native FFI Layer** — C++/OpenCV image processing
- **OCR Engine** — Local Tesseract/ML Kit integration
- **AI Provider Layer** — Pluggable Gemini/OpenAI clients

### 2.2 User Characteristics

| Class | Technical Level | Usage Pattern |
|---|---|---|
| Student | Low-Medium | Daily note capture, flashcard generation |
| Professional | Medium | Meeting notes, whiteboard captures, exports |
| Power User | High | Bulk scanning, semantic search, AI workflows |

### 2.3 Operating Environment

- Android 8.0+ (API 26)
- iOS 15.0+
- Minimum 3GB RAM recommended
- 200MB free storage for app + models

---

## 3. External Interface Requirements

### 3.1 Hardware Interfaces

- **Camera:** Access via `camera` Flutter plugin. Minimum 1080p capture at 30fps. Auto-focus required.
- **Storage:** Read/write to app-specific and shared storage for exports.

### 3.2 Software Interfaces

- **OCR:** Tesseract via `tesseract_ffi` or Google ML Kit Text Recognition via `google_mlkit_text_recognition`.
- **OpenCV:** Precompiled C++ libraries loaded via `dart:ffi`.
- **AI Providers:** HTTP REST clients for Gemini API and OpenAI API (interchangeable via config).

### 3.3 Communication Interfaces

- **AI Feature Network Calls:** HTTPS only. TLS 1.2+ required.
- **No telemetry or analytics in MVP** (user opt-in for future versions).

---

## 4. Functional Requirements Summary

| ID | Title | Priority |
|---|---|---|
| REQ-F-001 | Camera capture with auto edge detection | P0 |
| REQ-F-002 | Manual photo capture | P0 |
| REQ-F-003 | Document corner detection | P0 |
| REQ-F-004 | Perspective correction | P0 |
| REQ-F-005 | Auto image enhancement | P0 |
| REQ-F-006 | Manual image adjustment | P1 |
| REQ-F-007 | OCR text extraction (offline) | P0 |
| REQ-F-008 | OCR text editing | P0 |
| REQ-F-009 | Export to Markdown | P0 |
| REQ-F-010 | Export to TXT | P0 |
| REQ-F-011 | Export to PDF | P1 |
| REQ-F-012 | Copy to clipboard | P0 |
| REQ-F-013 | Scan history | P0 |
| REQ-F-014 | History search | P1 |
| REQ-F-015 | Tag management | P1 |
| REQ-F-016 | AI summarization | P0 |
| REQ-F-017 | AI action items | P1 |
| REQ-F-018 | AI flashcards | P1 |
| REQ-F-019 | AI mind map | P1 |
| REQ-F-020 | AI translation | P2 |
| REQ-F-021 | AI grammar correction | P2 |
| REQ-F-022 | Semantic search | P2 |
| REQ-F-023 | Dark/Light theme | P0 |
| REQ-F-024 | Settings persistence | P0 |
| REQ-F-025 | Onboarding flow | P0 |
| REQ-F-026 | Multi-page document support | P2 |

Full behavior specifications for each requirement are provided in the Feature Specifications document (docs/07-feature-specs.md).
