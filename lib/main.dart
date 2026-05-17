import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();
  runApp(const JadaFitApp());
}