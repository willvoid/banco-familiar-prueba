import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/session.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  Session? _session;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Session? get session => _session;

  Future<void> login(String document, String password) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _session = null;
    notifyListeners();

    final result = await _authRepository.login(
      document: document,
      password: password,
    );

    switch (result) {
      case Ok(:final value):
        _session = value;
      case Err(:final failure):
        _errorMessage = failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
