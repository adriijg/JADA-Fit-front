import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'auth_gate.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

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
  bool _obscurePassword = true;

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
          builder: (_) => AuthGate(),
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
        builder: (_) => RegisterScreen(),
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
                      size: 82,
                      color: context.colors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: context.colors.primary,
                        fontFamily: 'Orbitron',
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.8,
                      ),
                    ),
                    SizedBox(height: 48),
                    _LoginCard(
                      identifierController: identifierController,
                      passwordController: passwordController,
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                      identifierError: identifierError,
                      passwordError: passwordError,
                      obscurePassword: _obscurePassword,
                      onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                      onLogin: _login,
                      onGoToRegister: _goToRegister,
                      onGoogleLogin: () =>
                          _showComingSoon(AppStrings.googleProvider),
                      onAppleLogin: () =>
                          _showComingSoon(AppStrings.appleProvider),
                      onFacebookLogin: () =>
                          _showComingSoon(AppStrings.facebookProvider),
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

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.identifierController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.identifierError,
    required this.passwordError,
    required this.obscurePassword,
    required this.onToggleObscure,
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
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onGoToRegister;
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;
  final VoidCallback onFacebookLogin;

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
              AppStrings.loginTitle,
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
            AppStrings.loginUserLabel,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          AuthTextField(
            controller: identifierController,
            hintText: AppStrings.loginIdentifierHint,
            icon: Icons.alternate_email,
            keyboardType: TextInputType.text,
            errorText: identifierError,
          ),
          SizedBox(height: 22),
          Text(
            AppStrings.loginPasswordLabel,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          AuthTextField(
            controller: passwordController,
            hintText: AppStrings.loginPasswordHint,
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            errorText: passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: context.colors.secondary,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForgotPasswordScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: context.colors.secondary,
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.9,
                ),
              ),
              child: Text(AppStrings.forgotPasswordPrompt),
            ),
          ),
          SizedBox(height: 22),
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
              onPressed: isLoading ? null : onLogin,
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
          SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: onGoToRegister,
              style: TextButton.styleFrom(
                foregroundColor: context.colors.secondary,
                textStyle: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
              child: Text(AppStrings.noAccountPrompt),
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: context.colors.divider,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  AppStrings.continueWith,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: context.colors.divider,
                  thickness: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
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
                color: context.colors.textMain,
                onTap: onAppleLogin,
              ),
              SocialLoginButton(
                icon: FontAwesomeIcons.facebookF,
                color: Color(0xFF1877F2),
                onTap: onFacebookLogin,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
