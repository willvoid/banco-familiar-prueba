import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/user_profile.dart';

class MeViewModel extends ChangeNotifier {
  MeViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _profile = null;
    notifyListeners();

    final result = await _authRepository.fetchMe();

    switch (result) {
      case Ok(:final value):
        _profile = value;
      case Err(:final failure):
        _errorMessage = failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
