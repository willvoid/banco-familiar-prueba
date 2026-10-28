import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/services/auth_api_service.dart';
import 'features/auth/ui/login_view.dart';
import 'features/auth/ui/login_view_model.dart';

/// Composition root: wires services, repositories and view models.
class BancoApp extends StatelessWidget {
  const BancoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(
            client: http.Client(),
            baseUrl: AppConfig.apiBaseUrl,
          ),
          dispose: (_, apiClient) => apiClient.close(),
        ),
        // Created once: the repository holds the in-memory session.
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            AuthApiService(context.read<ApiClient>()),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Banco Simulacro',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const LoginView(),
        ),
      ),
    );
  }
}
