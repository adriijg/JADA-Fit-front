import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
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

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
      _showMessage('Rellena todos los campos');
      return;
    }

    if (password != repeatPassword) {
      _showMessage('Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    try {
      setState(() => isLoading = true);

      await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('Cuenta creada correctamente');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (error) {
      _showMessage('No se pudo crear la cuenta');
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
                          'JADA FIT',
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
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;
  final bool isLoading;
  final VoidCallback onRegister;
  final VoidCallback onGoToLogin;

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
              'CREAR CUENTA',
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
            'NOMBRE',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: nameController,
            hintText: 'TU NOMBRE',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 22),

          const Text(
            'EMAIL',
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

          const SizedBox(height: 22),

          const Text(
            'REPETIR CONTRASEÑA',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: repeatPasswordController,
            hintText: 'REPEAT PASSWORD',
            icon: Icons.lock_reset,
            obscureText: true,
          ),

          const SizedBox(height: 28),

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
                          'REGISTRARME',
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
              child: const Text('¿Ya tienes cuenta? Inicia sesión'),
            ),
          ),
        ],
      ),
    );
  }
}