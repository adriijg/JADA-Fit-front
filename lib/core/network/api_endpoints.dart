import '../config/api_config.dart';

class ApiEndpoints {
  static const String users = '${ApiConfig.baseUrl}/users';

  static const String login = '$users/login';
  static const String register = '$users/register';
  static const String me = '$users/me';
}