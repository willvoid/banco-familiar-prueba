import 'package:banco_simulacro/features/auth/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the GET /auth/me response', () {
    final profile = UserProfile.fromJson({
      'nombre': 'Ana Pérez',
      'documento': '1000001',
      'cuentas': [
        {
          'numero_cuenta': '1001',
          'estado': 'ACTIVA',
          'saldo': 5000000,
          'saldo_disponible': 4500000,
        },
        {
          'numero_cuenta': '1004',
          'estado': 'BLOQUEADA',
          'saldo': '2000000.50',
          'saldo_disponible': 0,
        },
      ],
    });

    expect(profile.name, 'Ana Pérez');
    expect(profile.accounts, hasLength(2));
    expect(profile.accounts[0].isActive, isTrue);
    expect(profile.accounts[0].availableBalance, 4500000);
    expect(profile.accounts[1].isActive, isFalse);
    expect(profile.accounts[1].balance, 2000000.5);
  });

  test('treats a missing "cuentas" as no accounts', () {
    final profile = UserProfile.fromJson({'nombre': 'Ana', 'documento': '1'});

    expect(profile.accounts, isEmpty);
  });

  test('throws FormatException when a required field is missing', () {
    expect(
      () => UserProfile.fromJson({'documento': '1'}),
      throwsFormatException,
    );
  });
}
