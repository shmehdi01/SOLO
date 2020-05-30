import 'dart:collection';

import 'package:solo/models/base_model.dart';

class Connection extends BaseModel {
  int id;
  String follower;
  String following;
  String time;
  String message;
  int isSync;

  Connection({this.id, this.follower, this.following, this.time, this.message, this.isSync});

  factory Connection.fromMap(Map<String, dynamic> map) {
    return Connection(
      follower: map['follower'],
      following: map['following'],
      time: map['time'],
      message: map['message'],
      isSync: map['isSync'],
      id: map['id']
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new HashMap();

    map['follower'] = follower;
    map['following'] = following;
    map['time'] = time;
    map['message'] = message;
    map['isSync'] = isSync;
    map['id'] = id;

    return map;
  }
}
