# VisionNote AI — Design System

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** UI/UX Designer

---

## 1. Design Philosophy

VisionNote AI follows **Material 3** design language with the following principles:

- **Clarity:** Content is king. UI chrome is minimal.
- **Consistency:** One button pattern, one color scheme, one typography scale.
- **Hierarchy:** Scanning workflow is linear and guided — each screen has one primary action.
- **Accessibility:** WCAG AA compliant (4.5:1 contrast ratio, 48x48dp touch targets).
- **Adaptive:** Same layout works on phones and tablets.

---

## 2. Color Palette

### 2.1 Light Theme

| Token | Color | Hex | Usage |
|---|---|---|---|
| `primary` | Indigo 600 | `#3949AB` | Primary actions, active states, FAB |
| `onPrimary` | White | `#FFFFFF` | Text/icons on primary |
| `primaryContainer` | Indigo 100 | `#C5CAE9` | Secondary surfaces, chips |
| `secondary` | Teal 600 | `#00897B` | Accent, AI features |
| `surface` | White | `#FFFFFF` | Card backgrounds, sheets |
| `surfaceVariant` | Gray 50 | `#F5F5F5` | Elevated surfaces |
| `background` | Gray 50 | `#FAFAFA` | Screen backgrounds |
| `error` | Red 600 | `#E53935` | Errors, deletions |
| `outline` | Gray 300 | `#E0E0E0` | Borders, dividers |
| `onBackground` | Gray 900 | `#212121` | Primary text |
| `onSurfaceVariant` | Gray 600 | `#757575` | Secondary text |

### 2.2 Dark Theme

| Token | Color | Hex | Usage |
|---|---|---|---|
| `primary` | Indigo 300 | `#7986CB` | Primary actions, active states |
| `onPrimary` | Gray 900 | `#212121` | Text/icons on primary |
| `primaryContainer` | Indigo 800 | `#283593` | Secondary surfaces |
| `secondary` | Teal 300 | `#4DB6AC` | Accent, AI features |
| `surface` | Gray 900 | `#1E1E1E` | Card backgrounds |
| `surfaceVariant` | Gray 800 | `#2C2C2C` | Elevated surfaces |
| `background` | Gray 950 | `#121212` | Screen backgrounds |
| `error` | Red 300 | `#E57373` | Errors |
| `outline` | Gray 700 | `#616161` | Borders |
| `onBackground` | Gray 100 | `#F5F5F5` | Primary text |
| `onSurfaceVariant` | Gray 400 | `#BDBDBD` | Secondary text |

---

## 3. Typography

### 3.1 Font Family

**Primary:** Inter (system fallback: Roboto on Android, SF Pro on iOS)

### 3.2 Type Scale

| Style | Size | Weight | Height | Usage |
|---|---|---|---|---|
| `displayLarge` | 57 | 400 | 64 | Splash screen title |
| `displayMedium` | 45 | 400 | 52 | Welcome/onboarding |
| `headlineLarge` | 32 | 600 | 40 | Screen titles |
| `headlineMedium` | 28 | 600 | 36 | Section headers |
| `headlineSmall` | 24 | 600 | 32 | Card titles |
| `titleLarge` | 22 | 500 | 28 | Dialog titles |
| `titleMedium` | 16 | 500 | 24 | List item titles |
| `titleSmall` | 14 | 500 | 20 | Chip labels |
| `bodyLarge` | 16 | 400 | 24 | Primary reading text |
| `bodyMedium` | 14 | 400 | 20 | Secondary text |
| `bodySmall` | 12 | 400 | 16 | Captions, timestamps |
| `labelLarge` | 14 | 500 | 20 | Button text |
| `labelMedium` | 12 | 500 | 16 | Tab labels |
| `labelSmall` | 11 | 500 | 16 | Badge text |

---

## 4. Spacing Scale

| Token | dp |
|---|---|
| `space-2` | 2 |
| `space-4` | 4 |
| `space-8` | 8 |
| `space-12` | 12 |
| `space-16` | 16 |
| `space-20` | 20 |
| `space-24` | 24 |
| `space-32` | 32 |
| `space-48` | 48 |
| `space-64` | 64 |

---

## 5. Shape / Corners

| Token | Radius | Usage |
|---|---|---|
| `shapeNone` | 0 | Images, camera preview |
| `shapeSmall` | 4 | Input fields, small chips |
| `shapeMedium` | 8 | Cards, dialogs, bottom sheets |
| `shapeLarge` | 16 | Modal bottom sheets |
| `shapeFull` | 999 | FAB, circular avatars |

---

## 6. Elevation / Shadow

| Level | dp | Usage |
|---|---|---|
| `elevation-0` | 0 | Surfaces flush |
| `elevation-1` | 1 | Cards resting |
| `elevation-2` | 3 | Raised cards |
| `elevation-3` | 6 | FAB (resting) |
| `elevation-4` | 8 | Bottom navigation bar |
| `elevation-5` | 12 | Modal bottom sheets |

---

## 7. Core Widgets

### 7.1 Buttons

```dart
// Primary Filled Button (one per screen for primary action)
VNAPrimaryButton(
  label: 'Extract Text',
  icon: Icons.text_snippet,
  onPressed: () {},
)

// Secondary Outlined Button
VNAOutlinedButton(
  label: 'Retake Photo',
  icon: Icons.camera_alt,
  onPressed: () {},
)

// Ghost / Text Button
VNATextButton(
  label: 'Skip',
  onPressed: () {},
)

// Icon Button (48x48dp)
VNAIconButton(
  icon: Icons.flash_on,
  onPressed: () {},
)

// FAB (camera button)
VNAFab(
  onPressed: () {},
)
```

### 7.2 Cards

```dart
// Scan history card
VNACard(
  thumbnail: Image.file(originalImage),
  title: 'Lecture Notes - Biology 101',
  subtitle: 'Jul 25, 2026 • 5 pages',
  tags: ['biology', 'lecture'],
  onTap: () => navigateToDetail(),
)

// Feature card (on home screen)
VNAFeatureCard(
  icon: Icons.auto_awesome,
  title: 'AI Summary',
  description: 'Generate a concise summary of your notes',
  onTap: () {},
)
```

### 7.3 Input Fields

```dart
// Search bar (history screen)
VNASearchBar(
  hintText: 'Search your notes...',
  onChanged: (query) => bloc.add(SearchHistory(query)),
)

// Editable text (OCR preview)
VNAEditableText(
  initialText: ocrText,
  onChanged: (text) => bloc.add(EditText(text)),
)
```

### 7.4 Sliders (Enhancement Screen)

```dart
VNASlider(
  label: 'Brightness',
  value: brightness,
  min: -100,
  max: 100,
  onChanged: (v) => bloc.add(UpdateBrightness(v)),
)
```

### 7.5 Bottom Navigation

```dart
VNABottomNav(
  items: [
    BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt, label: 'Scan'),
    BottomNavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'History'),
    BottomNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ],
  centerFab: true, // Camera tab has a prominent FAB
)
```

---

## 8. Loading States

```dart
// Full-screen loading
VNALoadingOverlay(
  message: 'Processing image...',
)

// Inline shimmer
VNAShimmerCard()

// Skeleton list
VNASkeletonList(
  itemCount: 5,
)
```

---

## 9. Empty States

```dart
VNAEmptyState(
  icon: Icons.document_scanner_outlined,
  title: 'No scans yet',
  description: 'Tap the camera button to scan your first document',
  actionLabel: 'Start Scanning',
  onAction: () => router.push(const CameraRoute()),
)
```

---

## 10. Error States

```dart
VNAErrorState(
  message: 'Failed to process image',
  actionLabel: 'Retry',
  onAction: () => bloc.add(RetryProcessing()),
)
```

---

## 11. Theming Implementation

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3949AB),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7986CB),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      // ... same overrides as light
    );
  }
}
```

---

## 12. Icons

Use Material Icons (outlined style by default, filled for active states):

| Icon | Usage |
|---|---|
| `document_scanner` | App icon, scan feature |
| `camera_alt` | Camera tab |
| `text_snippet` | OCR |
| `auto_awesome` | AI features |
| `flash_on/off` | Torch toggle |
| `crop` | Crop editor |
| `tune` | Enhancement |
| `file_download` | Export |
| `search` | Search |
| `history` | History tab |
| `settings` | Settings tab |
| `delete` | Delete action |
| `label` | Tags |
| `dark_mode/light_mode` | Theme toggle |
| `info` | About |
| `share` | Share sheet |
| `content_copy` | Copy to clipboard |
