import 'dart:convert';

import 'package:banco_simulacro/core/network/api_client.dart';
import 'package:banco_simulacro/core/result/result.dart';
import 'package:banco_simulacro/features/auth/data/repositories/auth_repository.dart';
import 'package:banco_simulacro/features/auth/data/services/auth_api_service.dart';
import 'package:banco_simulacro/features/auth/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

AuthRepository _repositoryWith(MockClient client) => AuthRepositoryImpl(
      AuthApiService(ApiClient(client: client, baseUrl: 'http://bank.test')),
    );

const _profileJson = {
  'nombre': 'Ana Pérez',
  'documento': '1000001',
  'cuentas': [
    {
      'numero_cuenta': '1001',
      'estado': 'ACTIVA',
      'saldo': 5000000,
      'saldo_disponible': 5000000,
    },
  ],
};

void main() {
  test('parses the session and sends documento/password', () async {
    late http.Request captured;
    final repository = _repositoryWith(MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'access_token': 'abc123',
          'token_type': 'bearer',
          'expires_in': 1800,
        }),
        200,
      );
    }));

    final result = await repository.login(document: '1000001', password: 'pw');

    final session = (result as Ok).value;
    expect(session.accessToken, 'abc123');
    expect(session.tokenType, 'bearer');
    expect(session.expiresIn, const Duration(minutes: 30));
    expect(captured.url.toString(), 'http://bank.test/auth/login');
    expect(jsonDecode(captured.body), {'documento': '1000001', 'password': 'pw'});
  });

  test('returns the server "mensaje" on a 401', () async {
    final repository = _repositoryWith(MockClient((_) async {
      return http.Response(
        jsonEncode({
          'error': 'CREDENCIALES_INVALIDAS',
          'mensaje': 'Documento o contraseña incorrectos',
        }),
        401,
      );
    }));

    final result = await repository.login(document: '1000001', password: 'bad');

    final failure = (result as Err).failure;
    expect(failure.message, 'Documento o contraseña incorrectos');
    expect(failure.statusCode, 401);
  });

  test('keeps the status code on a 429 rate limit', () async {
    final repository = _repositoryWith(MockClient((_) async {
      return http.Response(
        jsonEncode({'error': 'DEMASIADOS_INTENTOS', 'mensaje': 'Too many'}),
        429,
      );
    }));

    final result = await repository.login(document: '1000001', password: 'bad');

    expect((result as Err).failure.statusCode, 429);
  });

  test('fails when a 200 response has no access_token', () async {
    final repository = _repositoryWith(
      MockClient((_) async => http.Response('{}', 200)),
    );

    final result = await repository.login(document: '1000001', password: 'pw');

    expect(result, isA<Err>());
  });

  group('fetchMe', () {
    test('fails without calling the server when not signed in', () async {
      var calls = 0;
      final repository = _repositoryWith(MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }));

      final result = await repository.fetchMe();

      expect(result, isA<Err>());
      expect(calls, 0);
    });

    test('fails when the profile has an unexpected shape', () async {
      final repository = _repositoryWith(MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(jsonEncode({'access_token': 't'}), 200);
        }
        return http.Response('{}', 200);
      }));
      await repository.login(document: '1000001', password: 'pw');

      final result = await repository.fetchMe();

      expect((result as Err).failure.message, startsWith('Unexpected response'));
    });

    test('sends the Bearer token obtained at login', () async {
      late http.Request captured;
      final repository = _repositoryWith(MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(
            jsonEncode({'access_token': 'abc123', 'token_type': 'bearer'}),
            200,
          );
        }
        captured = request;
        return http.Response(jsonEncode(_profileJson), 200);
      }));
      await repository.login(document: '1000001', password: 'pw');

      final result = await repository.fetchMe();

      final profile = (result as Ok<UserProfile>).value;
      expect(profile.name, 'Ana Pérez');
      expect(profile.accounts, hasLength(1));
      expect(captured.method, 'GET');
      expect(captured.url.path, '/auth/me');
      expect(captured.headers['Authorization'], 'Bearer abc123');
    });

    test('returns the server "mensaje" when the token is rejected', () async {
      final repository = _repositoryWith(MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(jsonEncode({'access_token': 'old'}), 200);
        }
        return http.Response(
          jsonEncode({'error': 'TOKEN_INVALIDO', 'mensaje': 'Token expirado'}),
          401,
        );
      }));
      await repository.login(document: '1000001', password: 'pw');

      final result = await repository.fetchMe();

      final failure = (result as Err).failure;
      expect(failure.message, 'Token expirado');
      expect(failure.statusCode, 401);
    });
  });

  test('maps connection errors to a failure', () async {
    final repository = _repositoryWith(
      MockClient((_) async => throw http.ClientException('no connection')),
    );

    final result = await repository.login(document: '1000001', password: 'pw');

    expect((result as Err).failure.message, 'no connection');
  });
}
