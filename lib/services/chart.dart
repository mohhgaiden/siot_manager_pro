import 'package:flutter/material.dart';

import 'api.dart';
import 'endpoints.dart';

class ChartService {
  final ApiService apiService = ApiService();

  // fetch Chart Data
  Future<Map<String, dynamic>> chartTags(
    Map<String, dynamic> data, {
    int type = 0,
  }) async {
    String endpoint = Endpoints.chartTag1;
    if (type == 1) endpoint = Endpoints.chartTag2;
    final response = await apiService.post(endpoint, data);
    debugPrint(response.body, wrapWidth: 1024);
    return apiService.handleResponse(response);
  }

  // fetch All Room
  Future<Map<String, dynamic>> chartAll(
    Map<String, dynamic> data, {
    int type = 0,
  }) async {
    String endpoint = Endpoints.chartAll1;
    if (type == 1) endpoint = Endpoints.chartAll2;
    final response = await apiService.post(endpoint, data);
    debugPrint(response.body, wrapWidth: 1024);
    return apiService.handleResponse(response);
  }
}

final ChartService chartService = ChartService();
