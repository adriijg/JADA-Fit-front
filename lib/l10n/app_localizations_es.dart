// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'JADA FIT';

  @override
  String get homeWelcomeTitle => 'Bienvenido a JADA FIT';

  @override
  String get homeWelcomeSubtitle =>
      'Esta es la pantalla principal. Aquí configuraremos más funciones pronto.';

  @override
  String get navigationHome => 'Inicio';

  @override
  String get navigationNutrition => 'Alimentación';

  @override
  String get navigationAi => 'IA';

  @override
  String get navigationRoutines => 'Rutinas';

  @override
  String get navigationSocial => 'Social';

  @override
  String get homeQuickActions => 'Accesos rápidos';

  @override
  String get homeScanFood => 'Escanear alimento';

  @override
  String get homeLogMeal => 'Registrar comida';

  @override
  String get homeAddPhysicalData => 'Añadir datos físicos';

  @override
  String get homeViewRoutine => 'Ver rutina';

  @override
  String get homeAskAI => 'Preguntar a la IA';

  @override
  String get homeNutritionToday => 'Nutrición de hoy';

  @override
  String get homeCaloriesAndMacrosSummary => 'Resumen de calorías y macros';

  @override
  String get homeConsumed => 'Consumidas';

  @override
  String get homeGoal => 'Objetivo';

  @override
  String get homeRemaining => 'Restantes';

  @override
  String get homeProtein => 'Proteína';

  @override
  String get homeCarbs => 'Carbos';

  @override
  String get homeFats => 'Grasas';

  @override
  String get homeGreeting => 'Hola 👋';

  @override
  String get homeMainPanel =>
      'Este es tu panel principal. Pronto añadiremos más funciones.';

  @override
  String get homeAICoach => 'Coach IA';

  @override
  String get homeAICoachSubtitle =>
      'Toca para recibir una recomendación personalizada.';

  @override
  String get homeConnectWithOthers => 'Conéctate con otros usuarios';

  @override
  String get homeNoRecentActivity => 'Sin actividad reciente';

  @override
  String get homeSocialActivity => 'Actividad social';

  @override
  String get homeWorkoutCardTitle => 'Entrenamiento';

  @override
  String get homeNoRoutine => 'Sin rutina';

  @override
  String homePendingExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios pendientes',
      one: '1 ejercicio pendiente',
    );
    return '$_temp0';
  }

  @override
  String get homeNoPendingExercises => 'Sin ejercicios pendientes';

  @override
  String get homeProgressCardTitle => 'Progreso';

  @override
  String get homeNoProgressData => 'Sin datos';

  @override
  String get homeAddFirstRecord => 'Añade tu primer registro';

  @override
  String homeWeightChangeSinceStart(String weightChange) {
    return '$weightChange desde inicio';
  }

  @override
  String get homeNutritionLoadError =>
      'No se pudo cargar el resumen nutricional';

  @override
  String get nutritionTitle => 'Alimentación';

  @override
  String get nutritionSubtitle =>
      'Aquí verás planes de comidas, recetas y macros personalizados.';

  @override
  String get nutritionCaloriesPer100g => 'Calorías /100g';

  @override
  String get nutritionProteinPer100g => 'Proteína /100g';

  @override
  String get nutritionCalories => 'Calorías';

  @override
  String get nutritionProtein => 'Proteína';

  @override
  String get nutritionRecipesEmpty => 'Todavía no tienes recetas';

  @override
  String get nutritionRecipesSearchEmpty =>
      'Prueba con otro término de búsqueda.';

  @override
  String get nutritionAddToDay => 'Añadir al día';

  @override
  String get nutritionFoodsEmpty => 'Aún no tienes alimentos personalizados';

  @override
  String get nutritionDeleteConfirmation => 'Se eliminará...\n¿Continuar?';

  @override
  String get nutritionAddRecipeError => 'No se pudo añadir la receta';

  @override
  String get nutritionAddToEllipsis => 'Añadir a...';

  @override
  String get nutritionSearchOrScan =>
      'Busca en el catálogo o escanea código de barras';

  @override
  String get nutritionAddManually => 'Añadir manualmente';

  @override
  String get nutritionAddIngredient => 'Añadir ingrediente';

  @override
  String get nutritionAddAtLeastOneIngredient =>
      'Añade al menos un ingrediente';

  @override
  String get nutritionCameraError =>
      'No se pudo iniciar la cámara. Revisa los permisos o la cámara del emulador.';

  @override
  String get nutritionCameraSwitchError => 'No se pudo cambiar de cámara';

  @override
  String get nutritionCameraHint =>
      'Apunta la cámara al código de barras del producto.';

  @override
  String get nutritionCameraStarting => 'Iniciando cámara...';

  @override
  String get nutritionFoodName => 'Nombre del alimento';

  @override
  String get nutritionFoodNameHint => 'Ej: Arroz integral';

  @override
  String get nutritionCarbsPer100g => 'Hidratos /100g';

  @override
  String get nutritionFatPer100g => 'Grasas /100g';

  @override
  String get nutritionCalculatedSummary => 'RESUMEN CALCULADO';

  @override
  String get nutritionCarbs => 'Hidratos';

  @override
  String get nutritionFat => 'Grasas';

  @override
  String get nutritionDeleteRecipe => 'Eliminar receta';

  @override
  String get nutritionCancel => 'Cancelar';

  @override
  String get nutritionDelete => 'Eliminar';

  @override
  String get nutritionErrorDeletingRecipe => 'Error al eliminar la receta';

  @override
  String get nutritionAddRecipeTo => 'AÑADIR RECETA A...';

  @override
  String get nutritionMyRecipes => 'Mis recetas';

  @override
  String get nutritionSearchRecipe => 'Buscar receta...';

  @override
  String get nutritionRetry => 'Reintentar';

  @override
  String get nutritionCreateFirstRecipe => 'Crea tu primera receta';

  @override
  String get nutritionCreateRecipe => 'Crear receta';

  @override
  String get nutritionNoMatchingRecipes => 'No hay recetas que coincidan';

  @override
  String get nutritionDeleteFood => 'Eliminar alimento';

  @override
  String nutritionFoodDeleted(String foodName) {
    return '\"$foodName\" eliminado';
  }

  @override
  String get nutritionCouldNotDelete => 'No se pudo eliminar';

  @override
  String get nutritionMyFoods => 'Mis Alimentos';

  @override
  String get nutritionKcalPer100g => 'Kcal /100g';

  @override
  String get nutritionCreateFood => 'CREAR ALIMENTO';

  @override
  String nutritionFoodDeletedFromHistory(String foodName) {
    return '\"$foodName\" eliminado del historial';
  }

  @override
  String get nutritionSelectFood => 'Seleccionar alimento';

  @override
  String get nutritionNoBrand => 'Sin marca';

  @override
  String get nutritionAddUpper => 'AÑADIR';

  @override
  String get nutritionSearchUpper => 'BUSCAR';

  @override
  String get nutritionAddIngredientTitle => 'AÑADIR INGREDIENTE';

  @override
  String get nutritionSearchFood => 'Buscar alimento';

  @override
  String get nutritionEnterNameAndMacros =>
      'Introduce nombre y macros del alimento';

  @override
  String get nutritionFlashError => 'No se pudo activar el flash';

  @override
  String get nutritionBreakfast => 'Desayuno';

  @override
  String get nutritionLunch => 'Comida';

  @override
  String get nutritionDinner => 'Cena';

  @override
  String get nutritionSnack => 'Snack';

  @override
  String get nutritionBreakfasts => 'Desayunos';

  @override
  String get nutritionLunches => 'Comidas';

  @override
  String get nutritionDinners => 'Cenas';

  @override
  String get nutritionSnacks => 'Snacks';

  @override
  String get nutritionErrorAddingRecipe => 'Error al añadir la receta';

  @override
  String get nutritionSave => 'Guardar';

  @override
  String get nutritionRecipeNameRequired => 'El nombre es obligatorio';

  @override
  String get nutritionRequired => 'Obligatorio';

  @override
  String get nutritionQuantityGrams => 'Cantidad (g)';

  @override
  String get nutritionServings => 'Porciones';

  @override
  String get nutritionTotalRecipe => 'TOTAL RECETA';

  @override
  String get nutritionQuantity => 'Cantidad';

  @override
  String get nutritionCustom => 'Personalizado';

  @override
  String get nutritionCustomFood => 'Alimento personalizado';

  @override
  String get nutritionSearchFoodHint => 'Buscar alimento, ej: Nutella';

  @override
  String get nutritionFoodNameShort => 'Nombre';

  @override
  String get workoutRoutineUpdated => '¡Rutina actualizada!';

  @override
  String get workoutEditRoutine => 'Editar Rutina';

  @override
  String get workoutNewRoutine => 'Nueva Rutina';

  @override
  String get workoutDetails => 'Detalles';

  @override
  String get workoutName => 'Nombre';

  @override
  String get workoutNameHint => 'Ej. Push Day / Pierna / Full Body';

  @override
  String get workoutClose => 'CERRAR';

  @override
  String get workoutSuggestions => 'SUGERENCIAS';

  @override
  String get workoutAdd => 'AÑADIR';

  @override
  String get workoutTapExercise => 'Toca un ejercicio...';

  @override
  String get workoutStartAddingExercises => '¡Empieza a añadir ejercicios!';

  @override
  String get workoutDeleteRoutine => '¿Eliminar rutina?';

  @override
  String workoutDeleteRoutineConfirm(String routineName) {
    return 'Se eliminará \"$routineName\"...';
  }

  @override
  String get workoutRoutineCompleted => '¡Rutina completada!';

  @override
  String get workoutNoResults => 'Sin resultados';

  @override
  String get workoutFullBody => 'Full Body';

  @override
  String get workoutPush => 'Empuje (Push)';

  @override
  String get workoutPull => 'Tirón (Pull)';

  @override
  String get workoutLegs => 'Piernas';

  @override
  String get workoutTorso => 'Torso';

  @override
  String get workoutUpperBody => 'Upper Body';

  @override
  String get workoutLowerBody => 'Lower Body';

  @override
  String get workoutFullBodyDesc => 'Todo el cuerpo en una sesión';

  @override
  String get workoutPushDesc => 'Pecho, hombros y tríceps';

  @override
  String get workoutPullDesc => 'Espalda y bíceps';

  @override
  String get workoutLegsDesc => 'Cuádriceps, isquiotibiales y glúteos';

  @override
  String get workoutTorsoDesc => 'Pecho, espalda y hombros';

  @override
  String get workoutUpperBodyDesc => 'Sesión enfocada en tren superior';

  @override
  String get workoutLowerBodyDesc => 'Sesión enfocada en tren inferior';

  @override
  String get workoutStrength => 'FUERZA';

  @override
  String get workoutVolume => 'VOLUMEN';

  @override
  String get workoutEndurance => 'RESISTENCIA';

  @override
  String get workoutDefinition => 'DEFINICIÓN';

  @override
  String get workoutStrengthDesc =>
      'Maximizar tu fuerza con cargas altas y bajas repeticiones';

  @override
  String get workoutVolumeDesc =>
      'Aumentar masa muscular con cargas moderadas y volumen';

  @override
  String get workoutEnduranceDesc =>
      'Mejorar resistencia muscular con cargas ligeras y altas repeticiones';

  @override
  String get workoutDefinitionDesc =>
      'Definir tu físico con intensidad controlada';

  @override
  String get workoutTimer => 'Temporizador';

  @override
  String get workoutReps => 'Repeticiones';

  @override
  String get workoutRest => 'Descanso';

  @override
  String get workoutRoutinesEmpty => 'Aún no hay rutinas';

  @override
  String get workoutNoRoutinesFound => 'No encontramos rutinas';

  @override
  String get workoutDesignFirstRoutine => 'Diseña tu primera rutina';

  @override
  String get workoutExerciseLibrary => 'Biblioteca de Ejercicios';

  @override
  String get workoutSearchExercise => 'Buscar ejercicio...';

  @override
  String get workoutFilterAll => 'Todas';

  @override
  String get workoutFilterBodyweight => 'Sin peso';

  @override
  String get workoutNoExercisesFound => 'No se encontraron ejercicios';

  @override
  String get workoutWhatIsItFor => '¿Para qué sirve?';

  @override
  String get workoutMainBenefits => 'Beneficios Principales';

  @override
  String get workoutCouldNotLoadVideo => 'No se pudo cargar el video.';

  @override
  String workoutExerciseBenefitsTemplate(String muscleGroup) {
    return 'Fortalece y desarrolla los $muscleGroup. Ideal para mejorar el rendimiento y la estética muscular.';
  }

  @override
  String get fitnessProgress => 'Progreso físico';

  @override
  String get fitnessStats => 'Estadísticas físicas';

  @override
  String get fitnessMuscle => 'Músculo';

  @override
  String get fitnessWeightEvolution => 'Evolución de peso';

  @override
  String get fitnessAddRecord => 'AÑADIR REGISTRO FÍSICO';

  @override
  String get fitnessMin => 'Mínimo';

  @override
  String get fitnessMax => 'Máximo';

  @override
  String get fitnessNeedTwoRecords =>
      'Necesitas al menos 2 registros para ver la gráfica';

  @override
  String get fitnessNoRecordsThisDay => 'No hay registros para este día';

  @override
  String get fitnessNoProgressData => 'Todavía no hay datos de progreso';

  @override
  String get fitnessAddFirstRecord => 'AÑADIR PRIMER REGISTRO';

  @override
  String get fitnessGainMuscle => 'Ganar músculo';

  @override
  String get fitnessLoseFat => 'Perder grasa';

  @override
  String get fitnessStayAthletic => 'Mantenerse atlético/a';

  @override
  String get fitnessPhysicalProfile => 'Perfil físico';

  @override
  String get fitnessPhysicalData => 'Datos físicos';

  @override
  String get fitnessGender => 'Género';

  @override
  String get fitnessEditPhysicalData => 'Editar datos físicos';

  @override
  String get fitnessViewStats => 'Ver estadísticas';

  @override
  String get fitnessNotConfigured => 'Sin configurar';

  @override
  String get fitnessEnterHeightAge => 'Introduce tu altura y edad';

  @override
  String get fitnessSelectGenderGoal => 'Selecciona tu género y objetivo';

  @override
  String get fitnessMale => 'Hombre';

  @override
  String get fitnessFemale => 'Mujer';

  @override
  String get fitnessSaveChanges => 'GUARDAR CAMBIOS';

  @override
  String get fitnessHeight => 'Altura';

  @override
  String get fitnessAge => 'Edad';

  @override
  String get fitnessRecordSaved => 'Registro físico guardado correctamente';

  @override
  String get fitnessNewRecord => 'Nuevo registro físico';

  @override
  String get fitnessRecordDate => 'FECHA DEL REGISTRO';

  @override
  String get fitnessSaveRecord => 'GUARDAR REGISTRO';

  @override
  String get fitnessCurrentWeight => 'Peso actual';

  @override
  String get fitnessBodyFat => 'Grasa corporal';

  @override
  String get fitnessMuscleMass => 'Masa muscular';

  @override
  String get fitnessNoPhysicalRecords => 'Sin registros físicos';

  @override
  String get fitnessSelectDay => 'Selecciona un día';

  @override
  String get fitnessAddTodayRecord => 'AÑADIR REGISTRO DE HOY';

  @override
  String get fitnessGoal => 'Objetivo';

  @override
  String get fitnessYears => 'años';

  @override
  String get fitnessLoadError => 'No se pudo cargar el progreso físico';

  @override
  String get fitnessProfileLoadError => 'No se pudo cargar el perfil físico';

  @override
  String get socialNewPost => 'Nueva publicación';

  @override
  String get socialPickFromGallery => 'Seleccionar de la galería';

  @override
  String get socialDescriptionOptional => 'Descripción (opcional)';

  @override
  String get socialSelectImageFirst => 'Selecciona una imagen primero';

  @override
  String get socialPostCreated => '¡Publicación creada!';

  @override
  String get socialStoryCreated => '¡Historia creada!';

  @override
  String get socialBio => 'Biografía';

  @override
  String get socialProfileUpdated => '¡Perfil actualizado!';

  @override
  String get socialNoPosts => 'Aún no tienes publicaciones';

  @override
  String get socialFeedEmpty => 'Tu feed está vacío';

  @override
  String get socialFollowOthers => 'Sigue a otros usuarios...';

  @override
  String get socialChallengeFriends => '¡Desafía a tus amigos!';

  @override
  String get socialChallengeUser => '¡Desafiar a un pique!';

  @override
  String get socialNoPostsYet => 'Aún no hay publicaciones';

  @override
  String get socialPickExercise => '¿En qué ejercicio quieres competir?';

  @override
  String get socialChallengeSent => '¡Desafío enviado con éxito!';

  @override
  String get socialSendChallenge => 'Enviar Desafío';

  @override
  String get socialNothingToExplore => 'Nada que explorar aún';

  @override
  String get socialPublicPostsHere =>
      'Las publicaciones públicas aparecerán aquí';

  @override
  String get socialUnexpectedError => 'Ocurrió un error inesperado';

  @override
  String get aiLimitReached =>
      'Límite de historial de chat alcanzado. Elimina un chat existente para crear uno nuevo.';

  @override
  String get aiCopiedToClipboard => 'Copiado al portapapeles';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get aiWelcomeSubtitle =>
      'Pregúntame sobre rutinas, nutrición o cualquier duda fitness.';

  @override
  String get aiInputHint => 'Escribe tu mensaje...';

  @override
  String get aiHistoryTitle => 'HISTORIAL';

  @override
  String get aiNoSavedConversations => 'No hay conversaciones guardadas';

  @override
  String aiMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppPreferences => 'Preferencias de la aplicación';

  @override
  String get settingsShareProgress => 'Compartir progreso';

  @override
  String get settingsIntegrations => 'Integraciones';

  @override
  String get settingsIntegrationsSoon => 'Integraciones próximamente';

  @override
  String get settingsPhysicalData => 'Datos físicos';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsVersion => 'Versión 1.0.0';

  @override
  String get settingsDescription => 'Descripción';

  @override
  String get settingsAppDescription =>
      'JADA Fit es tu compañero de fitness inteligente. Crea rutinas personalizadas, sigue tu progreso físico, recibe asistencia con IA y conecta con una comunidad fitness.';

  @override
  String get settingsContact => 'Contacto';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsTerms => 'Términos y condiciones';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Auto';

  @override
  String get settingsUnits => 'Unidades';

  @override
  String get settingsImperialUnits => 'Unidades imperiales';

  @override
  String get settingsImperialUnitsDesc => 'Mostrar peso y altura en lbs / ft';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsAiAssistant => 'Asistente IA';

  @override
  String get settingsAiAssistantDesc => 'Notificaciones cuando la IA responda';

  @override
  String get settingsWorkoutReminders => 'Recordatorio de entrenos';

  @override
  String get settingsWorkoutRemindersDesc => 'Recordar entrenar cada día';

  @override
  String get settingsInfo => 'Información';

  @override
  String get settingsAbout => 'Acerca de JADA Fit';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSelectLanguage => 'Seleccionar idioma';

  @override
  String get settingsLanguageEn => 'Inglés';

  @override
  String get settingsLanguageEs => 'Español';

  @override
  String get settingsLanguageSystem => 'Por defecto del sistema';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get onboardingStart => 'EMPEZAR';

  @override
  String get onboardingSetupFitnessProfile => 'Configura tu perfil fitness';

  @override
  String get onboardingCurrentWeight => 'Peso actual';

  @override
  String get onboardingHeight => 'Altura';

  @override
  String get onboardingAge => 'Edad';

  @override
  String get onboardingBodyFat => 'Grasa corporal';

  @override
  String get onboardingMuscleMass => 'Masa muscular';

  @override
  String get aiTitle => 'Modo IA';

  @override
  String get aiSubtitle =>
      'Aquí aparecerán sugerencias inteligentes y recomendaciones personalizadas.';

  @override
  String get aiPromptHint =>
      'Pregúntame sobre rutinas, nutrición o cualquier duda fitness.';

  @override
  String get aiSuggestionMacros => '¿Cómo voy con mis macros hoy?';

  @override
  String get aiSuggestionDinner => '¿Qué debería cenar?';

  @override
  String get aiSuggestionAnalyze => 'Analiza mi nutrición...';

  @override
  String get aiSuggestionAdvice => 'Dame un consejo...';

  @override
  String get aiErrorMessage => 'Lo siento, ocurrió un error. Intenta de nuevo.';

  @override
  String get aiWhatElse => '¿Qué más puedo hacer hoy?';

  @override
  String get aiRecoveryTips => 'Consejos de recuperación';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileLoading => 'Cargando perfil...';

  @override
  String get profileError => 'No se pudo cargar el perfil.';

  @override
  String get profileNameLabel => 'Nombre';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileEditPhysicalData => 'Editar datos físicos';

  @override
  String get profileYears => 'años';

  @override
  String get profileGender => 'Género';

  @override
  String get profileUserLabel => 'Usuario';

  @override
  String get profileAccountCreated => 'Cuenta creada';

  @override
  String get profileNotAvailable => 'No disponible';

  @override
  String get profileShareActivityDescription =>
      'Permitir a otros ver tu actividad';

  @override
  String get profileLogoutDescription => 'Salir de tu cuenta';

  @override
  String get profileUpdateError => 'No se pudo actualizar el perfil';

  @override
  String get profileWeightHint => 'Ej: 78.5';

  @override
  String get profileWeightSuffix => 'kg';

  @override
  String get profileHeightHint => 'Ej: 180';

  @override
  String get profileHeightSuffix => 'cm';

  @override
  String get profileGoalHint => 'Ej: ganar masa muscular';

  @override
  String get profileBodyFatHint => 'Ej: 15.2';

  @override
  String get profileBodyFatSuffix => '%';

  @override
  String get profileMuscleMassHint => 'Ej: 62';

  @override
  String get profileSelectDateOfBirth => 'Selecciona tu fecha de nacimiento';

  @override
  String get profileDateOfBirth => 'Fecha de nacimiento';

  @override
  String get loginTitle => 'INICIAR SESIÓN';

  @override
  String get loginUserLabel => 'USUARIO';

  @override
  String get loginPasswordLabel => 'CONTRASEÑA';

  @override
  String get loginIdentifierHint => 'EMAIL O USUARIO';

  @override
  String get loginPasswordHint => 'PASSWORD';

  @override
  String get loginButton => 'ENTRAR';

  @override
  String get forgotPasswordPrompt => '¿Has olvidado la contraseña?';

  @override
  String get recoverPasswordSoon => 'Recuperar contraseña próximamente';

  @override
  String get noAccountPrompt => '¿No tienes cuenta? Regístrate';

  @override
  String get registerTitle => 'CREAR CUENTA';

  @override
  String get registerNameLabel => 'NOMBRE';

  @override
  String get registerEmailLabel => 'EMAIL';

  @override
  String get registerPasswordLabel => 'CONTRASEÑA';

  @override
  String get registerRepeatPasswordLabel => 'REPETIR CONTRASEÑA';

  @override
  String get registerNameHint => 'TU NOMBRE';

  @override
  String get registerEmailHint => 'EMAIL ADDRESS';

  @override
  String get registerPasswordHint => 'PASSWORD';

  @override
  String get registerRepeatPasswordHint => 'REPEAT PASSWORD';

  @override
  String get registerButton => 'REGISTRARME';

  @override
  String get alreadyHaveAccountPrompt => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get continueWith => 'o continúa con';

  @override
  String get errorEnterEmail => 'Introduce tu email';

  @override
  String get errorInvalidEmail => 'Email no válido';

  @override
  String get errorEnterIdentifier => 'Introduce tu email o usuario';

  @override
  String get errorEnterPassword => 'Introduce tu contraseña';

  @override
  String get errorFixErrors => 'Corrige los errores para continuar';

  @override
  String get errorFixForm => 'Corrige los errores del formulario';

  @override
  String get errorLoginFailed => 'No se pudo iniciar sesión. Intenta de nuevo';

  @override
  String get errorEnterName => 'Introduce tu nombre';

  @override
  String get errorEnterRegisterEmail => 'Introduce tu email';

  @override
  String get errorPasswordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get errorRepeatPassword => 'Repite la contraseña';

  @override
  String get errorPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get accountCreated => 'Cuenta creada correctamente';

  @override
  String get errorRegisterFailed =>
      'No se pudo crear la cuenta. Intenta de nuevo';

  @override
  String get googleProvider => 'Google';

  @override
  String get appleProvider => 'Apple';

  @override
  String get facebookProvider => 'Facebook';

  @override
  String get sessionNotActive => 'No hay sesión activa';

  @override
  String get notAuthorized => 'No autorizado. Vuelve a iniciar sesión.';

  @override
  String get authPasswordMinLength6 =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authServerError => 'Ocurrió un error en el servidor';

  @override
  String get forgotPasswordTitle => 'RESTABLECER CONTRASEÑA';

  @override
  String get forgotPasswordEmailLabel => 'EMAIL';

  @override
  String get forgotPasswordEmailHint => 'TU EMAIL';

  @override
  String get forgotPasswordButton => 'ENVIAR CÓDIGO';

  @override
  String get forgotPasswordSuccess => 'Revisa tu correo electrónico';

  @override
  String get resetPasswordTitle => 'RESTABLECER CONTRASEÑA';

  @override
  String get resetPasswordTokenLabel => 'CÓDIGO DE VERIFICACIÓN';

  @override
  String get resetPasswordTokenHint => 'CÓDIGO';

  @override
  String get resetPasswordNewPasswordLabel => 'NUEVA CONTRASEÑA';

  @override
  String get resetPasswordNewPasswordHint => 'NUEVA CONTRASEÑA';

  @override
  String get resetPasswordButton => 'CAMBIAR CONTRASEÑA';

  @override
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String comingSoonProvider(String provider) {
    return 'Inicio con $provider próximamente';
  }

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String get dateTomorrow => 'Mañana';

  @override
  String get nutritionDeleteMealError => 'No se pudo eliminar la comida';

  @override
  String get nutritionAddFoodTo => 'AÑADIR ALIMENTO A...';

  @override
  String get nutritionWaterLogError => 'Error al registrar agua';

  @override
  String get nutritionAddFoodsHint =>
      'Añade alimentos para calcular calorías y macros.';

  @override
  String get nutritionWater => 'Agua';

  @override
  String get nutritionPhysicalTracking => 'Seguimiento Físico';

  @override
  String get nutritionNoRecordsYet => 'Aún no hay registros';

  @override
  String get nutritionAddRecord => 'Añadir registro';

  @override
  String get nutritionViewSummary => 'Ver resumen';

  @override
  String get nutritionWeightLabel => 'Peso';

  @override
  String get nutritionNoFoods => 'Sin alimentos';

  @override
  String nutritionFoodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alimentos',
      one: '1 alimento',
    );
    return '$_temp0';
  }

  @override
  String get nutritionMyFoodsCard => 'Mis\nalimentos';

  @override
  String get nutritionMyRecipesCard => 'Mis\nrecetas';

  @override
  String get nutritionMealRegistered => 'Comida registrada correctamente';

  @override
  String get nutritionCompleteAllFields => 'Completa todos los campos';

  @override
  String get nutritionRecipeUpdated => 'Receta actualizada correctamente';

  @override
  String get nutritionRecipeCreated => 'Receta creada correctamente';

  @override
  String get nutritionRecipeSaveError => 'Error al guardar la receta';

  @override
  String get nutritionFoodDeleteError => 'No se pudo eliminar el alimento';

  @override
  String nutritionRecipeAddedToMeal(String recipeName, String mealName) {
    return '$recipeName añadida a $mealName';
  }

  @override
  String nutritionDeleteFoodFromHistory(String foodName) {
    return '¿Eliminar \"$foodName\" del historial?';
  }

  @override
  String nutritionDeleteRecipeConfirm(String recipeName) {
    return '¿Eliminar \"$recipeName\"?';
  }

  @override
  String get homeQuickActionScanSubtitle =>
      'Lee un código de barras y busca el alimento';

  @override
  String get homeQuickActionMealSubtitle => 'Añade una comida al día actual';

  @override
  String get homeQuickActionPhysicalSubtitle =>
      'Registra peso, grasa corporal y masa muscular';

  @override
  String get homeQuickActionRoutineSubtitle =>
      'Consulta tu entrenamiento actual';

  @override
  String get homeQuickActionAiSubtitle =>
      'Recibe una recomendación personalizada';

  @override
  String get socialExplore => 'Explorar';

  @override
  String get socialChallenges => 'Piques';

  @override
  String get socialMyProfile => 'Mi Perfil';

  @override
  String get socialNoActiveChallenges => 'No tienes piques activos.';

  @override
  String get socialUpdateMyRecords => 'Actualizar mis marcas';

  @override
  String get socialYourChallenges => 'Tus Piques';

  @override
  String get socialMyRecords => 'Mis Marcas';

  @override
  String get socialChallengeAwaitingConfirmation => 'Pendiente de confirmación';

  @override
  String get socialDeleteStory => 'Eliminar historia';

  @override
  String get socialDeleteStoryConfirm => '¿Eliminar esta historia?';

  @override
  String get socialDeletePost => 'Eliminar publicación';

  @override
  String get socialDeletePostConfirm => '¿Eliminar esta publicación?';

  @override
  String get socialDeletePostSuccess => 'Publicación eliminada';

  @override
  String socialDeletePostError(Object error) {
    return 'Error al eliminar publicación: $error';
  }

  @override
  String get socialReject => 'Rechazar';

  @override
  String get socialAccept => 'Aceptar';

  @override
  String get socialPostDetail => 'Publicación';

  @override
  String get socialComments => 'Comentarios';

  @override
  String get socialNoCommentsYet => 'No hay comentarios todavía';

  @override
  String get socialAddCommentHint => 'Añadir un comentario...';

  @override
  String get socialChallengeStatusPending => 'PENDIENTE';

  @override
  String get socialChallengeStatusActive => 'ACTIVO';

  @override
  String get socialChallengeStatusRejected => 'RECHAZADO';

  @override
  String get socialChallengeStatusFinished => 'FINALIZADO';

  @override
  String get socialUpdatePersonalRecord => 'Actualizar Marca Personal';

  @override
  String get socialExerciseHint => 'Ejercicio (ej: Press Banca)';

  @override
  String get socialWeightKg => 'Peso (kg)';

  @override
  String get socialRecordUpdated => 'Marca actualizada';

  @override
  String get socialSave => 'Guardar';

  @override
  String socialChallengeLoadError(String error) {
    return 'Error al cargar piques: $error';
  }

  @override
  String socialChallengeUserTitle(String username) {
    return 'Desafiar a $username';
  }

  @override
  String socialErrorDetails(String error) {
    return 'Error: $error';
  }

  @override
  String socialSearchError(String error) {
    return 'Error al buscar: $error';
  }

  @override
  String get socialTimeAgoNow => 'ahora';

  @override
  String socialTimeAgoMinutes(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String socialTimeAgoHours(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String socialTimeAgoDays(int days) {
    return 'hace ${days}d';
  }

  @override
  String get socialProfileLoadError => 'Error al cargar perfil';

  @override
  String get onboardingSelectGender => 'Selecciona tu género';

  @override
  String get onboardingSelectGoal => 'Selecciona tu objetivo';

  @override
  String get onboardingEnterAge => 'Introduce tu edad';

  @override
  String get onboardingSetupFailed =>
      'No se pudo completar la configuración inicial';

  @override
  String get onboardingGoal => 'Objetivo';

  @override
  String get fitnessDataUpdated => 'Datos físicos actualizados correctamente';

  @override
  String get fitnessSelectGenderError => 'Selecciona tu género';

  @override
  String get fitnessUpdateDataError =>
      'No se pudieron actualizar los datos físicos';

  @override
  String get fitnessRecomposition => 'Recomposición corporal';

  @override
  String get fitnessSelectOption => 'Selecciona una opción';

  @override
  String get fitnessPersonalizeHelp => 'Esto ayudará a personalizar la app';

  @override
  String get fitnessSetupProfile => 'Configura tu perfil físico';

  @override
  String get fitnessSetupProfileDesc =>
      'Estos datos sirven para personalizar tus objetivos, recomendaciones y futuros análisis.';

  @override
  String get fitnessAddRecordForDay => 'AÑADIR REGISTRO PARA ESTE DÍA';

  @override
  String get fitnessPhysicalRecord => 'Registro físico';

  @override
  String get fitnessCalendarHint =>
      'Pulsa un día del calendario para ver o añadir registros físicos.';

  @override
  String get fitnessAddRecordUsingButton =>
      'Puedes añadir un registro usando el botón superior.';

  @override
  String get fitnessRecordSaveError => 'No se pudo guardar el registro físico';

  @override
  String get fitnessAddPhysicalDataTitle => 'Añadir datos físicos';

  @override
  String get fitnessRecordDateHint =>
      'Puedes registrar datos de hoy o de una fecha anterior si se te olvidó apuntarlos.';

  @override
  String get fitnessAutoSaveTime => 'La hora se guardará automáticamente';

  @override
  String get fitnessSwipeChartHint => 'Desliza la gráfica para cambiar de mes';

  @override
  String get fitnessAddFirstDataHint =>
      'Añade tus primeros datos físicos para empezar a ver tu evolución.';

  @override
  String fitnessRecordSummary(
    String time,
    String weight,
    String bodyFat,
    String muscleMass,
  ) {
    return '$time · $weight · $bodyFat grasa · $muscleMass músculo';
  }

  @override
  String get fitnessProfileDataSubtitle => 'Altura, edad, género y objetivo';

  @override
  String get fitnessAddPhysicalRecordTitle => 'Añadir registro físico';

  @override
  String get fitnessAddPhysicalRecordSubtitle =>
      'Registra peso, grasa corporal y masa muscular';

  @override
  String get fitnessHistorySubtitle => 'Histórico y progreso físico';

  @override
  String fitnessProfileUpdatedAt(String dateTime) {
    return 'Actualizado: $dateTime';
  }

  @override
  String get fitnessWeightLabel => 'Peso';

  @override
  String get fitnessFatLabel => 'Grasa';

  @override
  String get fitnessEnterWeight => 'Introduce tu peso actual';

  @override
  String get fitnessWeightPositiveError => 'El peso debe ser mayor que 0';

  @override
  String get fitnessFatNegativeError =>
      'La grasa corporal no puede ser negativa';

  @override
  String get fitnessMuscleNegativeError =>
      'La masa muscular no puede ser negativa';

  @override
  String get fitnessFutureDateError =>
      'No puedes registrar datos en una fecha futura';

  @override
  String get fitnessEnterHeight => 'Introduce tu altura';

  @override
  String get fitnessHeightPositiveError => 'La altura debe ser mayor que 0';

  @override
  String get fitnessEnterBirthDate => 'Introduce tu fecha de nacimiento';

  @override
  String get fitnessSelectGoalPrompt => 'Selecciona tu objetivo';

  @override
  String get fitnessImprovePerformance => 'Mejorar rendimiento';

  @override
  String get fitnessViewMonthlyCalendar => 'Ver calendario mensual';

  @override
  String get fitnessCalendarWeekly => 'Calendario semanal';

  @override
  String get fitnessCalendarMonthly => 'Calendario mensual';

  @override
  String get fitnessWeightSubtitle =>
      'Peso registrado durante el mes seleccionado';

  @override
  String get fitnessFatSubtitle =>
      'Porcentaje de grasa durante el mes seleccionado';

  @override
  String get fitnessMuscleSubtitle =>
      'Masa muscular durante el mes seleccionado';

  @override
  String fitnessTotalChange(String value) {
    return 'Cambio total: $value';
  }

  @override
  String fitnessRecordsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros guardados',
      one: '1 registro guardado',
    );
    return '$_temp0';
  }

  @override
  String get fitnessCurrentLabel => 'Actual';

  @override
  String get fitnessChangeLabel => 'Cambio';

  @override
  String fitnessWeekOfRange(String start, String end) {
    return 'Semana del $start al $end';
  }

  @override
  String get fitnessOnboardingDescription =>
      'Usaremos estos datos para personalizar tus recomendaciones, objetivos y progreso.';

  @override
  String get fitnessEnterWeightOnboarding => 'Introduce tu peso';

  @override
  String profilePrivacyUpdateError(String error) {
    return 'Error al actualizar privacidad: $error';
  }

  @override
  String get profilePhysicalDataSubtitle =>
      'Peso, altura, composición corporal y más';

  @override
  String get workoutRoutineCreated => '¡Rutina creada con éxito!';

  @override
  String get workoutDescription => 'Descripción';

  @override
  String get aiSuggestionDeepDive => 'Profundiza en ese tema';

  @override
  String get aiSuggestionWorkout => 'Dame una rutina de ejercicios';

  @override
  String aiChatTitle(int number) {
    return 'Chat $number';
  }

  @override
  String get sharedAccept => 'Aceptar';

  @override
  String get socialNewStory => 'Nueva historia';

  @override
  String get socialStoryExpires => 'Las historias desaparecen en 24 horas';

  @override
  String get socialPublish => 'Publicar';

  @override
  String get socialUploadStory => 'Subir historia';

  @override
  String get socialEditProfile => 'Editar perfil';

  @override
  String get socialShareProgressCommunity =>
      'Comparte tu progreso con la comunidad';

  @override
  String socialLikeSuccess(String username) {
    return 'Le has dado me gusta a $username';
  }

  @override
  String socialLikeError(String error) {
    return 'No se pudo actualizar el me gusta: $error';
  }

  @override
  String get socialSendTo => 'Enviar a';

  @override
  String get socialNoFollowing => 'Todavía no sigues a ningún usuario';

  @override
  String socialPostSent(String username) {
    return 'Publicación enviada a $username';
  }

  @override
  String get socialLoadFollowingError => 'No se pudieron cargar tus seguidos';

  @override
  String get socialFollowers => 'Seguidores';

  @override
  String get socialFollowing => 'Siguiendo';

  @override
  String get socialFollow => 'Seguir';

  @override
  String get socialUnfollow => 'Dejar de seguir';

  @override
  String get socialProgressShared => 'Este usuario comparte su progreso';

  @override
  String get socialProgressPrivate => 'Progreso privado';

  @override
  String get socialPosts => 'Publicaciones';

  @override
  String get socialChallengeExpired => 'Expirado';

  @override
  String get socialAddProgressToday => 'Añadir avance de hoy';

  @override
  String get socialProgressToday => 'Avance de hoy';

  @override
  String get socialWeightTodayHint => 'Peso conseguido hoy (kg)';

  @override
  String socialGoalReach(String weight) {
    return 'Objetivo: alcanzar $weight kg';
  }

  @override
  String socialWinnerLabel(String username) {
    return 'Ganador: $username';
  }

  @override
  String socialWinnerYouLabel(String username) {
    return 'Ganador: $username (tú)';
  }

  @override
  String get socialLastProgressSync => 'Últimos avances sincronizados';

  @override
  String get socialProgressSavedWon => 'Avance guardado. Has ganado el pique.';

  @override
  String get socialProgressSaved => 'Avance guardado y sincronizado.';

  @override
  String get socialSaveProgress => 'Guardar avance';

  @override
  String socialChallengeExpiresIn(String time) {
    return 'Expira en $time';
  }

  @override
  String get socialChallengeDeleteExpired => 'Eliminar expirados';

  @override
  String get socialChallengeConfirmDeleteExpired =>
      '¿Eliminar todos los piques expirados?';

  @override
  String get socialChallengeNoExpired => 'No hay piques expirados';

  @override
  String get workoutMyPlans => 'Tus planes de entrenamiento';

  @override
  String get workoutRoutines => 'RUTINAS';

  @override
  String get workoutCompleted => 'COMPLETADAS';

  @override
  String get workoutAll => 'TODOS';

  @override
  String get workoutInProgress => 'En progreso';

  @override
  String workoutExercisesCount(int count) {
    return '$count ejercicios';
  }

  @override
  String get workoutCompleteRoutine => 'Completar rutina';

  @override
  String get workoutNoExercises => 'Esta rutina no tiene ejercicios';

  @override
  String get workoutObjective => 'Objetivo';

  @override
  String get workoutRoutineType => 'Tipo de rutina';

  @override
  String get workoutSelectObjective => 'Selecciona un objetivo';

  @override
  String get workoutSelectRoutineType => 'Selecciona el tipo de rutina';

  @override
  String get workoutAdditionalNotes => 'Notas adicionales...';

  @override
  String get workoutExercises => 'Ejercicios';

  @override
  String workoutSuggestedExercises(String goal) {
    return 'Ejercicios sugeridos para $goal';
  }

  @override
  String get workoutTrySuggested =>
      'o prueba ejercicios sugeridos para tu objetivo';

  @override
  String get workoutSets => 'Series';

  @override
  String get workoutSeconds => 'Segundos';

  @override
  String get workoutSaveChanges => 'GUARDAR CAMBIOS';

  @override
  String get workoutSaveRoutine => 'GUARDAR RUTINA';

  @override
  String get workoutRoutineNameHint => 'Ej. Empuje, Piernas, Full Body...';

  @override
  String get workoutExerciseNameHint => 'Ej. Press de Banca';

  @override
  String get workoutRequired => 'Requerido';

  @override
  String get workoutSearchRoutines => 'Buscar rutinas...';

  @override
  String get workoutCompletedSection => 'Completadas';

  @override
  String get workoutDeleteRoutineError => 'No se pudo eliminar la rutina';

  @override
  String get workoutCompleteRoutineError => 'No se pudo completar la rutina';

  @override
  String get workoutRoutinesLoadError => 'No se pudieron cargar las rutinas';

  @override
  String get workoutSelectObjectiveError =>
      'Selecciona un objetivo para la rutina';

  @override
  String get workoutCreateRoutineError => 'No se pudo crear la rutina';

  @override
  String get workoutUpdateRoutineError => 'No se pudo actualizar la rutina';

  @override
  String get workoutRoutineCompletedLabel => 'Completada';

  @override
  String get workoutExercise => 'Ejercicio';

  @override
  String get socialSearchUsers => 'Buscar usuarios...';

  @override
  String get socialNoUsersFound => 'No se encontraron usuarios';

  @override
  String get socialCancel => 'Cancelar';

  @override
  String socialLoadCommentsError(String error) {
    return 'Error al cargar comentarios: $error';
  }

  @override
  String socialSendCommentError(String error) {
    return 'Error al enviar comentario: $error';
  }

  @override
  String socialDeleteStoryError(String error) {
    return 'Error al eliminar historia: $error';
  }

  @override
  String get socialStoryLoadError => 'No se pudo cargar la historia';

  @override
  String get socialUserFallback => 'Usuario';

  @override
  String get socialMyPosts => 'Mis publicaciones';

  @override
  String get weekdayMon => 'L';

  @override
  String get weekdayTue => 'M';

  @override
  String get weekdayWed => 'X';

  @override
  String get weekdayThu => 'J';

  @override
  String get weekdayFri => 'V';

  @override
  String get weekdaySat => 'S';

  @override
  String get weekdaySun => 'D';
}
