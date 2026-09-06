import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSourceImpl {
  AuthRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  Future<AuthResponseModel> login(String phone, String password) async {
    final data = await apiClient.post(
      ApiEndpoints.driverLogin,
      data: {'phone': phone, 'password': password, 'guard': 'driver'},
    );
    return AuthResponseModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.driverLogout);
    } catch (_) {
      // Local logout proceeds even if the remote call fails.
    }
  }
}
