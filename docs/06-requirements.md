# VisionNote AI — Functional & Non-Functional Requirements

**Version:** 1.0  
**Date:** 2026-07-25

---

## 1. Functional Requirements

### FR-1: Camera Capture

| ID | Requirement | Verification |
|---|---|---|
| FR-1.1 | The app SHALL display a real-time camera preview at minimum 1080p resolution. | Visual inspection |
| FR-1.2 | The app SHALL overlay detected document edges on the camera preview in real time (< 300ms latency). | Performance benchmark |
| FR-1.3 | The app SHALL auto-capture when the document is stably framed for 500ms with > 80% of the frame covered. | Integration test |
| FR-1.4 | The app SHALL provide a manual shutter button as an alternative. | Visual inspection |
| FR-1.5 | The app SHALL support a torch/flash toggle. | Visual inspection |

### FR-2: Crop & Perspective Correction

| ID | Requirement | Verification |
|---|---|---|
| FR-2.1 | The app SHALL display the captured image with four draggable corner handles. | Visual inspection |
| FR-2.2 | The app SHALL auto-detect document corners and pre-position handles accordingly. | Integration test |
| FR-2.3 | The app SHALL apply perspective transformation to produce a flat, rectangular document image. | Unit test (OpenCV) |
| FR-2.4 | The app SHALL allow the user to confirm or retake the cropped image. | Visual inspection |

### FR-3: Image Enhancement

| ID | Requirement | Verification |
|---|---|---|
| FR-3.1 | The app SHALL provide a one-tap "Auto Enhance" that applies shadow removal, contrast adjustment, adaptive thresholding, and denoising. | Unit test |
| FR-3.2 | The app SHALL provide manual sliders for brightness (-100 to +100), contrast (0 to 200%), saturation (0 to 200%). | Visual inspection |
| FR-3.3 | The app SHALL display a real-time preview of enhancement changes. | Visual inspection |
| FR-3.4 | The app SHALL support a before/after toggle on the enhancement screen. | Visual inspection |

### FR-4: OCR

| ID | Requirement | Verification |
|---|---|---|
| FR-4.1 | The app SHALL extract text from the enhanced image using a local OCR engine (Tesseract or ML Kit). | Unit test |
| FR-4.2 | OCR processing SHALL complete within 3 seconds for a standard document page. | Performance benchmark |
| FR-4.3 | The extracted text SHALL be displayed in a scrollable, editable text field. | Visual inspection |
| FR-4.4 | The app SHALL support at least 10 OCR languages: English, Spanish, French, German, Italian, Portuguese, Dutch, Russian, Japanese, Chinese. | Integration test |
| FR-4.5 | The selected OCR language SHALL persist across sessions. | Integration test |

### FR-5: AI Features

| ID | Requirement | Verification |
|---|---|---|
| FR-5.1 | The app SHALL extract text from the current document and generate a summary using the configured AI provider. | Integration test |
| FR-5.2 | The app SHALL extract action items from the text with assignee and deadline when inferable. | Integration test |
| FR-5.3 | The app SHALL generate study flashcards from the text in Q&A format. | Integration test |
| FR-5.4 | The app SHALL generate a Mermaid-compatible mind map from the document content. | Integration test |
| FR-5.5 | The app SHALL translate extracted text into a user-selected target language. | Integration test |
| FR-5.6 | The app SHALL correct grammar and OCR errors in the text before export. | Integration test |
| FR-5.7 | The app SHALL support a chat interface where the user can ask questions about the extracted text. | Integration test |

### FR-6: Export

| ID | Requirement | Verification |
|---|---|---|
| FR-6.1 | The app SHALL export the OCR text (with optional AI enhancements) as Markdown (.md). | Integration test |
| FR-6.2 | The app SHALL export as plain text (.txt). | Integration test |
| FR-6.3 | The app SHALL copy the text to the system clipboard. | Integration test |
| FR-6.4 | The app SHALL export as PDF (.pdf) with formatted layout. | Integration test |
| FR-6.5 | The app SHALL export as JSON (.json) with structured fields. | Integration test |
| FR-6.6 | The app SHALL open the native share sheet after export for easy sharing. | Visual inspection |

### FR-7: History

| ID | Requirement | Verification |
|---|---|---|
| FR-7.1 | Each scan SHALL be persisted locally with original image, enhanced image, OCR text, AI output, timestamp, and tags. | Integration test |
| FR-7.2 | The history screen SHALL display scans in reverse chronological order with thumbnail, title, and date. | Visual inspection |
| FR-7.3 | The app SHALL support searching history by OCR text content. | Integration test |
| FR-7.4 | The app SHALL support adding, editing, and removing tags on scans. | Integration test |
| FR-7.5 | The app SHALL support deleting individual scans or clearing all history. | Integration test |

### FR-8: Settings

| ID | Requirement | Verification |
|---|---|---|
| FR-8.1 | The app SHALL persist all settings in Hive for fast read/write. | Unit test |
| FR-8.2 | Settings SHALL include: dark/light theme, OCR language, AI provider (Gemini/OpenAI), AI API key, image quality, compression level, default export format. | Visual inspection |
| FR-8.3 | Theme changes SHALL apply immediately without restart. | Visual inspection |

---

## 2. Non-Functional Requirements

### NFR-1: Performance

| ID | Requirement | Target | Measurement |
|---|---|---|---|
| NFR-1.1 | App cold start time | ≤ 2 seconds | Android/iOS profiler |
| NFR-1.2 | Camera preview launch | ≤ 1 second | Profiler |
| NFR-1.3 | Auto-capture detection latency | ≤ 300ms | Profiler |
| NFR-1.4 | Image preprocessing pipeline (full) | ≤ 500ms | Profiler |
| NFR-1.5 | OCR processing time (full page) | ≤ 3 seconds | Profiler |
| NFR-1.6 | AI summary generation | ≤ 5 seconds (network) | Profiler |
| NFR-1.7 | History list load (100 items) | ≤ 500ms | Profiler |

### NFR-2: Reliability

| ID | Requirement | Target |
|---|---|---|
| NFR-2.1 | Crash-free session rate | ≥ 99.5% |
| NFR-2.2 | OCR accuracy (clean printed text) | ≥ 98% |
| NFR-2.3 | OCR accuracy (handwritten) | ≥ 85% |
| NFR-2.4 | Image processing should never crash on invalid input | 100% graceful handling |
| NFR-2.5 | App should handle camera permissions denied gracefully | Show guidance, not crash |

### NFR-3: Security

| ID | Requirement | Detail |
|---|---|---|
| NFR-3.1 | API keys SHALL be stored securely | Use flutter_secure_storage |
| NFR-3.2 | AI API calls SHALL use HTTPS only | TLS 1.2+ |
| NFR-3.3 | No user data shall be transmitted without explicit consent | All network calls require user action |
| NFR-3.4 | Image data SHALL remain on-device | No cloud upload by default |
| NFR-3.5 | Camera permission SHALL be requested contextually | Not at app install |

### NFR-4: Usability

| ID | Requirement | Target |
|---|---|---|
| NFR-4.1 | New users shall complete scan-to-export in ≤ 3 taps | UX audit |
| NFR-4.2 | All interactive elements shall have minimum touch target of 48x48dp | Accessibility check |
| NFR-4.3 | Text contrast ratio SHALL meet WCAG AA standards (4.5:1) | Accessibility audit |
| NFR-4.4 | The app SHALL support screen reader (TalkBack/VoiceOver) | Accessibility audit |

### NFR-5: Offline Capability

| ID | Requirement | Detail |
|---|---|---|
| NFR-5.1 | Camera capture, image processing, and OCR SHALL work fully offline | Verified with airplane mode |
| NFR-5.2 | All history and settings SHALL be accessible offline | Verified with airplane mode |
| NFR-5.3 | AI features SHALL gracefully show "offline" state when no network | Visual indicator |
| NFR-5.4 | OCR models SHALL be bundled or downloaded once at first launch | Verified |

### NFR-6: Maintainability

| ID | Requirement | Detail |
|---|---|---|
| NFR-6.1 | Code SHALL follow Clean Architecture principles | Architecture review |
| NFR-6.2 | All BLoC classes SHALL have unit tests | Coverage ≥ 90% |
| NFR-6.3 | Repository pattern SHALL be used for all data access | Architecture review |
| NFR-6.4 | AI provider SHALL be swappable via configuration | Verified by switching provider |
| NFR-6.5 | OpenCV pipeline functions SHALL be independently unit-testable | Unit tests per function |

### NFR-7: Compatibility

| ID | Requirement | Detail |
|---|---|---|
| NFR-7.1 | Minimum Android API: 26 (Oreo 8.0) | build.gradle config |
| NFR-7.2 | Minimum iOS version: 15.0 | Podfile config |
| NFR-7.3 | Supported architectures: arm64-v8a, armeabi-v7a, x86_64 (Android); arm64 (iOS) | Native library build |
| NFR-7.4 | The app SHALL support both phone and tablet layouts | Responsive breakpoints |

### NFR-8: Storage

| ID | Requirement | Detail |
|---|---|---|
| NFR-8.1 | Database size SHALL not exceed 100MB for 500 scans | Performance test |
| NFR-8.2 | Settings read/write SHALL complete in < 10ms | Unit test |
| NFR-8.3 | Image files SHALL be compressed and stored with configurable quality | Settings option |
