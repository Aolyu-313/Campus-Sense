import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_settings.dart';
import '../models/environment_models.dart';
import '../models/history_models.dart';
import '../models/profile_models.dart';
import '../models/report_models.dart';
import 'api_exception.dart';

class CampusSenseApiClient {
  CampusSenseApiClient({required String baseUrl, http.Client? httpClient})
    : _baseUrl = _normalizeBaseUrl(baseUrl),
      _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  void close() => _httpClient.close();

  Future<Map<String, Object?>> health() async {
    return _getJson('/api/health');
  }

  Future<EnvironmentCurrent> fetchCurrentEnvironment(
    AppSettings settings, {
    String movementState = 'UNKNOWN',
  }) async {
    final json = await _getJson(
      '/api/environment/current',
      query: {
        'lat': settings.latitude.toString(),
        'lon': settings.longitude.toString(),
        'movementState': movementState,
      },
    );
    return EnvironmentCurrent.fromJson(json);
  }

  Future<CampusReport> submitReport({
    required AppSettings settings,
    required String scene,
    required List<String> tags,
    required String note,
    String movementState = 'UNKNOWN',
  }) async {
    final json = await _sendJson(
      'POST',
      '/api/reports',
      body: {
        'deviceId': settings.deviceId,
        'latitude': settings.latitude,
        'longitude': settings.longitude,
        'scene': scene,
        'tags': tags,
        'note': note,
        'movementState': movementState,
      },
    );
    return CampusReport.fromJson(json);
  }

  Future<List<CampusReport>> fetchNearbyReports(
    AppSettings settings, {
    double radiusMeters = 500,
  }) async {
    final json = await _getJsonList(
      '/api/reports/nearby',
      query: {
        'lat': settings.latitude.toString(),
        'lon': settings.longitude.toString(),
        'radius': radiusMeters.toString(),
      },
    );
    return json.map(CampusReport.fromJson).toList();
  }

  Future<List<HistoryRecord>> fetchHistory(String deviceId) async {
    final json = await _getJsonList(
      '/api/history',
      query: {'deviceId': deviceId},
    );
    return json.map(HistoryRecord.fromJson).toList();
  }

  Future<HistoryTrend> fetchTrends(String deviceId, {int limit = 10}) async {
    final json = await _getJson(
      '/api/history/trends',
      query: {'deviceId': deviceId, 'limit': limit.toString()},
    );
    return HistoryTrend.fromJson(json);
  }

  Future<UserProfile> fetchProfile(String deviceId) async {
    final json = await _getJson('/api/profile', query: {'deviceId': deviceId});
    return UserProfile.fromJson(json);
  }

  Future<UserProfile> updateProfile({
    required String deviceId,
    required String preferredLanguage,
  }) async {
    final json = await _sendJson(
      'PUT',
      '/api/profile',
      body: {'deviceId': deviceId, 'preferredLanguage': preferredLanguage},
    );
    return UserProfile.fromJson(json);
  }

  Future<Map<String, Object?>> _getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _request(() {
      return _httpClient
          .get(_uri(path, query))
          .timeout(const Duration(seconds: 8));
    });
    return _decodeMap(response);
  }

  Future<List<Map<String, Object?>>> _getJsonList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _request(() {
      return _httpClient
          .get(_uri(path, query))
          .timeout(const Duration(seconds: 8));
    });
    return _decodeList(response);
  }

  Future<Map<String, Object?>> _sendJson(
    String method,
    String path, {
    required Map<String, Object?> body,
  }) async {
    final response = await _request(() {
      final uri = _uri(path);
      final encoded = jsonEncode(body);
      final headers = {'Content-Type': 'application/json'};
      if (method == 'POST') {
        return _httpClient
            .post(uri, headers: headers, body: encoded)
            .timeout(const Duration(seconds: 8));
      }
      return _httpClient
          .put(uri, headers: headers, body: encoded)
          .timeout(const Duration(seconds: 8));
    });
    return _decodeMap(response);
  }

  Future<http.Response> _request(Future<http.Response> Function() send) async {
    try {
      return await send();
    } on SocketException catch (error) {
      throw ApiException(
        kind: ApiFailureKind.network,
        message: 'Cannot reach backend: ${error.message}',
      );
    } on TimeoutException {
      throw const ApiException(
        kind: ApiFailureKind.network,
        message: 'Backend request timed out.',
      );
    } on http.ClientException catch (error) {
      throw ApiException(kind: ApiFailureKind.network, message: error.message);
    }
  }

  Map<String, Object?> _decodeMap(http.Response response) {
    final decoded = _decodeResponse(response);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const ApiException(
      kind: ApiFailureKind.parse,
      message: 'Backend returned an unexpected JSON object.',
    );
  }

  List<Map<String, Object?>> _decodeList(http.Response response) {
    final decoded = _decodeResponse(response);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => item.cast<String, Object?>())
          .toList();
    }
    throw const ApiException(
      kind: ApiFailureKind.parse,
      message: 'Backend returned an unexpected JSON list.',
    );
  }

  Object? _decodeResponse(http.Response response) {
    final statusCode = response.statusCode;
    Object? decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, Object?>{}
          : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        kind: ApiFailureKind.parse,
        statusCode: statusCode,
        message: 'Backend returned invalid JSON.',
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (decoded is Map) {
        return decoded.cast<String, Object?>();
      }
      return decoded;
    }

    final message = decoded is Map
        ? decoded['message']?.toString() ?? 'Backend request failed.'
        : 'Backend request failed.';

    if (statusCode >= 400 && statusCode < 500) {
      throw ApiException(
        kind: ApiFailureKind.badRequest,
        statusCode: statusCode,
        message: message,
      );
    }

    throw ApiException(
      kind: ApiFailureKind.server,
      statusCode: statusCode,
      message: message,
    );
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  static String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
