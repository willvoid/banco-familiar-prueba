import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';

/// Talks to the authentication endpoints. Returns raw responses.
class AuthApiService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> login({
    required String document,
    required String password,
  }) {
    return _apiClient.postJson(
      AppConfig.loginPath,
      {'documento': document, 'password': password},
    );
  }

  Future<ApiResponse> me({required String accessToken}) {
    return _apiClient.getJson(
      AppConfig.mePath,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
