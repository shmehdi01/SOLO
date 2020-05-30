import 'package:flutter/material.dart';
import 'package:solo/database/app_constants.dart';
import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/database/dao/UsereDao.dart';
import 'package:solo/home/notifications/api/push_notification.dart';
import 'package:solo/models/connections.dart';
import 'package:solo/models/follow_detail.dart';
import 'package:solo/models/notification_detail.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/utils.dart';

import '../../session_manager.dart';

class ProfileActionNotifier with ChangeNotifier {
  final User currentUser;
  final User otherUser;
  ConnectionDao connectionDao = ConnectionDao();
  UserDao userDao = UserDao();

  ProfileActionNotifier(
      {@required this.currentUser, @required this.otherUser}) {
    refresh();
  }

  void refresh() {
    if (otherUser != null) {
      _checkIsFollowing(currentUser, otherUser);
    }

    fetchPhotos();
    fetchFollowers();
    fetchFollowing();
  }

  int _topAction = 1;
  bool _isFollowing = false;
  int _photoCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  Connection followingConnection;

  List<User> _myFollowers = [];
  List<User> _myFollowings = [];

  int get getTopAction => _topAction;

  bool get isFollowing => _isFollowing;

  int get photoCount => _photoCount;

  int get followerCount => _followerCount;

  int get followingCount => _followingCount;

  List<User> get myFollowings => _myFollowings;

  List<User> get myFollowers => _myFollowers;

  set setTopAction(int action) {
    _topAction = action;
    notifyListeners();
  }

  void _checkIsFollowing(User follower, User following) async {
    var resp = await ApiProvider.profileApi.isFollowing(follower, following);

    if (resp.hasError)
      _isFollowing = false;
    else {
      followingConnection = resp.success;
      _isFollowing = followingConnection != null;
    }


//      followingConnection =  await connectionDao.isFollowing(follower.id, following.id);
//      _isFollowing = followingConnection != null;

    notifyListeners();
  }

  void fetchPhotos() async {}

  void fetchFollowers() async {
    var user = otherUser != null ? otherUser : currentUser;
    var resp = await ApiProvider.profileApi.getFollower(user);

    if (!resp.hasError) {
      _followerCount = resp.success.length;
      var respUsers = await SessionManager.fetchUsrByConnection(
          user, resp.success,
          following: false);
      _myFollowers = respUsers.success;

      notifyListeners();
    }

//    _myFollowers = await connectionDao.getFollowers(user.id);
//    _followerCount = _myFollowers.length;

//    notifyListeners();

  }

  void fetchFollowing() async {
    var user = otherUser != null ? otherUser : currentUser;
    var resp = await ApiProvider.profileApi.getFollowing(user);

    if (!resp.hasError) {
      _followingCount = resp.success.length;
      var respUsers = await SessionManager.fetchUsrByConnection(
          user, resp.success,
          following: true);
      _myFollowings = respUsers.success;
      notifyListeners();
    }

//  _myFollowings = await connectionDao.getFollowing(user.id);
//  _followingCount = _myFollowings.length;
//
//  notifyListeners();

  }

  void followUser(BuildContext context, String myID, User other,
      {String msg = "Hi, I want to connect with you",
      bool notifyPage = true}) async {

    var connection = Connection(
        follower: myID,
        following: other.id,
        time: DateTime.now().toString(),
        message: msg);

    var result = await ApiProvider.profileApi.followUser(connection);

    if (result.hasError) {

      showSnack(context, result.error.errorMsg);
    } else {
      if (notifyPage) {
        showSnack(context, "You are started to following ${other.name}");
        _isFollowing = true;

        //INSERT CONNECTION INTO DB
        connection.isSync = 1;
        await connectionDao.insert(connection);

        //CHECK IF USER NOT IN DB INSERT
        var user = await userDao.findEntityByID(other.id);
        if(user == null) {
          print("User insering");
          await userDao.insert(other);
        }
        else {
          print("User was exist");
        }

        fetchFollowers();
        notifyListeners();
      }

      //CREATE A FOLLOW NOTIFICATION OBJECT
      var followDetail =  FollowDetail.fromConnection(currentUser.name, connection);

      //UPLOAD TO FIRE STORE NOTIFICATION
      ApiProvider.notificationApi.createNotification(
          NotificationDetail.fromFollowDetail(followDetail));

      //PUSH NOTIFICATION
      PushNotificationBuilder(
              message: "${followDetail.followerName} has started following you",
              title: "New Follower",
              token: other.pushToken)
          .createToken()
          .sendNotification();

      //UPDATE TO REALTIME DATABASE
      //LocalPushNotification.sendFollowNotification(followDetail);

      SessionManager.loadFriends();
    }
  }

  void unFollowUser(Connection connection, BuildContext context,
      {bool notifyPage = true}) async {

    //UPDATE LOCALLY
    connection.isSync = 0;
    await connectionDao.updateByID(connection, "${connection.id}");

    if (notifyPage) {
      _isFollowing = false;
      fetchFollowers();
      notifyListeners();
    }

    //REMOVE FROM SERVER
    var result = await ApiProvider.profileApi.unFollowUser(connection);

    if (result.hasError) {
      showSnack(context, result.error.errorMsg);
      //IF FAILED UPDATE TO 1
      connection.isSync = 1;
      await connectionDao.updateByID(connection, "${connection.id}");
    }
    else {
      connectionDao.deleteByID("${connection.id}");
    }

//    if (notifyPage) {
//      _isFollowing = false;
//      fetchFollowers();
//      notifyListeners();
//    }
  }
}
