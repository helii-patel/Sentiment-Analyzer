import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sentiment_result.dart';
import '../utils/constants.dart';

enum ApiErrorType { network, server, unknown }

class ApiException implements Exception {
  final String message;
  final ApiErrorType type;

  ApiException(this.message, this.type);

  @override
  String toString() => message;
}

class ApiService {
  static Future<SentimentResult> analyzeTexts(List<String> texts) async {
    final url = Uri.parse("${AppConstants.baseUrl}/predict");

    http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"texts": texts}),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException("Request timed out. Check your backend.", ApiErrorType.network);
    } catch (e) {
      throw ApiException("Unable to reach backend. Start the API server.", ApiErrorType.network);
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SentimentResult.fromJson(data);
    } else {
      throw ApiException("Server error (${response.statusCode}). Try again.", ApiErrorType.server);
    }
  }
}
