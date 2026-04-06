import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      "https://admin.sirius-iot.eu/Mobile/API/SiotManager2026";
  // --- JSON Requests ---
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) {
    return _sendRequest('POST', endpoint, body: body);
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _sendRequest('GET', endpoint, body: queryParameters);
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) {
    return _sendRequest('PATCH', endpoint, body: body);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) {
    return _sendRequest('PUT', endpoint, body: body);
  }

  Future<http.Response> delete(String endpoint, {Map<String, dynamic>? body}) {
    return _sendRequest('DELETE', endpoint, body: body);
  }

  // --- Internal JSON Request with auto-refresh ---
  Future<http.Response> _sendRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    // ✅ Convert to Map<String, String> for form encoding
    final formBody = body?.map((k, v) => MapEntry(k, v.toString()));

    try {
      switch (method) {
        case 'POST':
          return await http.post(
            url,
            body: formBody, // ✅ No jsonEncode — sends as form data
          );
        case 'GET':
          final uri =
              body != null
                  ? Uri.parse(
                    '$baseUrl$endpoint',
                  ).replace(queryParameters: formBody)
                  : url;
          return await http.get(uri);
        case 'PATCH':
          return await http.patch(url, body: formBody);
        case 'PUT':
          return await http.put(url, body: formBody);
        case 'DELETE':
          return await http.delete(url, body: formBody?.toString());
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- Response Handler ---
  Map<String, dynamic> handleResponse(http.Response response) {
    final body = response.body.trim();

    print(response.statusCode);

    // success
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (body.isEmpty) return {};
      return jsonDecode(body);
    }

    // No Content success
    if (response.statusCode == 204) return {};

    // error
    if (body.isEmpty) {
      throw "Server returned empty response (Status: ${response.statusCode})";
    }

    final responseData = jsonDecode(body);
    throw responseData['msg'] ?? "Unknown error";
  }
}
