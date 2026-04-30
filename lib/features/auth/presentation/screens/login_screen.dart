import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Introduce email y contraseña');
      return;
    }

    try {
      setState(() => isLoading = true);

      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('Login correcto');

      // Aquí luego puedes navegar al HomeScreen.
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const HomeScreen()),
      // );
    } catch (error) {
      _showMessage('No se pudo iniciar sesión');
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
    _showMessage('Inicio con $provider próximamente');
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
                          'JADA FIT',
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
                          emailController: emailController,
                          passwordController: passwordController,
                          isLoading: isLoading,
                          onLogin: _login,
                          onGoToRegister: _goToRegister,
                          onGoogleLogin: () => _showComingSoon('Google'),
                          onAppleLogin: () => _showComingSoon('Apple'),
                          onFacebookLogin: () => _showComingSoon('Facebook'),
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
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onGoToRegister,
    required this.onGoogleLogin,
    required this.onAppleLogin,
    required this.onFacebookLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onGoToRegister;
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;
  final VoidCallback onFacebookLogin;

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
              'INICIAR SESIÓN',
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
            'USUARIO',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          AuthTextField(
            controller: emailController,
            hintText: 'EMAIL ADDRESS',
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 22),

          const Text(
            'CONTRASEÑA',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          AuthTextField(
            controller: passwordController,
            hintText: 'PASSWORD',
            icon: Icons.lock_outline,
            obscureText: true,
          ),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recuperar contraseña próximamente'),
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
              child: const Text('¿Has olvidado la contraseña?'),
            ),
          ),

          const SizedBox(height: 22),

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
                          'ENTRAR',
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
              child: const Text('¿No tienes cuenta? Regístrate'),
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
                  'o continúa con',
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