import 'package:banco_simulacro/core/result/result.dart';
import 'package:banco_simulacro/features/auth/domain/session.dart';
import 'package:banco_simulacro/features/auth/ui/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  test('exposes the session after a successful login', () async {
    final viewModel = LoginViewModel(
      authRepository: FakeAuthRepository(
        loginResult: const Ok(Session(accessToken: 't', tokenType: 'bearer')),
      ),
    );
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.login('1000001', 'pw');

    expect(viewModel.session?.accessToken, 't');
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
    expect(notifications, 2); // loading on, loading off
  });

  test('exposes the error message after a failed login', () async {
    final viewModel = LoginViewModel(
      authRepository: FakeAuthRepository(
        loginResult: const Err(Failure('Nope')),
      ),
    );

    await viewModel.login('1000001', 'bad');

    expect(viewModel.session, isNull);
    expect(viewModel.errorMessage, 'Nope');
    expect(viewModel.isLoading, isFalse);
  });
}
