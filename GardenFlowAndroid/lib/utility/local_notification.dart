import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class LocalNotification {
  static Future init() async {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestExactAlarmsPermission();

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future getNotificationDetails(String channelID, String channelName, String channelDescription) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelID, channelName, channelDescription: channelDescription, importance: Importance.max, priority: Priority.high);
    return NotificationDetails(android: androidNotificationDetails);
  }

  static Future showScheduledNotification({required String message, required int hour, required int channel}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(channel, 'Watering and Fertilizer Notification', message, scheduled(hour),
        await getNotificationDetails("MyChannelID", "NotificationChannel", "Channel Description"),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  static tz.TZDateTime scheduled(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  static Future<bool> isAlreadyInitializeScheduled() async {
    var listOfPending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if (listOfPending.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Future clearNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
