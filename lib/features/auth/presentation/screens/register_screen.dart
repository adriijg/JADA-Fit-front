import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import 'auth_gate.dart';
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
    final password = passwordController.text;
    final repeatPassword = repeatPasswordController.text;

    setState(() {
      errorMessage = null;
      nameError = null;
      emailError = null;
      passwordError = null;
      repeatPasswordError = null;
    });

    if (name.isEmpty) {
      nameError = AppLocalizations.of(context)!.errorEnterName;
    }

    if (email.isEmpty) {
      emailError = AppLocalizations.of(context)!.errorEnterRegisterEmail;
    } else if (!_validateEmail(email)) {
      emailError = AppLocalizations.of(context)!.errorInvalidEmail;
    }

    if (password.isEmpty) {
      passwordError = AppLocalizations.of(context)!.errorEnterPassword;
    } else if (password.length < 8) {
      passwordError = AppLocalizations.of(context)!.errorPasswordMinLength;
    }

    if (repeatPassword.isEmpty) {
      repeatPasswordError = AppLocalizations.of(context)!.errorRepeatPassword;
    } else if (password != repeatPassword) {
      repeatPasswordError = AppLocalizations.of(context)!.errorPasswordsDontMatch;
    }

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        repeatPasswordError != null) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.errorFixForm;
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

      if (!mounted) return;

      _goToHome();
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });

      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = AppLocalizations.of(context)!.errorRegisterFailed;
      });

      _showMessage(AppLocalizations.of(context)!.errorRegisterFailed);
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
        builder: (_) => LoginScreen(),
      ),
    );
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AuthGate(),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
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
                    Icon(
                      Icons.fitness_center,
                      size: 72,
                      color: context.colors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.appName,
                      style: TextStyle(
                        color: context.colors.primary,
                        fontFamily: 'Orbitron',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.8,
                      ),
                    ),
                    SizedBox(height: 40),
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
                    SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
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
      padding: EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)!.registerTitle,
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.registerNameLabel,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          AuthTextField(
            controller: nameController,
            hintText: AppLocalizations.of(context)!.registerNameHint,
            icon: Icons.person_outline,
            errorText: nameError,
          ),
          SizedBox(height: 22),
          Text(
            AppLocalizations.of(context)!.registerEmailLabel,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          AuthTextField(
            controller: emailController,
            hintText: AppLocalizations.of(context)!.registerEmailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: emailError,
          ),
          SizedBox(height: 22),
          Text(
            AppLocalizations.of(context)!.registerPasswordLabel,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          AuthTextField(
            controller: passwordController,
            hintText: AppLocalizations.of(context)!.registerPasswordHint,
            icon: Icons.lock_outline,
            obscureText: true,
            errorText: passwordError,
          ),
          SizedBox(height: 22),
          Text(
            AppLocalizations.of(context)!.registerRepeatPasswordLabel,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          AuthTextField(
            controller: repeatPasswordController,
            hintText: AppLocalizations.of(context)!.registerRepeatPasswordHint,
            icon: Icons.lock_reset,
            obscureText: true,
            errorText: repeatPasswordError,
          ),
          SizedBox(height: 28),
          if (errorMessage != null)
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isLoading ? null : onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: context.colors.background,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.registerButton,
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
          SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: onGoToLogin,
              style: TextButton.styleFrom(
                foregroundColor: context.colors.secondary,
              ),
              child: Text(AppLocalizations.of(context)!.alreadyHaveAccountPrompt),
            ),
          ),
        ],
      ),
    );
  }
}
