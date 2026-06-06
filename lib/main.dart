import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/navigation/app_navigator.dart';
import 'core/network/auth_http_client.dart';
import 'core/services/preferences_service.dart';
import 'core/services/notification_service.dart';
import 'features/ai/presentation/providers/ai_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = PreferencesService.instance;
  try {
    await prefs.init();
  } catch (error, stack) {
    debugPrint('PreferencesService.init failed: $error');
    debugPrint('$stack');
  }

  final notificationService = NotificationService.instance;
  try {
    await notificationService.init();
    await notificationService.requestPermission();
  } catch (error, stack) {
    debugPrint('NotificationService init failed: $error');
    debugPrint('$stack');
  }

  AuthHttpClient.onUnauthorized = () {
    AppNavigator.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  };

  runZonedGuarded(() {
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
  }, (error, stack) {
    debugPrint('Uncaught error during app startup: $error');
    debugPrint('$stack');
  });
}