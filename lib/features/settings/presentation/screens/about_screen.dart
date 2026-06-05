import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
        backgroundColor: Colors.transparent,
        foregroundColor: context.colors.textMain,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.fitness_center,
                color: context.colors.primary,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              l10n.appName,
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              l10n.settingsVersion,
              style: TextStyle(
                color: context.colors.secondary.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 32),
            AppCard.elevated(
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsDescription,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.settingsAppDescription,
                    style: TextStyle(
                      color: context.colors.textMain.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            AppCard.elevated(
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsContact,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  _ContactRow(icon: Icons.email_outlined, text: 'soporte@jadafit.com'),
                  SizedBox(height: 8),
                  _ContactRow(icon: Icons.language_outlined, text: 'www.jadafit.com'),
                ],
              ),
            ),
            SizedBox(height: 16),
            AppCard.elevated(
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsLegal,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.settingsTerms,
                    style: TextStyle(
                      color: context.colors.primary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    l10n.settingsPrivacy,
                    style: TextStyle(
                      color: context.colors.primary.withOpacity(0.8),
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
        Icon(icon, color: context.colors.secondary, size: 18),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: context.colors.textMain.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
