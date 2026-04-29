import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_settings.dart';
import '../../core/i18n/campus_copy.dart';
import '../../core/location/location_service.dart';
import '../../core/models/report_models.dart';
import '../../core/sensors/movement_service.dart';
import '../../shared/widgets/section_header.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.settings,
    required this.apiClient,
  });

  final AppSettings settings;
  final CampusSenseApiClient apiClient;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final LocationService _locationService = const LocationService();
  final MovementService _movementService = const MovementService();
  static const _scenes = ['STUDY', 'REST', 'WALK', 'COMMUTE'];
  static const _tags = [
    'COMFORTABLE',
    'QUIET',
    'GOOD_FOR_STUDY',
    'TOO_HOT',
    'TOO_COLD',
    'TOO_NOISY',
    'POOR_AIR',
  ];

  final _noteController = TextEditingController();
  final Set<String> _selectedTags = {'COMFORTABLE'};
  String _selectedScene = 'STUDY';
  bool _submitting = false;
  CampusReport? _lastReport;
  ResolvedLocation? _lastLocation;
  MovementState _lastMovementState = MovementState.unknown;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedTags.isEmpty || _submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _lastReport = null;
    });

    try {
      final location = await _locationService.resolve(widget.settings);
      final movement = await _movementService.sampleMovementState();
      final report = await widget.apiClient.submitReport(
        settings: location.applyTo(widget.settings),
        scene: _selectedScene,
        tags: _selectedTags.toList(),
        note: _noteController.text.trim(),
        movementState: movement.code,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _lastReport = report;
        _lastLocation = location;
        _lastMovementState = movement;
        _noteController.clear();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = CampusCopy.forLanguage(widget.settings.preferredLanguage);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.place_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${copy.text('reportingAt')} ${widget.settings.latitude.toStringAsFixed(4)}, '
                    '${widget.settings.longitude.toStringAsFixed(4)}',
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(title: copy.text('scene')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _scenes.map((scene) {
            return ChoiceChip(
              label: Text(_label(scene)),
              selected: scene == _selectedScene,
              onSelected: (_) => setState(() => _selectedScene = scene),
            );
          }).toList(),
        ),
        SectionHeader(title: copy.text('feedbackTags')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            return FilterChip(
              label: Text(copy.codeLabel(tag)),
              selected: _selectedTags.contains(tag),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
        SectionHeader(title: copy.text('optionalNote')),
        TextField(
          controller: _noteController,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(hintText: copy.text('noteHint')),
        ),
        SectionHeader(title: copy.text('deviceContext')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sensors_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _lastLocation == null
                        ? copy.text('submitDeviceHelp')
                        : '${_lastLocation!.source == LocationSource.gps ? copy.text('gpsLocation') : copy.text('manualLocation')}\n${copy.text('movement')}: ${copy.codeLabel(_lastMovementState.code)}',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _selectedTags.isEmpty || _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(
            _submitting ? copy.text('submitting') : copy.text('submitReport'),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          _StatusPanel.error(message: _error!),
        ],
        if (_lastReport != null) ...[
          const SizedBox(height: 14),
          _StatusPanel.success(report: _lastReport!, copy: copy),
        ],
      ],
    );
  }

  String _label(String code) {
    return CampusCopy.forLanguage(
      widget.settings.preferredLanguage,
    ).codeLabel(code);
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel.success({
    required CampusReport report,
    required CampusCopy copy,
  }) : _copy = copy,
       _report = report,
       _message = null,
       _isError = false;

  const _StatusPanel.error({required String message})
    : _copy = null,
      _message = message,
      _report = null,
      _isError = true;

  final CampusReport? _report;
  final String? _message;
  final CampusCopy? _copy;
  final bool _isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _isError ? Icons.error_outline : Icons.check_circle_outline,
              color: _isError ? theme.colorScheme.error : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isError
                    ? _message!
                    : '${_copy!.text('reportSaved')} ${_report!.comfortScore}.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
