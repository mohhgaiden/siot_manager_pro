import 'api.dart';
import 'endpoints.dart';

class SensorsService {
  final ApiService apiService = ApiService();

  // access
  Future<Map<String, dynamic>> access(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.access, data);
    return apiService.handleResponse(response);
  }

  // fetch rooms
  Future<Map<String, dynamic>> fetchRooms(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.rooms, data);
    return apiService.handleResponse(response);
  }

  // fetch sensors
  Future<Map<String, dynamic>> fetchSensors(Map<String, dynamic> data) async {
    final response = await apiService.post(Endpoints.sensors, data);
    return apiService.handleResponse(response);
  }
}

final SensorsService sensorService = SensorsService();
