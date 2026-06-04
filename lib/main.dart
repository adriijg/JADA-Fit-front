import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/preferences_service.dart';
import 'core/services/notification_service.dart';
import 'features/ai/presentation/providers/ai_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = PreferencesService.instance;
  await prefs.init();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AiProvider>(
          create: (_) => AiProvider()..loadSessions(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefs),
        ),
      ],
      child: const JadaFitApp(),
    ),
  );
}