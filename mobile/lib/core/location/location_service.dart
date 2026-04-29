import 'package:geolocator/geolocator.dart' as geo;

import '../config/app_settings.dart';

enum LocationPermissionState {
  allowed,
  denied,
  deniedForever,
  unableToDetermine,
}

enum LocationSource { gps, manual }

class DeviceCoordinates {
  const DeviceCoordinates({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}

class ResolvedLocation {
  const ResolvedLocation({
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.message,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final LocationSource source;
  final String message;
  final double? accuracyMeters;

  bool get usedFallback => source == LocationSource.manual;

  AppSettings applyTo(AppSettings settings) {
    return settings.copyWith(latitude: latitude, longitude: longitude);
  }
}

abstract class LocationGateway {
  Future<bool> isLocationServiceEnabled();

  Future<LocationPermissionState> checkPermission();

  Future<LocationPermissionState> requestPermission();

  Future<DeviceCoordinates> getCurrentPosition();
}

class GeolocatorLocationGateway implements LocationGateway {
  const GeolocatorLocationGateway();

  @override
  Future<bool> isLocationServiceEnabled() {
    return geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionState> checkPermission() async {
    return _mapPermission(await geo.Geolocator.checkPermission());
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    return _mapPermission(await geo.Geolocator.requestPermission());
  }

  @override
  Future<DeviceCoordinates> getCurrentPosition() async {
    final position = await geo.Geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        timeLimit: Duration(seconds: 6),
      ),
    );
    return DeviceCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }

  LocationPermissionState _mapPermission(geo.LocationPermission permission) {
    switch (permission) {
      case geo.LocationPermission.always:
      case geo.LocationPermission.whileInUse:
        return LocationPermissionState.allowed;
      case geo.LocationPermission.denied:
        return LocationPermissionState.denied;
      case geo.LocationPermission.deniedForever:
        return LocationPermissionState.deniedForever;
      case geo.LocationPermission.unableToDetermine:
        return LocationPermissionState.unableToDetermine;
    }
  }
}

class LocationService {
  const LocationService({this.gateway = const GeolocatorLocationGateway()});

  final LocationGateway gateway;

  Future<ResolvedLocation> resolve(AppSettings fallback) async {
    try {
      final enabled = await gateway.isLocationServiceEnabled();
      if (!enabled) {
        return _fallback(
          fallback,
          'Location service is disabled; using saved demo coordinates.',
        );
      }

      var permission = await gateway.checkPermission();
      if (permission == LocationPermissionState.denied ||
          permission == LocationPermissionState.unableToDetermine) {
        permission = await gateway.requestPermission();
      }

      if (permission != LocationPermissionState.allowed) {
        return _fallback(
          fallback,
          'Location permission is not available; using saved demo coordinates.',
        );
      }

      final position = await gateway.getCurrentPosition();
      return ResolvedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracyMeters,
        source: LocationSource.gps,
        message: position.accuracyMeters == null
            ? 'Using device GPS location.'
            : 'Using device GPS location, +/- ${position.accuracyMeters!.round()} m.',
      );
    } catch (error) {
      return _fallback(
        fallback,
        'Location lookup failed; using saved demo coordinates. $error',
      );
    }
  }

  ResolvedLocation _fallback(AppSettings settings, String message) {
    return ResolvedLocation(
      latitude: settings.latitude,
      longitude: settings.longitude,
      source: LocationSource.manual,
      message: message,
    );
  }
}
