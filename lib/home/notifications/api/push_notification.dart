import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:solo/models/follow_detail.dart';

class LocalPushNotification {
  static Future<void> sendFollowNotification(FollowDetail followDetail) async {
    await FirebaseDatabase.instance
        .reference()
        .child("Solo")
        .child("Notifications")
        .child(followDetail.followingId)
        .child("notifications")
        .set(followDetail.toMap());
  }

  static void listenNotification(
      String id, Function(FollowDetail followDetail) onDataReceived) {
    FirebaseDatabase.instance
        .reference()
        .child("Solo")
        .child("Notifications")
        .child(id)
        .onChildChanged
        .listen((event) {
      print("Change Wala");
      onDataReceived(FollowDetail.fromMap(event.snapshot.value));
    });

    FirebaseDatabase.instance
        .reference()
        .child("Solo")
        .child("Notifications")
        .child(id)
        .onChildAdded
        .listen((event) {
      print("Added Wala");
      onDataReceived(FollowDetail.fromMap(event.snapshot.value));
    });
  }

  static void deleteNotification(String id) {
    print("Delete Called");
    FirebaseDatabase.instance
        .reference()
        .child("Solo")
        .child("Notifications")
        .child(id)
        .remove();
  }
}

class PushNotificationBuilder {

  String _title;
  String _message;
  String _topic;
  String _token;
  String _image;

  PushNotificationBuilder({@required title, @required message, topic, token,
      image}) {
    _title = title;
    _message = message;
    _image = image;
    _token = token;
    _topic = topic;
  }


  PushNotification createTopic() {
    Map mapJson = Map();

    mapJson['notification'] = _notificationMap();
    mapJson['to'] = "/topics/$_topic";

    return PushNotification(jsonEncode(mapJson));

  }

  PushNotification createToken() {
    Map mapJson = Map();

    mapJson['notification'] = _notificationMap();
    mapJson['to'] = "$_token";
    mapJson['data'] = _payload();


    return PushNotification(jsonEncode(mapJson));

  }

  Map<String, dynamic> _notificationMap() {
    Map<String, dynamic> notifications = Map();
    notifications['title'] = "$_title";
    notifications['body'] = "$_message";

    if(_image != null)
      notifications['image'] = "$_image";

    return notifications;
  }

  Map<String, dynamic> _payload() {
    Map<String, dynamic> payload = Map();
    payload['click_action'] = "FLUTTER_NOTIFICATION_CLICK";
    payload['myData'] = "Hello bava";

    return payload;
  }

}

class PushNotification {

  static const String _API_KEY =
      "AAAA0Xo4FlY:APA91bHtvwU3CTIiVw75fXrFqUJ4qdn391h40DCPdxokYZm1BUnKtWvkoKrYoUEg1z9I55xJhxkgCLAV2SUCgIZNrh3MbElApGhO4jEoxirOuYh1ZeXgJHsRgfHa6Yk5rfySO72H8dnQ";

  String _json;
  PushNotification(this._json);

  Map<String, String> _headers = {
    "Content-type": "application/json",
    "Authorization": "key=$_API_KEY"
  };

  static const String _URL = "https://fcm.googleapis.com/fcm/send";

  void sendNotification() async {
    print(_json);

    http.Response response = await http.post(_URL,headers: _headers,body: _json);

    print("Response code: ${response.statusCode}");
    print("Response Body: ${response.body}");
  }

}
