import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../services/settings_service.dart';
import '../../../services/tts_service.dart';
import '../../../widgets/accessible_button.dart';

/// Pantalla de bienvenida y configuración inicial de accesibilidad (omisible).
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final tts = context.read<TtsService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.welcomeTitle),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () async {
              await settings.setHasSeenOnboarding(true);
              widget.onComplete();
            },
            child: const Text(
              AppStrings.welcomeSkip,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logotipo de Naviun
              Center(
                child: Semantics(
                  label: 'Logotipo de Naviun: Tu guía en la universidad',
                  child: Image.asset(
                    'assets/logotipo_Naviun.png',
                    height: 90,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.navigation,
                      size: 80,
                      color: AppConstants.primaryGreenLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                AppStrings.welcomeSubtitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // Aviso de Seguridad Obligatorio
              Semantics(
                container: true,
                label: '${AppStrings.safetyWarningTitle}: ${AppStrings.safetyWarningBody}',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD97706), width: 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.safetyWarningTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.safetyWarningBody,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: isDark ? Colors.white70 : AppConstants.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ajuste de Tema Claro / Oscuro
              Text(
                AppStrings.welcomeThemeTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(AppStrings.themeSystem),
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Claro'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Oscuro'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (val) {
                  settings.setThemeMode(val.first);
                },
              ),
              const SizedBox(height: 24),

              // Ajuste de Escala de Texto
              Text(
                AppStrings.welcomeTextSizeTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              SegmentedButton<double>(
                segments: const [
                  ButtonSegment(
                    value: 1.0,
                    label: Text(AppStrings.textSizeNormal),
                  ),
                  ButtonSegment(
                    value: 1.15,
                    label: Text(AppStrings.textSizeLarge),
                  ),
                  ButtonSegment(
                    value: 1.30,
                    label: Text(AppStrings.textSizeExtraLarge),
                  ),
                ],
                selected: {settings.textScaleMultiplier},
                onSelectionChanged: (val) {
                  settings.setTextScaleMultiplier(val.first);
                },
              ),
              const SizedBox(height: 24),

              // Velocidad de Voz y Prueba de Audio
              Text(
                AppStrings.welcomeVoiceTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Slider(
                value: settings.ttsRate,
                min: 0.3,
                max: 0.9,
                divisions: 6,
                label: '${(settings.ttsRate * 2).toStringAsFixed(1)}x',
                onChanged: (val) {
                  settings.setTtsRate(val);
                },
              ),
              const SizedBox(height: 8),
              AccessibleButton(
                label: AppStrings.testVoiceButton,
                icon: Icons.volume_up,
                type: AccessibleButtonType.secondary,
                onPressed: () {
                  tts.testVoice(rate: settings.ttsRate, volume: settings.ttsVolume);
                },
              ),
              const SizedBox(height: 36),

              // Botón Principal Comenzar
              AccessibleButton(
                label: AppStrings.welcomeStart,
                icon: Icons.check,
                type: AccessibleButtonType.primary,
                minHeight: 56,
                onPressed: () async {
                  await settings.setHasSeenOnboarding(true);
                  widget.onComplete();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
