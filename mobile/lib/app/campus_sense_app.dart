import 'package:flutter/material.dart';

import '../core/config/app_settings.dart';
import '../core/config/settings_repository.dart';
import '../core/i18n/campus_copy.dart';
import '../features/onboarding/splash_screen.dart';
import 'app_shell.dart';
import 'theme.dart';

class CampusSenseApp extends StatefulWidget {
  const CampusSenseApp({
    super.key,
    required this.settingsRepository,
    required this.initialSettings,
  });

  final SettingsRepository settingsRepository;
  final AppSettings initialSettings;

  @override
  State<CampusSenseApp> createState() => _CampusSenseAppState();
}

class _CampusSenseAppState extends State<CampusSenseApp> {
  bool _introComplete = false;

  @override
  Widget build(BuildContext context) {
    final copy = CampusCopy.forLanguage(
      widget.initialSettings.preferredLanguage,
    );
    return MaterialApp(
      title: 'CampusSense',
      debugShowCheckedModeBanner: false,
      theme: CampusSenseTheme.light(),
      home: _introComplete
          ? AppShell(
              settingsRepository: widget.settingsRepository,
              initialSettings: widget.initialSettings,
            )
          : SplashScreen(
              copy: copy,
              onContinue: () => setState(() => _introComplete = true),
            ),
    );
  }
}
