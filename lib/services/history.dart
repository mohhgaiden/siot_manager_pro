import 'api.dart';
import 'endpoints.dart';

class HistoryService {
  final ApiService apiService = ApiService();

  // fetch All Tags
  Future<Map<String, dynamic>> fetchTags(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.listTags, data);
    return apiService.handleResponse(response);
  }

  // fetch All Tags
  Future<Map<String, dynamic>> fetchHistory(
    Map<String, dynamic> data, {
    int type = 0,
    int? page = 1,
  }) async {
    String endpoint = Endpoints.historyDate;
    switch (type) {
      case 0:
        endpoint = Endpoints.historyDate;
      case 1:
        endpoint = Endpoints.historyWeek;
      case 2:
        endpoint = Endpoints.historyRange;
    }
    final response = await apiService.post('$endpoint?page=$page', data);
    return apiService.handleResponse(response);
  }
}

final HistoryService historyService = HistoryService();
