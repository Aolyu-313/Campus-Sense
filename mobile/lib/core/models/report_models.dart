class CampusReport {
  const CampusReport({
    required this.id,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.scene,
    required this.movementState,
    required this.tags,
    required this.note,
    required this.comfortScore,
    required this.createdAt,
    this.distanceMeters,
  });

  final int id;
  final String deviceId;
  final double latitude;
  final double longitude;
  final String scene;
  final String movementState;
  final List<String> tags;
  final String note;
  final int comfortScore;
  final DateTime? createdAt;
  final double? distanceMeters;

  String get tagLine => tags.isEmpty ? 'No tags' : tags.join(', ');

  factory CampusReport.fromJson(Map<String, Object?> json) {
    return CampusReport(
      id: _int(json['id']),
      deviceId: _text(json['deviceId'], 'unknown-device'),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      scene: _text(json['scene'], 'GENERAL'),
      movementState: _text(json['movementState'], 'UNKNOWN'),
      tags: _stringList(json['tags']),
      note: _text(json['note'], ''),
      comfortScore: _int(json['comfortScore']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      distanceMeters: json.containsKey('distanceMeters')
          ? _double(json['distanceMeters'])
          : null,
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  final text = value?.toString() ?? '';
  if (text.trim().isEmpty) {
    return const [];
  }
  return text.split(',').map((item) => item.trim()).toList();
}

String _text(Object? value, String fallback) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

double _double(Object? value, [double fallback = 0]) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int _int(Object? value, [int fallback = 0]) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
