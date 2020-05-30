import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => instance;

  static final PushNotificationsManager instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;
  String _token = "";

//fDhTwC9gK7k:APA91bHExLu6fa5hxs-ireE2arqmYbQzJq3aBBWCetT-jnCfskDze-I2LA_TQzeAzeIIsZP9QQQdWdzDjcSjb81gmOTmdk1zYcZGDj6ZVk-itvvVwW0VvX3Z21D1eqoRQWrRCpZlRSfq
  Future<void> init(User user) async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(onMessage: (msg) async {
        print("Syed Notification onMessage $msg");
        return;
      }, onLaunch: (msg) async {
        print("Syed Notification onLaunch $msg");
        return;
      }, onResume: (msg) async {
        print("Syed Notification onResume $msg");
        return;
      });

      // For testing purposes print the Firebase Messaging token
      _generateToken(user);

      _firebaseMessaging.subscribeToTopic("all");
      _initialized = true;
    }
  }

  _generateToken(user) async {
     _token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $_token");
   updateUserToken(user);
  }

  _updateToken(String token, User user) {
    user.pushToken = token;
    ApiProvider.profileApi.updatePushToken(user);
  }

  updateUserToken(User user) {
    print("Current Token is");
    _updateToken(_token, user);
  }
  //WHEN USER LOGOUT UNLINK
  deleteTokenFromUser(User user) {
    _updateToken("", user);
  }

  subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  unSubscribeToTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }


}
