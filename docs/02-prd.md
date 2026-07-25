# VisionNote AI — Product Requirements Document (PRD)

**Version:** 1.0  
**Date:** 2026-07-25  
**Status:** Draft  
**Author:** Product Manager

---

## 1. Purpose

This PRD defines the product requirements for VisionNote AI, a Flutter-based mobile application for scanning, processing, and intelligently extracting information from physical documents. It serves as the single source of truth for what the product must deliver across MVP and post-MVP phases.

## 2. Scope

### In Scope (MVP)

- Camera-based document capture (auto-edge detection)
- Image preprocessing pipeline (edge detect, perspective correct, denoise, threshold)
- OCR text extraction (offline)
- Text enhancement and review
- Export to Markdown, TXT, and clipboard
- Scan history with local storage
- Settings (theme, OCR language, export defaults)

### In Scope (Post-MVP — Q4 2026+)

- AI summarization, action items, flashcards
- AI mind maps, translation, grammar correction
- PDF export
- Semantic search
- Multi-page document support
- Cloud sync (optional opt-in)

### Out of Scope (V1)

- Real-time camera OCR overlay
- Hand-drawn diagram recognition (beyond text)
- Cloud-only features
- Collaborative editing
- Plugin SDK for third-party developers

## 3. User Workflows

### Primary Workflow: Capture → Process → OCR → Export

```
[Open App] → [Camera Screen] → [Auto-capture or Manual] →
[Crop Editor] → [Enhancement Preview] → [OCR Processing] →
[OCR Preview & Edit] → [Export]
```

### Secondary Workflow: AI Augmentation (Post-MVP)

```
[OCR Preview] → [AI Summary] → [Action Items] → [Flashcards]
→ [Mind Map] → [Export Selected Format]
```

### Tertiary Workflow: History & Search

```
[Home Dashboard] → [History] → [Search] → [Select Scan] →
[View/Edit] → [Re-export]
```

## 4. Features by Priority

| Feature | Priority | Phase |
|---|---|---|
| Camera capture with edge detection | P0 | MVP |
| Manual capture (tap to shoot) | P0 | MVP |
| Crop editor with corner adjustment | P0 | MVP |
| Image enhancement (auto) | P0 | MVP |
| Image enhancement (manual sliders) | P1 | MVP |
| OCR text extraction (offline) | P0 | MVP |
| OCR text preview and editing | P0 | MVP |
| Export to Markdown | P0 | MVP |
| Export to TXT | P0 | MVP |
| Copy to clipboard | P0 | MVP |
| Scan history list | P0 | MVP |
| History search (OCR text) | P1 | MVP |
| Tag management | P1 | MVP |
| Dark/Light theme | P0 | MVP |
| OCR language selection | P1 | MVP |
| Image quality / compression settings | P1 | MVP |
| AI summarization | P0 | Post-MVP |
| AI action items | P0 | Post-MVP |
| AI flashcards | P1 | Post-MVP |
| AI mind maps | P1 | Post-MVP |
| AI translation | P2 | Post-MVP |
| AI grammar correction | P2 | Post-MVP |
| PDF export | P1 | Post-MVP |
| JSON export | P1 | Post-MVP |
| AI semantic search | P2 | Post-MVP |
| Multi-page document | P2 | Post-MVP |
| Cloud sync (optional) | P2 | Post-MVP |

## 5. User Interface Requirements

### 5.1 Screens

| Screen | Route | Description |
|---|---|---|
| Splash | `/splash` | App loading with logo animation |
| Onboarding | `/onboarding` | 3-page intro carousel (skip + next) |
| Home Dashboard | `/home` | Recent scans grid/list, quick actions |
| Camera | `/camera` | Full-screen camera with edge overlay |
| Crop Editor | `/crop` | Corner handles for perspective crop |
| Image Enhancement | `/enhance` | Auto-enhance + manual sliders |
| OCR Preview | `/ocr-preview` | Extracted text with edit capability |
| AI Summary | `/ai-summary` | AI-generated summary view |
| Chat with Notes | `/chat` | Q&A interface over extracted text |
| Export | `/export` | Format picker + share sheet |
| History | `/history` | Scrollable list with search bar |
| Settings | `/settings` | All configuration options |
| About | `/about` | App version, licenses, credits |

### 5.2 Navigation

- **Bottom Navigation:** Home, Camera (center FAB), History, Settings
- **Modal Routes:** Crop Editor, Enhancement, OCR Preview, Export
- **Push Routes:** AI Summary, Chat, Onboarding, About

## 6. Performance Targets

| Metric | Target | Measurement |
|---|---|---|
| App cold start | < 2s | On device launch to interactive |
| Camera launch | < 1s | From tapping camera to viewfinder |
| Auto-capture detection | < 300ms | From stable frame to capture signal |
| Image preprocessing | < 500ms | Full edge→crop→enhance→threshold pipeline |
| OCR processing (full page) | < 3s | From enhanced image to text output |
| AI summary generation | < 5s | From request to response (with network) |
| History load (100 items) | < 500ms | List rendering with thumbnails |

## 7. Platform Requirements

- **Minimum SDK:** Android API 26 (8.0 Oreo), iOS 15.0
- **Target SDK:** Android 34, iOS 17
- **Form Factors:** Phones (primary), Tablets (adapted layout)
- **Orientation:** Portrait primary, landscape supported in camera
- **Permissions:** Camera, Storage (Android 13+ scoped), Internet (AI features)

## 8. Assumptions

1. Users have devices with cameras capable of 1080p capture minimum.
2. Internet is not available for core scanning/OCR workflow.
3. Users are comfortable with AI processing their extracted text (no PII stored).
4. OpenCV native libraries will be compiled per-platform for arm64-v8a, armeabi-v7a, x86_64.
5. Google ML Kit or Tesseract will be used for offline OCR.
