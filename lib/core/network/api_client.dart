import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Raised when the request could not reach the server or timed out.
class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ApiResponse {
  const ApiResponse({required this.statusCode, this.body});

  final int statusCode;

  /// Decoded JSON when possible, the raw string otherwise, null when empty.
  final Object? body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Thin JSON-over-HTTP wrapper. Knows nothing about the bank domain.
class ApiClient {
  ApiClient({required http.Client client, required String baseUrl})
      : _client = client,
        _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<ApiResponse> postJson(
    String path,
    Map<String, Object?> body, {
    Map<String, String> headers = const {},
  }) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...headers,
        },
        body: jsonEncode(body),
      ),
    );
  }

  Future<ApiResponse> getJson(
    String path, {
    Map<String, String> headers = const {},
  }) {
    return _send(
      () => _client.get(
        _uri(path),
        headers: {'Accept': 'application/json', ...headers},
      ),
    );
  }

  void close() => _client.close();

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<ApiResponse> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(AppConfig.requestTimeout);
      return ApiResponse(
        statusCode: response.statusCode,
        body: _decode(response.body),
      );
    } on TimeoutException {
      throw const NetworkException('The request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Object? _decode(String raw) {
    if (raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return raw;
    }
  }
}
