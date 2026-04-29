import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/config/app_settings.dart';
import '../core/config/settings_repository.dart';
import '../core/i18n/campus_copy.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';
import '../features/nearby/nearby_screen.dart';
import '../features/report/report_screen.dart';
import '../features/settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.settingsRepository,
    required this.initialSettings,
  });

  final SettingsRepository settingsRepository;
  final AppSettings initialSettings;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppSettings _settings;
  late CampusSenseApiClient _apiClient;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _apiClient = CampusSenseApiClient(baseUrl: _settings.baseUrl);
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  void _applySettings(AppSettings settings) {
    setState(() {
      _settings = settings;
      _apiClient.close();
      _apiClient = CampusSenseApiClient(baseUrl: settings.baseUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = CampusCopy.forLanguage(_settings.preferredLanguage);
    final screens = <Widget>[
      DashboardScreen(
        key: ValueKey('dashboard-${_settings.cacheKey}'),
        settings: _settings,
        apiClient: _apiClient,
        onOpenSettings: () => setState(() => _selectedIndex = 4),
      ),
      ReportScreen(
        key: ValueKey('report-${_settings.cacheKey}'),
        settings: _settings,
        apiClient: _apiClient,
      ),
      HistoryScreen(
        key: ValueKey('history-${_settings.cacheKey}'),
        settings: _settings,
        apiClient: _apiClient,
      ),
      NearbyScreen(
        key: ValueKey('nearby-${_settings.cacheKey}'),
        settings: _settings,
        apiClient: _apiClient,
      ),
      SettingsScreen(
        settings: _settings,
        settingsRepository: widget.settingsRepository,
        onSettingsSaved: _applySettings,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusSense'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                _settings.preferredLanguage.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() => _selectedIndex = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: copy.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.edit_location_alt_outlined),
            selectedIcon: const Icon(Icons.edit_location_alt),
            label: copy.report,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: copy.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: copy.nearby,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: copy.settings,
          ),
        ],
      ),
    );
  }
}
