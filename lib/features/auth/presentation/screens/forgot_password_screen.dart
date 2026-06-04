import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => errorMessage = AppStrings.errorEnterEmail);
      return;
    }

    try {
      setState(() => isLoading = true);

      await _authService.forgotPassword(email);

      if (!mounted) return;

      _showMessage(AppStrings.forgotPasswordSuccess);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.message);
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => errorMessage = AppStrings.errorLoginFailed);
      _showMessage(AppStrings.errorLoginFailed);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
                      Icons.lock_outline,
                      size: 82,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppStrings.forgotPasswordTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Orbitron',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.4,
                      ),
                    ),
                    SizedBox(height: 48),
                    Container(
                      padding: EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.forgotPasswordEmailLabel,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 8),
                          AuthTextField(
                            controller: _emailController,
                            hintText: AppStrings.forgotPasswordEmailHint,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
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
                              onPressed: isLoading ? null : _sendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.background,
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
                                        color: AppColors.background,
                                      ),
                                    )
                                  : Text(
                                      AppStrings.forgotPasswordButton,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(),
                        ),
                        (route) => false,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                      ),
                      child: Text(AppStrings.backToLogin),
                    ),
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
