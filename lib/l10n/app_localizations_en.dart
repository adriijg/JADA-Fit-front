// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'JADA FIT';

  @override
  String get homeWelcomeTitle => 'Welcome to JADA FIT';

  @override
  String get homeWelcomeSubtitle =>
      'This is the main screen. We will configure more features here soon.';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationNutrition => 'Nutrition';

  @override
  String get navigationAi => 'AI';

  @override
  String get navigationRoutines => 'Routines';

  @override
  String get navigationSocial => 'Social';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeScanFood => 'Scan food';

  @override
  String get homeLogMeal => 'Log meal';

  @override
  String get homeAddPhysicalData => 'Add physical data';

  @override
  String get homeViewRoutine => 'View routine';

  @override
  String get homeAskAI => 'Ask AI';

  @override
  String get homeNutritionToday => 'Today\'s nutrition';

  @override
  String get homeCaloriesAndMacrosSummary => 'Calories and macros summary';

  @override
  String get homeConsumed => 'Consumed';

  @override
  String get homeGoal => 'Goal';

  @override
  String get homeRemaining => 'Remaining';

  @override
  String get homeProtein => 'Protein';

  @override
  String get homeCarbs => 'Carbs';

  @override
  String get homeFats => 'Fats';

  @override
  String get homeGreeting => 'Hello 👋';

  @override
  String get homeMainPanel =>
      'This is your main panel. We will add more features soon.';

  @override
  String get homeAICoach => 'AI Coach';

  @override
  String get homeAICoachSubtitle => 'Tap to get a personalized recommendation.';

  @override
  String get homeConnectWithOthers => 'Connect with other users';

  @override
  String get homeNoRecentActivity => 'No recent activity';

  @override
  String get homeSocialActivity => 'Social activity';

  @override
  String get homeWorkoutCardTitle => 'Workout';

  @override
  String get homeNoRoutine => 'No routine';

  @override
  String homePendingExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises pending',
      one: '1 exercise pending',
    );
    return '$_temp0';
  }

  @override
  String get homeNoPendingExercises => 'No pending exercises';

  @override
  String get homeProgressCardTitle => 'Progress';

  @override
  String get homeNoProgressData => 'No data';

  @override
  String get homeAddFirstRecord => 'Add your first record';

  @override
  String homeWeightChangeSinceStart(String weightChange) {
    return '$weightChange since start';
  }

  @override
  String get homeNutritionLoadError => 'Could not load nutrition summary';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionSubtitle =>
      'Here you will see personalized meal plans, recipes and macros.';

  @override
  String get nutritionCaloriesPer100g => 'Calories /100g';

  @override
  String get nutritionProteinPer100g => 'Protein /100g';

  @override
  String get nutritionCalories => 'Calories';

  @override
  String get nutritionProtein => 'Protein';

  @override
  String get nutritionRecipesEmpty => 'You don\'t have any recipes yet';

  @override
  String get nutritionRecipesSearchEmpty => 'Try another search term.';

  @override
  String get nutritionAddToDay => 'Add to day';

  @override
  String get nutritionFoodsEmpty => 'You don\'t have any custom foods yet';

  @override
  String get nutritionDeleteConfirmation => 'It will be removed...\nContinue?';

  @override
  String get nutritionAddRecipeError => 'Could not add recipe';

  @override
  String get nutritionAddToEllipsis => 'Add to...';

  @override
  String get nutritionSearchOrScan => 'Search in the catalog or scan barcode';

  @override
  String get nutritionAddManually => 'Add manually';

  @override
  String get nutritionAddIngredient => 'Add ingredient';

  @override
  String get nutritionAddAtLeastOneIngredient => 'Add at least one ingredient';

  @override
  String get nutritionCameraError =>
      'Could not start the camera. Check the permissions or the emulator camera.';

  @override
  String get nutritionCameraSwitchError => 'Could not switch camera';

  @override
  String get nutritionCameraHint => 'Point the camera at the product barcode.';

  @override
  String get nutritionCameraStarting => 'Starting camera...';

  @override
  String get nutritionFoodName => 'Food name';

  @override
  String get nutritionFoodNameHint => 'e.g. Brown rice';

  @override
  String get nutritionCarbsPer100g => 'Carbs /100g';

  @override
  String get nutritionFatPer100g => 'Fat /100g';

  @override
  String get nutritionCalculatedSummary => 'CALCULATED SUMMARY';

  @override
  String get nutritionCarbs => 'Carbs';

  @override
  String get nutritionFat => 'Fat';

  @override
  String get nutritionDeleteRecipe => 'Delete recipe';

  @override
  String get nutritionCancel => 'Cancel';

  @override
  String get nutritionDelete => 'Delete';

  @override
  String get nutritionErrorDeletingRecipe => 'Error deleting recipe';

  @override
  String get nutritionAddRecipeTo => 'ADD RECIPE TO...';

  @override
  String get nutritionMyRecipes => 'My recipes';

  @override
  String get nutritionSearchRecipe => 'Search recipe...';

  @override
  String get nutritionRetry => 'Retry';

  @override
  String get nutritionCreateFirstRecipe => 'Create your first recipe!';

  @override
  String get nutritionCreateRecipe => 'Create recipe';

  @override
  String get nutritionNoMatchingRecipes => 'No matching recipes';

  @override
  String get nutritionDeleteFood => 'Delete food';

  @override
  String nutritionFoodDeleted(String foodName) {
    return '\"$foodName\" deleted';
  }

  @override
  String get nutritionCouldNotDelete => 'Could not delete';

  @override
  String get nutritionMyFoods => 'My Foods';

  @override
  String get nutritionKcalPer100g => 'Kcal /100g';

  @override
  String get nutritionCreateFood => 'CREATE FOOD';

  @override
  String nutritionFoodDeletedFromHistory(String foodName) {
    return '\"$foodName\" deleted from history';
  }

  @override
  String get nutritionSelectFood => 'Select food';

  @override
  String get nutritionNoBrand => 'No brand';

  @override
  String get nutritionAddUpper => 'ADD';

  @override
  String get nutritionSearchUpper => 'SEARCH';

  @override
  String get nutritionAddIngredientTitle => 'ADD INGREDIENT';

  @override
  String get nutritionSearchFood => 'Search food';

  @override
  String get nutritionEnterNameAndMacros => 'Enter name and macros of the food';

  @override
  String get nutritionFlashError => 'Could not activate flash';

  @override
  String get nutritionBreakfast => 'Breakfast';

  @override
  String get nutritionLunch => 'Lunch';

  @override
  String get nutritionDinner => 'Dinner';

  @override
  String get nutritionSnack => 'Snack';

  @override
  String get nutritionBreakfasts => 'Breakfasts';

  @override
  String get nutritionLunches => 'Lunches';

  @override
  String get nutritionDinners => 'Dinners';

  @override
  String get nutritionSnacks => 'Snacks';

  @override
  String get nutritionErrorAddingRecipe => 'Error adding recipe';

  @override
  String get workoutRoutineUpdated => 'Routine updated!';

  @override
  String get workoutEditRoutine => 'Edit Routine';

  @override
  String get workoutNewRoutine => 'New Routine';

  @override
  String get workoutDetails => 'Details';

  @override
  String get workoutName => 'Name';

  @override
  String get workoutNameHint => 'e.g. Push Day / Legs / Full Body';

  @override
  String get workoutClose => 'CLOSE';

  @override
  String get workoutSuggestions => 'SUGGESTIONS';

  @override
  String get workoutAdd => 'ADD';

  @override
  String get workoutTapExercise => 'Tap an exercise...';

  @override
  String get workoutStartAddingExercises => 'Start adding exercises!';

  @override
  String get workoutDeleteRoutine => 'Delete routine?';

  @override
  String workoutDeleteRoutineConfirm(String routineName) {
    return '\"$routineName\" will be deleted...';
  }

  @override
  String get workoutRoutineCompleted => 'Routine completed!';

  @override
  String get workoutNoResults => 'No results';

  @override
  String get workoutFullBody => 'Full Body';

  @override
  String get workoutPush => 'Push';

  @override
  String get workoutPull => 'Pull';

  @override
  String get workoutLegs => 'Legs';

  @override
  String get workoutTorso => 'Torso';

  @override
  String get workoutUpperBody => 'Upper body';

  @override
  String get workoutLowerBody => 'Lower body';

  @override
  String get workoutFullBodyDesc => 'Whole body in one session';

  @override
  String get workoutPushDesc => 'Chest, shoulders and triceps';

  @override
  String get workoutPullDesc => 'Back and biceps';

  @override
  String get workoutLegsDesc => 'Quadriceps, hamstrings and glutes';

  @override
  String get workoutTorsoDesc => 'Chest, back and shoulders';

  @override
  String get workoutUpperBodyDesc => 'Upper body focused session';

  @override
  String get workoutLowerBodyDesc => 'Lower body focused session';

  @override
  String get workoutStrength => 'STRENGTH';

  @override
  String get workoutVolume => 'VOLUME';

  @override
  String get workoutEndurance => 'ENDURANCE';

  @override
  String get workoutDefinition => 'DEFINITION';

  @override
  String get workoutStrengthDesc =>
      'Maximize your strength with heavy loads and low reps';

  @override
  String get workoutVolumeDesc =>
      'Increase muscle mass with moderate loads and volume';

  @override
  String get workoutEnduranceDesc =>
      'Improve muscular endurance with light loads and high reps';

  @override
  String get workoutDefinitionDesc =>
      'Define your physique with controlled intensity';

  @override
  String get workoutTimer => 'Timer';

  @override
  String get workoutReps => 'Reps';

  @override
  String get workoutRest => 'Rest';

  @override
  String get workoutRoutinesEmpty => 'No routines yet';

  @override
  String get workoutNoRoutinesFound => 'We couldn\'t find routines';

  @override
  String get workoutDesignFirstRoutine => 'Design your first routine!';

  @override
  String get workoutExerciseLibrary => 'Exercise Library';

  @override
  String get workoutSearchExercise => 'Search exercise...';

  @override
  String get workoutFilterAll => 'All';

  @override
  String get workoutFilterBodyweight => 'Bodyweight';

  @override
  String get workoutNoExercisesFound => 'No exercises found';

  @override
  String get workoutWhatIsItFor => 'What is it for?';

  @override
  String get workoutMainBenefits => 'Main Benefits';

  @override
  String get workoutCouldNotLoadVideo => 'Could not load video.';

  @override
  String workoutExerciseBenefitsTemplate(String muscleGroup) {
    return 'Strengthens and develops the $muscleGroup. Ideal for improving performance and muscle aesthetics.';
  }

  @override
  String get fitnessProgress => 'Physical progress';

  @override
  String get fitnessStats => 'Physical stats';

  @override
  String get fitnessMuscle => 'Muscle';

  @override
  String get fitnessWeightEvolution => 'Weight evolution';

  @override
  String get fitnessAddRecord => 'ADD PHYSICAL RECORD';

  @override
  String get fitnessMin => 'Min';

  @override
  String get fitnessMax => 'Max';

  @override
  String get fitnessNeedTwoRecords =>
      'You need at least 2 records to see the graph';

  @override
  String get fitnessNoRecordsThisDay => 'No records for this day';

  @override
  String get fitnessNoProgressData => 'No progress data yet';

  @override
  String get fitnessAddFirstRecord => 'ADD FIRST RECORD';

  @override
  String get fitnessGainMuscle => 'Gain muscle';

  @override
  String get fitnessLoseFat => 'Lose fat';

  @override
  String get fitnessStayAthletic => 'Stay athletic';

  @override
  String get fitnessPhysicalProfile => 'Physical profile';

  @override
  String get fitnessPhysicalData => 'Physical data';

  @override
  String get fitnessGender => 'Gender';

  @override
  String get fitnessEditPhysicalData => 'Edit physical data';

  @override
  String get fitnessViewStats => 'View stats';

  @override
  String get fitnessNotConfigured => 'Not configured';

  @override
  String get fitnessEnterHeightAge => 'Enter your height and age';

  @override
  String get fitnessSelectGenderGoal => 'Select your gender and goal';

  @override
  String get fitnessMale => 'Male';

  @override
  String get fitnessFemale => 'Female';

  @override
  String get fitnessSaveChanges => 'SAVE CHANGES';

  @override
  String get fitnessHeight => 'Height';

  @override
  String get fitnessAge => 'Age';

  @override
  String get fitnessRecordSaved => 'Physical record saved successfully';

  @override
  String get fitnessNewRecord => 'New physical record';

  @override
  String get fitnessRecordDate => 'RECORD DATE';

  @override
  String get fitnessSaveRecord => 'SAVE RECORD';

  @override
  String get fitnessCurrentWeight => 'Current weight';

  @override
  String get fitnessBodyFat => 'Body fat';

  @override
  String get fitnessMuscleMass => 'Muscle mass';

  @override
  String get fitnessNoPhysicalRecords => 'No physical records';

  @override
  String get fitnessSelectDay => 'Select a day';

  @override
  String get fitnessAddTodayRecord => 'ADD TODAY\'S RECORD';

  @override
  String get fitnessGoal => 'Goal';

  @override
  String get fitnessYears => 'years';

  @override
  String get fitnessLoadError => 'Could not load physical progress';

  @override
  String get fitnessProfileLoadError => 'Could not load physical profile';

  @override
  String get socialNewPost => 'New post';

  @override
  String get socialPickFromGallery => 'Pick from gallery';

  @override
  String get socialDescriptionOptional => 'Description (optional)';

  @override
  String get socialSelectImageFirst => 'Select an image first';

  @override
  String get socialPostCreated => 'Post created!';

  @override
  String get socialStoryCreated => 'Story created!';

  @override
  String get socialBio => 'Bio';

  @override
  String get socialProfileUpdated => 'Profile updated!';

  @override
  String get socialNoPosts => 'No posts yet';

  @override
  String get socialFeedEmpty => 'Your feed is empty';

  @override
  String get socialFollowOthers => 'Follow other users...';

  @override
  String get socialChallengeFriends => 'Challenge your friends!';

  @override
  String get socialChallengeUser => 'Challenge to a duel!';

  @override
  String get socialNoPostsYet => 'No posts yet';

  @override
  String get socialPickExercise => 'Which exercise do you want to compete in?';

  @override
  String get socialChallengeSent => 'Challenge sent successfully!';

  @override
  String get socialSendChallenge => 'Send Challenge';

  @override
  String get socialNothingToExplore => 'Nothing to explore yet';

  @override
  String get socialPublicPostsHere => 'Public posts will appear here';

  @override
  String get socialUnexpectedError => 'An unexpected error occurred';

  @override
  String get aiLimitReached =>
      'Chat history limit reached. Delete an existing chat to create a new one.';

  @override
  String get aiCopiedToClipboard => 'Copied to clipboard';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiWelcomeSubtitle =>
      'Ask me about routines, nutrition or any fitness questions.';

  @override
  String get aiInputHint => 'Write your message...';

  @override
  String get aiHistoryTitle => 'HISTORY';

  @override
  String get aiNoSavedConversations => 'No saved conversations';

  @override
  String aiMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppPreferences => 'App preferences';

  @override
  String get settingsShareProgress => 'Share progress';

  @override
  String get settingsIntegrations => 'Integrations';

  @override
  String get settingsIntegrationsSoon => 'Integrations coming soon';

  @override
  String get settingsPhysicalData => 'Physical data';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsVersion => 'Version 1.0.0';

  @override
  String get settingsDescription => 'Description';

  @override
  String get settingsAppDescription =>
      'JADA Fit is your smart fitness companion. Create custom routines, track your physical progress, receive AI assistance, and connect with a fitness community.';

  @override
  String get settingsContact => 'Contact';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsTerms => 'Terms and conditions';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'Auto';

  @override
  String get settingsUnits => 'Units';

  @override
  String get settingsImperialUnits => 'Imperial units';

  @override
  String get settingsImperialUnitsDesc => 'Show weight and height in lbs / ft';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAiAssistant => 'AI Assistant';

  @override
  String get settingsAiAssistantDesc => 'Notifications when the AI responds';

  @override
  String get settingsWorkoutReminders => 'Workout reminders';

  @override
  String get settingsWorkoutRemindersDesc => 'Remind to train every day';

  @override
  String get settingsInfo => 'Information';

  @override
  String get settingsAbout => 'About JADA Fit';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSelectLanguage => 'Select language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageEs => 'Spanish';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get aboutTitle => 'About';

  @override
  String get onboardingStart => 'START';

  @override
  String get onboardingSetupFitnessProfile => 'Set up your fitness profile';

  @override
  String get onboardingCurrentWeight => 'Current weight';

  @override
  String get onboardingHeight => 'Height';

  @override
  String get onboardingAge => 'Age';

  @override
  String get onboardingBodyFat => 'Body fat';

  @override
  String get onboardingMuscleMass => 'Muscle mass';

  @override
  String get aiTitle => 'AI Mode';

  @override
  String get aiSubtitle =>
      'Here you will see smart suggestions and personalized recommendations.';

  @override
  String get aiPromptHint =>
      'Ask me about routines, nutrition or any fitness questions.';

  @override
  String get aiSuggestionMacros => 'How are my macros today?';

  @override
  String get aiSuggestionDinner => 'What should I have for dinner?';

  @override
  String get aiSuggestionAnalyze => 'Analyze my nutrition...';

  @override
  String get aiSuggestionAdvice => 'Give me a tip...';

  @override
  String get aiErrorMessage => 'Sorry, an error occurred. Try again.';

  @override
  String get aiWhatElse => 'What else can I do today?';

  @override
  String get aiRecoveryTips => 'Recovery tips';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoading => 'Loading profile...';

  @override
  String get profileError => 'Could not load profile.';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileEditPhysicalData => 'Edit physical data';

  @override
  String get profileYears => 'years';

  @override
  String get profileGender => 'Gender';

  @override
  String get loginTitle => 'SIGN IN';

  @override
  String get loginUserLabel => 'USERNAME';

  @override
  String get loginPasswordLabel => 'PASSWORD';

  @override
  String get loginIdentifierHint => 'EMAIL OR USERNAME';

  @override
  String get loginPasswordHint => 'PASSWORD';

  @override
  String get loginButton => 'LOGIN';

  @override
  String get forgotPasswordPrompt => 'Forgot your password?';

  @override
  String get recoverPasswordSoon => 'Recover password coming soon';

  @override
  String get noAccountPrompt => 'Don\'t have an account? Register';

  @override
  String get registerTitle => 'CREATE ACCOUNT';

  @override
  String get registerNameLabel => 'NAME';

  @override
  String get registerEmailLabel => 'EMAIL';

  @override
  String get registerPasswordLabel => 'PASSWORD';

  @override
  String get registerRepeatPasswordLabel => 'REPEAT PASSWORD';

  @override
  String get registerNameHint => 'YOUR NAME';

  @override
  String get registerEmailHint => 'EMAIL ADDRESS';

  @override
  String get registerPasswordHint => 'PASSWORD';

  @override
  String get registerRepeatPasswordHint => 'REPEAT PASSWORD';

  @override
  String get registerButton => 'REGISTER';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account? Sign in';

  @override
  String get continueWith => 'or continue with';

  @override
  String get errorEnterEmail => 'Enter your email';

  @override
  String get errorInvalidEmail => 'Invalid email';

  @override
  String get errorEnterIdentifier => 'Enter your email or username';

  @override
  String get errorEnterPassword => 'Enter your password';

  @override
  String get errorFixErrors => 'Fix the errors to continue';

  @override
  String get errorFixForm => 'Fix the form errors';

  @override
  String get errorLoginFailed => 'Could not sign in. Try again';

  @override
  String get errorEnterName => 'Enter your name';

  @override
  String get errorEnterRegisterEmail => 'Enter your email';

  @override
  String get errorPasswordMinLength => 'Password must be at least 8 characters';

  @override
  String get errorRepeatPassword => 'Repeat the password';

  @override
  String get errorPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get errorRegisterFailed => 'Could not create account. Try again';

  @override
  String get googleProvider => 'Google';

  @override
  String get appleProvider => 'Apple';

  @override
  String get facebookProvider => 'Facebook';

  @override
  String get sessionNotActive => 'No active session';

  @override
  String get notAuthorized => 'Not authorized. Please sign in again.';

  @override
  String get authPasswordMinLength6 => 'Password must be at least 6 characters';

  @override
  String get authServerError => 'A server error occurred';

  @override
  String get forgotPasswordTitle => 'RESET PASSWORD';

  @override
  String get forgotPasswordEmailLabel => 'EMAIL';

  @override
  String get forgotPasswordEmailHint => 'YOUR EMAIL';

  @override
  String get forgotPasswordButton => 'SEND CODE';

  @override
  String get forgotPasswordSuccess => 'Check your email';

  @override
  String get resetPasswordTitle => 'RESET PASSWORD';

  @override
  String get resetPasswordTokenLabel => 'VERIFICATION CODE';

  @override
  String get resetPasswordTokenHint => 'CODE';

  @override
  String get resetPasswordNewPasswordLabel => 'NEW PASSWORD';

  @override
  String get resetPasswordNewPasswordHint => 'NEW PASSWORD';

  @override
  String get resetPasswordButton => 'CHANGE PASSWORD';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String comingSoonProvider(String provider) {
    return 'Sign in with $provider coming soon';
  }

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get nutritionDeleteMealError => 'Could not delete meal';

  @override
  String get nutritionAddFoodTo => 'ADD FOOD TO...';

  @override
  String get nutritionWaterLogError => 'Error logging water';

  @override
  String get nutritionAddFoodsHint =>
      'Add foods to calculate calories and macros.';

  @override
  String get nutritionWater => 'Water';

  @override
  String get nutritionPhysicalTracking => 'Physical tracking';

  @override
  String get nutritionNoRecordsYet => 'No records yet';

  @override
  String get nutritionAddRecord => 'Add record';

  @override
  String get nutritionViewSummary => 'View summary';

  @override
  String get nutritionWeightLabel => 'Weight';

  @override
  String get nutritionNoFoods => 'No foods';

  @override
  String nutritionFoodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foods',
      one: '1 food',
    );
    return '$_temp0';
  }

  @override
  String get nutritionMyFoodsCard => 'My\nfoods';

  @override
  String get nutritionMyRecipesCard => 'My\nrecipes';

  @override
  String get nutritionMealRegistered => 'Meal registered successfully';

  @override
  String get nutritionCompleteAllFields => 'Complete all fields';

  @override
  String get nutritionRecipeUpdated => 'Recipe updated successfully';

  @override
  String get nutritionRecipeCreated => 'Recipe created successfully';

  @override
  String get nutritionRecipeSaveError => 'Error saving recipe';

  @override
  String get nutritionFoodDeleteError => 'Could not delete food';

  @override
  String nutritionRecipeAddedToMeal(String recipeName, String mealName) {
    return '$recipeName added to $mealName';
  }

  @override
  String nutritionDeleteFoodFromHistory(String foodName) {
    return 'Delete \"$foodName\" from history?';
  }

  @override
  String nutritionDeleteRecipeConfirm(String recipeName) {
    return 'Delete \"$recipeName\"?';
  }

  @override
  String get homeQuickActionScanSubtitle => 'Scan a barcode and find the food';

  @override
  String get homeQuickActionMealSubtitle => 'Add a meal to the current day';

  @override
  String get homeQuickActionPhysicalSubtitle =>
      'Log weight, body fat and muscle mass';

  @override
  String get homeQuickActionRoutineSubtitle => 'Check your current workout';

  @override
  String get homeQuickActionAiSubtitle => 'Get a personalized recommendation';

  @override
  String get socialExplore => 'Explore';

  @override
  String get socialChallenges => 'Challenges';

  @override
  String get socialMyProfile => 'My Profile';

  @override
  String get socialNoActiveChallenges => 'You have no active challenges.';

  @override
  String get socialUpdateMyRecords => 'Update my records';

  @override
  String get socialYourChallenges => 'Your Challenges';

  @override
  String get socialMyRecords => 'My Records';

  @override
  String get socialChallengeAwaitingConfirmation => 'Awaiting confirmation';

  @override
  String get socialReject => 'Reject';

  @override
  String get socialAccept => 'Accept';

  @override
  String get socialChallengeStatusPending => 'PENDING';

  @override
  String get socialChallengeStatusActive => 'ACTIVE';

  @override
  String get socialChallengeStatusRejected => 'REJECTED';

  @override
  String get socialChallengeStatusFinished => 'FINISHED';

  @override
  String get socialUpdatePersonalRecord => 'Update Personal Record';

  @override
  String get socialExerciseHint => 'Exercise (e.g. Bench Press)';

  @override
  String get socialWeightKg => 'Weight (kg)';

  @override
  String get socialRecordUpdated => 'Record updated';

  @override
  String get socialSave => 'Save';

  @override
  String socialChallengeLoadError(String error) {
    return 'Error loading challenges: $error';
  }

  @override
  String socialChallengeUserTitle(String username) {
    return 'Challenge $username';
  }

  @override
  String socialErrorDetails(String error) {
    return 'Error: $error';
  }

  @override
  String socialSearchError(String error) {
    return 'Search error: $error';
  }

  @override
  String get socialTimeAgoNow => 'now';

  @override
  String socialTimeAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String socialTimeAgoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String socialTimeAgoDays(int days) {
    return '${days}d ago';
  }

  @override
  String get socialProfileLoadError => 'Could not load profile';

  @override
  String get onboardingSelectGender => 'Select your gender';

  @override
  String get onboardingSelectGoal => 'Select your goal';

  @override
  String get onboardingEnterAge => 'Enter your age';

  @override
  String get onboardingSetupFailed => 'Could not complete initial setup';

  @override
  String get onboardingGoal => 'Goal';

  @override
  String get fitnessDataUpdated => 'Physical data updated successfully';

  @override
  String get fitnessSelectGenderError => 'Select your gender';

  @override
  String get fitnessUpdateDataError => 'Could not update physical data';

  @override
  String get fitnessRecomposition => 'Body recomposition';

  @override
  String get fitnessSelectOption => 'Select an option';

  @override
  String get fitnessPersonalizeHelp => 'This will help personalize the app';

  @override
  String get fitnessSetupProfile => 'Set up your physical profile';

  @override
  String get fitnessSetupProfileDesc =>
      'This data is used to personalize your goals, recommendations and future analysis.';

  @override
  String get fitnessAddRecordForDay => 'ADD RECORD FOR THIS DAY';

  @override
  String get fitnessPhysicalRecord => 'Physical record';

  @override
  String get fitnessCalendarHint =>
      'Tap a calendar day to view or add physical records.';

  @override
  String get fitnessAddRecordUsingButton =>
      'You can add a record using the button above.';

  @override
  String get fitnessRecordSaveError => 'Could not save physical record';

  @override
  String get fitnessAddPhysicalDataTitle => 'Add physical data';

  @override
  String get fitnessRecordDateHint =>
      'You can log today\'s data or a past date if you forgot to record it.';

  @override
  String get fitnessAutoSaveTime => 'Time will be saved automatically';

  @override
  String get fitnessSwipeChartHint => 'Swipe the chart to change month';

  @override
  String get fitnessAddFirstDataHint =>
      'Add your first physical data to start seeing your progress.';

  @override
  String fitnessRecordSummary(
    String time,
    String weight,
    String bodyFat,
    String muscleMass,
  ) {
    return '$time · $weight · $bodyFat fat · $muscleMass muscle';
  }

  @override
  String get fitnessProfileDataSubtitle => 'Height, age, gender and goal';

  @override
  String get fitnessAddPhysicalRecordTitle => 'Add physical record';

  @override
  String get fitnessHistorySubtitle => 'History and physical progress';

  @override
  String profilePrivacyUpdateError(String error) {
    return 'Error updating privacy: $error';
  }

  @override
  String get profilePhysicalDataSubtitle =>
      'Weight, height, body composition and more';

  @override
  String get workoutRoutineCreated => 'Routine created successfully!';

  @override
  String get workoutDescription => 'Description';

  @override
  String get aiSuggestionDeepDive => 'Go deeper on that topic';

  @override
  String get aiSuggestionWorkout => 'Give me a workout routine';

  @override
  String aiChatTitle(int number) {
    return 'Chat $number';
  }

  @override
  String get sharedAccept => 'Accept';

  @override
  String get socialNewStory => 'New story';

  @override
  String get socialStoryExpires => 'Stories disappear in 24 hours';

  @override
  String get socialPublish => 'Publish';

  @override
  String get socialUploadStory => 'Upload story';

  @override
  String get socialEditProfile => 'Edit profile';

  @override
  String get socialShareProgressCommunity =>
      'Share your progress with the community';
}
