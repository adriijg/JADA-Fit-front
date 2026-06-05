import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final token = _tokenController.text.trim();
    final newPassword = _passwordController.text;

    if (token.isEmpty) {
      setState(() => errorMessage = 'Introduce el token');
      return;
    }

    if (newPassword.length < 6) {
      setState(() => errorMessage = AppLocalizations.of(context)!.authPasswordMinLength6);
      return;
    }

    try {
      setState(() => isLoading = true);

      final message = await _authService.resetPassword(token, newPassword);

      if (!mounted) return;

      _showMessage(message);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.message);
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => errorMessage = AppLocalizations.of(context)!.errorLoginFailed);
      _showMessage(AppLocalizations.of(context)!.errorLoginFailed);
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
                      color: context.colors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.resetPasswordTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.primary,
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
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.resetPasswordTokenLabel,
                            style: TextStyle(
                              color: context.colors.secondary,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 8),
                          AuthTextField(
                            controller: _tokenController,
                            hintText: AppLocalizations.of(context)!.resetPasswordTokenHint,
                            icon: Icons.vpn_key_outlined,
                          ),
                          SizedBox(height: 22),
                          Text(
                            AppLocalizations.of(context)!.resetPasswordNewPasswordLabel,
                            style: TextStyle(
                              color: context.colors.secondary,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 8),
                          AuthTextField(
                            controller: _passwordController,
                            hintText: AppLocalizations.of(context)!.resetPasswordNewPasswordHint,
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: context.colors.secondary,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                              onPressed: isLoading ? null : _reset,
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
                                  : Text(
                                      AppLocalizations.of(context)!.resetPasswordButton,
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
                        foregroundColor: context.colors.secondary,
                      ),
                      child: Text(AppLocalizations.of(context)!.backToLogin),
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
