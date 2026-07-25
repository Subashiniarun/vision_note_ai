# VisionNote AI — Navigation & Routing Design

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** UI/UX Designer / Staff Flutter Architect

---

## 1. Router Library

**Choice:** `auto_route` for declarative, type-safe routing with generated code.

**Rationale:**
- Type-safe route parameters (no string parsing)
- Deep linking support (future)
- Guard support (auth gates for future cloud features)
- Nested navigation
- Animated transitions support

---

## 2. Route Table

```dart
// lib/core/router/app_router.dart
import 'package:auto_route/auto_route.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    // --- Bottom Navigation Shell ---
    AutoRoute(
      page: MainShell,
      path: '/',
      children: [
        AutoRoute(page: HomeScreen, path: 'home', initial: true),
        AutoRoute(page: CameraScreen, path: 'camera'),
        AutoRoute(page: HistoryScreen, path: 'history'),
        AutoRoute(page: SettingsScreen, path: 'settings'),
      ],
    ),

    // --- Modal / Push Routes ---
    AutoRoute(page: SplashScreen, path: '/splash', initial: true),
    AutoRoute(page: OnboardingScreen, path: '/onboarding'),
    AutoRoute(page: CropEditorScreen, path: '/crop'),
    AutoRoute(page: EnhancementScreen, path: '/enhance'),
    AutoRoute(page: OCRPreviewScreen, path: '/ocr-preview'),
    AutoRoute(page: AISummaryScreen, path: '/ai-summary'),
    AutoRoute(page: ChatScreen, path: '/chat'),
    AutoRoute(page: ExportScreen, path: '/export'),
    AutoRoute(page: ScanDetailScreen, path: '/scan/:id'),
    AutoRoute(page: AboutScreen, path: '/about'),
  ],
)
class AppRouter {}
```

## 3. Navigation Structure

```
App Shell (Bottom Navigation)
┌─────────────────────────────────────────────┐
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  │
│  │ Home  │  │Camera │  │History│  │Settings│
│  └──────┘  └──────┘  └──────┘  └──────┘  │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         Current Tab Content         │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘

Push Routes (full-screen):
  /splash          → Auto-route to /onboarding (first launch) or /home
  /onboarding      → Auto-route to /home
  /crop            → Captured image editing
  /enhance         → Image enhancement
  /ocr-preview     → OCR text view/edit
  /ai-summary      → AI features
  /chat            → Q&A chat
  /export          → Export options
  /scan/:id        → View saved scan detail
  /about           → App info
```

## 4. Navigation Flow Diagram

```
[App Launch]
    │
    ▼
[SplashScreen] ──first launch──▶ [OnboardingScreen]
    │                                    │
    └─────────returning──────────────────┘
    │
    ▼
[MainShell]
    │
    ├── Tab 0: [HomeScreen]
    │       │
    │       ├── Tap scan card → /scan/:id (ScanDetailScreen)
    │       │       ├── /ocr-preview
    │       │       ├── /ai-summary
    │       │       ├── /chat
    │       │       └── /export
    │       │
    │       └── Tap FAB → /camera
    │
    ├── Tab 1: [CameraScreen]
    │       │
    │       ├── Auto-capture OR manual capture
    │       └── ▶ /crop
    │               └── ▶ /enhance
    │                       └── ▶ /ocr-preview
    │                               ├── ▶ /ai-summary
    │                               │       └── ▶ /chat
    │                               └── ▶ /export
    │
    ├── Tab 2: [HistoryScreen]
    │       │
    │       ├── Tap scan → /scan/:id
    │       ├── Search bar → filter results
    │       └── Long-press → delete / tag
    │
    └── Tab 3: [SettingsScreen]
            │
            ├── Theme → Hive update → UI rebuild
            ├── OCR Language
            ├── AI Provider / API Key
            ├── Export defaults
            └── About → /about
```

## 5. Route Guards

```dart
@injectable
class OnboardingGuard extends AutoRouteGuard {
  final HiveCache _cache;

  OnboardingGuard(this._cache);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final completed = _cache.get('onboardingComplete', defaultValue: false);
    if (completed || resolver.route.path == '/onboarding') {
      resolver.next(true);
    } else {
      router.replace(const OnboardingRoute());
    }
  }
}
```

## 6. Transition Animations

```dart
// Custom transitions for specific routes
const cropTransition = CustomTransitionPage(
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(opacity: animation, child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
          .animate(animation),
      child: child,
    ));
  },
);

// Camera → Crop: Slide up from bottom
// Crop → Enhance: Slide right
// Enhance → OCR: Slide right
// OCR → AI: Slide right
// OCR → Export: Slide up (modal)
// All dismiss: Slide down/back
```

## 7. Deep Linking (Future)

```dart
// Future support for:
// visionnote://scan/42          → Open scan detail
// visionnote://camera           → Open camera
// visionnote://export/42/markdown → Export specific scan
```
