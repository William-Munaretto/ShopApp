class HttpsException implements Exception {
  final String msg;
  final int statusCode;

  HttpsException({
    required this.msg,
    required this.statusCode,
  });

  @override
  String toString() {
    return msg;
  }
}
