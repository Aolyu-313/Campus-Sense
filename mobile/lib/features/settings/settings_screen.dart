import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_settings.dart';
import '../../core/config/settings_repository.dart';
import '../../core/i18n/campus_copy.dart';
import '../../shared/widgets/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.settingsRepository,
    required this.onSettingsSaved,
  });

  final AppSettings settings;
  final SettingsRepository settingsRepository;
  final ValueChanged<AppSettings> onSettingsSaved;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _deviceIdController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late String _language;
  bool _saving = false;
  bool _checking = false;
  String? _status;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: widget.settings.baseUrl);
    _deviceIdController = TextEditingController(text: widget.settings.deviceId);
    _latitudeController = TextEditingController(
      text: widget.settings.latitude.toString(),
    );
    _longitudeController = TextEditingController(
      text: widget.settings.longitude.toString(),
    );
    _language = widget.settings.preferredLanguage;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _deviceIdController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final copy = CampusCopy.forLanguage(_language);
    final next = _readSettings();
    if (next == null) {
      return;
    }

    setState(() {
      _saving = true;
      _status = null;
    });

    final client = CampusSenseApiClient(baseUrl: next.baseUrl);
    try {
      await widget.settingsRepository.save(next);
      widget.onSettingsSaved(next);
      try {
        await client.updateProfile(
          deviceId: next.deviceId,
          preferredLanguage: next.preferredLanguage,
        );
        _setStatus(copy.text('settingsSavedProfileSynced'), isError: false);
      } catch (error) {
        _setStatus(
          '${copy.text('settingsSavedProfileFailed')} $error',
          isError: true,
        );
      }
    } finally {
      client.close();
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _checkHealth() async {
    final copy = CampusCopy.forLanguage(_language);
    final next = _readSettings();
    if (next == null) {
      return;
    }
    setState(() {
      _checking = true;
      _status = null;
    });

    final client = CampusSenseApiClient(baseUrl: next.baseUrl);
    try {
      final response = await client.health();
      _setStatus(
        '${copy.text('healthOk')} ${response['status'] ?? 'OK'}',
        isError: false,
      );
    } catch (error) {
      _setStatus('${copy.text('healthFailed')} $error', isError: true);
    } finally {
      client.close();
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  void _regenerateDeviceId() {
    setState(() {
      _deviceIdController.text = AppSettings.generateDeviceId();
    });
  }

  AppSettings? _readSettings() {
    final copy = CampusCopy.forLanguage(_language);
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude == null ||
        longitude < -180 ||
        longitude > 180) {
      _setStatus(copy.text('invalidCoordinates'), isError: true);
      return null;
    }

    final baseUrl = _baseUrlController.text.trim();
    final deviceId = _deviceIdController.text.trim();
    if (baseUrl.isEmpty || deviceId.isEmpty) {
      _setStatus(copy.text('requiredBackendDevice'), isError: true);
      return null;
    }

    return AppSettings(
      baseUrl: baseUrl,
      deviceId: deviceId,
      preferredLanguage: _language,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void _setStatus(String message, {required bool isError}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _status = message;
      _statusIsError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = CampusCopy.forLanguage(_language);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          title: copy.text('backend'),
          subtitle: copy.text('backendSubtitle'),
        ),
        TextField(
          controller: _baseUrlController,
          decoration: InputDecoration(
            labelText: copy.text('backendBaseUrl'),
            prefixIcon: const Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: _checking ? null : _checkHealth,
          icon: _checking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.monitor_heart_outlined),
          label: Text(
            _checking ? copy.text('checking') : copy.text('healthCheck'),
          ),
        ),
        SectionHeader(title: copy.text('identity')),
        TextField(
          controller: _deviceIdController,
          decoration: InputDecoration(
            labelText: copy.text('anonymousDeviceId'),
            prefixIcon: const Icon(Icons.badge_outlined),
            suffixIcon: IconButton(
              tooltip: copy.text('regenerate'),
              onPressed: _regenerateDeviceId,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
        SectionHeader(title: copy.text('demoLocation')),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latitudeController,
                decoration: InputDecoration(labelText: copy.text('latitude')),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _longitudeController,
                decoration: InputDecoration(labelText: copy.text('longitude')),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SectionHeader(title: copy.text('language')),
        DropdownButtonFormField<String>(
          initialValue: _language,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.language)),
          items: [
            DropdownMenuItem(value: 'en', child: Text(copy.text('english'))),
            DropdownMenuItem(value: 'zh', child: Text(copy.text('chinese'))),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _language = value);
            }
          },
        ),
        SectionHeader(title: copy.text('dataSources')),
        Text(copy.text('dataSourcesBody')),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(
            _saving ? copy.text('saving') : copy.text('saveSettings'),
          ),
        ),
        if (_status != null) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    _statusIsError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: _statusIsError
                        ? Theme.of(context).colorScheme.error
                        : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_status!)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
