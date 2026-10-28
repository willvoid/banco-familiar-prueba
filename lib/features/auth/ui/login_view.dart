import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../data/repositories/auth_repository.dart';
import 'login_view_model.dart';
import 'me_view.dart';
import 'me_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginViewModel>().login(
          _documentController.text.trim(),
          _passwordController.text,
        );
  }

  void _openMe() {
    final repository = context.read<AuthRepository>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MeViewModel(authRepository: repository)..load(),
          child: const MeView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final session = viewModel.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Bank Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _documentController,
                    decoration:
                        const InputDecoration(labelText: 'Document number'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Enter your document number'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: viewModel.isLoading ? null : _submit,
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (session != null) ...[
                    Text(
                      'Signed in. Token received'
                      '${session.expiresIn == null ? '' : ', expires in ${session.expiresIn!.inMinutes} min'}.',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _openMe,
                      child: const Text('View my accounts'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Endpoint: ${AppConfig.apiBaseUrl}${AppConfig.loginPath}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
