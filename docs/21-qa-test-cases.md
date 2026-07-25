# VisionNote AI — QA Test Cases

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Senior QA Engineer

---

## 1. Test Case Convention

```
TC-{Module}-{Number}: {Title}
Priority: P0/P1/P2
Type: Functional / UI / Performance / Security / Accessibility
Preconditions: ...
Steps: ...
Expected: ...
```

---

## 2. Smoke Tests (P0)

### TC-CAM-001: Camera Launches Successfully
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | App installed, permissions not yet granted |
| **Steps** | 1. Tap Camera FAB → 2. Grant camera permission |
| **Expected** | Camera viewfinder fills screen. Edge overlay visible on documents. Shutter button visible. |

### TC-CAM-002: Manual Photo Capture
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | Camera launched, document in frame |
| **Steps** | 1. Point camera at document → 2. Tap shutter button |
| **Expected** | Photo captured. Navigation to crop editor. |

### TC-CAM-003: Auto-Capture Triggers
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | Camera launched, auto-capture enabled in settings |
| **Steps** | 1. Hold camera steady over document covering > 80% frame → 2. Wait for 500ms |
| **Expected** | Auto-capture fires. Haptic feedback. Navigated to crop editor. |

### TC-CROP-001: Crop Editor Displays Handles
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | UI |
| **Precondition** | Photo captured |
| **Steps** | 1. Observe crop editor screen |
| **Expected** | Image displayed. Four corner handles visible. Confirm and Retake buttons visible. |

### TC-CROP-002: Corner Drag Adjusts Crop
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | Crop editor open |
| **Steps** | 1. Drag top-left corner handle inward → 2. Tap Confirm |
| **Expected** | Perspective correction applied with new corners. Cropped image displayed. |

### TC-ENHANCE-001: Auto Enhance Works
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | Cropped image displayed |
| **Steps** | 1. Tap "Auto Enhance" button |
| **Expected** | Loading indicator. Image updates with enhanced quality (shadows removed, contrast improved, text sharper). |

### TC-OCR-001: Text Extraction Succeeds
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | Enhanced image ready |
| **Steps** | 1. Tap "Extract Text" |
| **Expected** | Loading indicator. OCR text appears in scrollable text field. Extraction time < 5 seconds for single page. |

### TC-OCR-002: OCR Text is Editable
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | OCR text extracted |
| **Steps** | 1. Tap on OCR text field → 2. Edit a word → 3. Delete a word → 4. Add new text |
| **Expected** | Text field is editable. Changes persist in preview. |

### TC-EXPORT-001: Export to Markdown
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | OCR text extracted |
| **Steps** | 1. Tap "Export" → 2. Select "Markdown" |
| **Expected** | File generated. Share sheet opens with .md file. File contains OCR text formatted as Markdown. |

### TC-EXPORT-002: Copy to Clipboard
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | OCR text extracted |
| **Steps** | 1. Tap "Export" → 2. Tap "Copy to Clipboard" |
| **Expected** | Toast "Copied to clipboard". Paste into another app works. |

### TC-HISTORY-001: Scan Saved to History
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | After export or returning from scan flow |
| **Steps** | 1. Navigate to History tab |
| **Expected** | Recent scan appears in list with thumbnail, title, date. |

### TC-SETTINGS-001: Theme Toggle Works
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | App running |
| **Steps** | 1. Navigate to Settings → 2. Change theme from Light to Dark |
| **Expected** | App immediately transitions to dark theme. All screens reflect change. |

### TC-ONBOARDING-001: Onboarding Flow
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | Fresh install |
| **Steps** | 1. Launch app for first time → 2. Swipe through 3 onboarding pages → 3. Tap "Get Started" |
| **Expected** | Onboarding shown once. Navigated to Home. |

---

## 3. Functional Tests (P1-P2)

### TC-CAM-004: Flash Toggle
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Open camera → 2. Tap flash icon → 3. Observe flash state → 4. Tap again |
| **Expected** | Flash toggles between Off/On/Auto. Icon updates accordingly. |

### TC-CAM-005: Camera Error Handling (Permission Denied)
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Precondition** | Camera permission denied |
| **Steps** | 1. Tap Camera FAB |
| **Expected** | Graceful error message. Button to open settings. No crash. |

### TC-CROP-003: Retake Returns to Camera
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. In crop editor → 2. Tap "Retake" |
| **Expected** | Returns to camera screen. Previous photo discarded. |

### TC-ENHANCE-002: Manual Sliders Affect Image
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. In enhancement screen → 2. Drag brightness slider to +50 → 3. Drag contrast to 150% |
| **Expected** | Image updates in real-time. Before/after toggle works. |

### TC-ENHANCE-003: Before/After Toggle
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | UI |
| **Steps** | 1. Apply enhancement → 2. Long-press image (or tap toggle) |
| **Expected** | Holding shows original. Releasing shows enhanced. |

### TC-OCR-003: Language Selection Affects Recognition
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Place a French document → 2. Set OCR language to French → 3. Extract text |
| **Expected** | French characters (é, à, ç, etc.) recognized correctly. Higher accuracy than English mode. |

### TC-OCR-004: Empty/BLank Document
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Scan a blank white page → 2. Extract text |
| **Expected** | Empty state message: "No text detected". No crash. |

### TC-AI-001: AI Summary Generation (Online)
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Precondition** | Internet connected, AI provider configured, OCR text available |
| **Steps** | 1. From OCR preview → 2. Tap "AI Summary" |
| **Expected** | Loading indicator. Bullet-point summary displayed. < 10 seconds. |

### TC-AI-002: AI Features Offline Banner
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Precondition** | Airplane mode ON |
| **Steps** | 1. Navigate to AI screen |
| **Expected** | Banner: "Connect to the internet for AI features". AI buttons disabled with tooltip. |

### TC-AI-003: Action Items Extraction
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Scan meeting notes with action items → 2. Tap "Action Items" |
| **Expected** | Table with Task, Assignee, Priority columns displayed. |

### TC-AI-004: Flashcard Generation
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Scan textbook page → 2. Tap "Flashcards" |
| **Expected** | Q&A flashcards displayed. Tap to flip. |

### TC-AI-005: Chat Q&A
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. OCR text extracted → 2. Navigate to Chat → 3. Type question → 4. Send |
| **Expected** | AI responds based solely on document text. Follow-up questions maintain context. |

### TC-AI-006: Translation
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. English document scanned → 2. Tap Translate → 3. Select Spanish |
| **Expected** | Translated text displayed. Original formatting preserved. |

### TC-AI-007: Grammar Fix
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. Scan document with OCR errors → 2. Tap "Fix Grammar" |
| **Expected** | Cleaned text displayed. Only errors corrected, content preserved. |

### TC-EXPORT-003: PDF Export
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. OCR text available → 2. Export → 3. Select PDF |
| **Expected** | PDF generated with title, date, formatted text. Share sheet opens. |

### TC-EXPORT-004: JSON Export
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Scan + OCR + AI summary → 2. Export → 3. Select JSON |
| **Expected** | JSON file with fields: title, ocr_text, ai_summary, timestamps, tags. |

### TC-HISTORY-002: Search by OCR Content
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Navigate to History → 2. Type search term from OCR text |
| **Expected** | Matching scans displayed. Results update as user types (debounced). |

### TC-HISTORY-003: Tag Management
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. View scan detail → 2. Tap "Add Tag" → 3. Enter "biology" → 4. Save → 5. Remove tag |
| **Expected** | Tag appears on scan. Tag removable. Tag persists after app restart. |

### TC-HISTORY-004: Delete Scan
| Field | Value |
|---|---|
| **Priority** | P0 |
| **Type** | Functional |
| **Steps** | 1. Long-press scan in history → 2. Tap "Delete" → 3. Confirm deletion |
| **Expected** | Scan removed from list. Files deleted. Cannot be recovered. |

### TC-SETTINGS-002: AI Provider Switch
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Settings → AI Provider → 2. Switch from Gemini to OpenAI → 3. Enter API key → 4. Test AI feature |
| **Expected** | AI features use new provider. No app restart needed. |

### TC-SETTINGS-003: API Key Persistence
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Security |
| **Steps** | 1. Enter API key → 2. Close app → 3. Reopen → 4. Check Settings |
| **Expected** | API key still configured (masked). Not visible in plain text. |

### TC-SETTINGS-004: Image Quality Setting
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Functional |
| **Steps** | 1. Set image quality to 50% → 2. Scan a document → 3. Check file size |
| **Expected** | Stored image is smaller than 100% quality setting. |

---

## 4. Performance Tests

### TC-PERF-001: Cold Start Time
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Performance |
| **Steps** | 1. Force-close app → 2. Launch → 3. Measure time to Home screen |
| **Expected** | < 2 seconds on mid-range device (Pixel 6 / iPhone 13 equivalent). |

### TC-PERF-002: Image Processing Pipeline Latency
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Performance |
| **Steps** | 1. Capture high-res document → 2. Measure edge detection + perspective + enhance time |
| **Expected** | Full pipeline < 500ms total. |

### TC-PERF-003: OCR Latency
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Performance |
| **Steps** | 1. Capture enhanced image → 2. Measure OCR extraction time |
| **Expected** | < 3 seconds for standard page (300 DPI equivalent). |

### TC-PERF-004: History Load Time
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Performance |
| **Precondition** | 100+ scans in history |
| **Steps** | 1. Navigate to History tab → 2. Measure list render time |
| **Expected** | < 500ms. Smooth scrolling at 60fps. |

---

## 5. Security Tests

### TC-SEC-001: API Key Not Exposed
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Security |
| **Steps** | 1. Enter API key → 2. Check system logs → 3. Check app storage |
| **Expected** | API key not in logs. Stored in encrypted storage only. |

### TC-SEC-002: No Network Calls Without User Action
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Security |
| **Steps** | 1. Install app → 2. Monitor network with proxy → 3. Scan and enhance (offline-capable operations) |
| **Expected** | No network calls without explicit user action (AI feature request). |

### TC-SEC-003: Camera Permission Denied Handling
| Field | Value |
|---|---|
| **Priority** | P1 |
| **Type** | Security |
| **Steps** | 1. Deny camera permission → 2. Tap Camera FAB |
| **Expected** | Guidance dialog: "Camera access is required for scanning. Go to Settings to enable." |

---

## 6. Edge Case Tests

### TC-EDGE-001: Very Low Light Document
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. Scan document in dim light (10 lux) → 2. Auto enhance |
| **Expected** | Enhancement pipeline compensates. Text still readable after processing. |

### TC-EDGE-002: Highly Skewed Document (> 45°)
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. Place document at 45° angle → 2. Capture → 3. Perspective correction |
| **Expected** | Document corrected to flat rectangle. Minimal distortion. |

### TC-EDGE-003: Non-Document Image (Photo)
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. Scan a photograph (no text) → 2. Extract text |
| **Expected** | Empty text result. "No text detected" message. No crash. |

### TC-EDGE-004: Multiple Columns of Text
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. Scan two-column document → 2. Extract text |
| **Expected** | OCR reads left-to-right, top-to-bottom. Both columns captured. Text order may vary by engine. |

### TC-EDGE-005: App Backgrounded During Processing
| Field | Value |
|---|---|
| **Priority** | P2 |
| **Type** | Functional |
| **Steps** | 1. Start OCR extraction → 2. Immediately press Home → 3. Reopen app |
| **Expected** | Processing completes. UV result displayed on return. Or state is restored. |
