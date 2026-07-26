import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../features/scan/presentation/screens/scan_detail_screen.dart';
import '../../features/scan/presentation/screens/home_screen.dart';
import '../../features/camera/presentation/screens/camera_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/image_process/presentation/screens/crop_editor_screen.dart';
import '../../features/image_process/presentation/screens/enhancement_screen.dart';
import '../../features/ocr/presentation/screens/ocr_preview_screen.dart';
import '../../features/ai/presentation/screens/ai_summary_screen.dart';
import '../../features/ai/presentation/screens/chat_screen.dart';
import '../../features/export/presentation/screens/export_screen.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../core/widgets/splash_screen.dart';

class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

class AppShellRoute extends PageRouteInfo<void> {
  const AppShellRoute({List<PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppShell();
    },
  );
}

class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

class CameraRoute extends PageRouteInfo<void> {
  const CameraRoute({List<PageRouteInfo>? children})
    : super(CameraRoute.name, initialChildren: children);

  static const String name = 'CameraRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CameraScreen();
    },
  );
}

class HistoryRoute extends PageRouteInfo<void> {
  const HistoryRoute({List<PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HistoryScreen();
    },
  );
}

class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

class CropEditorRoute extends PageRouteInfo<void> {
  const CropEditorRoute({List<PageRouteInfo>? children})
    : super(CropEditorRoute.name, initialChildren: children);

  static const String name = 'CropEditorRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CropEditorScreen();
    },
  );
}

class EnhancementRoute extends PageRouteInfo<void> {
  const EnhancementRoute({List<PageRouteInfo>? children})
    : super(EnhancementRoute.name, initialChildren: children);

  static const String name = 'EnhancementRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EnhancementScreen();
    },
  );
}

class OCRPreviewRoute extends PageRouteInfo<void> {
  const OCRPreviewRoute({List<PageRouteInfo>? children})
    : super(OCRPreviewRoute.name, initialChildren: children);

  static const String name = 'OCRPreviewRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OCRPreviewScreen();
    },
  );
}

class AISummaryRoute extends PageRouteInfo<void> {
  const AISummaryRoute({List<PageRouteInfo>? children})
    : super(AISummaryRoute.name, initialChildren: children);

  static const String name = 'AISummaryRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AISummaryScreen();
    },
  );
}

class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatScreen();
    },
  );
}

class ExportRoute extends PageRouteInfo<void> {
  const ExportRoute({List<PageRouteInfo>? children})
    : super(ExportRoute.name, initialChildren: children);

  static const String name = 'ExportRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExportScreen();
    },
  );
}

class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute({List<PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutScreen();
    },
  );
}

@RoutePage()
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        CameraRoute(),
        HistoryRoute(),
        SettingsRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}

class ScanDetailRoute extends PageRouteInfo<void> {
  const ScanDetailRoute({List<PageRouteInfo>? children})
    : super(ScanDetailRoute.name, initialChildren: children);

  static const String name = 'ScanDetailRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScanDetailScreen();
    },
  );
}

class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),
    AutoRoute(
      page: AppShellRoute.page,
      path: '/main',
      children: [
        AutoRoute(page: HomeRoute.page, path: 'home', initial: true),
        AutoRoute(page: CameraRoute.page, path: 'camera'),
        AutoRoute(page: HistoryRoute.page, path: 'history'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
    AutoRoute(page: CropEditorRoute.page, path: '/crop'),
    AutoRoute(page: EnhancementRoute.page, path: '/enhance'),
    AutoRoute(page: OCRPreviewRoute.page, path: '/ocr-preview'),
    AutoRoute(page: AISummaryRoute.page, path: '/ai-summary'),
    AutoRoute(page: ChatRoute.page, path: '/chat'),
    AutoRoute(page: ExportRoute.page, path: '/export'),
    AutoRoute(page: AboutRoute.page, path: '/about'),
    AutoRoute(page: ScanDetailRoute.page, path: '/scan/:scanId'),
  ];
}
