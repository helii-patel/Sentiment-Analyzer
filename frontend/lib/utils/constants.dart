import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    const defineUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) {
      return defineUrl;
    }

    return 'http://localhost:8000';
  }
}
