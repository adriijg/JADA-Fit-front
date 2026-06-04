import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Acerca de'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textMain,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versión 1.0.0',
              style: TextStyle(
                color: AppColors.secondary.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            AppCard.elevated(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'JADA Fit es tu compañero de fitness inteligente. '
                    'Crea rutinas personalizadas, sigue tu progreso físico, '
                    'recibe asistencia con IA y conecta con una comunidad fitness.',
                    style: TextStyle(
                      color: AppColors.textMain.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard.elevated(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contacto',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ContactRow(icon: Icons.email_outlined, text: 'soporte@jadafit.com'),
                  const SizedBox(height: 8),
                  _ContactRow(icon: Icons.language_outlined, text: 'www.jadafit.com'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard.elevated(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legal',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Términos y condiciones',
                    style: TextStyle(
                      color: AppColors.primary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Política de privacidad',
                    style: TextStyle(
                      color: AppColors.primary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: AppColors.textMain.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
