import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_settings.dart';
import '../../core/i18n/campus_copy.dart';
import '../../core/models/history_models.dart';
import '../../shared/widgets/async_state_view.dart';
import '../../shared/widgets/metric_tile.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/comfort_trend_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.settings,
    required this.apiClient,
  });

  final AppSettings settings;
  final CampusSenseApiClient apiClient;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<_HistoryBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HistoryBundle> _load() async {
    final recordsFuture = widget.apiClient.fetchHistory(
      widget.settings.deviceId,
    );
    final trendFuture = widget.apiClient.fetchTrends(
      widget.settings.deviceId,
      limit: 10,
    );
    return _HistoryBundle(
      records: await recordsFuture,
      trend: await trendFuture,
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
    return FutureBuilder<_HistoryBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AsyncStateView.loading();
        }
        if (snapshot.hasError) {
          return AsyncStateView.error(
            title: copy.text('historyUnavailable'),
            message: snapshot.error.toString(),
            actionLabel: copy.text('retry'),
            onAction: _refresh,
          );
        }
        final bundle = snapshot.data;
        if (bundle == null ||
            (bundle.records.isEmpty && bundle.trend.points.isEmpty)) {
          return AsyncStateView.empty(
            title: copy.text('noReportsYet'),
            message: copy.text('submitToStart'),
            actionLabel: copy.text('refresh'),
            onAction: _refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionHeader(
                title: copy.text('trendSummary'),
                subtitle: copy.text('trendSubtitle'),
                action: IconButton(
                  tooltip: copy.text('refresh'),
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ),
              if (bundle.trend.points.isEmpty)
                Text(copy.text('noTrendPoints'))
              else ...[
                ComfortTrendChart(points: bundle.trend.points),
                const SizedBox(height: 8),
                ...bundle.trend.points.reversed
                    .take(5)
                    .map((point) => _TrendPointTile(point: point, copy: copy)),
              ],
              SectionHeader(title: copy.text('recentReports')),
              ...bundle.records.map((record) {
                return _HistoryRecordTile(record: record, copy: copy);
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TrendPointTile extends StatelessWidget {
  const _TrendPointTile({required this.point, required this.copy});

  final HistoryTrendPoint point;
  final CampusCopy copy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: MetricTile(
              label: _formatDate(point.createdAt),
              value: '${point.comfortScore}',
              helper: copy.text('comfort'),
              icon: Icons.favorite_outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MetricTile(
              label: 'AQI',
              value: '${point.aqi}',
              helper: '${point.temperature.toStringAsFixed(1)}C',
              icon: Icons.eco_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRecordTile extends StatelessWidget {
  const _HistoryRecordTile({required this.record, required this.copy});

  final HistoryRecord record;
  final CampusCopy copy;

  @override
  Widget build(BuildContext context) {
    final report = record.report;
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${report.comfortScore}')),
        title: Text(copy.codeLabel(report.scene)),
        subtitle: Text(
          '${report.tags.isEmpty ? copy.text('noTags') : report.tags.map(copy.codeLabel).join(', ')}\n${report.note.isEmpty ? copy.text('noNote') : report.note}',
        ),
        isThreeLine: true,
        trailing: Text(_formatDate(report.createdAt)),
      ),
    );
  }
}

class _HistoryBundle {
  const _HistoryBundle({required this.records, required this.trend});

  final List<HistoryRecord> records;
  final HistoryTrend trend;
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '--';
  }
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}
