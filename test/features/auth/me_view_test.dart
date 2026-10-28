import 'package:banco_simulacro/core/result/result.dart';
import 'package:banco_simulacro/features/auth/ui/me_view.dart';
import 'package:banco_simulacro/features/auth/ui/me_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets('shows the user and each account with grouped amounts',
      (tester) async {
    final viewModel = MeViewModel(
      authRepository: FakeAuthRepository(meResult: const Ok(sampleProfile)),
    );
    await viewModel.load();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const MeView(),
        ),
      ),
    );

    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Account 1001'), findsOneWidget);
    expect(find.text('ACTIVA'), findsOneWidget);
    expect(find.text('Account 1004'), findsOneWidget);
    expect(find.text('BLOQUEADA'), findsOneWidget);
    expect(find.textContaining('5.000.000'), findsOneWidget);
  });
}
