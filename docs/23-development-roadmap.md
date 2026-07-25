# VisionNote AI — Development Roadmap

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Technical Lead / Product Manager

---

## 1. Development Phases Overview

```
Phase 1: Foundation (Sprints 1-3)    → MVP Core: Camera + Crop + Enhance + OCR
Phase 2: Infrastructure (Sprints 4-5) → History, Settings, Export, Theme
Phase 3: AI Integration (Sprints 6-8) → AI Features: Summary, Action Items, Flashcards
Phase 4: Polish (Sprints 9-10)       → Performance, Testing, Release
Phase 5: Post-MVP (Future)           → Semantic Search, Multi-page, Cloud Sync
```

---

## 2. Sprint Plan (2-week sprints)

### Phase 1: Foundation (6 weeks)

#### Sprint 1: Project Setup & Architecture
| Task | Effort | Owner |
|---|---|---|
| Initialize Flutter project with Clean Architecture structure | 1d | Architect |
| Configure `get_it` + `injectable` DI | 1d | Architect |
| Set up `auto_route` with all routes | 1d | Flutter Eng |
| Set up Drift database with Scans table | 2d | Flutter Eng |
| Set up Hive for settings cache | 1d | Flutter Eng |
| Set up `flutter_secure_storage` | 0.5d | Flutter Eng |
| Create Theme system (light/dark) | 1d | UI/UX + Flutter Eng |
| Create Design System widgets (buttons, cards, inputs) | 3d | UI/UX + Flutter Eng |
| Set up OpenCV C++ project structure | 2d | Native Eng |
| Implement Canny edge detection in C++ | 2d | Native Eng |
| Create Dart FFI bindings | 1d | Native Eng |
| Set up CI/CD (GitHub Actions) | 1d | DevOps |
| **Sprint total** | **~16d** | |

#### Sprint 2: Camera & Capture
| Task | Effort | Owner |
|---|---|---|
| Implement CameraScreen with camera plugin | 3d | Flutter Eng |
| Camera BLoC with events/states | 2d | Flutter Eng |
| Real-time edge detection overlay (CustomPainter) | 2d | Flutter Eng |
| Wire FFI edge detection into camera stream | 2d | Native Eng + Flutter Eng |
| Implement auto-capture logic (500ms stability check) | 2d | Flutter Eng |
| Manual shutter button + flash toggle | 1d | Flutter Eng |
| Camera permission handling | 1d | Flutter Eng |
| Onboarding screen (3 pages) | 2d | UI/UX + Flutter Eng |
| **Sprint total** | **~15d** | |

#### Sprint 3: Crop & Enhancement
| Task | Effort | Owner |
|---|---|---|
| Implement CropEditorScreen with interactive viewer | 3d | Flutter Eng |
| Draggable corner handles | 2d | Flutter Eng |
| Wire FFI perspective correction | 2d | Native Eng + Flutter Eng |
| Implement EnhancementScreen with before/after | 2d | Flutter Eng |
| Implement FFI auto-enhance pipeline | 3d | Native Eng |
| Manual brightness/contrast/saturation sliders | 2d | Flutter Eng |
| ImageProcess BLoC | 2d | Flutter Eng |
| **Sprint total** | **~16d** | |

---

### Phase 2: Infrastructure (4 weeks)

#### Sprint 4: OCR & Export
| Task | Effort | Owner |
|---|---|---|
| Integrate Google ML Kit text recognition | 3d | Flutter Eng |
| Fallback: Tesseract via FFI | 3d | Native Eng |
| OCR BLoC with language selection | 2d | Flutter Eng |
| OCRPreviewScreen with editable text | 2d | Flutter Eng |
| Export BLoC | 1d | Flutter Eng |
| Export to Markdown implementation | 1d | Flutter Eng |
| Export to TXT implementation | 0.5d | Flutter Eng |
| Copy to clipboard | 0.5d | Flutter Eng |
| Share sheet integration | 1d | Flutter Eng |
| **Sprint total** | **~14d** | |

#### Sprint 5: History & Settings
| Task | Effort | Owner |
|---|---|---|
| HistoryScreen with scrollable list | 2d | Flutter Eng |
| History BLoC | 1d | Flutter Eng |
| SQLite FTS5 search integration | 2d | Flutter Eng |
| Tag management (add/remove) | 2d | Flutter Eng |
| Scan detail screen | 2d | Flutter Eng |
| Delete scan functionality | 1d | Flutter Eng |
| SettingsScreen implementation | 3d | Flutter Eng |
| Settings BLoC + Hive persistence | 2d | Flutter Eng |
| Home dashboard with recent scans | 2d | Flutter Eng |
| **Sprint total** | **~17d** | |

---

### Phase 3: AI Integration (6 weeks)

#### Sprint 6: AI Provider Infrastructure
| Task | Effort | Owner |
|---|---|---|
| IAIClient abstract interface | 1d | AI Solutions Arch |
| GeminiClient implementation | 2d | Flutter Eng |
| OpenAIClient implementation | 2d | Flutter Eng |
| AI Repository with provider switching | 2d | Flutter Eng |
| Secure API key storage flow | 1d | Flutter Eng |
| AI provider selection in Settings | 1d | Flutter Eng |
| Connectivity observer for offline detection | 1d | Flutter Eng |
| AI BLoC base structure | 2d | Flutter Eng |
| **Sprint total** | **~12d** | |

#### Sprint 7: AI Features (Part 1)
| Task | Effort | Owner |
|---|---|---|
| Prompt engineering — Summary | 1d | AI Solutions Arch |
| AISummaryScreen with bullet-point display | 2d | Flutter Eng |
| Prompt engineering — Action Items | 1d | AI Solutions Arch |
| Action items table widget | 2d | Flutter Eng |
| Prompt engineering — Flashcards | 1d | AI Solutions Arch |
| Flashcard interactive widget (tap to flip) | 2d | Flutter Eng |
| Offline state handling for AI features | 1d | Flutter Eng |
| **Sprint total** | **~10d** | |

#### Sprint 8: AI Features (Part 2) + Export
| Task | Effort | Owner |
|---|---|---|
| Mind map generation prompt + Mermaid viewer | 3d | AI + Flutter Eng |
| Translation feature | 2d | Flutter Eng |
| Grammar correction feature | 2d | Flutter Eng |
| Chat Q&A screen implementation | 3d | Flutter Eng |
| AI JSON mode for deterministic parsing | 1d | Flutter Eng |
| PDF export with formatted layout | 3d | Flutter Eng |
| JSON export with structured data | 1d | Flutter Eng |
| Include AI content in export toggle | 1d | Flutter Eng |
| **Sprint total** | **~16d** | |

---

### Phase 4: Polish (4 weeks)

#### Sprint 9: Performance & Testing
| Task | Effort | Owner |
|---|---|---|
| Performance optimization — image pipeline | 2d | All Engineers |
| Memory profiling and leak fixes | 2d | Flutter Eng |
| Unit tests — Domain layer (100%) | 2d | Flutter Eng |
| Unit tests — BLoC layer (90%) | 3d | Flutter Eng |
| Unit tests — Data layer (90%) | 2d | Flutter Eng |
| Unit tests — FFI bindings (90%) | 2d | Native Eng |
| Performance benchmarks | 1d | QA |
| **Sprint total** | **~14d** | |

#### Sprint 10: QA & Release
| Task | Effort | Owner |
|---|---|---|
| Widget tests — all screens | 3d | Flutter Eng |
| Widget tests — all custom widgets | 2d | Flutter Eng |
| Integration tests — critical flows | 3d | QA |
| Accessibility audit | 2d | QA |
| Device compatibility testing (top 10 devices) | 3d | QA |
| iOS App Store submission prep | 2d | DevOps |
| Android Play Store submission prep | 1d | DevOps |
| Bug fixes from QA | 3d | All |
| Final release build | 1d | DevOps |
| **Sprint total** | **~20d** | |

---

## 3. Milestones

| Milestone | Date | Deliverable |
|---|---|---|
| M1: Architecture Complete | End of Sprint 1 | DI, DB, Router, Theme, FFI bindings configured |
| M2: Camera MVP | End of Sprint 2 | Capture, crop with corner detection |
| M3: Enhance + OCR MVP | End of Sprint 4 | Full capture → enhance → OCR → TXT export pipeline |
| M4: History + Settings | End of Sprint 5 | Persistent history, search, settings |
| M5: AI Integration | End of Sprint 8 | Summary, action items, flashcards, chat, mind map, translation, grammar |
| M6: Release Ready | End of Sprint 10 | All tests passing, performance targets met, app store submissions |

---

## 4. Resource Allocation

| Role | Sprint 1-3 | Sprint 4-5 | Sprint 6-8 | Sprint 9-10 |
|---|---|---|---|---|
| Flutter Architect (1) | 100% | 50% | 25% | 25% |
| Flutter Engineer (2) | 100% | 100% | 100% | 100% |
| Native/C++ Engineer (1) | 100% | 50% | — | 50% |
| UI/UX Designer (1) | 100% | 50% | 25% | 25% |
| AI Solutions Architect (1) | — | — | 100% | 50% |
| QA Engineer (1) | — | 50% | 50% | 100% |

---

## 5. Post-MVP Roadmap (Q1 2027+)

| Feature | Priority | Estimated Effort | Quarter |
|---|---|---|---|
| AI Semantic Search (vector embeddings) | P1 | 4 weeks | Q1 2027 |
| Multi-Page Document Support | P1 | 3 weeks | Q1 2027 |
| Cloud Sync (opt-in, provider-agnostic) | P2 | 6 weeks | Q2 2027 |
| Handwriting Recognition Improvement | P2 | 4 weeks | Q2 2027 |
| Team Collaboration (shared notebooks) | P2 | 8 weeks | Q3 2027 |
| AI-Generated Quizzes | P2 | 3 weeks | Q2 2027 |
| Voice Summaries (TTS) | P3 | 2 weeks | Q3 2027 |
| Plugin Architecture for AI Providers | P3 | 4 weeks | Q3 2027 |
| Web Platform Support | P3 | 8 weeks | Q4 2027 |

---

## 6. Dependencies & Critical Path

```
Critical Path:
Sprint 1 (Architecture)
  → Sprint 2 (Camera + FFI)
    → Sprint 3 (Crop + Enhance + FFI)
      → Sprint 4 (OCR + Export)        [MVP Gate]
        → Sprint 6 (AI Providers)
          → Sprint 7 (AI Features)
            → Sprint 9 (Performance + Testing)
              → Sprint 10 (QA + Release)

Parallel Paths:
  Sprint 5 (History + Settings) — can run parallel to Sprint 4
  Sprint 8 (AI Part 2) — depends on Sprint 6-7
  OpenCV C++ functions — continuous across Sprints 1-3
```
