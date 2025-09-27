import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:emovie/domain/exceptions/offline_exception.dart';
import 'package:http/http.dart' as http;

mixin HttpService {
  Future<Map<String, dynamic>> getJson(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    http.Response response;
    try {
      response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const OfflineException();
    } on TimeoutException {
      throw const OfflineException('Tiempo de espera agotado (offline o red lenta)');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception('Expected JSON object, got ${data.runtimeType}');
        }
      } catch (e) {
        throw Exception('Invalid JSON: $e');
      }
    } else {
      throw Exception(
        'GET request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }
}
