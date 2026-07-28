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
  final TextEditingController _apiKeyController = TextEditingController(text: '................');
  bool _isApiKeyObscured = true;

  @override
  void initState() {
    super.initState();
    _settingsBloc = getIt<SettingsBloc>()..add(const LoadSettings());
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {},
          ),
          title: Text(
            'VisionNote AI',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: const Icon(Icons.person, size: 20, color: AppColors.primary),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 0),
      children: [
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B2342),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Customize your scanning and AI experience.',
                style: AppTypography.bodyLg.copyWith(
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionTitle('APPEARANCE'),
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: Icon(Icons.palette_outlined, color: Color(0xFF4B5563)),
                title: Text('Theme', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                subtitle: Text('Switch interface appearance', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildThemeSegment('Light', Icons.light_mode_outlined, settings.themeMode == 'light', () {
                        _settingsBloc.add(const UpdateTheme('light'));
                      }),
                      _buildThemeSegment('Dark', Icons.dark_mode_outlined, settings.themeMode == 'dark', () {
                        _settingsBloc.add(const UpdateTheme('dark'));
                      }),
                      _buildThemeSegment('System', Icons.settings_system_daydream_outlined, settings.themeMode == 'system', () {
                        _settingsBloc.add(const UpdateTheme('system'));
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        _buildSectionTitle('OCR & SCANNING'),
        _buildPremiumCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.translate, color: Color(0xFF4B5563)),
                title: const Text('Recognition Language', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                subtitle: const Text('Primary text detection\nlanguage', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                isThreeLine: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                trailing: InkWell(
                  onTap: () => _showLanguagePicker(context, settings),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _languageName(settings.ocrLanguage),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.hd_outlined, color: Color(0xFF4B5563)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Image Quality', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                              const SizedBox(height: 4),
                              const Text('Balance speed and detail', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  activeTrackColor: const Color(0xFFDAE2FF),
                                  inactiveTrackColor: const Color(0xFFDAE2FF),
                                  thumbColor: AppColors.primary,
                                  overlayColor: AppColors.primary.withOpacity(0.1),
                                ),
                                child: Slider(
                                  value: settings.imageQuality.toDouble(),
                                  min: 10,
                                  max: 100,
                                  onChanged: (val) {
                                    _settingsBloc.add(UpdateImageQuality(val.round()));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${settings.imageQuality}%',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        _buildSectionTitle('AI ENGINE'),
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy_outlined, color: Color(0xFF4B5563)),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text('Service Provider', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    ),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF2FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          _buildAISegment('Gemini', settings.aiProvider == 'gemini', () {
                            _settingsBloc.add(const UpdateAIProvider('gemini'));
                          }),
                          _buildAISegment('OpenAI', settings.aiProvider == 'openai', () {
                            _settingsBloc.add(const UpdateAIProvider('openai'));
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('API Key', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _apiKeyController,
                            obscureText: _isApiKeyObscured,
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 24, letterSpacing: 2, height: 1.0),
                            onTap: () {
                              _showApiKeyDialog(context, settings);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isApiKeyObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            _isApiKeyObscured = !_isApiKeyObscured;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Keys are encrypted and stored locally.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),

        _buildSectionTitle('EXPORT DEFAULTS'),
        _buildPremiumCard(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.description_outlined, color: Color(0xFF4B5563)),
                title: const Text('Auto-export to PDF', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD1D5DB),
                value: settings.autoExportPdf,
                onChanged: (val) {
                  _settingsBloc.add(UpdateAutoExportPdf(val));
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
              SwitchListTile(
                secondary: const Icon(Icons.code_outlined, color: Color(0xFF4B5563)),
                title: const Text('Save as Markdown', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD1D5DB),
                value: settings.saveAsMarkdown,
                onChanged: (val) {
                  _settingsBloc.add(UpdateSaveAsMarkdown(val));
                },
              ),
            ],
          ),
        ),

        _buildSectionTitle('DATA MANAGEMENT'),
        _buildPremiumCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.storage_outlined, color: Color(0xFF4B5563)),
                title: const Text('Export All Library Data', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
                onTap: () {
                  // Handle export
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                title: const Text('Clear Local Cache', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFFDC2626))),
                trailing: const Text('248.5 MB', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                onTap: () {
                  // Handle clear cache
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: Column(
            children: [
              Text(
                'VisionNote AI v2.4.0 (Stable)',
                style: AppTypography.labelMd.copyWith(color: const Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 4),
              Text(
                'Built for High-Precision Knowledge Conversion',
                style: AppTypography.labelMd.copyWith(color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildThemeSegment(String text, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primary : const Color(0xFF6B7280)),
              const SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAISegment(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _languageName(String code) {
    final languages = {
      'en': 'English (US)', 'es': 'Spanish', 'fr': 'French',
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
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              'en', 'es', 'fr', 'de', 'it', 'pt', 'nl', 'ru', 'ja', 'ko', 'zh',
            ].map((code) => ListTile(
              title: Text(_languageName(code)),
              selected: settings.ocrLanguage == code,
              onTap: () {
                _settingsBloc.add(UpdateOCRLanguage(code));
                Navigator.pop(context);
              },
            )).toList(),
          ),
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
}
