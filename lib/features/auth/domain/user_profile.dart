/// The authenticated user's profile, as returned by `GET /auth/me`.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.document,
    required this.accounts,
  });

  final String name;
  final String document;
  final List<BankAccount> accounts;

  /// Throws [FormatException] when a required field is missing or invalid.
  factory UserProfile.fromJson(Map<String, Object?> json) {
    final accounts = json['cuentas'];
    return UserProfile(
      name: _string(json, 'nombre'),
      document: _string(json, 'documento'),
      accounts: accounts is List
          ? [for (final account in accounts) BankAccount.fromJson(_map(account))]
          : const [],
    );
  }
}

class BankAccount {
  const BankAccount({
    required this.number,
    required this.status,
    required this.balance,
    required this.availableBalance,
  });

  final String number;

  /// Server value, e.g. `ACTIVA` or `BLOQUEADA`.
  final String status;
  final num balance;
  final num availableBalance;

  bool get isActive => status == 'ACTIVA';

  factory BankAccount.fromJson(Map<String, Object?> json) {
    return BankAccount(
      number: _string(json, 'numero_cuenta'),
      status: _string(json, 'estado'),
      balance: _number(json, 'saldo'),
      availableBalance: _number(json, 'saldo_disponible'),
    );
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is Map) return Map<String, Object?>.from(value);
  throw const FormatException('Expected an object in "cuentas"');
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) return value;
  if (value is num) return value.toString();
  throw FormatException('Missing or invalid "$key"');
}

num _number(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Missing or invalid "$key"');
}
