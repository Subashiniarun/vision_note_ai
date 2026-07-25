# VisionNote AI — User Stories

**Version:** 1.0  
**Date:** 2026-07-25  
**Status:** Refined

---

## Epic 1: Document Capture

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-101 | As a student, I want to open the camera and see real-time edge detection overlay so that I know when the document is framed correctly before capturing. | P0 | 3 | Camera plugin, OpenCV edge detection |
| US-102 | As a user, I want the app to auto-capture when the document is well-framed and stable so that I don't have to tap the shutter button precisely. | P0 | 5 | US-101 |
| US-103 | As a user, I want a manual shutter button to capture when I choose so that I have control over the timing. | P0 | 1 | Camera plugin |
| US-104 | As a user, I want a flash/torch toggle on the camera screen so that I can illuminate dark documents. | P1 | 1 | Camera plugin |
| US-105 | As a user, I want a grid overlay option (rule of thirds) so that I can compose the shot better. | P2 | 1 | — |

## Epic 2: Image Editing

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-201 | As a user, I want to see the captured image with draggable corner handles so that I can adjust the crop area. | P0 | 3 | OpenCV perspective correction |
| US-202 | As a user, I want the app to auto-detect document corners so that manual adjustment is minimal. | P0 | 5 | US-101 |
| US-203 | As a user, I want to apply auto-enhancement (shadow removal, contrast, brightness) with one tap so that text becomes more readable. | P0 | 3 | OpenCV enhancement pipeline |
| US-204 | As a user, I want manual sliders for brightness, contrast, and saturation so that I can fine-tune the image. | P1 | 2 | — |
| US-205 | As a user, I want to see a before/after preview of the enhancement so that I can decide if I'm satisfied. | P1 | 2 | — |

## Epic 3: OCR

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-301 | As a user, I want to extract text from the enhanced image with one tap so that I don't have to type it manually. | P0 | 5 | US-203, Tesseract/ML Kit |
| US-302 | As a user, I want to see the extracted text in a scrollable preview so that I can review accuracy. | P0 | 2 | — |
| US-303 | As a user, I want to tap and edit any word in the OCR output so that I can fix recognition errors. | P0 | 2 | — |
| US-304 | As a user, I want to select the OCR language (English, Spanish, French, etc.) so that non-English documents are recognized. | P1 | 2 | OCR engine language packs |

## Epic 4: AI Features

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-401 | As a professional, I want to generate an AI summary of the extracted text so that I can quickly understand the key points. | P0 | 5 | US-301, AI provider integration |
| US-402 | As a product manager, I want AI to extract action items from my meeting notes so that I can copy them into my task tracker. | P1 | 3 | US-401 |
| US-403 | As a student, I want to generate flashcards from my notes so that I can study efficiently. | P1 | 3 | US-401 |
| US-404 | As a researcher, I want to generate a mind map from the document so that I can visualize connections. | P1 | 5 | US-401 |
| US-405 | As a user, I want to translate extracted text into another language so that I can work with multilingual documents. | P2 | 2 | US-401 |
| US-406 | As a user, I want AI to fix grammar and OCR errors in the text so that the export is clean. | P2 | 2 | US-401 |
| US-407 | As a user, I want to ask questions about the extracted text in a chat interface so that I can query my notes conversationally. | P2 | 5 | US-401 |

## Epic 5: Export

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-501 | As a user, I want to export the OCR text as Markdown so that I can use it in my note-taking app. | P0 | 2 | US-301 |
| US-502 | As a user, I want to export as a plain text file so that it's universally compatible. | P0 | 1 | US-301 |
| US-503 | As a user, I want to copy the text to my clipboard so that I can paste it anywhere. | P0 | 1 | US-301 |
| US-504 | As a user, I want to export as PDF so that I can share a formatted document. | P1 | 3 | US-301 |
| US-505 | As a developer, I want to export as JSON so that I can process the data programmatically. | P1 | 2 | US-301 |

## Epic 6: History & Organization

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-601 | As a user, I want every scan to be saved in a history list with thumbnail and title so that I can find past scans. | P0 | 3 | Drift database |
| US-602 | As a user, I want to search my scans by OCR text content so that I can find relevant notes quickly. | P1 | 3 | US-601 |
| US-603 | As a user, I want to add tags to scans so that I can organize them by project or subject. | P1 | 2 | US-601 |
| US-604 | As a user, I want to delete scans from history so that I can manage storage. | P0 | 1 | US-601 |

## Epic 7: Settings & Personalization

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-701 | As a user, I want to switch between dark and light mode so that the app is comfortable in any lighting. | P0 | 2 | Theme system |
| US-702 | As a user, I want to select my preferred OCR language so that documents in my language are recognized accurately. | P1 | 1 | Hive storage |
| US-703 | As a user, I want to choose my AI provider (Gemini or OpenAI) so that I can use my preferred service. | P1 | 2 | AI provider abstraction |
| US-704 | As a user, I want to set the default export format so that I don't have to choose every time. | P1 | 1 | Hive storage |
| US-705 | As a user, I want to adjust image compression quality so that I can balance quality and storage. | P1 | 1 | — |

## Epic 8: Onboarding

| Story ID | Story | Priority | Effort | Dependencies |
|---|---|---|---|---|
| US-801 | As a new user, I want to see an onboarding flow explaining the app's features so that I understand what's possible. | P0 | 2 | — |
| US-802 | As a user, I want to grant camera permission during onboarding so that I don't have to figure it out later. | P0 | 1 | — |
