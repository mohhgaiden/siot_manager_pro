import 'api.dart';
import 'endpoints.dart';

class ChartService {
  final ApiService apiService = ApiService();

  // fetch Chart Data
  Future<Map<String, dynamic>> chartTags(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.chartTag, data);
    return apiService.handleResponse(response);
  }

  // fetch All Room
  Future<Map<String, dynamic>> chartAll(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.chartAll, data);
    return apiService.handleResponse(response);
  }
}

final ChartService chartService = ChartService();
