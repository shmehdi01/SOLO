import 'dart:convert';

import 'package:solo/database/entity/base.dart';
import 'package:solo/models/user.dart';

class UserEntity implements Entity {
  int id;
  String userID;
  String type; //FOLLOWER //FOLLOWING
  String data;
  bool isSync;

  UserEntity({this.id, this.userID, this.type, this.data, this.isSync});

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "userID": this.userID,
      "type": this.type,
      "data": this.data,
      "isSync": this.isSync ? 1 : 0,
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json["id"],
      userID: json["userID"],
      type: json["type"],
      data: json["data"],
      isSync: json["isSync"] == 1,
    );
  }

  User getUser() {
    return User.fromMap(jsonDecode(data));
  }

  factory UserEntity.fromUser(User user, String type) {
    return UserEntity(
        userID: user.id, type: type, data: jsonEncode(user.toMap()), isSync: true);
  }

  static List<User> getAllUser(List<UserEntity> entities) {
    var list = <User>[];
    entities.forEach((entity) {
      list.add(entity.getUser());
    });
    return list;
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}
