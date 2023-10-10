import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi{
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init({bool schedule = false}) async {
    var initAndroidSettings = const AndroidInitializationSettings("@drawable/ic_stat_notifications_none");
    var ios = const DarwinInitializationSettings();
    final settings = InitializationSettings(android: initAndroidSettings, iOS: ios);
    await _notifications.initialize(settings);
  }


  static _notificationsDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'channel id',
            'channel name',
            importance: Importance.max
        ),
        iOS: DarwinNotificationDetails()
    );
  }

  static Future showNotification({
    var id  = 0,
    var title,
    var body,
    var payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationsDetails(),
      );

}