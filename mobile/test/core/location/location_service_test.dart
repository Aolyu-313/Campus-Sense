import 'package:campussense_mobile/core/config/app_settings.dart';
import 'package:campussense_mobile/core/location/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fallback = AppSettings(
    baseUrl: 'http://localhost:8080',
    deviceId: 'test-device',
    preferredLanguage: 'en',
    latitude: 51.5246,
    longitude: -0.1340,
  );

  test(
    'resolve returns GPS coordinates when permission and service are ready',
    () async {
      final service = LocationService(
        gateway: _FakeLocationGateway(
          permission: LocationPermissionState.allowed,
          position: const DeviceCoordinates(
            latitude: 51.5007,
            longitude: -0.1246,
            accuracyMeters: 12,
          ),
        ),
      );

      final result = await service.resolve(fallback);

      expect(result.latitude, 51.5007);
      expect(result.longitude, -0.1246);
      expect(result.source, LocationSource.gps);
      expect(result.usedFallback, isFalse);
    },
  );

  test('resolve falls back to settings when permission is denied', () async {
    final service = LocationService(
      gateway: _FakeLocationGateway(
        permission: LocationPermissionState.deniedForever,
      ),
    );

    final result = await service.resolve(fallback);

    expect(result.latitude, fallback.latitude);
    expect(result.longitude, fallback.longitude);
    expect(result.source, LocationSource.manual);
    expect(result.usedFallback, isTrue);
    expect(result.message, contains('permission'));
  });

  test(
    'resolve falls back to settings when location service is disabled',
    () async {
      final service = LocationService(
        gateway: _FakeLocationGateway(serviceEnabled: false),
      );

      final result = await service.resolve(fallback);

      expect(result.source, LocationSource.manual);
      expect(result.message, contains('disabled'));
    },
  );
}

class _FakeLocationGateway implements LocationGateway {
  _FakeLocationGateway({
    this.serviceEnabled = true,
    this.permission = LocationPermissionState.allowed,
    this.position = const DeviceCoordinates(
      latitude: 51.501,
      longitude: -0.141,
      accuracyMeters: 20,
    ),
  });

  final bool serviceEnabled;
  final LocationPermissionState permission;
  final DeviceCoordinates position;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermissionState> checkPermission() async => permission;

  @override
  Future<LocationPermissionState> requestPermission() async => permission;

  @override
  Future<DeviceCoordinates> getCurrentPosition() async => position;
}
