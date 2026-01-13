import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Localnotification {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init({bool scheduled = false}) async {
    var initAndroidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final settings =
        InitializationSettings(android: initAndroidSettings, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future showNotification(
          {var id = 0,
          var title,
          var body,
          var payload,
          var som,
          var somios}) async =>
      _notifications.show(
        id,
        title,
        body,
        await notificationDetails(som, somios),
      );

  static Future cancelnotification(int id) async {
    _notifications.cancel(id);
  }

  static Future showNotificationsperiodic(
      {var id = 0,
      var title,
      var body,
      var payload,
      var som,
      var somios}) async {
    _notifications.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      await notificationDetails(som, somios),
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  static Future showNotificationscheduled(
      {var id = 0,
      var title,
      var body,
      var payload,
      var dateTime,
      var som,
      var somios}) async {
    tz.initializeTimeZones();
    // DateTime dateTime = DateTime.now().add(Duration(minutes: 1));
    final tz.TZDateTime scheduledAt = tz.TZDateTime.from(dateTime, tz.local);

    _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledAt,
      await notificationDetails(som, somios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  static notificationDetails(var som, var somios) async {
    // String? i = (Random().nextInt(4) + 1).toString();
    // if (i == '4') i = '3';

    // String som = 'notification' + i;
    // String somios = 'notification' + i + '.aiff';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'Notifications_4youpet',
        'Notifications',
        channelDescription: 'Canal de notificacoes',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        //timeoutAfter: 5000,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound(som),
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
        sound: somios,
      ),
    );
  }
}
