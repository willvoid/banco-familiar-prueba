import 'package:banco_simulacro/core/result/result.dart';
import 'package:banco_simulacro/features/auth/data/repositories/auth_repository.dart';
import 'package:banco_simulacro/features/auth/domain/session.dart';
import 'package:banco_simulacro/features/auth/domain/user_profile.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.loginResult = const Err(Failure('login not stubbed')),
    this.meResult = const Err(Failure('me not stubbed')),
  });

  final Result<Session> loginResult;
  final Result<UserProfile> meResult;

  @override
  Future<Result<Session>> login({
    required String document,
    required String password,
  }) async =>
      loginResult;

  @override
  Future<Result<UserProfile>> fetchMe() async => meResult;
}

/// Same shape as the real `GET /auth/me` response.
const sampleProfile = UserProfile(
  name: 'Ana Pérez',
  document: '1000001',
  accounts: [
    BankAccount(
      number: '1001',
      status: 'ACTIVA',
      balance: 5000000,
      availableBalance: 5000000,
    ),
    BankAccount(
      number: '1004',
      status: 'BLOQUEADA',
      balance: 2000000,
      availableBalance: 2000000,
    ),
  ],
);
