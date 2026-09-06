import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

/// Remote data source for authentication. Talks HTTP only.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<AuthResponseModel> login(String identifier, String password) async {
    final data = await apiClient.post(
      ApiEndpoints.customerLogin,
      data: {'identifier': identifier, 'password': password},
    );

    return AuthResponseModel.fromJson(
      (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final data = await apiClient.post(
      ApiEndpoints.customerRegister,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );

    return AuthResponseModel.fromJson(
      (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.customerLogout);
    } catch (_) {
      // Local logout proceeds even if the remote call fails.
    }
  }
}
