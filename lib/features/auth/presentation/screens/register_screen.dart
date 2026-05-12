import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import 'package:jada_fit/features/home/presentation/screens/home_screen.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  String? errorMessage;
  String? nameError;
  String? emailError;
  String? passwordError;
  String? repeatPasswordError;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    setState(() {
      errorMessage = null;
      nameError = null;
      emailError = null;
      passwordError = null;
      repeatPasswordError = null;
    });

    if (name.isEmpty) {
      nameError = AppStrings.errorEnterName;
    }

    if (email.isEmpty) {
      emailError = AppStrings.errorEnterRegisterEmail;
    } else if (!_validateEmail(email)) {
      emailError = AppStrings.errorInvalidEmail;
    }

    if (password.isEmpty) {
      passwordError = AppStrings.errorEnterPassword;
    } else if (password.length < 8) {
      passwordError = AppStrings.errorPasswordMinLength;
    }

    if (repeatPassword.isEmpty) {
      repeatPasswordError = AppStrings.errorRepeatPassword;
    } else if (password != repeatPassword) {
      repeatPasswordError = AppStrings.errorPasswordsDontMatch;
    }

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        repeatPasswordError != null) {
      setState(() {
        errorMessage = AppStrings.errorFixForm;
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      await _authService.register(
        username: name,
        email: email,
        password: password,
      );

      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage(AppStrings.accountCreated);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });

      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = AppStrings.errorRegisterFailed;
      });

      _showMessage(AppStrings.errorRegisterFailed);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    Color(0xFF061216),
                    Color(0xFF071A20),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fitness_center,
                          size: 72,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'Orbitron',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 2,
                          width: 92,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 40),
                        _RegisterCard(
                          nameController: nameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          repeatPasswordController: repeatPasswordController,
                          isLoading: isLoading,
                          onRegister: _register,
                          onGoToLogin: _goToLogin,
                          nameError: nameError,
                          emailError: emailError,
                          passwordError: passwordError,
                          repeatPasswordError: repeatPasswordError,
                          errorMessage: errorMessage,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.repeatPasswordController,
    required this.isLoading,
    required this.onRegister,
    required this.onGoToLogin,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.repeatPasswordError,
    this.errorMessage,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;
  final bool isLoading;
  final VoidCallback onRegister;
  final VoidCallback onGoToLogin;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? repeatPasswordError;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              AppStrings.registerTitle,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            AppStrings.registerNameLabel,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: nameController,
            hintText: AppStrings.registerNameHint,
            icon: Icons.person_outline,
            errorText: nameError,
          ),
          if (nameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                nameError!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 22),
          const Text(
            AppStrings.registerEmailLabel,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: emailController,
            hintText: AppStrings.registerEmailHint,
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            errorText: emailError,
          ),
          if (emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                emailError!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 22),
          const Text(
            AppStrings.registerPasswordLabel,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: passwordController,
            hintText: AppStrings.registerPasswordHint,
            icon: Icons.lock_outline,
            obscureText: true,
            errorText: passwordError,
          ),
          if (passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                passwordError!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 22),
          const Text(
            AppStrings.registerRepeatPasswordLabel,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: repeatPasswordController,
            hintText: AppStrings.registerRepeatPasswordHint,
            icon: Icons.lock_reset,
            obscureText: true,
            errorText: repeatPasswordError,
          ),
          if (repeatPasswordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                repeatPasswordError!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 28),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isLoading ? null : onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 12,
                shadowColor: AppColors.primary.withOpacity(0.32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.background,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.registerButton,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: onGoToLogin,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
              ),
              child: const Text(AppStrings.alreadyHaveAccountPrompt),
            ),
          ),
        ],
      ),
    );
  }
}
