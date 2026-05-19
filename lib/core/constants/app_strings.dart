class AppStrings {
  AppStrings._();

  static const appName = 'JADA FIT';

  // Home
  static const homeWelcomeTitle = 'Bienvenido a JADA FIT';
  static const homeWelcomeSubtitle = 'Esta es la pantalla principal. Aquí configuraremos más funciones pronto.';
  static const navigationHome = 'Inicio';
  static const navigationNutrition = 'Alimentación';
  static const navigationAi = 'IA';
  static const navigationRoutines = 'Rutinas';
  static const navigationSocial = 'Social';

  static const nutritionTitle = 'Alimentación';
  static const nutritionSubtitle = 'Aquí verás planes de comidas, recetas y macros personalizados.';

  static const aiTitle = 'Modo IA';
  static const aiSubtitle = 'Aquí aparecerán sugerencias inteligentes y recomendaciones personalizadas.';

  static const routinesTitle = 'Rutinas';
  static const routinesSubtitle = 'Accede a tus entrenamientos y organiza tus rutinas aquí.';

  static const socialTitle = 'Social';
  static const socialSubtitle = 'Conecta con otros usuarios, comparte resultados y retos.';

  static const profileTitle = 'Perfil';
  static const profileLoading = 'Cargando perfil...';
  static const profileError = 'No se pudo cargar el perfil.';
  static const profileNameLabel = 'Nombre';
  static const profileEmailLabel = 'Email';

  // Login
  static const loginTitle = 'INICIAR SESIÓN';
  static const loginUserLabel = 'USUARIO';
  static const loginPasswordLabel = 'CONTRASEÑA';
  static const loginIdentifierHint = 'EMAIL O USUARIO';
  static const loginPasswordHint = 'PASSWORD';
  static const loginButton = 'ENTRAR';
  static const forgotPasswordPrompt = '¿Has olvidado la contraseña?';
  static const recoverPasswordSoon = 'Recuperar contraseña próximamente';
  static const noAccountPrompt = '¿No tienes cuenta? Regístrate';

  // Register
  static const registerTitle = 'CREAR CUENTA';
  static const registerNameLabel = 'NOMBRE';
  static const registerEmailLabel = 'EMAIL';
  static const registerPasswordLabel = 'CONTRASEÑA';
  static const registerRepeatPasswordLabel = 'REPETIR CONTRASEÑA';
  static const registerNameHint = 'TU NOMBRE';
  static const registerEmailHint = 'EMAIL ADDRESS';
  static const registerPasswordHint = 'PASSWORD';
  static const registerRepeatPasswordHint = 'REPEAT PASSWORD';
  static const registerButton = 'REGISTRARME';
  static const alreadyHaveAccountPrompt = '¿Ya tienes cuenta? Inicia sesión';

  // Shared
  static const continueWith = 'o continúa con';
  static const errorEnterEmail = 'Introduce tu email';
  static const errorInvalidEmail = 'Email no válido';
  static const errorEnterIdentifier = 'Introduce tu email o usuario';
  static const errorEnterPassword = 'Introduce tu contraseña';
  static const errorFixErrors = 'Corrige los errores para continuar';
  static const errorFixForm = 'Corrige los errores del formulario';
  static const errorLoginFailed = 'No se pudo iniciar sesión. Intenta de nuevo';
  static const errorEnterName = 'Introduce tu nombre';
  static const errorEnterRegisterEmail = 'Introduce tu email';
  static const errorPasswordMinLength = 'La contraseña debe tener al menos 8 caracteres';
  static const errorRepeatPassword = 'Repite la contraseña';
  static const errorPasswordsDontMatch = 'Las contraseñas no coinciden';
  static const accountCreated = 'Cuenta creada correctamente';
  static const errorRegisterFailed = 'No se pudo crear la cuenta. Intenta de nuevo';

  static const googleProvider = 'Google';
  static const appleProvider = 'Apple';
  static const facebookProvider = 'Facebook';

  // Forgot / Reset Password
  static const forgotPasswordTitle = 'RESTABLECER CONTRASEÑA';
  static const forgotPasswordEmailLabel = 'EMAIL';
  static const forgotPasswordEmailHint = 'TU EMAIL';
  static const forgotPasswordButton = 'ENVIAR CÓDIGO';
  static const forgotPasswordSuccess = 'Revisa tu correo electrónico';

  static const resetPasswordTitle = 'RESTABLECER CONTRASEÑA';
  static const resetPasswordTokenLabel = 'CÓDIGO DE VERIFICACIÓN';
  static const resetPasswordTokenHint = 'CÓDIGO';
  static const resetPasswordNewPasswordLabel = 'NUEVA CONTRASEÑA';
  static const resetPasswordNewPasswordHint = 'NUEVA CONTRASEÑA';
  static const resetPasswordButton = 'CAMBIAR CONTRASEÑA';
  static const backToLogin = 'Volver al inicio de sesión';

  static String comingSoonProvider(String provider) => 'Inicio con $provider próximamente';
}
