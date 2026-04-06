import 'api.dart';
import 'endpoints.dart';

class ReportService {
  final ApiService apiService = ApiService();

  // fetch report
  Future<Map<String, dynamic>> fetchReport(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.report, data);
    return apiService.handleResponse(response);
  }
}

final ReportService reportService = ReportService();
