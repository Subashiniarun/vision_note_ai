import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
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
              return const Center(child: CircularProgressIndicator());
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
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Toggle dark/light theme'),
          value: settings.themeMode == 'dark',
          onChanged: (v) => _settingsBloc.add(
            UpdateTheme(v ? 'dark' : 'light'),
          ),
        ),
        const Divider(),

        _buildSection('OCR'),
        ListTile(
          title: const Text('OCR Language'),
          subtitle: Text(_languageName(settings.ocrLanguage)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguagePicker(context, settings),
        ),
        const Divider(),

        _buildSection('AI'),
        ListTile(
          title: const Text('AI Provider'),
          subtitle: Text(settings.aiProvider == 'gemini' ? 'Gemini' : 'OpenAI'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showProviderPicker(context, settings),
        ),
        ListTile(
          title: const Text('API Key'),
          subtitle: const Text('Configure your AI provider API key'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showApiKeyDialog(context, settings),
        ),
        const Divider(),

        _buildSection('Image'),
        ListTile(
          title: const Text('Image Quality'),
          subtitle: Text('${settings.imageQuality}%'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showQualitySlider(context, settings),
        ),
        SwitchListTile(
          title: const Text('Compression'),
          subtitle: const Text('Compress stored images'),
          value: settings.compressionEnabled,
          onChanged: (v) => _settingsBloc.add(UpdateCompression(v)),
        ),
        const Divider(),

        _buildSection('Capture'),
        SwitchListTile(
          title: const Text('Auto Capture'),
          subtitle: const Text('Auto-capture when document is stable'),
          value: settings.autoCapture,
          onChanged: (v) => _settingsBloc.add(UpdateAutoCapture(v)),
        ),
        SwitchListTile(
          title: const Text('Auto Enhance'),
          subtitle: const Text('Auto-enhance after capture'),
          value: settings.autoEnhance,
          onChanged: (v) => _settingsBloc.add(UpdateAutoEnhance(v)),
        ),
        const Divider(),

        _buildSection('Export'),
        ListTile(
          title: const Text('Default Format'),
          subtitle: Text(settings.defaultExportFormat.toUpperCase()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showFormatPicker(context, settings),
        ),
        const Divider(),

        _buildSection('About'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About VisionNote AI'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.pushRoute(PageRouteInfo.named('AboutRoute')),
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
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
      builder: (_) => SimpleDialog(
        title: const Text('Select OCR Language'),
        children: [
          'en', 'es', 'fr', 'de', 'it', 'pt', 'nl', 'ru', 'ja', 'ko', 'zh',
        ].map((code) {
          return SimpleDialogOption(
            onPressed: () {
              _settingsBloc.add(UpdateOCRLanguage(code));
              Navigator.pop(context);
            },
            child: Text(_languageName(code)),
          );
        }).toList(),
      ),
    );
  }

  void _showProviderPicker(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select AI Provider'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              _settingsBloc.add(const UpdateAIProvider('gemini'));
              Navigator.pop(context);
            },
            child: const Text('Gemini'),
          ),
          SimpleDialogOption(
            onPressed: () {
              _settingsBloc.add(const UpdateAIProvider('openai'));
              Navigator.pop(context);
            },
            child: const Text('OpenAI'),
          ),
        ],
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
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _settingsBloc.add(UpdateAIKey(
                  settings.aiProvider,
                  controller.text,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
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
                Text('$quality%'),
                Slider(
                  value: quality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 9,
                  label: '$quality%',
                  onChanged: (v) => setDialogState(() => quality = v.round()),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  _settingsBloc.add(UpdateImageQuality(quality));
                  Navigator.pop(context);
                },
                child: const Text('Save'),
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
      builder: (_) => SimpleDialog(
        title: const Text('Default Export Format'),
        children: ['markdown', 'txt', 'pdf', 'json'].map((format) {
          return SimpleDialogOption(
            onPressed: () {
              _settingsBloc.add(UpdateDefaultExport(format));
              Navigator.pop(context);
            },
            child: Text(format.toUpperCase()),
          );
        }).toList(),
      ),
    );
  }
}
