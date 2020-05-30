import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:solo/models/base_model.dart';
import 'package:solo/models/follow_detail.dart';
import 'package:solo/utils.dart';

class NotificationType {
  static const int POST = 0;
  static const int FOLLOW = 1;
}

class NotificationDetail extends BaseModel {
  String documentID;
  String message;
  String id;
  int type;
  bool isRead;
  String intentId;
  String addtionalMsg;
  String fromId;
  String timestamp;
  String imageUrl;
  int isSync;

  NotificationDetail(
      {@required this.message,
      @required this.id,
      @required this.type,
      @required this.isRead,
      @required this.intentId,
      @required this.fromId,
      @required this.timestamp,
      @required this.imageUrl,
      @required this.addtionalMsg,
      this.documentID,
      this.isSync});

  factory NotificationDetail.fromFollowDetail(FollowDetail followDetail) {
    return NotificationDetail(
        message: "${followDetail.followerName} has started following you",
        id: followDetail.followingId,
        fromId: followDetail.followerID,
        type: NotificationType.FOLLOW,
        intentId: followDetail.followerID,
        timestamp: Utils.timestamp(),
        addtionalMsg: followDetail.msg,
        isRead: false,
        imageUrl: null);
  }

  factory NotificationDetail.fromMap(Map<String, dynamic> map,
      {String documentID}) {
    return NotificationDetail(
        message: map['message'],
        id: map['id'],
        fromId: map['fromId'],
        type: map['type'],
        intentId: map['intentId'],
        addtionalMsg: map['addtionalMsg'],
        timestamp: map['timestamp'],
        isRead: map['isRead'] == 1,
        documentID: documentID,
        isSync: map['isSync'],
        imageUrl: map['imageUrl']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new HashMap();
    map['message'] = message;
    map['id'] = id;
    map['type'] = type;
    map['intentId'] = intentId;
    map['isRead'] = isRead ? 1 : 0;
    map['addtionalMsg'] = addtionalMsg;
    map['isSync'] = isSync;
    map['fromId'] = fromId;
    map['imageUrl'] = imageUrl;
    map['timestamp'] = timestamp;
    return map;
  }
}
