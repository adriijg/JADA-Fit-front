import '../config/api_config.dart';

class ApiEndpoints {
  static const String users = '${ApiConfig.baseUrl}/users';

  static const String login = '$users/login';
  static const String register = '$users/register';
  static const String me = '$users/me';
  static const String forgotPassword = '$users/forgot-password';
  static const String resetPassword = '$users/reset-password';

  static const String mePrivacy = '$me/privacy';
  static const String meProfile = '$me/profile';

  static const String onboarding = '${ApiConfig.baseUrl}/onboarding';
  static const String completeOnboarding = '$onboarding/complete';

  static const String fitnessProfile = '${ApiConfig.baseUrl}/fitness-profile';
  static const String myFitnessProfile = '$fitnessProfile/me';

  static const String fitnessProgress = '${ApiConfig.baseUrl}/fitness-progress';
  static const String myFitnessProgress = '$fitnessProgress/me';

  static const String foods = '${ApiConfig.baseUrl}/foods';
  static const String foodsSearch = '$foods/search';
  static const String foodsBarcode = '$foods/barcode';
  static const String foodsCustom = '$foods/custom';
  static const String myCustomFoods = '$foods/my-custom';

  static const String nutrition = '${ApiConfig.baseUrl}/nutrition';
  static const String nutritionMeals = '$nutrition/meals';
  static const String nutritionMealsFromRecipe = '$nutritionMeals/from-recipe';
  static const String nutritionMealsRecent = '$nutritionMeals/recent';
  static const String nutritionDay = '$nutrition/day';
  static const String nutritionGoals = '$nutrition/goals';
  static const String nutritionGoalsRecalculate = '$nutritionGoals/me/recalculate';

  static const String water = '$nutrition/water';
  static const String waterToday = '$water/today';

  static const String social = '${ApiConfig.baseUrl}/social';
  static const String follow = '$social/follow';
  static const String unfollow = '$social/unfollow';

  static const String challenges = '${ApiConfig.baseUrl}/challenges';
  static const String myChallenges = '$challenges/my';
  static const String exerciseRecords = '$challenges/records';
  static const String myExerciseRecords = '$exerciseRecords/my';

  // Posts
  static const String posts = '$social/posts';
  static const String postsFeed = '$posts/feed';
  static const String postsExplore = '$posts/explore';

  static String postsByUser(String userId) => '$posts/user/$userId';
  static String postLike(String postId) => '$posts/$postId/like';
  static String postComments(String postId) => '$posts/$postId/comments';

  // Stories
  static const String stories = '$social/stories';
  static const String storiesFeed = '$stories/feed';

  static const String routines = '${ApiConfig.baseUrl}/routines';

  static String routineById(int id) => '$routines/$id';

  static const String recipes = '${ApiConfig.baseUrl}/recipes';

  static String recipeById(String id) => '$recipes/$id';

  static const String ai = '${ApiConfig.baseUrl}/ai';
  static const String aiChat = '$ai/chat';

  static String foodByBarcode(String barcode) {
    return '$foods/barcode/$barcode';
  }

  static String customFoodById(String foodId) => '$foodsCustom/$foodId';

  // Catalog Exercises
  static const String catalogExercises = '${ApiConfig.baseUrl}/catalog/exercises';

  // Upload
  static const String uploadImage = '${ApiConfig.baseUrl}/upload/image';
}
