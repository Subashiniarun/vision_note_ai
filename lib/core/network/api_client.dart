import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';

class ApiClient {
  final http.Client _client;

  ApiClient(this._client);

  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 429) {
        throw AIException('Rate limited. Please wait and retry.');
      } else if (response.statusCode >= 500) {
        throw AIException('Server error. Please try again later.');
      } else {
        throw AIException('Request failed: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    }
  }

  void dispose() {
    _client.close();
  }
}
