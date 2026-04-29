enum ApiFailureKind { network, badRequest, server, parse }

class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  final ApiFailureKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' ($statusCode)';
    return '$message$status';
  }
}
