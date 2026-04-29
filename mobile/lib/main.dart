import 'package:flutter/material.dart';

import 'app/campus_sense_app.dart';
import 'core/config/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = SettingsRepository();
  final settings = await settingsRepository.load();

  runApp(
    CampusSenseApp(
      settingsRepository: settingsRepository,
      initialSettings: settings,
    ),
  );
}
