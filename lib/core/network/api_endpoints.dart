import '../config/api_config.dart';

class ApiEndpoints {
  static const String users = '${ApiConfig.baseUrl}/users';

  static const String login = '$users/login';
  static const String register = '$users/register';
  static const String me = '$users/me';

  static const String mePrivacy = '$me/privacy';

  static const String onboarding = '${ApiConfig.baseUrl}/onboarding';
  static const String completeOnboarding = '$onboarding/complete';

  static const String fitnessProfile = '${ApiConfig.baseUrl}/fitness-profile';
  static const String myFitnessProfile = '$fitnessProfile/me';

  static const String fitnessProgress = '${ApiConfig.baseUrl}/fitness-progress';
  static const String myFitnessProgress = '$fitnessProgress/me';

  static const String foods = '${ApiConfig.baseUrl}/foods';
  static const String foodsSearch = '$foods/search';
  static const String foodsBarcode = '$foods/barcode';

  static const String nutrition = '${ApiConfig.baseUrl}/nutrition';
  static const String nutritionMeals = '$nutrition/meals';
  static const String nutritionDay = '$nutrition/day';

  static const String social = '${ApiConfig.baseUrl}/social';
  static const String follow = '$social/follow';
  static const String unfollow = '$social/unfollow';

  static const String routines = '${ApiConfig.baseUrl}/routines';

  static String routineById(int id) => '$routines/$id';

  static String foodByBarcode(String barcode) {
    return '$foods/barcode/$barcode';
  }
}