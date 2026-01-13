import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
//simport 'package:timezone/data/latest.dart' as tz;

class Schedulenotificatio {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  final DarwinInitializationSettings _iosInitializationSettings =
      DarwinInitializationSettings();

  void initialiseNotifications() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future sendNotification(String title, String body) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Notifications_4youpet', 'Notifications',
            channelDescription: 'Canal de notificacoes',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true);

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 0,
      sound: 'assets/sound/cat_notification.mp3',
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  Schedulenotification(String title, String desc, DateTime dateTime) {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'Notifications_4youpet',
      'Notifications',
      channelDescription: 'Canal de notificacoes',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound(
          'assets/sound/cat_notification.mp3'),
    );

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 0,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    final tz.TZDateTime scheduledAt = tz.TZDateTime.from(dateTime, tz.local);
    _flutterLocalNotificationsPlugin.zonedSchedule(
        01, title, desc, scheduledAt, notificationDetails,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.wallClockTime,
        // ignore: deprecated_member_use
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }
}
