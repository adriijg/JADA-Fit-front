import '../config/api_config.dart';

class ApiEndpoints {
  static String get users => '${ApiConfig.baseUrl}/users';

  static String get login => '$users/login';
  static String get register => '$users/register';
  static String get logout => '$users/logout';
  static String get me => '$users/me';
  static String get forgotPassword => '$users/forgot-password';
  static String get resetPassword => '$users/reset-password';

  static String get mePrivacy => '$me/privacy';
  static String get meProfile => '$me/profile';

  static String get onboarding => '${ApiConfig.baseUrl}/onboarding';
  static String get completeOnboarding => '$onboarding/complete';

  static String get fitnessProfile => '${ApiConfig.baseUrl}/fitness-profile';
  static String get myFitnessProfile => '$fitnessProfile/me';

  static String get fitnessProgress => '${ApiConfig.baseUrl}/fitness-progress';
  static String get myFitnessProgress => '$fitnessProgress/me';

  static String get foods => '${ApiConfig.baseUrl}/foods';
  static String get foodsSearch => '$foods/search';
  static String get foodsBarcode => '$foods/barcode';
  static String get foodsCustom => '$foods/custom';
  static String get myCustomFoods => '$foods/my-custom';

  static String get nutrition => '${ApiConfig.baseUrl}/nutrition';
  static String get nutritionMeals => '$nutrition/meals';
  static String get nutritionMealsFromRecipe => '$nutritionMeals/from-recipe';
  static String get nutritionMealsRecent => '$nutritionMeals/recent';
  static String get nutritionDay => '$nutrition/day';
  static String get nutritionGoals => '$nutrition/goals';
  static String get nutritionGoalsRecalculate => '$nutritionGoals/me/recalculate';

  static String get water => '$nutrition/water';
  static String get waterToday => '$water/today';

  static String get social => '${ApiConfig.baseUrl}/social';
  static String get follow => '$social/follow';
  static String get unfollow => '$social/unfollow';

  static String get challenges => '${ApiConfig.baseUrl}/challenges';
  static String get myChallenges => '$challenges/my';
  static String get exerciseRecords => '$challenges/records';
  static String get myExerciseRecords => '$exerciseRecords/my';

  // Posts
  static String get posts => '$social/posts';
  static String get postsFeed => '$posts/feed';
  static String get postsExplore => '$posts/explore';

  static String postsByUser(String userId) => '$posts/user/$userId';
  static String postLike(String postId) => '$posts/$postId/like';
  static String postDelete(String postId) => '$posts/$postId';
  static String postComments(String postId) => '$posts/$postId/comments';

  // Stories
  static String get stories => '$social/stories';
  static String get storiesFeed => '$stories/feed';
  static String storyDelete(String storyId) => '$stories/$storyId';

  static String get routines => '${ApiConfig.baseUrl}/routines';

  static String routineById(int id) => '$routines/$id';

  static String get recipes => '${ApiConfig.baseUrl}/recipes';

  static String recipeById(String id) => '$recipes/$id';

  static String get ai => '${ApiConfig.baseUrl}/ai';
  static String get aiChat => '$ai/chat';

  static String foodByBarcode(String barcode) {
    return '$foods/barcode/$barcode';
  }

  static String customFoodById(String foodId) => '$foodsCustom/$foodId';

  // Catalog Exercises
  static String get catalogExercises => '${ApiConfig.baseUrl}/catalog/exercises';

  // Upload
  static String get uploadImage => '${ApiConfig.baseUrl}/upload/image';
}
