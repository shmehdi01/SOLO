import 'dart:convert';

import 'package:solo/models/base_model.dart';
import 'package:solo/models/user.dart';

class PostModel extends BaseModel {
  String id;
  String userId;
  User user;
  String caption;
  String imageUrl;
  List<User> tagsUser;
  String locations;
  String timestamp;
  List<Like> likes;
  List<Comment> comments;
  String documentID;

  PostModel(
      {this.id,
      this.userId,
      this.user,
      this.caption,
      this.imageUrl,
      this.tagsUser,
      this.locations,
      this.timestamp,
      this.likes,
      this.comments,
      this.documentID});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json["id"],
      userId: json["userId"],
      user: User.fromMap(Map<String, dynamic>.from(json["user"])),
      caption: json["caption"],
      imageUrl: json["imageUrl"],
      tagsUser: List.of(json["tagsUser"])
          .map((i) => User.fromMap(Map<String, dynamic>.from(i)) /* can't generate it properly yet */)
          .toList(),
      locations: json["locations"],
      timestamp: json["timestamp"],
      likes: List.of(json["likes"])
          .map((i) => Like.fromMap(Map<String, dynamic>.from(i)) /* can't generate it properly yet */)
          .toList(),
      comments: List.of(json["comments"])
          .map((i) => Comment.fromMap(Map<String, dynamic>.from(i)) /* can't generate it properly yet */)
          .toList(),
      documentID:  json["documentID"]
    );
  }

  //https://firebasestorage.googleapis.com/v0/b/solo-adcfe.appspot.com/o/posts%2FVumUnSPCCxRu4bANEoslwH1nLWt2%2F1588843268531?alt=media&token=28c4fd58-d280-4d7d-b373-a14f6f58eb2b
  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "userId": this.userId,
      "user": this.user.toMap(),
      "caption": this.caption,
      "imageUrl": this.imageUrl,
      "tagsUser": List.of(tagsUser).map<Map<String,dynamic>>((user) {
        return user.toMap();
      }).toList(),
      "locations": this.locations,
      "timestamp": this.timestamp,
      "likes": List.of(likes).map<Map<String,dynamic>>((like) {
        return like.toMap();
      }).toList(),
      "comments": List.of(comments).map<Map<String,dynamic>>((comment) {
        return comment.toMap();
      }).toList(),
      "documentID": documentID
    };
  }
}

class Like extends BaseModel {
  String id;
  User user;

  Like({this.id, this.user});

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "user": this.user.toMap(),
    };
  }

  factory Like.fromMap(Map<String, dynamic> json) {
    return Like(
      id: json["id"],
      user: User.fromMap(Map<String, dynamic>.from(json["user"]))
    );
  }

  @override
  bool operator ==(other) {
    if(other is User) {
      return other.id == this.user.id;
    }
    if(other is Like) {
      return other.user.id == this.user.id;
    }
    return super==(other);
  }
}

class Comment extends BaseModel {
  String id;
  String comments;
  User user;
  String timestamp;

  Comment({this.id, this.comments, this.user,this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "comments": this.comments,
      "user": this.user.toMap(),
      "timestamp": this.timestamp,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      comments: json["comments"], timestamp: json["timestamp"],
      user: User.fromMap(Map<String, dynamic>.from(json["user"]))
    );
  }

  @override
  bool operator ==(other) {
    if(other is User) {
      return other.id == this.user.id;
    }
    if(other is Comment) {
      return other.id == this.id;
    }
    return super==(other);
  }
}
