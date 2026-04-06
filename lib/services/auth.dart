import 'api.dart';
import 'endpoints.dart';

class AuthService {
  final ApiService apiService = ApiService();

  // login
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.login, data);
    return apiService.handleResponse(response);
  }
}

final AuthService authService = AuthService();
