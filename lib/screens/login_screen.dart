import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart'; // Asegúrate de importar tu nueva clase de colores

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO Y TÍTULO
                const Icon(Icons.fitness_center, size: 70, color: AppColors.primary),
                const SizedBox(height: 10),
                const Text(
                  "JADA FIT",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Orbitron',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                Container(
                  height: 2,
                  width: 80,
                  color: AppColors.primary,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                const SizedBox(height: 50),

                // CONTENEDOR PRINCIPAL
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.2), width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // CAMPO EMAIL
                      const Text(
                        "USUARIO",
                        style: TextStyle(color: AppColors.secondary, fontSize: 14, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: emailController,
                        hintText: "EMAIL ADDRESS",
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 20),

                      // CAMPO CONTRASEÑA
                      const Text(
                        "CONTRASEÑA",
                        style: TextStyle(color: AppColors.secondary, fontSize: 14, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: passwordController,
                        hintText: "PASSWORD",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),

                      // FORGOT KEY
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "¿Has olvidado la contraseña?",
                            style: TextStyle(color: AppColors.secondary, fontSize: 10, letterSpacing: 1.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // BOTÓN PRINCIPAL
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            elevation: 8,
                            shadowColor: AppColors.primary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            try {
                              await AuthService().login(emailController.text, passwordController.text);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: Colors.redAccent, content: Text(e.toString())),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "ENTRAR",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background, // Usamos el fondo más oscuro
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textMain, fontSize: 14, letterSpacing: 1.0),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textMain.withOpacity(0.4), fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.secondary, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}