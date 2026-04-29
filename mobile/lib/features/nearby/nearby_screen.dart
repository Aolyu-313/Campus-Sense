import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_settings.dart';
import '../../core/i18n/campus_copy.dart';
import '../../core/models/report_models.dart';
import '../../shared/widgets/async_state_view.dart';
import '../../shared/widgets/section_header.dart';

typedef NearbyReportsLoader = Future<List<CampusReport>> Function();

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({
    super.key,
    this.settings,
    this.apiClient,
    this.reportsLoader,
  }) : assert(
         reportsLoader != null || (settings != null && apiClient != null),
         'Provide reportsLoader or both settings and apiClient.',
       );

  final AppSettings? settings;
  final CampusSenseApiClient? apiClient;
  final NearbyReportsLoader? reportsLoader;

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  late Future<List<CampusReport>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant NearbyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings ||
        oldWidget.apiClient != widget.apiClient ||
        oldWidget.reportsLoader != widget.reportsLoader) {
      _future = _load();
    }
  }

  Future<List<CampusReport>> _load() {
    final loader = widget.reportsLoader;
    if (loader != null) {
      return loader();
    }
    return widget.apiClient!.fetchNearbyReports(widget.settings!);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.settings == null
        ? CampusCopy.forLanguage('en')
        : CampusCopy.forLanguage(widget.settings!.preferredLanguage);
    return FutureBuilder<List<CampusReport>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AsyncStateView.loading();
        }
        if (snapshot.hasError) {
          return AsyncStateView.error(
            title: copy.text('nearbyUnavailable'),
            message: snapshot.error.toString(),
            actionLabel: copy.text('retry'),
            onAction: _refresh,
          );
        }
        final reports = snapshot.data ?? const <CampusReport>[];
        if (reports.isEmpty) {
          return AsyncStateView.empty(
            title: copy.text('noNearbyReports'),
            message: copy.text('submitNearby'),
            actionLabel: copy.text('refresh'),
            onAction: _refresh,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _NearbyMapPanel(reports: reports, copy: copy),
              SectionHeader(
                title: copy.text('nearbyReports'),
                subtitle: copy.text('nearbySubtitle'),
                action: IconButton(
                  tooltip: copy.text('refresh'),
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ),
              ...reports.map(
                (report) => _NearbyReportTile(report: report, copy: copy),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NearbyMapPanel extends StatelessWidget {
  const _NearbyMapPanel({required this.reports, required this.copy});

  final List<CampusReport> reports;
  final CampusCopy copy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: copy.text('nearbyComfortMap'),
          subtitle: copy.text('nearbyMapSubtitle'),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bounds = _MapBounds.fromReports(reports);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NearbyMapPainter(theme.colorScheme),
                    ),
                  ),
                  for (final report in reports)
                    _MapMarker(
                      report: report,
                      copy: copy,
                      offset: bounds.offsetFor(report),
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const _LegendDot(color: Color(0xFF1B7F5C)),
            Text(copy.text('higherComfort')),
            const SizedBox(width: 12),
            _LegendDot(color: theme.colorScheme.error),
            Text(copy.text('lowerComfort')),
          ],
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.report,
    required this.copy,
    required this.offset,
    required this.width,
    required this.height,
  });

  final CampusReport report;
  final CampusCopy copy;
  final Offset offset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 42.0;
    final left = (offset.dx * width - size / 2).clamp(6.0, width - size - 6);
    final top = (offset.dy * height - size / 2).clamp(6.0, height - size - 6);
    final color = _scoreColor(theme, report.comfortScore);
    return Positioned(
      left: left,
      top: top,
      child: Tooltip(
        message: '${copy.codeLabel(report.scene)} ${report.comfortScore}',
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            '${report.comfortScore}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
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

class _NearbyMapPainter extends CustomPainter {
  const _NearbyMapPainter(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final dx = size.width * i / 4;
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final centerPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.shortestSide * 0.28,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NearbyMapPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MapBounds {
  const _MapBounds({
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
  });

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;

  factory _MapBounds.fromReports(List<CampusReport> reports) {
    var minLatitude = reports.first.latitude;
    var maxLatitude = reports.first.latitude;
    var minLongitude = reports.first.longitude;
    var maxLongitude = reports.first.longitude;
    for (final report in reports.skip(1)) {
      if (report.latitude < minLatitude) minLatitude = report.latitude;
      if (report.latitude > maxLatitude) maxLatitude = report.latitude;
      if (report.longitude < minLongitude) minLongitude = report.longitude;
      if (report.longitude > maxLongitude) maxLongitude = report.longitude;
    }
    return _MapBounds(
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
    );
  }

  Offset offsetFor(CampusReport report) {
    final latitudeSpan = maxLatitude - minLatitude;
    final longitudeSpan = maxLongitude - minLongitude;
    final x = longitudeSpan == 0
        ? 0.5
        : 0.12 + ((report.longitude - minLongitude) / longitudeSpan) * 0.76;
    final y = latitudeSpan == 0
        ? 0.5
        : 0.88 - ((report.latitude - minLatitude) / latitudeSpan) * 0.76;
    return Offset(x, y);
  }
}

class _NearbyReportTile extends StatelessWidget {
  const _NearbyReportTile({required this.report, required this.copy});

  final CampusReport report;
  final CampusCopy copy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = report.distanceMeters == null
        ? copy.text('distanceUnknown')
        : _formatDistance(report.distanceMeters!.round(), copy);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _scoreColor(
            theme,
            report.comfortScore,
          ).withValues(alpha: 0.14),
          child: Text('${report.comfortScore}'),
        ),
        title: Text(copy.codeLabel(report.scene)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(distance),
            Text(
              report.note.isEmpty
                  ? report.tags.isEmpty
                        ? copy.text('noTags')
                        : report.tags.map(copy.codeLabel).join(', ')
                  : report.note,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.place_outlined),
      ),
    );
  }

  String _formatDistance(int meters, CampusCopy copy) {
    if (copy.text('metersAway') == '米外') {
      return '$meters ${copy.text('metersAway')}';
    }
    return '$meters ${copy.text('metersAway')}';
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
