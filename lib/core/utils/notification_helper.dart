import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(settings: initializationSettings);
  }

  static Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required TimeOfDay time,
  }) async {
    // In a real app, we would use timezone-aware scheduling
    debugPrint('Scheduled reminder for $habitName at ${time.hour}:${time.minute}');
  }

  static Future<void> cancelHabitReminder(String habitId) async {
    await _notifications.cancel(id: habitId.hashCode);
  }

  static Future<void> showPartnerActivityNotification(String partnerName, String action) async {
    const androidDetails = AndroidNotificationDetails(
      'partner_activity',
      'Partner Activity',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notifications.show(
      id: 0,
      title: 'Partner Update',
      body: '$partnerName $action 🌸',
      notificationDetails: notificationDetails,
    );
  }
}
