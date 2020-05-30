import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:solo/home/notifications/api/push_notification.dart';
import 'package:solo/models/follow_detail.dart';
import 'package:solo/models/notification_detail.dart';
import 'package:solo/models/user.dart';

import 'notifications/api/push_notification_manager.dart';

class NotificationService extends SoloService {
  User user;

  NotificationService(this.user);

  @override
  void init() {

    PushNotificationsManager.instance.init(user);
    
    initNotification();

    LocalPushNotification.listenNotification(user.id,
        (FollowDetail onDataReceived) {
      showNotificationWithSound(
          NotificationDetail.fromFollowDetail(onDataReceived));
    });
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void initNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('launch_background');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
      return onSelectNotification(payload);
    });
  }

  Future onSelectNotification(String payload) async {
    print("Play is ${payload}");
  }

  // Method 1
  Future showNotificationWithSound(
      NotificationDetail notificationDetail) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Follower',
      '${notificationDetail.message}',
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );

    LocalPushNotification.deleteNotification(user.id);
  }
}

abstract class SoloService {
  void init();
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
