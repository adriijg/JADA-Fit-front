import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

class JadaFitApp extends StatelessWidget {
  const JadaFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'JADA FIT',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}