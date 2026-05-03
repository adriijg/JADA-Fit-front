import '../config/api_config.dart';

class ApiEndpoints {
  static const String users = '${ApiConfig.baseUrl}/users';

  static const String login = '$users/login';
  static const String register = '$users/register';
  static const String me = '$users/me';

  static const String onboarding = '${ApiConfig.baseUrl}/onboarding';
  static const String completeOnboarding = '$onboarding/complete';

  static const String fitnessProfile = '${ApiConfig.baseUrl}/fitness-profile';
  static const String myFitnessProfile = '$fitnessProfile/me';

  static const String fitnessProgress = '${ApiConfig.baseUrl}/fitness-progress';
  static const String myFitnessProgress = '$fitnessProgress/me';

  static const String foods = '${ApiConfig.baseUrl}/foods';

  static String foodByBarcode(String barcode) {
    return '$foods/barcode/$barcode';
  }
}