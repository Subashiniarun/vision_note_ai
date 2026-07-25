# VisionNote AI — Risk Register

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Technical Lead

---

## 1. Risk Assessment Matrix

| Likelihood / Impact | Low (1) | Medium (2) | High (3) |
|---|---|---|---|
| **High (3)** | | R-004, R-007 | R-001, R-002, R-003 |
| **Medium (2)** | R-010 | R-005, R-006, R-009 | R-008 |
| **Low (1)** | R-012 | R-011 | R-013 |

---

## 2. Risk Register

### R-001: OpenCV FFI Integration Failures on Specific Devices
| Field | Value |
|---|---|
| **Category** | Technical |
| **Likelihood** | High (3) |
| **Impact** | High (3) |
| **Risk Score** | 9 |
| **Description** | OpenCV native libraries may fail to load on certain Android devices (custom ROMs, old architectures) or iOS simulators. ABI mismatch, missing OpenCV dependencies. |
| **Mitigation** | 1. Bundle compiled libraries for arm64-v8a, armeabi-v7a, x86_64. 2. Graceful fallback to Dart-based processing (slower but functional). 3. Device-specific testing on top 20 Android devices. 4. Runtime architecture detection. |
| **Contingency** | Pure Dart fallback image processor that handles grayscale, contrast, and basic edge detection without FFI. |
| **Owner** | Native Engineer |

### R-002: OCR Accuracy Below Acceptable Threshold
| Field | Value |
|---|---|
| **Category** | Quality |
| **Likelihood** | High (3) |
| **Impact** | High (3) |
| **Risk Score** | 9 |
| **Description** | Offline OCR (Tesseract/ML Kit) may produce < 85% accuracy on handwritten text or low-quality documents, frustrating users. |
| **Mitigation** | 1. Aggressive image pre-processing (adaptive threshold, deskew, CLAHE). 2. Allow user text editing. 3. Offer AI grammar correction (post-MVP). 4. Publish expected accuracy ranges. |
| **Contingency** | Add Google Cloud Vision API as optional cloud OCR fallback (requires internet). |
| **Owner** | ML Engineer / QA Lead |

### R-003: AI API Cost Overruns
| Field | Value |
|---|---|
| **Category** | Business |
| **Likelihood** | High (3) |
| **Impact** | High (3) |
| **Risk Score** | 9 |
| **Description** | Users may abuse AI features, generating hundreds of requests and causing high API costs for the user (BYOK model) or for the company if subsidized. |
| **Mitigation** | 1. BYOK (Bring Your Own Key) model — users pay for their own API usage. 2. Warning before first AI use. 3. Token usage display per session. 4. Rate limiting (max 10 requests/minute). |
| **Contingency** | Offer local AI models (e.g., llama.cpp via FFI) for users who don't want API costs. |
| **Owner** | Product Manager |

### R-004: Camera Permissions on Android 13+
| Field | Value |
|---|---|
| **Category** | Technical |
| **Likelihood** | Medium (2) |
| **Impact** | High (3) |
| **Risk Score** | 6 |
| **Description** | Android 13+ granular permissions and photo picker changes may cause camera access issues or confuse users. |
| **Mitigation** | 1. Use `photo_picker` for gallery import. 2. Contextual permission requests. 3. Clear rationale dialogs. 4. Handle permanently-denied state with settings redirect. |
| **Contingency** | Allow importing images from gallery as fallback (no camera required). |
| **Owner** | Mobile Engineer |

### R-005: Large Image Memory Pressure
| Field | Value |
|---|---|
| **Category** | Performance |
| **Likelihood** | Medium (2) |
| **Impact** | Medium (2) |
| **Risk Score** | 4 |
| **Description** | High-resolution camera images (12MP+) consume significant memory. Multiple images in processing pipeline may cause OOM on devices with 3GB RAM. |
| **Mitigation** | 1. Downscale images to 1080p before processing. 2. Stream processing (process in chunks). 3. Release intermediate bitmaps immediately. 4. Memory warning monitoring. |
| **Contingency** | Warn user when device has < 500MB free RAM. Suggest lower capture resolution. |
| **Owner** | Flutter Engineer |

### R-006: Flutter BLoC Boilerplate Overhead
| Field | Value |
|---|---|
| **Category** | Development |
| **Likelihood** | Medium (2) |
| **Impact** | Medium (2) |
| **Risk Score** | 4 |
| **Description** | BLoC pattern with separate Event/State classes for 10+ BLoCs creates significant boilerplate, potentially slowing development velocity. |
| **Mitigation** | 1. Use code generation (freezed for events/states). 2. Create base BLoC class. 3. Standardized templates for new BLoCs. 4. Document pattern with examples. |
| **Contingency** | Adopt `hydrated_bloc` for persistence without extra boilerplate. |
| **Owner** | Flutter Architect |

### R-007: App Size Exceeds 50MB
| Field | Value |
|---|---|
| **Category** | Technical |
| **Likelihood** | Medium (2) |
| **Impact** | High (3) |
| **Risk Score** | 6 |
| **Description** | OpenCV native libraries + OCR language packs + AI client SDKs may push APK size over 50MB, causing download friction. |
| **Mitigation** | 1. Android App Bundle (not APK). 2. On-demand OCR language pack downloads. 3. Strip debug symbols from OpenCV libs. 4. Obfuscate and shrink (R8/ProGuard). |
| **Contingency** | Split APKs by architecture. Offer "light" version without OCR language packs. |
| **Owner** | DevOps / Native Engineer |

### R-008: iOS App Store Review Rejection
| Field | Value |
|---|---|
| **Category** | Business |
| **Likelihood** | Low (1) |
| **Impact** | High (3) |
| **Risk Score** | 3 |
| **Description** | Apple may reject the app for camera usage justification, or for including "AI features" without clear privacy disclosures. |
| **Mitigation** | 1. Clear camera usage description in Info.plist. 2. Privacy policy within app. 3. No hidden data collection. 4. Pre-submission review with Apple guidelines. |
| **Contingency** | Remove AI features from iOS build during review, add back via update. |
| **Owner** | Product Manager |

### R-009: Cross-Platform OpenCV Build Complexity
| Field | Value |
|---|---|
| **Category** | Technical |
| **Likelihood** | Medium (2) |
| **Impact** | Medium (2) |
| **Risk Score** | 4 |
| **Description** | Building OpenCV for both Android (NDK/CMake) and iOS (Xcode/fat binaries) requires complex CI setup and may cause integration delays. |
| **Mitigation** | 1. Use OpenCV prebuilt frameworks for iOS. 2. Docker-based build environment. 3. GH Actions with Android NDK. 4. Document build process. |
| **Contingency** | Use `opencv_dart` pub package as temporary replacement. |
| **Owner** | DevOps / Native Engineer |

### R-010: User Loses Scan Data
| Field | Value |
|---|---|
| **Category** | Data |
| **Likelihood** | Low (1) |
| **Impact** | Medium (2) |
| **Risk Score** | 2 |
| **Description** | Database corruption, app uninstall, or storage cleanup may cause permanent loss of scanned data. |
| **Mitigation** | 1. Database integrity checks on startup. 2. Auto-backup to cloud (future, opt-in). 3. Export prompt after successful OCR. 4. Android Auto Backup for app data. |
| **Contingency** | Manual export is the primary backup mechanism. |
| **Owner** | Flutter Engineer |

### R-011: Accessibility Compliance Issues
| Field | Value |
|---|---|
| **Category** | Legal |
| **Likelihood** | Low (1) |
| **Impact** | Medium (2) |
| **Risk Score** | 2 |
| **Description** | App may not fully comply with WCAG accessibility standards, potentially excluding users with disabilities. |
| **Mitigation** | 1. Semantic labels on all interactive elements. 2. Minimum 48x48dp touch targets. 3. Sufficient color contrast. 4. Screen reader testing (TalkBack/VoiceOver). |
| **Contingency** | Accessibility audit before launch. Fix issues iteratively. |
| **Owner** | QA Engineer |

### R-012: Dependency Conflicts
| Field | Value |
|---|---|
| **Category** | Technical |
| **Likelihood** | Low (1) |
| **Impact** | Low (1) |
| **Risk Score** | 1 |
| **Description** | Multiple complex Flutter packages (drift, bloc, auto_route, camera, etc.) may have conflicting transitive dependencies. |
| **Mitigation** | 1. Pin dependency versions in pubspec.yaml. 2. Regular `flutter pub upgrade` testing. 3. Dependency overrides when necessary. 4. CI build verification. |
| **Contingency** | Evaluate alternative packages for conflicting dependencies. |
| **Owner** | Flutter Engineer |

### R-013: AI Provider API Changes
| Field | Value |
|---|---|
| **Category** | Business |
| **Likelihood** | Low (1) |
| **Impact** | High (3) |
| **Risk Score** | 3 |
| **Description** | Gemini or OpenAI may deprecate/change their API, breaking AI features until the client is updated. |
| **Mitigation** | 1. Abstract AI client behind IAIClient interface. 2. Version-pin API calls. 3. Monitor provider changelogs. 4. Implement graceful degradation (disable AI if provider fails). |
| **Contingency** | Built-in provider switching — users can change to the other provider instantly. |
| **Owner** | AI Solutions Architect |

---

## 3. Risk Mitigation Timeline

| Risk | Mitigation Deadline | Owner |
|---|---|---|
| R-001 (FFI Failures) | Before Alpha release | Native Engineer |
| R-002 (OCR Accuracy) | Before Beta release | ML Engineer |
| R-003 (AI Costs) | Before AI feature release | Product Manager |
| R-004 (Camera Permissions) | Before Alpha | Mobile Engineer |
| R-005 (Memory Pressure) | Before Alpha | Flutter Engineer |
| R-006 (BLoC Boilerplate) | Sprint 2 | Flutter Architect |
| R-007 (App Size) | Before Beta release | DevOps |
| R-008 (App Store Review) | Before Release | Product Manager |
| R-009 (OpenCV Build) | Sprint 1 | Native Engineer |
| R-010 (Data Loss) | Before Beta | Flutter Engineer |
| R-011 (Accessibility) | Before Release | QA Engineer |
| R-012 (Dependencies) | Continuous | Flutter Engineer |
| R-013 (AI API Changes) | Continuous | AI Solutions Architect |
