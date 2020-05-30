import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/database/dao/UsereDao.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/connections.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/service/sync_service.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

class HomeActionNotifier with ChangeNotifier {
  FirebaseUser _user;
  User _currentUser;

  HomePageState _homePageState = HomePageState.HOME;

  HomePageState get pageState => _homePageState;

  FirebaseUser get user => _user;

  int notificationCount = 0;
  int unReadMessage = 0;

  set updatePage(HomePageState state) {
    _homePageState = state;
    notifyListeners();
  }

  Future<void> initializeHome() async {
    _currentUser = SessionManager.currentUser;

    ApiProvider.notificationApi.fetchNotificationStream(_currentUser)
    .listen((onData) {

      notificationCount = onData.where((test) => !test.isRead).length;
      print("Data Change");
      notifyListeners();
    });

    ApiProvider.chatAPi.fetchAllChat(_currentUser.id).listen((onData) {
      unReadMessage = onData.where((test) => !test.isRead && test.senderID != _currentUser.id).length;
      notifyListeners();
    });

    await SessionManager.loadFriends();
    notifyListeners();
  }

  Future<List<PostModel>> fetchPost() async {
    final resp = await ApiProvider.homeApi.fetchPosts();
    return resp.success;
  }

  Future<Null> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  void refreshUI() {
    notifyListeners();
  }
}

enum HomePageState { HOME, EXPLORE, CHAT, PROFILE }


