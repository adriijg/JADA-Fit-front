import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/ai/presentation/providers/ai_provider.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

class JadaFitApp extends StatelessWidget {
  const JadaFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AiProvider>(
      create: (_) => AiProvider()..loadSessions(),
      child: MaterialApp(
        title: 'JADA FIT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}