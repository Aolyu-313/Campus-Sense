class UserProfile {
  const UserProfile({
    required this.deviceId,
    required this.preferredLanguage,
    required this.createdAt,
  });

  final String deviceId;
  final String preferredLanguage;
  final DateTime? createdAt;

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      deviceId: json['deviceId']?.toString() ?? '',
      preferredLanguage: json['preferredLanguage']?.toString() ?? 'en',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
