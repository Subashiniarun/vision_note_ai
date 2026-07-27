import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_bloc.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = getIt<SettingsBloc>()..add(const LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is! SettingsLoaded) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            return _buildSettings(context, state.settings);
          },
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context, AppSettings settings) {
    return ListView(
      children: [
        _buildSection('Appearance'),
        _buildPremiumCard(
          child: ListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark/light theme'),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                settings.themeMode == 'dark' ? Icons.dark_mode : Icons.light_mode,
                key: ValueKey<String>(settings.themeMode),
                color: settings.themeMode == 'dark' ? AppColors.primary : const Color(0xFFF59E0B),
                size: 28,
              ),
            ),
            onTap: () => _settingsBloc.add(UpdateTheme(settings.themeMode == 'dark' ? 'light' : 'dark')),
          ),
        ),

        _buildSection('OCR'),
        _buildPremiumCard(
          child: ListTile(
            title: const Text('OCR Language'),
            subtitle: Text(_languageName(settings.ocrLanguage), style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
            onTap: () => _showLanguagePicker(context, settings),
          ),
        ),

        _buildSection('AI'),
        _buildPremiumCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('AI Provider'),
                subtitle: Text(settings.aiProvider == 'gemini' ? 'Gemini' : 'OpenAI', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
                onTap: () => _showProviderPicker(context, settings),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.outlineVariant),
              ListTile(
                title: const Text('API Key'),
                subtitle: const Text('Configure your AI provider API key', style: AppTypography.labelMd),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
                onTap: () => _showApiKeyDialog(context, settings),
              ),
            ],
          ),
        ),

        _buildSection('Image'),
        _buildPremiumCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('Image Quality'),
                subtitle: Text('${settings.imageQuality}%', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
                onTap: () => _showQualitySlider(context, settings),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.outlineVariant),
              SwitchListTile(
                title: const Text('Compression'),
                subtitle: const Text('Compress stored images'),
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                activeThumbColor: AppColors.primary,
                value: settings.compressionEnabled,
                onChanged: (v) => _settingsBloc.add(UpdateCompression(v)),
              ),
            ],
          ),
        ),

        _buildSection('Capture'),
        _buildPremiumCard(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Auto Capture'),
                subtitle: const Text('Auto-capture when document is stable'),
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                activeThumbColor: AppColors.primary,
                value: settings.autoCapture,
                onChanged: (v) => _settingsBloc.add(UpdateAutoCapture(v)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.outlineVariant),
              SwitchListTile(
                title: const Text('Auto Enhance'),
                subtitle: const Text('Auto-enhance after capture'),
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                activeThumbColor: AppColors.primary,
                value: settings.autoEnhance,
                onChanged: (v) => _settingsBloc.add(UpdateAutoEnhance(v)),
              ),
            ],
          ),
        ),

        _buildSection('Export'),
        _buildPremiumCard(
          child: ListTile(
            title: const Text('Default Format'),
            subtitle: Text(settings.defaultExportFormat.toUpperCase(), style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
            onTap: () => _showFormatPicker(context, settings),
          ),
        ),

        _buildSection('About'),
        _buildPremiumCard(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: const Icon(Icons.info_outline, size: 20, color: AppColors.onPrimaryContainer),
            ),
            title: const Text('About VisionNote AI'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
            onTap: () => context.pushRoute(PageRouteInfo.named('AboutRoute')),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.labelLg.copyWith(color: AppColors.primary),
      ),
    );
  }

  String _languageName(String code) {
    final languages = {
      'en': 'English', 'es': 'Spanish', 'fr': 'French',
      'de': 'German', 'it': 'Italian', 'pt': 'Portuguese',
      'nl': 'Dutch', 'ru': 'Russian', 'ja': 'Japanese', 'ko': 'Korean', 'zh': 'Chinese',
    };
    return languages[code] ?? code;
  }

  void _showLanguagePicker(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select OCR Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'en', 'es', 'fr', 'de', 'it', 'pt', 'nl', 'ru', 'ja', 'ko', 'zh',
          ].map((code) => ListTile(
            title: Text(_languageName(code)),
            onTap: () {
              _settingsBloc.add(UpdateOCRLanguage(code));
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showProviderPicker(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select AI Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Gemini'),
              leading: const Icon(Icons.auto_awesome, color: AppColors.primary),
              onTap: () {
                _settingsBloc.add(const UpdateAIProvider('gemini'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('OpenAI'),
              leading: const Icon(Icons.auto_awesome, color: AppColors.primary),
              onTap: () {
                _settingsBloc.add(const UpdateAIProvider('openai'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, AppSettings settings) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${settings.aiProvider == 'gemini' ? 'Gemini' : 'OpenAI'} API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your API key',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          VNAButton(
            label: 'Save',
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _settingsBloc.add(UpdateAIKey(settings.aiProvider, controller.text));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showQualitySlider(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          var quality = settings.imageQuality;
          return AlertDialog(
            title: const Text('Image Quality'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$quality%', style: AppTypography.headlineSm.copyWith(color: AppColors.primary)),
                Slider(
                  value: quality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 9,
                  activeColor: AppColors.primary,
                  label: '$quality%',
                  onChanged: (v) => setDialogState(() => quality = v.round()),
                ),
              ],
            ),
            actions: [
              VNAButton(
                label: 'Save',
                onPressed: () {
                  _settingsBloc.add(UpdateImageQuality(quality));
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFormatPicker(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Default Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['markdown', 'txt', 'pdf', 'json'].map((format) => ListTile(
            title: Text(format.toUpperCase()),
            onTap: () {
              _settingsBloc.add(UpdateDefaultExport(format));
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}
