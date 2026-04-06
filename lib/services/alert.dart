import 'api.dart';
import 'endpoints.dart';

class AlertService {
  final ApiService apiService = ApiService();

  // fetch All Alerts
  Future<Map<String, dynamic>> fetchAlert(
    Map<String, dynamic> data, {
    int type = 0,
    int? page = 1,
  }) async {
    String endpoint = Endpoints.alertTemp;
    switch (type) {
      case 0:
        endpoint = Endpoints.alertTemp;
      case 1:
        endpoint = Endpoints.alertHum;
    }
    final response = await apiService.post('$endpoint?page=$page', data);
    return apiService.handleResponse(response);
  }
}

final AlertService alertService = AlertService();
