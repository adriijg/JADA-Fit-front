import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'JADA FIT'**
  String get appName;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to JADA FIT'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is the main screen. We will configure more features here soon.'**
  String get homeWelcomeSubtitle;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get navigationNutrition;

  /// No description provided for @navigationAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navigationAi;

  /// No description provided for @navigationRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get navigationRoutines;

  /// No description provided for @navigationSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get navigationSocial;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeScanFood.
  ///
  /// In en, this message translates to:
  /// **'Scan food'**
  String get homeScanFood;

  /// No description provided for @homeLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Log meal'**
  String get homeLogMeal;

  /// No description provided for @homeAddPhysicalData.
  ///
  /// In en, this message translates to:
  /// **'Add physical data'**
  String get homeAddPhysicalData;

  /// No description provided for @homeViewRoutine.
  ///
  /// In en, this message translates to:
  /// **'View routine'**
  String get homeViewRoutine;

  /// No description provided for @homeAskAI.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get homeAskAI;

  /// No description provided for @homeNutritionToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s nutrition'**
  String get homeNutritionToday;

  /// No description provided for @homeCaloriesAndMacrosSummary.
  ///
  /// In en, this message translates to:
  /// **'Calories and macros summary'**
  String get homeCaloriesAndMacrosSummary;

  /// No description provided for @homeConsumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get homeConsumed;

  /// No description provided for @homeGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get homeGoal;

  /// No description provided for @homeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get homeRemaining;

  /// No description provided for @homeProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get homeProtein;

  /// No description provided for @homeCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get homeCarbs;

  /// No description provided for @homeFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get homeFats;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get homeGreeting;

  /// No description provided for @homeMainPanel.
  ///
  /// In en, this message translates to:
  /// **'This is your main panel. We will add more features soon.'**
  String get homeMainPanel;

  /// No description provided for @homeAICoach.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get homeAICoach;

  /// No description provided for @homeAICoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to get a personalized recommendation.'**
  String get homeAICoachSubtitle;

  /// No description provided for @homeConnectWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Connect with other users'**
  String get homeConnectWithOthers;

  /// No description provided for @homeNoRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get homeNoRecentActivity;

  /// No description provided for @homeSocialActivity.
  ///
  /// In en, this message translates to:
  /// **'Social activity'**
  String get homeSocialActivity;

  /// No description provided for @homeWorkoutCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get homeWorkoutCardTitle;

  /// No description provided for @homeNoRoutine.
  ///
  /// In en, this message translates to:
  /// **'No routine'**
  String get homeNoRoutine;

  /// No description provided for @homePendingExercises.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise pending} other{{count} exercises pending}}'**
  String homePendingExercises(int count);

  /// No description provided for @homeNoPendingExercises.
  ///
  /// In en, this message translates to:
  /// **'No pending exercises'**
  String get homeNoPendingExercises;

  /// No description provided for @homeProgressCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeProgressCardTitle;

  /// No description provided for @homeNoProgressData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get homeNoProgressData;

  /// No description provided for @homeAddFirstRecord.
  ///
  /// In en, this message translates to:
  /// **'Add your first record'**
  String get homeAddFirstRecord;

  /// No description provided for @homeWeightChangeSinceStart.
  ///
  /// In en, this message translates to:
  /// **'{weightChange} since start'**
  String homeWeightChangeSinceStart(String weightChange);

  /// No description provided for @homeNutritionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load nutrition summary'**
  String get homeNutritionLoadError;

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionTitle;

  /// No description provided for @nutritionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here you will see personalized meal plans, recipes and macros.'**
  String get nutritionSubtitle;

  /// No description provided for @nutritionCaloriesPer100g.
  ///
  /// In en, this message translates to:
  /// **'Calories /100g'**
  String get nutritionCaloriesPer100g;

  /// No description provided for @nutritionProteinPer100g.
  ///
  /// In en, this message translates to:
  /// **'Protein /100g'**
  String get nutritionProteinPer100g;

  /// No description provided for @nutritionCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutritionCalories;

  /// No description provided for @nutritionProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutritionProtein;

  /// No description provided for @nutritionRecipesEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any recipes yet'**
  String get nutritionRecipesEmpty;

  /// No description provided for @nutritionRecipesSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Try another search term.'**
  String get nutritionRecipesSearchEmpty;

  /// No description provided for @nutritionAddToDay.
  ///
  /// In en, this message translates to:
  /// **'Add to day'**
  String get nutritionAddToDay;

  /// No description provided for @nutritionFoodsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any custom foods yet'**
  String get nutritionFoodsEmpty;

  /// No description provided for @nutritionDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'It will be removed...\nContinue?'**
  String get nutritionDeleteConfirmation;

  /// No description provided for @nutritionAddRecipeError.
  ///
  /// In en, this message translates to:
  /// **'Could not add recipe'**
  String get nutritionAddRecipeError;

  /// No description provided for @nutritionAddToEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Add to...'**
  String get nutritionAddToEllipsis;

  /// No description provided for @nutritionSearchOrScan.
  ///
  /// In en, this message translates to:
  /// **'Search in the catalog or scan barcode'**
  String get nutritionSearchOrScan;

  /// No description provided for @nutritionAddManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get nutritionAddManually;

  /// No description provided for @nutritionAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get nutritionAddIngredient;

  /// No description provided for @nutritionAddAtLeastOneIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient'**
  String get nutritionAddAtLeastOneIngredient;

  /// No description provided for @nutritionCameraError.
  ///
  /// In en, this message translates to:
  /// **'Could not start the camera. Check the permissions or the emulator camera.'**
  String get nutritionCameraError;

  /// No description provided for @nutritionCameraSwitchError.
  ///
  /// In en, this message translates to:
  /// **'Could not switch camera'**
  String get nutritionCameraSwitchError;

  /// No description provided for @nutritionCameraHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the product barcode.'**
  String get nutritionCameraHint;

  /// No description provided for @nutritionCameraStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get nutritionCameraStarting;

  /// No description provided for @nutritionFoodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get nutritionFoodName;

  /// No description provided for @nutritionFoodNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Brown rice'**
  String get nutritionFoodNameHint;

  /// No description provided for @nutritionCarbsPer100g.
  ///
  /// In en, this message translates to:
  /// **'Carbs /100g'**
  String get nutritionCarbsPer100g;

  /// No description provided for @nutritionFatPer100g.
  ///
  /// In en, this message translates to:
  /// **'Fat /100g'**
  String get nutritionFatPer100g;

  /// No description provided for @nutritionCalculatedSummary.
  ///
  /// In en, this message translates to:
  /// **'CALCULATED SUMMARY'**
  String get nutritionCalculatedSummary;

  /// No description provided for @nutritionCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get nutritionCarbs;

  /// No description provided for @nutritionFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutritionFat;

  /// No description provided for @nutritionDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get nutritionDeleteRecipe;

  /// No description provided for @nutritionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get nutritionCancel;

  /// No description provided for @nutritionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get nutritionDelete;

  /// No description provided for @nutritionErrorDeletingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Error deleting recipe'**
  String get nutritionErrorDeletingRecipe;

  /// No description provided for @nutritionAddRecipeTo.
  ///
  /// In en, this message translates to:
  /// **'ADD RECIPE TO...'**
  String get nutritionAddRecipeTo;

  /// No description provided for @nutritionMyRecipes.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get nutritionMyRecipes;

  /// No description provided for @nutritionSearchRecipe.
  ///
  /// In en, this message translates to:
  /// **'Search recipe...'**
  String get nutritionSearchRecipe;

  /// No description provided for @nutritionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get nutritionRetry;

  /// No description provided for @nutritionCreateFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create your first recipe!'**
  String get nutritionCreateFirstRecipe;

  /// No description provided for @nutritionCreateRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create recipe'**
  String get nutritionCreateRecipe;

  /// No description provided for @nutritionNoMatchingRecipes.
  ///
  /// In en, this message translates to:
  /// **'No matching recipes'**
  String get nutritionNoMatchingRecipes;

  /// No description provided for @nutritionDeleteFood.
  ///
  /// In en, this message translates to:
  /// **'Delete food'**
  String get nutritionDeleteFood;

  /// No description provided for @nutritionFoodDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{foodName}\" deleted'**
  String nutritionFoodDeleted(String foodName);

  /// No description provided for @nutritionCouldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete'**
  String get nutritionCouldNotDelete;

  /// No description provided for @nutritionMyFoods.
  ///
  /// In en, this message translates to:
  /// **'My Foods'**
  String get nutritionMyFoods;

  /// No description provided for @nutritionKcalPer100g.
  ///
  /// In en, this message translates to:
  /// **'Kcal /100g'**
  String get nutritionKcalPer100g;

  /// No description provided for @nutritionCreateFood.
  ///
  /// In en, this message translates to:
  /// **'CREATE FOOD'**
  String get nutritionCreateFood;

  /// No description provided for @nutritionFoodDeletedFromHistory.
  ///
  /// In en, this message translates to:
  /// **'\"{foodName}\" deleted from history'**
  String nutritionFoodDeletedFromHistory(String foodName);

  /// No description provided for @nutritionSelectFood.
  ///
  /// In en, this message translates to:
  /// **'Select food'**
  String get nutritionSelectFood;

  /// No description provided for @nutritionNoBrand.
  ///
  /// In en, this message translates to:
  /// **'No brand'**
  String get nutritionNoBrand;

  /// No description provided for @nutritionAddUpper.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get nutritionAddUpper;

  /// No description provided for @nutritionSearchUpper.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get nutritionSearchUpper;

  /// No description provided for @nutritionAddIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'ADD INGREDIENT'**
  String get nutritionAddIngredientTitle;

  /// No description provided for @nutritionSearchFood.
  ///
  /// In en, this message translates to:
  /// **'Search food'**
  String get nutritionSearchFood;

  /// No description provided for @nutritionEnterNameAndMacros.
  ///
  /// In en, this message translates to:
  /// **'Enter name and macros of the food'**
  String get nutritionEnterNameAndMacros;

  /// No description provided for @nutritionFlashError.
  ///
  /// In en, this message translates to:
  /// **'Could not activate flash'**
  String get nutritionFlashError;

  /// No description provided for @nutritionBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get nutritionBreakfast;

  /// No description provided for @nutritionLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get nutritionLunch;

  /// No description provided for @nutritionDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get nutritionDinner;

  /// No description provided for @nutritionSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get nutritionSnack;

  /// No description provided for @nutritionBreakfasts.
  ///
  /// In en, this message translates to:
  /// **'Breakfasts'**
  String get nutritionBreakfasts;

  /// No description provided for @nutritionLunches.
  ///
  /// In en, this message translates to:
  /// **'Lunches'**
  String get nutritionLunches;

  /// No description provided for @nutritionDinners.
  ///
  /// In en, this message translates to:
  /// **'Dinners'**
  String get nutritionDinners;

  /// No description provided for @nutritionSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get nutritionSnacks;

  /// No description provided for @nutritionErrorAddingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Error adding recipe'**
  String get nutritionErrorAddingRecipe;

  /// No description provided for @workoutRoutineUpdated.
  ///
  /// In en, this message translates to:
  /// **'Routine updated!'**
  String get workoutRoutineUpdated;

  /// No description provided for @workoutEditRoutine.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get workoutEditRoutine;

  /// No description provided for @workoutNewRoutine.
  ///
  /// In en, this message translates to:
  /// **'New Routine'**
  String get workoutNewRoutine;

  /// No description provided for @workoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get workoutDetails;

  /// No description provided for @workoutName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get workoutName;

  /// No description provided for @workoutNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Push Day / Legs / Full Body'**
  String get workoutNameHint;

  /// No description provided for @workoutClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get workoutClose;

  /// No description provided for @workoutSuggestions.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTIONS'**
  String get workoutSuggestions;

  /// No description provided for @workoutAdd.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get workoutAdd;

  /// No description provided for @workoutTapExercise.
  ///
  /// In en, this message translates to:
  /// **'Tap an exercise...'**
  String get workoutTapExercise;

  /// No description provided for @workoutStartAddingExercises.
  ///
  /// In en, this message translates to:
  /// **'Start adding exercises!'**
  String get workoutStartAddingExercises;

  /// No description provided for @workoutDeleteRoutine.
  ///
  /// In en, this message translates to:
  /// **'Delete routine?'**
  String get workoutDeleteRoutine;

  /// No description provided for @workoutDeleteRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{routineName}\" will be deleted...'**
  String workoutDeleteRoutineConfirm(String routineName);

  /// No description provided for @workoutRoutineCompleted.
  ///
  /// In en, this message translates to:
  /// **'Routine completed!'**
  String get workoutRoutineCompleted;

  /// No description provided for @workoutNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get workoutNoResults;

  /// No description provided for @workoutFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get workoutFullBody;

  /// No description provided for @workoutPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get workoutPush;

  /// No description provided for @workoutPull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get workoutPull;

  /// No description provided for @workoutLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get workoutLegs;

  /// No description provided for @workoutTorso.
  ///
  /// In en, this message translates to:
  /// **'Torso'**
  String get workoutTorso;

  /// No description provided for @workoutUpperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper body'**
  String get workoutUpperBody;

  /// No description provided for @workoutLowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower body'**
  String get workoutLowerBody;

  /// No description provided for @workoutFullBodyDesc.
  ///
  /// In en, this message translates to:
  /// **'Whole body in one session'**
  String get workoutFullBodyDesc;

  /// No description provided for @workoutPushDesc.
  ///
  /// In en, this message translates to:
  /// **'Chest, shoulders and triceps'**
  String get workoutPushDesc;

  /// No description provided for @workoutPullDesc.
  ///
  /// In en, this message translates to:
  /// **'Back and biceps'**
  String get workoutPullDesc;

  /// No description provided for @workoutLegsDesc.
  ///
  /// In en, this message translates to:
  /// **'Quadriceps, hamstrings and glutes'**
  String get workoutLegsDesc;

  /// No description provided for @workoutTorsoDesc.
  ///
  /// In en, this message translates to:
  /// **'Chest, back and shoulders'**
  String get workoutTorsoDesc;

  /// No description provided for @workoutUpperBodyDesc.
  ///
  /// In en, this message translates to:
  /// **'Upper body focused session'**
  String get workoutUpperBodyDesc;

  /// No description provided for @workoutLowerBodyDesc.
  ///
  /// In en, this message translates to:
  /// **'Lower body focused session'**
  String get workoutLowerBodyDesc;

  /// No description provided for @workoutStrength.
  ///
  /// In en, this message translates to:
  /// **'STRENGTH'**
  String get workoutStrength;

  /// No description provided for @workoutVolume.
  ///
  /// In en, this message translates to:
  /// **'VOLUME'**
  String get workoutVolume;

  /// No description provided for @workoutEndurance.
  ///
  /// In en, this message translates to:
  /// **'ENDURANCE'**
  String get workoutEndurance;

  /// No description provided for @workoutDefinition.
  ///
  /// In en, this message translates to:
  /// **'DEFINITION'**
  String get workoutDefinition;

  /// No description provided for @workoutStrengthDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximize your strength with heavy loads and low reps'**
  String get workoutStrengthDesc;

  /// No description provided for @workoutVolumeDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase muscle mass with moderate loads and volume'**
  String get workoutVolumeDesc;

  /// No description provided for @workoutEnduranceDesc.
  ///
  /// In en, this message translates to:
  /// **'Improve muscular endurance with light loads and high reps'**
  String get workoutEnduranceDesc;

  /// No description provided for @workoutDefinitionDesc.
  ///
  /// In en, this message translates to:
  /// **'Define your physique with controlled intensity'**
  String get workoutDefinitionDesc;

  /// No description provided for @workoutTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get workoutTimer;

  /// No description provided for @workoutReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get workoutReps;

  /// No description provided for @workoutRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get workoutRest;

  /// No description provided for @workoutRoutinesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get workoutRoutinesEmpty;

  /// No description provided for @workoutNoRoutinesFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find routines'**
  String get workoutNoRoutinesFound;

  /// No description provided for @workoutDesignFirstRoutine.
  ///
  /// In en, this message translates to:
  /// **'Design your first routine!'**
  String get workoutDesignFirstRoutine;

  /// No description provided for @workoutExerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get workoutExerciseLibrary;

  /// No description provided for @workoutSearchExercise.
  ///
  /// In en, this message translates to:
  /// **'Search exercise...'**
  String get workoutSearchExercise;

  /// No description provided for @workoutFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get workoutFilterAll;

  /// No description provided for @workoutFilterBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get workoutFilterBodyweight;

  /// No description provided for @workoutNoExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get workoutNoExercisesFound;

  /// No description provided for @workoutWhatIsItFor.
  ///
  /// In en, this message translates to:
  /// **'What is it for?'**
  String get workoutWhatIsItFor;

  /// No description provided for @workoutMainBenefits.
  ///
  /// In en, this message translates to:
  /// **'Main Benefits'**
  String get workoutMainBenefits;

  /// No description provided for @workoutCouldNotLoadVideo.
  ///
  /// In en, this message translates to:
  /// **'Could not load video.'**
  String get workoutCouldNotLoadVideo;

  /// No description provided for @workoutExerciseBenefitsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Strengthens and develops the {muscleGroup}. Ideal for improving performance and muscle aesthetics.'**
  String workoutExerciseBenefitsTemplate(String muscleGroup);

  /// No description provided for @fitnessProgress.
  ///
  /// In en, this message translates to:
  /// **'Physical progress'**
  String get fitnessProgress;

  /// No description provided for @fitnessStats.
  ///
  /// In en, this message translates to:
  /// **'Physical stats'**
  String get fitnessStats;

  /// No description provided for @fitnessMuscle.
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get fitnessMuscle;

  /// No description provided for @fitnessWeightEvolution.
  ///
  /// In en, this message translates to:
  /// **'Weight evolution'**
  String get fitnessWeightEvolution;

  /// No description provided for @fitnessAddRecord.
  ///
  /// In en, this message translates to:
  /// **'ADD PHYSICAL RECORD'**
  String get fitnessAddRecord;

  /// No description provided for @fitnessMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get fitnessMin;

  /// No description provided for @fitnessMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get fitnessMax;

  /// No description provided for @fitnessNeedTwoRecords.
  ///
  /// In en, this message translates to:
  /// **'You need at least 2 records to see the graph'**
  String get fitnessNeedTwoRecords;

  /// No description provided for @fitnessNoRecordsThisDay.
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get fitnessNoRecordsThisDay;

  /// No description provided for @fitnessNoProgressData.
  ///
  /// In en, this message translates to:
  /// **'No progress data yet'**
  String get fitnessNoProgressData;

  /// No description provided for @fitnessAddFirstRecord.
  ///
  /// In en, this message translates to:
  /// **'ADD FIRST RECORD'**
  String get fitnessAddFirstRecord;

  /// No description provided for @fitnessGainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain muscle'**
  String get fitnessGainMuscle;

  /// No description provided for @fitnessLoseFat.
  ///
  /// In en, this message translates to:
  /// **'Lose fat'**
  String get fitnessLoseFat;

  /// No description provided for @fitnessStayAthletic.
  ///
  /// In en, this message translates to:
  /// **'Stay athletic'**
  String get fitnessStayAthletic;

  /// No description provided for @fitnessPhysicalProfile.
  ///
  /// In en, this message translates to:
  /// **'Physical profile'**
  String get fitnessPhysicalProfile;

  /// No description provided for @fitnessPhysicalData.
  ///
  /// In en, this message translates to:
  /// **'Physical data'**
  String get fitnessPhysicalData;

  /// No description provided for @fitnessGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get fitnessGender;

  /// No description provided for @fitnessEditPhysicalData.
  ///
  /// In en, this message translates to:
  /// **'Edit physical data'**
  String get fitnessEditPhysicalData;

  /// No description provided for @fitnessViewStats.
  ///
  /// In en, this message translates to:
  /// **'View stats'**
  String get fitnessViewStats;

  /// No description provided for @fitnessNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get fitnessNotConfigured;

  /// No description provided for @fitnessEnterHeightAge.
  ///
  /// In en, this message translates to:
  /// **'Enter your height and age'**
  String get fitnessEnterHeightAge;

  /// No description provided for @fitnessSelectGenderGoal.
  ///
  /// In en, this message translates to:
  /// **'Select your gender and goal'**
  String get fitnessSelectGenderGoal;

  /// No description provided for @fitnessMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get fitnessMale;

  /// No description provided for @fitnessFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get fitnessFemale;

  /// No description provided for @fitnessSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get fitnessSaveChanges;

  /// No description provided for @fitnessHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get fitnessHeight;

  /// No description provided for @fitnessAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fitnessAge;

  /// No description provided for @fitnessRecordSaved.
  ///
  /// In en, this message translates to:
  /// **'Physical record saved successfully'**
  String get fitnessRecordSaved;

  /// No description provided for @fitnessNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New physical record'**
  String get fitnessNewRecord;

  /// No description provided for @fitnessRecordDate.
  ///
  /// In en, this message translates to:
  /// **'RECORD DATE'**
  String get fitnessRecordDate;

  /// No description provided for @fitnessSaveRecord.
  ///
  /// In en, this message translates to:
  /// **'SAVE RECORD'**
  String get fitnessSaveRecord;

  /// No description provided for @fitnessCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get fitnessCurrentWeight;

  /// No description provided for @fitnessBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get fitnessBodyFat;

  /// No description provided for @fitnessMuscleMass.
  ///
  /// In en, this message translates to:
  /// **'Muscle mass'**
  String get fitnessMuscleMass;

  /// No description provided for @fitnessNoPhysicalRecords.
  ///
  /// In en, this message translates to:
  /// **'No physical records'**
  String get fitnessNoPhysicalRecords;

  /// No description provided for @fitnessSelectDay.
  ///
  /// In en, this message translates to:
  /// **'Select a day'**
  String get fitnessSelectDay;

  /// No description provided for @fitnessAddTodayRecord.
  ///
  /// In en, this message translates to:
  /// **'ADD TODAY\'S RECORD'**
  String get fitnessAddTodayRecord;

  /// No description provided for @fitnessGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get fitnessGoal;

  /// No description provided for @fitnessYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get fitnessYears;

  /// No description provided for @fitnessLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load physical progress'**
  String get fitnessLoadError;

  /// No description provided for @fitnessProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load physical profile'**
  String get fitnessProfileLoadError;

  /// No description provided for @socialNewPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get socialNewPost;

  /// No description provided for @socialPickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get socialPickFromGallery;

  /// No description provided for @socialDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get socialDescriptionOptional;

  /// No description provided for @socialSelectImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an image first'**
  String get socialSelectImageFirst;

  /// No description provided for @socialPostCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created!'**
  String get socialPostCreated;

  /// No description provided for @socialStoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Story created!'**
  String get socialStoryCreated;

  /// No description provided for @socialBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get socialBio;

  /// No description provided for @socialProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get socialProfileUpdated;

  /// No description provided for @socialNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get socialNoPosts;

  /// No description provided for @socialFeedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your feed is empty'**
  String get socialFeedEmpty;

  /// No description provided for @socialFollowOthers.
  ///
  /// In en, this message translates to:
  /// **'Follow other users...'**
  String get socialFollowOthers;

  /// No description provided for @socialChallengeFriends.
  ///
  /// In en, this message translates to:
  /// **'Challenge your friends!'**
  String get socialChallengeFriends;

  /// No description provided for @socialChallengeUser.
  ///
  /// In en, this message translates to:
  /// **'Challenge to a duel!'**
  String get socialChallengeUser;

  /// No description provided for @socialNoPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get socialNoPostsYet;

  /// No description provided for @socialPickExercise.
  ///
  /// In en, this message translates to:
  /// **'Which exercise do you want to compete in?'**
  String get socialPickExercise;

  /// No description provided for @socialChallengeSent.
  ///
  /// In en, this message translates to:
  /// **'Challenge sent successfully!'**
  String get socialChallengeSent;

  /// No description provided for @socialSendChallenge.
  ///
  /// In en, this message translates to:
  /// **'Send Challenge'**
  String get socialSendChallenge;

  /// No description provided for @socialNothingToExplore.
  ///
  /// In en, this message translates to:
  /// **'Nothing to explore yet'**
  String get socialNothingToExplore;

  /// No description provided for @socialPublicPostsHere.
  ///
  /// In en, this message translates to:
  /// **'Public posts will appear here'**
  String get socialPublicPostsHere;

  /// No description provided for @socialUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get socialUnexpectedError;

  /// No description provided for @aiLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Chat history limit reached. Delete an existing chat to create a new one.'**
  String get aiLimitReached;

  /// No description provided for @aiCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get aiCopiedToClipboard;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me about routines, nutrition or any fitness questions.'**
  String get aiWelcomeSubtitle;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message...'**
  String get aiInputHint;

  /// No description provided for @aiHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get aiHistoryTitle;

  /// No description provided for @aiNoSavedConversations.
  ///
  /// In en, this message translates to:
  /// **'No saved conversations'**
  String get aiNoSavedConversations;

  /// No description provided for @aiMessageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}'**
  String aiMessageCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get settingsAppPreferences;

  /// No description provided for @settingsShareProgress.
  ///
  /// In en, this message translates to:
  /// **'Share progress'**
  String get settingsShareProgress;

  /// No description provided for @settingsIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get settingsIntegrations;

  /// No description provided for @settingsIntegrationsSoon.
  ///
  /// In en, this message translates to:
  /// **'Integrations coming soon'**
  String get settingsIntegrationsSoon;

  /// No description provided for @settingsPhysicalData.
  ///
  /// In en, this message translates to:
  /// **'Physical data'**
  String get settingsPhysicalData;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get settingsVersion;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get settingsDescription;

  /// No description provided for @settingsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'JADA Fit is your smart fitness companion. Create custom routines, track your physical progress, receive AI assistance, and connect with a fitness community.'**
  String get settingsAppDescription;

  /// No description provided for @settingsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settingsContact;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsThemeSystem;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @settingsImperialUnits.
  ///
  /// In en, this message translates to:
  /// **'Imperial units'**
  String get settingsImperialUnits;

  /// No description provided for @settingsImperialUnitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show weight and height in lbs / ft'**
  String get settingsImperialUnitsDesc;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get settingsAiAssistant;

  /// No description provided for @settingsAiAssistantDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications when the AI responds'**
  String get settingsAiAssistantDesc;

  /// No description provided for @settingsWorkoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get settingsWorkoutReminders;

  /// No description provided for @settingsWorkoutRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Remind to train every day'**
  String get settingsWorkoutRemindersDesc;

  /// No description provided for @settingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get settingsInfo;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About JADA Fit'**
  String get settingsAbout;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settingsSelectLanguage;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageEs;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get onboardingStart;

  /// No description provided for @onboardingSetupFitnessProfile.
  ///
  /// In en, this message translates to:
  /// **'Set up your fitness profile'**
  String get onboardingSetupFitnessProfile;

  /// No description provided for @onboardingCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get onboardingCurrentWeight;

  /// No description provided for @onboardingHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get onboardingHeight;

  /// No description provided for @onboardingAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingAge;

  /// No description provided for @onboardingBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get onboardingBodyFat;

  /// No description provided for @onboardingMuscleMass.
  ///
  /// In en, this message translates to:
  /// **'Muscle mass'**
  String get onboardingMuscleMass;

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Mode'**
  String get aiTitle;

  /// No description provided for @aiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here you will see smart suggestions and personalized recommendations.'**
  String get aiSubtitle;

  /// No description provided for @aiPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Ask me about routines, nutrition or any fitness questions.'**
  String get aiPromptHint;

  /// No description provided for @aiSuggestionMacros.
  ///
  /// In en, this message translates to:
  /// **'How are my macros today?'**
  String get aiSuggestionMacros;

  /// No description provided for @aiSuggestionDinner.
  ///
  /// In en, this message translates to:
  /// **'What should I have for dinner?'**
  String get aiSuggestionDinner;

  /// No description provided for @aiSuggestionAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze my nutrition...'**
  String get aiSuggestionAnalyze;

  /// No description provided for @aiSuggestionAdvice.
  ///
  /// In en, this message translates to:
  /// **'Give me a tip...'**
  String get aiSuggestionAdvice;

  /// No description provided for @aiErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred. Try again.'**
  String get aiErrorMessage;

  /// No description provided for @aiWhatElse.
  ///
  /// In en, this message translates to:
  /// **'What else can I do today?'**
  String get aiWhatElse;

  /// No description provided for @aiRecoveryTips.
  ///
  /// In en, this message translates to:
  /// **'Recovery tips'**
  String get aiRecoveryTips;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile.'**
  String get profileError;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileEditPhysicalData.
  ///
  /// In en, this message translates to:
  /// **'Edit physical data'**
  String get profileEditPhysicalData;

  /// No description provided for @profileYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get profileYears;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get loginTitle;

  /// No description provided for @loginUserLabel.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get loginUserLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get loginPasswordLabel;

  /// No description provided for @loginIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'EMAIL OR USERNAME'**
  String get loginIdentifierHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get loginPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @forgotPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordPrompt;

  /// No description provided for @recoverPasswordSoon.
  ///
  /// In en, this message translates to:
  /// **'Recover password coming soon'**
  String get recoverPasswordSoon;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccountPrompt;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get registerTitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get registerNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get registerPasswordLabel;

  /// No description provided for @registerRepeatPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'REPEAT PASSWORD'**
  String get registerRepeatPasswordLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get registerNameHint;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get registerEmailHint;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get registerPasswordHint;

  /// No description provided for @registerRepeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'REPEAT PASSWORD'**
  String get registerRepeatPasswordHint;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get continueWith;

  /// No description provided for @errorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get errorEnterEmail;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get errorInvalidEmail;

  /// No description provided for @errorEnterIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get errorEnterIdentifier;

  /// No description provided for @errorEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get errorEnterPassword;

  /// No description provided for @errorFixErrors.
  ///
  /// In en, this message translates to:
  /// **'Fix the errors to continue'**
  String get errorFixErrors;

  /// No description provided for @errorFixForm.
  ///
  /// In en, this message translates to:
  /// **'Fix the form errors'**
  String get errorFixForm;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Try again'**
  String get errorLoginFailed;

  /// No description provided for @errorEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get errorEnterName;

  /// No description provided for @errorEnterRegisterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get errorEnterRegisterEmail;

  /// No description provided for @errorPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordMinLength;

  /// No description provided for @errorRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get errorRepeatPassword;

  /// No description provided for @errorPasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get errorPasswordsDontMatch;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @errorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create account. Try again'**
  String get errorRegisterFailed;

  /// No description provided for @googleProvider.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleProvider;

  /// No description provided for @appleProvider.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get appleProvider;

  /// No description provided for @facebookProvider.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebookProvider;

  /// No description provided for @sessionNotActive.
  ///
  /// In en, this message translates to:
  /// **'No active session'**
  String get sessionNotActive;

  /// No description provided for @notAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Not authorized. Please sign in again.'**
  String get notAuthorized;

  /// No description provided for @authPasswordMinLength6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordMinLength6;

  /// No description provided for @authServerError.
  ///
  /// In en, this message translates to:
  /// **'A server error occurred'**
  String get authServerError;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'YOUR EMAIL'**
  String get forgotPasswordEmailHint;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'SEND CODE'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotPasswordSuccess;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'VERIFICATION CODE'**
  String get resetPasswordTokenLabel;

  /// No description provided for @resetPasswordTokenHint.
  ///
  /// In en, this message translates to:
  /// **'CODE'**
  String get resetPasswordTokenHint;

  /// No description provided for @resetPasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get resetPasswordNewPasswordLabel;

  /// No description provided for @resetPasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get resetPasswordNewPasswordHint;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD'**
  String get resetPasswordButton;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToLogin;

  /// No description provided for @comingSoonProvider.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {provider} coming soon'**
  String comingSoonProvider(String provider);

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @nutritionDeleteMealError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete meal'**
  String get nutritionDeleteMealError;

  /// No description provided for @nutritionAddFoodTo.
  ///
  /// In en, this message translates to:
  /// **'ADD FOOD TO...'**
  String get nutritionAddFoodTo;

  /// No description provided for @nutritionWaterLogError.
  ///
  /// In en, this message translates to:
  /// **'Error logging water'**
  String get nutritionWaterLogError;

  /// No description provided for @nutritionAddFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Add foods to calculate calories and macros.'**
  String get nutritionAddFoodsHint;

  /// No description provided for @nutritionWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get nutritionWater;

  /// No description provided for @nutritionPhysicalTracking.
  ///
  /// In en, this message translates to:
  /// **'Physical tracking'**
  String get nutritionPhysicalTracking;

  /// No description provided for @nutritionNoRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get nutritionNoRecordsYet;

  /// No description provided for @nutritionAddRecord.
  ///
  /// In en, this message translates to:
  /// **'Add record'**
  String get nutritionAddRecord;

  /// No description provided for @nutritionViewSummary.
  ///
  /// In en, this message translates to:
  /// **'View summary'**
  String get nutritionViewSummary;

  /// No description provided for @nutritionWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get nutritionWeightLabel;

  /// No description provided for @nutritionNoFoods.
  ///
  /// In en, this message translates to:
  /// **'No foods'**
  String get nutritionNoFoods;

  /// No description provided for @nutritionFoodCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 food} other{{count} foods}}'**
  String nutritionFoodCount(int count);

  /// No description provided for @nutritionMyFoodsCard.
  ///
  /// In en, this message translates to:
  /// **'My\nfoods'**
  String get nutritionMyFoodsCard;

  /// No description provided for @nutritionMyRecipesCard.
  ///
  /// In en, this message translates to:
  /// **'My\nrecipes'**
  String get nutritionMyRecipesCard;

  /// No description provided for @nutritionMealRegistered.
  ///
  /// In en, this message translates to:
  /// **'Meal registered successfully'**
  String get nutritionMealRegistered;

  /// No description provided for @nutritionCompleteAllFields.
  ///
  /// In en, this message translates to:
  /// **'Complete all fields'**
  String get nutritionCompleteAllFields;

  /// No description provided for @nutritionRecipeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recipe updated successfully'**
  String get nutritionRecipeUpdated;

  /// No description provided for @nutritionRecipeCreated.
  ///
  /// In en, this message translates to:
  /// **'Recipe created successfully'**
  String get nutritionRecipeCreated;

  /// No description provided for @nutritionRecipeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving recipe'**
  String get nutritionRecipeSaveError;

  /// No description provided for @nutritionFoodDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete food'**
  String get nutritionFoodDeleteError;

  /// No description provided for @nutritionRecipeAddedToMeal.
  ///
  /// In en, this message translates to:
  /// **'{recipeName} added to {mealName}'**
  String nutritionRecipeAddedToMeal(String recipeName, String mealName);

  /// No description provided for @nutritionDeleteFoodFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{foodName}\" from history?'**
  String nutritionDeleteFoodFromHistory(String foodName);

  /// No description provided for @nutritionDeleteRecipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{recipeName}\"?'**
  String nutritionDeleteRecipeConfirm(String recipeName);

  /// No description provided for @homeQuickActionScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode and find the food'**
  String get homeQuickActionScanSubtitle;

  /// No description provided for @homeQuickActionMealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a meal to the current day'**
  String get homeQuickActionMealSubtitle;

  /// No description provided for @homeQuickActionPhysicalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log weight, body fat and muscle mass'**
  String get homeQuickActionPhysicalSubtitle;

  /// No description provided for @homeQuickActionRoutineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your current workout'**
  String get homeQuickActionRoutineSubtitle;

  /// No description provided for @homeQuickActionAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a personalized recommendation'**
  String get homeQuickActionAiSubtitle;

  /// No description provided for @socialExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get socialExplore;

  /// No description provided for @socialChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get socialChallenges;

  /// No description provided for @socialMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get socialMyProfile;

  /// No description provided for @socialNoActiveChallenges.
  ///
  /// In en, this message translates to:
  /// **'You have no active challenges.'**
  String get socialNoActiveChallenges;

  /// No description provided for @socialUpdateMyRecords.
  ///
  /// In en, this message translates to:
  /// **'Update my records'**
  String get socialUpdateMyRecords;

  /// No description provided for @socialYourChallenges.
  ///
  /// In en, this message translates to:
  /// **'Your Challenges'**
  String get socialYourChallenges;

  /// No description provided for @socialMyRecords.
  ///
  /// In en, this message translates to:
  /// **'My Records'**
  String get socialMyRecords;

  /// No description provided for @socialReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get socialReject;

  /// No description provided for @socialAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get socialAccept;

  /// No description provided for @socialChallengeStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get socialChallengeStatusPending;

  /// No description provided for @socialChallengeStatusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get socialChallengeStatusActive;

  /// No description provided for @socialChallengeStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get socialChallengeStatusRejected;

  /// No description provided for @socialChallengeStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'FINISHED'**
  String get socialChallengeStatusFinished;

  /// No description provided for @socialUpdatePersonalRecord.
  ///
  /// In en, this message translates to:
  /// **'Update Personal Record'**
  String get socialUpdatePersonalRecord;

  /// No description provided for @socialExerciseHint.
  ///
  /// In en, this message translates to:
  /// **'Exercise (e.g. Bench Press)'**
  String get socialExerciseHint;

  /// No description provided for @socialWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get socialWeightKg;

  /// No description provided for @socialRecordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Record updated'**
  String get socialRecordUpdated;

  /// No description provided for @socialSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get socialSave;

  /// No description provided for @socialChallengeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading challenges: {error}'**
  String socialChallengeLoadError(String error);

  /// No description provided for @socialChallengeUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge {username}'**
  String socialChallengeUserTitle(String username);

  /// No description provided for @socialErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String socialErrorDetails(String error);

  /// No description provided for @socialSearchError.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String socialSearchError(String error);

  /// No description provided for @socialTimeAgoNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get socialTimeAgoNow;

  /// No description provided for @socialTimeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String socialTimeAgoMinutes(int minutes);

  /// No description provided for @socialTimeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String socialTimeAgoHours(int hours);

  /// No description provided for @socialTimeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String socialTimeAgoDays(int days);

  /// No description provided for @socialProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get socialProfileLoadError;

  /// No description provided for @onboardingSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get onboardingSelectGender;

  /// No description provided for @onboardingSelectGoal.
  ///
  /// In en, this message translates to:
  /// **'Select your goal'**
  String get onboardingSelectGoal;

  /// No description provided for @onboardingEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get onboardingEnterAge;

  /// No description provided for @onboardingSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete initial setup'**
  String get onboardingSetupFailed;

  /// No description provided for @onboardingGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get onboardingGoal;

  /// No description provided for @fitnessDataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Physical data updated successfully'**
  String get fitnessDataUpdated;

  /// No description provided for @fitnessSelectGenderError.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get fitnessSelectGenderError;

  /// No description provided for @fitnessUpdateDataError.
  ///
  /// In en, this message translates to:
  /// **'Could not update physical data'**
  String get fitnessUpdateDataError;

  /// No description provided for @fitnessRecomposition.
  ///
  /// In en, this message translates to:
  /// **'Body recomposition'**
  String get fitnessRecomposition;

  /// No description provided for @fitnessSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get fitnessSelectOption;

  /// No description provided for @fitnessPersonalizeHelp.
  ///
  /// In en, this message translates to:
  /// **'This will help personalize the app'**
  String get fitnessPersonalizeHelp;

  /// No description provided for @fitnessSetupProfile.
  ///
  /// In en, this message translates to:
  /// **'Set up your physical profile'**
  String get fitnessSetupProfile;

  /// No description provided for @fitnessSetupProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'This data is used to personalize your goals, recommendations and future analysis.'**
  String get fitnessSetupProfileDesc;

  /// No description provided for @fitnessAddRecordForDay.
  ///
  /// In en, this message translates to:
  /// **'ADD RECORD FOR THIS DAY'**
  String get fitnessAddRecordForDay;

  /// No description provided for @fitnessPhysicalRecord.
  ///
  /// In en, this message translates to:
  /// **'Physical record'**
  String get fitnessPhysicalRecord;

  /// No description provided for @fitnessCalendarHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a calendar day to view or add physical records.'**
  String get fitnessCalendarHint;

  /// No description provided for @fitnessAddRecordUsingButton.
  ///
  /// In en, this message translates to:
  /// **'You can add a record using the button above.'**
  String get fitnessAddRecordUsingButton;

  /// No description provided for @fitnessRecordSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save physical record'**
  String get fitnessRecordSaveError;

  /// No description provided for @fitnessAddPhysicalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Add physical data'**
  String get fitnessAddPhysicalDataTitle;

  /// No description provided for @fitnessRecordDateHint.
  ///
  /// In en, this message translates to:
  /// **'You can log today\'s data or a past date if you forgot to record it.'**
  String get fitnessRecordDateHint;

  /// No description provided for @fitnessAutoSaveTime.
  ///
  /// In en, this message translates to:
  /// **'Time will be saved automatically'**
  String get fitnessAutoSaveTime;

  /// No description provided for @fitnessSwipeChartHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe the chart to change month'**
  String get fitnessSwipeChartHint;

  /// No description provided for @fitnessAddFirstDataHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first physical data to start seeing your progress.'**
  String get fitnessAddFirstDataHint;

  /// No description provided for @fitnessRecordSummary.
  ///
  /// In en, this message translates to:
  /// **'{time} · {weight} · {bodyFat} fat · {muscleMass} muscle'**
  String fitnessRecordSummary(
    String time,
    String weight,
    String bodyFat,
    String muscleMass,
  );

  /// No description provided for @fitnessProfileDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Height, age, gender and goal'**
  String get fitnessProfileDataSubtitle;

  /// No description provided for @fitnessAddPhysicalRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add physical record'**
  String get fitnessAddPhysicalRecordTitle;

  /// No description provided for @fitnessHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'History and physical progress'**
  String get fitnessHistorySubtitle;

  /// No description provided for @profilePrivacyUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating privacy: {error}'**
  String profilePrivacyUpdateError(String error);

  /// No description provided for @profilePhysicalDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weight, height, body composition and more'**
  String get profilePhysicalDataSubtitle;

  /// No description provided for @workoutRoutineCreated.
  ///
  /// In en, this message translates to:
  /// **'Routine created successfully!'**
  String get workoutRoutineCreated;

  /// No description provided for @workoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get workoutDescription;

  /// No description provided for @aiSuggestionDeepDive.
  ///
  /// In en, this message translates to:
  /// **'Go deeper on that topic'**
  String get aiSuggestionDeepDive;

  /// No description provided for @aiSuggestionWorkout.
  ///
  /// In en, this message translates to:
  /// **'Give me a workout routine'**
  String get aiSuggestionWorkout;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat {number}'**
  String aiChatTitle(int number);

  /// No description provided for @sharedAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get sharedAccept;

  /// No description provided for @socialNewStory.
  ///
  /// In en, this message translates to:
  /// **'New story'**
  String get socialNewStory;

  /// No description provided for @socialStoryExpires.
  ///
  /// In en, this message translates to:
  /// **'Stories disappear in 24 hours'**
  String get socialStoryExpires;

  /// No description provided for @socialPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get socialPublish;

  /// No description provided for @socialUploadStory.
  ///
  /// In en, this message translates to:
  /// **'Upload story'**
  String get socialUploadStory;

  /// No description provided for @socialEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get socialEditProfile;

  /// No description provided for @socialShareProgressCommunity.
  ///
  /// In en, this message translates to:
  /// **'Share your progress with the community'**
  String get socialShareProgressCommunity;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
