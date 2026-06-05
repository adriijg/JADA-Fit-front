import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'preferences_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _workoutChannelId = 'workout_reminders';
  static const _workoutChannelName = 'Recordatorios de entrenos';
  static const _workoutChannelDesc = 'Recordatorios diarios para entrenar';
  static const _workoutNotificationId = 1001;

  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  Future<void> showResponseReady() async {
    if (!PreferencesService.instance.aiNotificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'ai_chat_channel',
      'Asistente IA',
      channelDescription: 'Notificaciones del asistente de IA',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
      ),
    );
    await _plugin.show(
      0,
      'JADA Fit IA',
      'Respuesta lista de tu asistente',
      details,
    );
  }

  Future<void> scheduleWorkoutReminder() async {
    const androidDetails = AndroidNotificationDetails(
      _workoutChannelId,
      _workoutChannelName,
      channelDescription: _workoutChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
      ),
    );
    await _plugin.periodicallyShow(
      _workoutNotificationId,
      'JADA Fit',
      '¡Hora de entrenar! Tu cuerpo te lo agradecer\u00e1.',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelWorkoutReminder() async {
    await _plugin.cancel(_workoutNotificationId);
  }
}