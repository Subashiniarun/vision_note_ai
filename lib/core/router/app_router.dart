import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../features/scan/presentation/screens/scan_detail_screen.dart';
import '../../features/scan/presentation/screens/batch_screen.dart';
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
import '../../core/widgets/vna_bottom_nav.dart';
import '../theme/app_transitions.dart';

class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const SplashScreen(),
  );
}

class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const OnboardingScreen(),
  );
}

class AppShellRoute extends PageRouteInfo<void> {
  const AppShellRoute({List<PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const AppShell(),
  );
}

class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const HomeScreen(),
  );
}

class CameraRoute extends PageRouteInfo<void> {
  const CameraRoute({List<PageRouteInfo>? children})
    : super(CameraRoute.name, initialChildren: children);

  static const String name = 'CameraRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const CameraScreen(),
  );
}

class HistoryRoute extends PageRouteInfo<void> {
  const HistoryRoute({List<PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const HistoryScreen(),
  );
}

class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const SettingsScreen(),
  );
}

class CropEditorRoute extends PageRouteInfo<void> {
  const CropEditorRoute({List<PageRouteInfo>? children})
    : super(CropEditorRoute.name, initialChildren: children);

  static const String name = 'CropEditorRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const CropEditorScreen(),
  );
}

class EnhancementRoute extends PageRouteInfo<void> {
  const EnhancementRoute({List<PageRouteInfo>? children})
    : super(EnhancementRoute.name, initialChildren: children);

  static const String name = 'EnhancementRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const EnhancementScreen(),
  );
}

class OCRPreviewRoute extends PageRouteInfo<void> {
  const OCRPreviewRoute({List<PageRouteInfo>? children})
    : super(OCRPreviewRoute.name, initialChildren: children);

  static const String name = 'OCRPreviewRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const OCRPreviewScreen(),
  );
}

class AISummaryRoute extends PageRouteInfo<void> {
  const AISummaryRoute({List<PageRouteInfo>? children})
    : super(AISummaryRoute.name, initialChildren: children);

  static const String name = 'AISummaryRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const AISummaryScreen(),
  );
}

class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const ChatScreen(),
  );
}

class ExportRoute extends PageRouteInfo<void> {
  const ExportRoute({List<PageRouteInfo>? children})
    : super(ExportRoute.name, initialChildren: children);

  static const String name = 'ExportRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const ExportScreen(),
  );
}

class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute({List<PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const AboutScreen(),
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
        return VNABottomNav(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
        );
      },
      animationDuration: const Duration(milliseconds: 250),
    );
  }
}

class BatchRoute extends PageRouteInfo<void> {
  const BatchRoute({List<PageRouteInfo>? children})
    : super(BatchRoute.name, initialChildren: children);

  static const String name = 'BatchRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const BatchScreen(),
  );
}

class ScanDetailRoute extends PageRouteInfo<void> {
  const ScanDetailRoute({List<PageRouteInfo>? children})
    : super(ScanDetailRoute.name, initialChildren: children);

  static const String name = 'ScanDetailRoute';

  static final PageInfo page = PageInfo(
    name,
    builder: (data) => const ScanDetailScreen(),
  );
}

class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),
    CustomRoute(
      page: OnboardingRoute.page,
      path: '/onboarding',
      transitionsBuilder: AppTransitions.slideRight,
      duration: const Duration(milliseconds: 400),
    ),
    CustomRoute(
      page: AppShellRoute.page,
      path: '/main',
      transitionsBuilder: AppTransitions.fadeThrough,
      duration: const Duration(milliseconds: 350),
      children: [
        AutoRoute(page: HomeRoute.page, path: 'home', initial: true),
        AutoRoute(page: CameraRoute.page, path: 'camera'),
        AutoRoute(page: HistoryRoute.page, path: 'history'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
    CustomRoute(
      page: CropEditorRoute.page,
      path: '/crop',
      transitionsBuilder: AppTransitions.slideRight,
      duration: const Duration(milliseconds: 300),
    ),
    CustomRoute(
      page: EnhancementRoute.page,
      path: '/enhance',
      transitionsBuilder: AppTransitions.slideRight,
      duration: const Duration(milliseconds: 300),
    ),
    CustomRoute(
      page: OCRPreviewRoute.page,
      path: '/ocr-preview',
      transitionsBuilder: AppTransitions.slideRight,
      duration: const Duration(milliseconds: 300),
    ),
    CustomRoute(
      page: AISummaryRoute.page,
      path: '/ai-summary',
      transitionsBuilder: AppTransitions.slideBottom,
      duration: const Duration(milliseconds: 350),
    ),
    CustomRoute(
      page: ChatRoute.page,
      path: '/chat',
      transitionsBuilder: AppTransitions.slideBottom,
      duration: const Duration(milliseconds: 350),
    ),
    CustomRoute(
      page: ExportRoute.page,
      path: '/export',
      transitionsBuilder: AppTransitions.slideBottom,
      duration: const Duration(milliseconds: 300),
    ),
    CustomRoute(
      page: AboutRoute.page,
      path: '/about',
      transitionsBuilder: AppTransitions.fadeThrough,
      duration: const Duration(milliseconds: 250),
    ),
    CustomRoute(
      page: BatchRoute.page,
      path: '/batch',
      transitionsBuilder: AppTransitions.slideBottom,
      duration: const Duration(milliseconds: 300),
    ),
    CustomRoute(
      page: ScanDetailRoute.page,
      path: '/scan/:scanId',
      transitionsBuilder: AppTransitions.slideRight,
      duration: const Duration(milliseconds: 300),
    ),
  ];
}
