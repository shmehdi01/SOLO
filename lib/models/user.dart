import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:solo/home/chat/chat_page.dart';
import 'package:solo/models/base_model.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/onboarding/enums.dart';

class User extends BaseModel {

  String id;
  String name;
  String email;
  String phone;
  String photoUrl;
  String bannerUrl;
  String gender;
  String bio;
  bool isEmailVerified;
  int accountType = Privacy.public;
  String pushToken;
  int isSync;
  String username;
  String mobile;

  User({this.id, this.name, this.email, this.phone, this.photoUrl, this.bannerUrl, this.bio, this.isEmailVerified,
      this.accountType, this.pushToken, this.isSync, this.gender, this.mobile,this.username});

  Future<ApiResponse<String>> sendEmailVerification() async {
    return ApiProvider.signUpApi.sendEmailVerification();
  }

  factory User.fromFirebaseUser(FirebaseUser user) {
    return User(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      phone: user.phoneNumber,
      photoUrl: user.photoUrl,
      isEmailVerified: user.isEmailVerified,
      accountType: Privacy.public,
      gender: "",
      username: "",
      mobile: user.phoneNumber,
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      bannerUrl: map['bannerUrl'],
      bio: map['bio'],
      isEmailVerified: map['isEmailVerified'] == 1 ,
      accountType: map['accountType'],
      pushToken: map['pushToken'],
      isSync: map['isSync'],
      gender: map['gender'],
      username: map['username'],
      mobile: map['mobile'],
    );
  }

  
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new HashMap();

    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['photoUrl'] = photoUrl;
    map['bannerUrl'] = bannerUrl;
    map['bio'] = bio;
    map['isEmailVerified'] = isEmailVerified ? 1:0;
    map['accountType'] = accountType;
    map['pushToken'] = pushToken;
    map['isSync'] = isSync;
    map['gender'] = gender;
    map['mobile'] = mobile;
    map['username'] = username;

    return map;
  }

  @override
  bool operator ==(other) {
    if(other is User) {
      return other.id == id;
    }
    return super==(other);
  }

}