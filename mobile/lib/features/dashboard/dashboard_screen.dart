import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_settings.dart';
import '../../core/i18n/campus_copy.dart';
import '../../core/location/location_service.dart';
import '../../core/models/environment_models.dart';
import '../../core/sensors/movement_service.dart';
import '../../shared/widgets/async_state_view.dart';
import '../../shared/widgets/metric_tile.dart';
import '../../shared/widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.settings,
    required this.apiClient,
    required this.onOpenSettings,
  });

  final AppSettings settings;
  final CampusSenseApiClient apiClient;
  final VoidCallback onOpenSettings;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocationService _locationService = const LocationService();
  final MovementService _movementService = const MovementService();
  late Future<_DashboardBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardBundle> _load() async {
    final location = await _locationService.resolve(widget.settings);
    final movement = await _movementService.sampleMovementState();
    final environment = await widget.apiClient.fetchCurrentEnvironment(
      location.applyTo(widget.settings),
      movementState: movement.code,
    );
    return _DashboardBundle(
      environment: environment,
      location: location,
      movement: movement,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = CampusCopy.forLanguage(widget.settings.preferredLanguage);
    return FutureBuilder<_DashboardBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AsyncStateView.loading();
        }
        if (snapshot.hasError) {
          return AsyncStateView.error(
            title: copy.text('backendUnavailable'),
            message: '${snapshot.error}\n${copy.text('backendHelp')}',
            actionLabel: copy.text('openSettings'),
            onAction: widget.onOpenSettings,
          );
        }
        final bundle = snapshot.data;
        if (bundle == null) {
          return AsyncStateView.empty(
            title: copy.text('noEnvironmentData'),
            message: copy.text('tryRefreshing'),
            actionLabel: copy.text('refresh'),
            onAction: _refresh,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ComfortHero(environment: bundle.environment, copy: copy),
              SectionHeader(
                title: copy.text('location'),
                subtitle:
                    '${bundle.environment.location.latitude.toStringAsFixed(4)}, ${bundle.environment.location.longitude.toStringAsFixed(4)}',
                action: IconButton(
                  tooltip: copy.text('refresh'),
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ),
              Text(
                bundle.environment.location.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(bundle.environment.location.city),
              SectionHeader(title: copy.text('deviceContext')),
              _MetricGrid(
                children: [
                  MetricTile(
                    label: copy.text('locationSource'),
                    value: bundle.location.source == LocationSource.gps
                        ? copy.text('sourceGps')
                        : copy.text('sourceManual'),
                    helper: bundle.location.source == LocationSource.gps
                        ? copy.text('gpsLocation')
                        : copy.text('manualLocation'),
                    icon: Icons.my_location,
                  ),
                  MetricTile(
                    label: copy.text('movement'),
                    value: copy.codeLabel(bundle.movement.code),
                    helper: '${copy.text('sentAs')} ${bundle.movement.code}',
                    icon: Icons.directions_walk,
                  ),
                ],
              ),
              SectionHeader(title: copy.text('weather')),
              _MetricGrid(
                children: [
                  MetricTile(
                    label: copy.text('temperature'),
                    value:
                        '${bundle.environment.weather.temperature.toStringAsFixed(1)}C',
                    helper:
                        '${copy.text('feels')} ${bundle.environment.weather.feelsLike.toStringAsFixed(1)}C',
                    icon: Icons.thermostat,
                  ),
                  MetricTile(
                    label: copy.text('humidity'),
                    value: '${bundle.environment.weather.humidity}%',
                    icon: Icons.water_drop_outlined,
                  ),
                  MetricTile(
                    label: copy.text('wind'),
                    value:
                        '${bundle.environment.weather.windSpeed.toStringAsFixed(1)} km/h',
                    icon: Icons.air,
                  ),
                  MetricTile(
                    label: copy.text('rain'),
                    value:
                        '${bundle.environment.weather.precipitation.toStringAsFixed(1)} mm',
                    helper: copy.codeLabel(
                      bundle.environment.weather.conditionCode,
                    ),
                    icon: Icons.umbrella_outlined,
                  ),
                ],
              ),
              SectionHeader(title: copy.text('airQuality')),
              _MetricGrid(
                children: [
                  MetricTile(
                    label: 'AQI',
                    value: '${bundle.environment.airQuality.aqi}',
                    helper: copy.codeLabel(
                      bundle.environment.airQuality.levelCode,
                    ),
                    icon: Icons.eco_outlined,
                  ),
                  MetricTile(
                    label: 'PM2.5',
                    value: bundle.environment.airQuality.pm25.toStringAsFixed(
                      1,
                    ),
                    icon: Icons.blur_on,
                  ),
                  MetricTile(
                    label: 'PM10',
                    value: bundle.environment.airQuality.pm10.toStringAsFixed(
                      1,
                    ),
                    icon: Icons.grain,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ComfortHero extends StatelessWidget {
  const _ComfortHero({required this.environment, required this.copy});

  final EnvironmentCurrent environment;
  final CampusCopy copy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comfort = environment.comfort;
    final color = _scoreColor(theme, comfort.score);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(color: color, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                '${comfort.score}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.codeLabel(comfort.levelCode),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(copy.codeLabel(comfort.adviceCode)),
                  const SizedBox(height: 10),
                  Text(
                    copy.text('comfortScore'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(ThemeData theme, int score) {
    if (score >= 80) {
      return const Color(0xFF1B7F5C);
    }
    if (score >= 60) {
      return const Color(0xFFB7791F);
    }
    return theme.colorScheme.error;
  }
}

class _DashboardBundle {
  const _DashboardBundle({
    required this.environment,
    required this.location,
    required this.movement,
  });

  final EnvironmentCurrent environment;
  final ResolvedLocation location;
  final MovementState movement;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width > 520 ? 3 : 2,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: children,
    );
  }
}
