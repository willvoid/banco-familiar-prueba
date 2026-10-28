import 'package:banco_simulacro/core/result/result.dart';
import 'package:banco_simulacro/features/auth/ui/me_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  test('exposes the profile on success', () async {
    final viewModel = MeViewModel(
      authRepository: FakeAuthRepository(meResult: const Ok(sampleProfile)),
    );

    await viewModel.load();

    expect(viewModel.profile?.name, 'Ana Pérez');
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('exposes the error message on failure', () async {
    final viewModel = MeViewModel(
      authRepository: FakeAuthRepository(
        meResult: const Err(Failure('Token expired', statusCode: 401)),
      ),
    );

    await viewModel.load();

    expect(viewModel.profile, isNull);
    expect(viewModel.errorMessage, 'Token expired');
  });
}
