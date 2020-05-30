import 'dart:collection';

import 'package:solo/models/base_model.dart';

class ChatModel extends BaseModel {
  String senderID;
  String receiverID;
  String senderName;
  String receiverName;
  String senderPhoto;
  String receiverPhoto;
  String messageStatus;
  String messageType;
  String message;
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  bool isRead;
  int isSync;

  ChatModel(
      this.senderID,
      this.receiverID,
      this.senderName,
      this.receiverName,
      this.senderPhoto,
      this.receiverPhoto,
      this.messageStatus,
      this.messageType,
      this.message,
      this.timestamp,
      this.isRead,
      this.isSync);

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
        map['senderID'],
        map['receiverID'],
        map['senderName'],
        map['receiverName'],
        map['senderPhoto'],
        map['receiverPhoto'],
        map['messageStatus'],
        map['messageType'],
        map['message'],
        map['timestamp'],
        map['isRead'] == 1,
        map['isSync']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = HashMap();
    map['senderID'] = senderID;
    map['receiverID'] = receiverID;
    map['senderName'] = senderName;
    map['receiverName'] = receiverName;
    map['senderPhoto'] = senderPhoto;
    map['receiverPhoto'] = receiverPhoto;
    map['messageStatus'] = messageStatus;
    map['messageType'] = messageType;
    map['message'] = message;
    map['timestamp'] = timestamp;
    map['isRead'] = isRead ? 1: 0;
    map['isRead'] = isSync;
    return map;
  }
}

class MessageStatus {
  static const SENT = "sent";
  static const DELIVERED = "delivered";
  static const SEEN = "seen";
}

class MessageType {
  static const TEXT = "text";
  static const IMAGE = "image";
  static const VIDEO = "video";
}
