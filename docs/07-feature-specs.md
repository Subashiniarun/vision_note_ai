# VisionNote AI — Feature Specifications

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Product Manager / Technical Lead

---

## Feature 1: Camera Capture with Auto Edge Detection

### Overview
Full-screen camera viewfinder with real-time document edge detection overlay and optional auto-capture.

### UI Components
- `CameraViewfinder` widget wrapping `CameraController`
- `EdgeOverlay` custom painter drawing detected quadrilateral
- `ShutterButton` — circular FAB at bottom center
- `FlashToggle` — icon button top-left
- `GalleryButton` — thumbnail of last capture, bottom-left
- `GuideFrame` — faint rectangle guide when no document detected

### States
| State | UI |
|---|---|
| Loading | Camera initialization progress indicator |
| Ready — No Document | Guide frame visible, shutter enabled |
| Ready — Document Detected | Edge overlay drawn in accent color, shutter pulses |
| Auto-Capture Countdown | 500ms visual countdown ring |
| Captured | Flash animation, transition to crop editor |

### Edge Detection Algorithm (FFI)
1. Convert frame to grayscale (OpenCV `cvtColor`)
2. Apply Gaussian blur (`GaussianBlur`, kernel 5x5)
3. Canny edge detection (low=50, high=150)
4. Find contours (`findContours`, RETR_EXTERNAL)
5. Approximate polygon (`approxPolyDP`) — target 4 vertices
6. Validate quadrilateral (area > 30% of frame, convex, angles within [60°, 120°])
7. Return corner coordinates to Dart via FFI

---

## Feature 2: Crop & Perspective Correction

### Overview
Post-capture screen for fine-tuning document boundaries and applying perspective transform.

### UI Components
- `CroppableImage` — interactive viewer with corner handles
- `CornerHandle` — draggable circles at each corner
- `ConfirmButton` — checkmark FAB
- `RetakeButton` — back-to-camera icon button
- `AutoDetectButton` — re-run corner detection

### Perspective Correction Algorithm (FFI)
1. Map source corners to destination rectangle (0,0)→(width,height)
2. Compute perspective transform matrix (`getPerspectiveTransform`)
3. Warp image (`warpPerspective`, INTER_LINEAR)
4. Return corrected image bytes to Dart

### Edge Cases
- User drags corner to create non-convex quadrilateral → clamp to convex
- Corner handle dragged outside image bounds → clamp to image edge
- Very small crop area (< 100x100px) → warn user

---

## Feature 3: Image Enhancement

### Overview
Auto and manual image enhancement before OCR to maximize recognition accuracy.

### Auto-Enhance Pipeline (FFI)
1. Convert to grayscale
2. Apply CLAHE (Contrast Limited Adaptive Histogram Equalization) for contrast enhancement
3. Apply `fastNlMeansDenoising` for noise reduction
4. Apply adaptive threshold (`adaptiveThreshold`, ADAPTIVE_GAUSSIAN_C)
5. Optional deskew (`minAreaRect` to find angle, `warpAffine` to rotate)
6. Return enhanced bytes

### Manual Controls
| Slider | Range | Default | Effect |
|---|---|---|---|
| Brightness | -100 to +100 | 0 | `convertTo` with beta adjustment |
| Contrast | 0 to 200% | 100% | `convertTo` with alpha adjustment |
| Saturation | 0 to 200% | 100% | HSV conversion + S channel scaling |
| Sharpness | 0 to 200% | 100% | `filter2D` with sharpening kernel |

---

## Feature 4: OCR Text Extraction

### Overview
Extract text from enhanced image using local OCR engine.

### Implementation
- **Preferred:** Google ML Kit Text Recognition (on-device)
- **Fallback:** Tesseract via `tesseract_ffi` package
- **Language packs:** Download on first use, cached locally

### Output Structure
```dart
class OCRResult {
  final String text;
  final List<TextBlock> blocks;
  final String language;
  final double confidence;
  final Duration processingTime;
}

class TextBlock {
  final String text;
  final Rect boundingBox;
  final List<TextLine> lines;
}

class TextLine {
  final String text;
  final Rect boundingBox;
  final List<TextWord> words;
}

class TextWord {
  final String text;
  final Rect boundingBox;
  final double confidence;
}
```

---

## Feature 5: AI Integration

### Overview
Pluggable AI provider layer for text augmentation features.

### Supported Providers
| Provider | Models | Features |
|---|---|---|
| Gemini | gemini-1.5-pro, gemini-1.5-flash | All AI features |
| OpenAI | gpt-4o, gpt-4o-mini | All AI features |

### Prompt Engineering Templates

**Summary:**
```
You are a text summarization assistant. Given the following OCR-extracted text, produce a concise summary covering the main points. Format the output as bullet points.

Text:
{text}

Summary:
```

**Action Items:**
```
Extract action items from the following text. For each item, provide: task, assignee (if mentioned), priority (High/Medium/Low). Format as a Markdown table.

Text:
{text}

Action Items:
```

**Flashcards:**
```
Create a set of flashcards from the following text for study purposes. Each flashcard should have a question and answer. Format as:

## Flashcard 1
**Q:** ...
**A:** ...

{text}
```

**Mind Map:**
```
Generate a mind map from the following text in Mermaid.js format. Use 'mindmap' root element.

Text:
{text}

Mermaid mindmap:
```

**Translation:**
```
Translate the following text from {source_lang} to {target_lang}. Preserve the original formatting as much as possible.

Text:
{text}

Translation:
```

**Grammar Correction:**
```
Fix grammar, spelling, and OCR errors in the following text. Preserve the original meaning and structure. Only output the corrected text.

Text:
{text}

Corrected:
```

**Q&A (Chat):**
```
You are a helpful assistant answering questions about the following document. Use only the provided context to answer.

Document:
{text}

User Question:
{question}

Answer:
```

### Response Parsing
All AI responses are parsed as structured Markdown. The app may optionally request JSON format for deterministic parsing:

```json
{
  "summary": "...",
  "action_items": [
    {"task": "...", "assignee": "...", "priority": "High"}
  ],
  "flashcards": [
    {"question": "...", "answer": "..."}
  ]
}
```

---

## Feature 6: Export

### Supported Formats
| Format | Content | MIME |
|---|---|---|
| Markdown | OCR text + AI enhancements | text/markdown |
| TXT | Plain text | text/plain |
| PDF | Formatted document with title, date, text | application/pdf |
| JSON | Structured data (image paths, OCR, AI, metadata) | application/json |

### Export Flow
1. User selects format(s) on Export screen
2. App generates file in temporary directory
3. Opens native share sheet (via `share_plus`)
4. On success, file path is logged in history

---

## Feature 7: History

### Database Schema (Drift)

```sql
CREATE TABLE scans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL DEFAULT 'Untitled',
  original_image_path TEXT NOT NULL,
  enhanced_image_path TEXT,
  ocr_text TEXT,
  ocr_language TEXT DEFAULT 'en',
  ai_summary TEXT,
  ai_action_items TEXT,
  ai_flashcards TEXT,
  ai_mind_map TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  tags TEXT -- JSON array of strings
);

CREATE TABLE scan_tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  scan_id INTEGER NOT NULL REFERENCES scans(id),
  name TEXT NOT NULL
);
```

### Search
- OCR text search via SQLite FTS5 virtual table
- Search across title, OCR text, tags
- Results sorted by relevance (match count) then date

---

## Feature 8: Settings

### Persisted Keys (Hive)

| Key | Type | Default | Description |
|---|---|---|---|
| `theme_mode` | String | `'system'` | `light`, `dark`, `system` |
| `ocr_language` | String | `'en'` | ISO language code |
| `ai_provider` | String | `'gemini'` | `gemini` or `openai` |
| `ai_api_key` | String (encrypted) | `''` | Stored in flutter_secure_storage |
| `ai_model` | String | Context-dependent | Model name |
| `image_quality` | int | 90 | JPEG quality 1-100 |
| `compression_enabled` | bool | true | Compress stored images |
| `default_export_format` | String | `'markdown'` | Default export format |
| `auto_enhance` | bool | true | Auto-enhance after capture |
| `auto_capture` | bool | true | Auto-capture when document detected |
