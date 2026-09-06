import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/vendor_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<AuthResponseModel> login(String identifier, String password) async {
    final data = await apiClient.post(
      ApiEndpoints.vendorLogin,
      data: {'identifier': identifier, 'password': password, 'guard': 'vendor'},
    );
    return AuthResponseModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<VendorUserModel> profile() async {
    final data = await apiClient.get(ApiEndpoints.vendorProfile);
    return VendorUserModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.vendorLogout);
    } catch (_) {
      // Local logout proceeds even if the remote call fails.
    }
  }
}
