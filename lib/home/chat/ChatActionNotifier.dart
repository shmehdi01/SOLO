import 'package:flutter/material.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';

import '../../session_manager.dart';

class ChatActionNotifier extends ChangeNotifier {

  final User currentUser;

  List<User> _myFollowers = [];
  List<User> _myFollowings = [];

  List<User> get myFollowings => _myFollowings;
  List<User> get myFollowers => _myFollowers;

  bool _loader = false;

  bool get loader => _loader;

  ChatActionNotifier(this.currentUser) {
    fetchFollowers();
    fetchFollowing();
  }

  void fetchFollowers() async {
    _loader = true;
    var user =  currentUser;
    var resp = await ApiProvider.profileApi.getFollower(user);

    if (!resp.hasError) {
      var respUsers = await SessionManager.fetchUsrByConnection(
          user, resp.success,
          following: false);
      _myFollowers = respUsers.success;

      _loader = false;
      notifyListeners();
    }
  }

  void fetchFollowing() async {
    _loader = true;

    var user = currentUser;
    var resp = await ApiProvider.profileApi.getFollowing(user);

    if (!resp.hasError) {

      var respUsers = await SessionManager.fetchUsrByConnection(
          user, resp.success,
          following: true);
      _myFollowings = respUsers.success;

      _loader = false;
      notifyListeners();
    }

  }
}