import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:solo/models/base_model.dart';
import 'package:solo/models/connections.dart';

class FollowDetail extends BaseModel {
  final String followingId;
  final String followerName;
  final String followerID;
  final String msg;

  FollowDetail(
      {@required this.followingId,
      @required this.followerName,
      @required this.followerID,
      @required this.msg});

  factory FollowDetail.fromConnection(String myName, Connection connection) {
    return FollowDetail(
        followingId: connection.following,
        followerName: myName,
        followerID: connection.follower,
        msg: connection.message);
  }

  factory FollowDetail.fromMap(LinkedHashMap<dynamic, dynamic> map) {
    return FollowDetail(
        followerID: map['followerID'],
        followingId: map['followingId'],
        followerName: map['followerName'],
        msg: map['msg']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new HashMap();
    map['followerID'] = followerID;
    map['followingId'] = followingId;
    map['followerName'] = followerName;
    map['msg'] = msg;
    return map;
  }
}
