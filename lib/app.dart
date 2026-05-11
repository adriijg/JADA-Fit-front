import 'package:flutter/material.dart';
import 'package:jada_fit/features/auth/presentation/screens/auth_gate.dart';

import 'core/theme/app_theme.dart';

class JadaFitApp extends StatelessWidget {
  const JadaFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jada Fit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}
