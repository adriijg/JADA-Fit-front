import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'auth_gate.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  String? identifierError;
  String? passwordError;
  bool isLoading = false;

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      errorMessage = null;
      identifierError = null;
      passwordError = null;
    });

    if (identifier.isEmpty) {
      identifierError = AppStrings.errorEnterIdentifier;
    }

    if (password.isEmpty) {
      passwordError = AppStrings.errorEnterPassword;
    }

    if (identifierError != null || passwordError != null) {
      setState(() {
        errorMessage = AppStrings.errorFixErrors;
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      await _authService.login(
        email: identifier,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
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
        errorMessage = AppStrings.errorLoginFailed;
      });

      _showMessage(AppStrings.errorLoginFailed);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  void _showComingSoon(String provider) {
    _showMessage(AppStrings.comingSoonProvider(provider));
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
                          size: 82,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'Orbitron',
                            fontSize: 34,
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
                        const SizedBox(height: 48),
                        _LoginCard(
                          identifierController: identifierController,
                          passwordController: passwordController,
                          isLoading: isLoading,
                          errorMessage: errorMessage,
                          identifierError: identifierError,
                          passwordError: passwordError,
                          onLogin: _login,
                          onGoToRegister: _goToRegister,
                          onGoogleLogin: () =>
                              _showComingSoon(AppStrings.googleProvider),
                          onAppleLogin: () =>
                              _showComingSoon(AppStrings.appleProvider),
                          onFacebookLogin: () =>
                              _showComingSoon(AppStrings.facebookProvider),
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

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.identifierController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.identifierError,
    required this.passwordError,
    required this.onLogin,
    required this.onGoToRegister,
    required this.onGoogleLogin,
    required this.onAppleLogin,
    required this.onFacebookLogin,
  });

  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final String? identifierError;
  final String? passwordError;
  final VoidCallback onLogin;
  final VoidCallback onGoToRegister;
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;
  final VoidCallback onFacebookLogin;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      padding: const EdgeInsets.all(26),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              AppStrings.loginTitle,
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
            AppStrings.loginUserLabel,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: identifierController,
            hintText: AppStrings.loginIdentifierHint,
            icon: Icons.alternate_email,
            keyboardType: TextInputType.text,
            errorText: identifierError,
          ),
          if (identifierError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                identifierError!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 22),
          const Text(
            AppStrings.loginPasswordLabel,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: passwordController,
            hintText: AppStrings.loginPasswordHint,
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
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.recoverPasswordSoon),
                    backgroundColor: AppColors.surface,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.9,
                ),
              ),
              child: const Text(AppStrings.forgotPasswordPrompt),
            ),
          ),
          const SizedBox(height: 22),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
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
            ),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
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
                          AppStrings.loginButton,
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
              onPressed: onGoToRegister,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
              child: const Text(AppStrings.noAccountPrompt),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.divider,
                  thickness: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  AppStrings.continueWith,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.divider,
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SocialLoginButton(
                icon: FontAwesomeIcons.google,
                color: AppColors.googleRed,
                onTap: onGoogleLogin,
              ),
              SocialLoginButton(
                icon: FontAwesomeIcons.apple,
                color: AppColors.textMain,
                onTap: onAppleLogin,
              ),
              SocialLoginButton(
                icon: FontAwesomeIcons.facebookF,
                color: const Color(0xFF1877F2),
                onTap: onFacebookLogin,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
