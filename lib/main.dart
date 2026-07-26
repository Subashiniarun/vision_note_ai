import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/router/app_router.dart';
import 'core/widgets/placeholder_image.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/logger.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VNALogger.configure();
  final hive = await HiveService.initialize();
  await hive.openBox('visionnote_settings');
  await di.configureDependencies();
  runApp(const VisionNoteAIApp());
}

class VisionNoteAIApp extends StatelessWidget {
  const VisionNoteAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'VisionNote AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.mode,
            routerConfig: appRouter.config(),
          );
        },
      ),
    );
  }
}
