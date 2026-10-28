import '../../../../core/network/api_client.dart';
import '../../../../core/result/result.dart';
import '../../domain/session.dart';
import '../../domain/user_profile.dart';
import '../services/auth_api_service.dart';

abstract interface class AuthRepository {
  Future<Result<Session>> login({
    required String document,
    required String password,
  });

  /// Calls the authenticated profile endpoint with the current session.
  Future<Result<UserProfile>> fetchMe();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._service);

  final AuthApiService _service;

  /// In-memory only: the token is lost when the app restarts.
  Session? _session;

  // Server errors look like {"error": "CODE", "mensaje": "human text"}.
  static const _messageKeys = ['mensaje', 'message', 'detail'];

  @override
  Future<Result<Session>> login({
    required String document,
    required String password,
  }) async {
    try {
      final response = await _service.login(
        document: document,
        password: password,
      );

      if (!response.isSuccess) {
        return Err(_failureFrom(response, fallback: 'Login failed'));
      }

      final session = _parseSession(response.body);
      if (session == null) {
        return Err(
          Failure(
            'Login succeeded but the response has no access_token',
            statusCode: response.statusCode,
          ),
        );
      }
      _session = session;
      return Ok(session);
    } on NetworkException catch (e) {
      return Err(Failure(e.message));
    }
  }

  @override
  Future<Result<UserProfile>> fetchMe() async {
    final session = _session;
    if (session == null) return const Err(Failure('You are not signed in'));

    try {
      final response = await _service.me(accessToken: session.accessToken);

      if (!response.isSuccess) {
        return Err(_failureFrom(response, fallback: 'Request failed'));
      }

      final body = response.body;
      if (body is! Map) {
        return Err(
          Failure(
            'Unexpected response: expected a JSON object',
            statusCode: response.statusCode,
          ),
        );
      }
      try {
        return Ok(UserProfile.fromJson(Map<String, Object?>.from(body)));
      } on FormatException catch (e) {
        return Err(
          Failure(
            'Unexpected response: ${e.message}',
            statusCode: response.statusCode,
          ),
        );
      }
    } on NetworkException catch (e) {
      return Err(Failure(e.message));
    }
  }

  Session? _parseSession(Object? body) {
    if (body is! Map) return null;
    final token = body['access_token'];
    if (token is! String || token.isEmpty) return null;

    final tokenType = body['token_type'];
    final expiresIn = body['expires_in'];
    return Session(
      accessToken: token,
      tokenType: tokenType is String ? tokenType : 'bearer',
      expiresIn: expiresIn is num ? Duration(seconds: expiresIn.toInt()) : null,
    );
  }

  Failure _failureFrom(ApiResponse response, {required String fallback}) {
    final body = response.body;
    if (body is Map) {
      for (final key in _messageKeys) {
        final value = body[key];
        if (value is String && value.isNotEmpty) {
          return Failure(value, statusCode: response.statusCode);
        }
      }
    }
    return Failure(
      '$fallback (HTTP ${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
