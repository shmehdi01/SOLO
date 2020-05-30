import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solo/database/app_constants.dart';
import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/database/dao/UsereDao.dart';
import 'package:solo/database/entity/UserEntity.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/network/firebase/firebase_storage_manager.dart';
import 'package:solo/network/firebase/firestore_manager.dart';
import 'package:solo/utils.dart';

import 'models/Collection.dart';
import 'models/connections.dart';

class SessionManager implements SessionApi {
  ApiFlavor _apiFlavor;

  static User currentUser;
  static List<User> friendsList = [];

  SessionManager() {
    _apiFlavor = ApiProvider.apiFlavour;
  }

  @override
  Future<bool> isEmailVerified() async {
    bool isVerified = false;

    switch (_apiFlavor) {
      case ApiFlavor.FIREBASE:
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        isVerified = user != null && user.isEmailVerified;
        break;

      case ApiFlavor.NETWORK:
        isVerified = false;
        break;
    }

    return isVerified;
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return getUser() != null;
  }

  @override
  Future<void> signOut() {
    var response;

    switch (_apiFlavor) {
      case ApiFlavor.FIREBASE:
        response = FirebaseAuth.instance.signOut();
        break;

      case ApiFlavor.NETWORK:
        response = null;
        break;
    }

    ConnectionDao().deleteAll();
    UserDao().deleteAll();

    return response;
  }

  @override
  Future<User> getUser() async {
    User user;
    switch (_apiFlavor) {
      case ApiFlavor.FIREBASE:
        FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
        if (firebaseUser != null) {
          var readResp = await FirestoreManager.readUserByID(firebaseUser.uid);
          if (readResp.hasError)
            user = null;
          else {
            user = readResp.success;
            currentUser = readResp.success;
            //fetchAllFriends(currentUser);
          }
        } else
          user = null;
        break;
      case ApiFlavor.NETWORK:
        user = null;
        break;
    }
    return user;
  }

  @override
  Future<ApiResponse<void>> updateEmail(String email) {
    // TODO: implement updateEmail
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<void>> updatePassword(String password) {
    // TODO: implement updatePassword
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<void>> uploadProfile(User user) async {
    ApiResponse<void> apiResponse = ApiResponse();

    switch (_apiFlavor) {
      case ApiFlavor.FIREBASE:
        UserUpdateInfo updateInfo = new UserUpdateInfo();
        updateInfo.photoUrl = user.photoUrl;
        updateInfo.displayName = user.name;
        FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
        var response =
            await firebaseUser.updateProfile(updateInfo).catchError((onError) {
          apiResponse.hasError = true;
          apiResponse.error = ApiError.fromFirebaseError(onError);
        });

        apiResponse.success = response;
        break;
      case ApiFlavor.NETWORK:
        // TODO: Handle this case.
        break;
    }

    return apiResponse;
  }

  @override
  Future<ApiResponse<String>> updateImage(File file) async {
    ApiResponse<String> apiResponse = ApiResponse();

    switch (_apiFlavor) {
      case ApiFlavor.FIREBASE:
        User user = await getUser();
        String imgUrl =
            await FirebaseStorageManager.upload("$PROFILE/${user.id}", file);
        UserUpdateInfo updateInfo = new UserUpdateInfo();
        updateInfo.photoUrl = imgUrl;
        FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
        await firebaseUser.updateProfile(updateInfo).catchError((onError) {
          apiResponse.hasError = true;
          apiResponse.error = ApiError.fromFirebaseError(onError);
        });

        //UPDATING IMAGE URL TO FIRE STORE AFTER UPDATING TO AUTH
        Map<String, dynamic> data = new HashMap();
        data['photoUrl'] = imgUrl;
        var updateResp = await FirestoreManager.updateWithDocuments(
            collection: Collection.USER, document: user.id, data: data);

        apiResponse.hasError = updateResp.hasError;
        apiResponse.error = updateResp.error;

        user.photoUrl = imgUrl;
        apiResponse.success = imgUrl;
        break;
      case ApiFlavor.NETWORK:
        // TODO: Handle this case.
        break;
    }

    return apiResponse;
  }

  
  static Future<ApiResponse<List<User>>> cacheFollowing(User currentUser) async {
    ApiResponse<List<User>> apiResponse = ApiResponse();
    
    var _apiFlavor = ApiProvider.apiFlavour;
    var resp = await  ApiProvider.profileApi.getFollowing(currentUser);

    switch (_apiFlavor) {
      case ApiFlavor.FIREBASE:
        var apiResp = await fetchUsrByConnection(currentUser, resp.success, following: true);
        apiResponse.success = apiResp.success;
        break;
      case ApiFlavor.NETWORK:
        // TODO: Handle this case.
        break;
    }


//    //INSERT INTO DATABASE
//    var friendDao = UserDao();
//    friendDao.deleteAll();
//
//    developerLog("Following", apiResponse.success.length);
//    apiResponse.success.forEach((user) async {
//      var entity = UserEntity.fromUser(user, AppConstant.FOLLOWING);
//      await friendDao.insert(entity);
//    });


    return apiResponse;
  }

  static Future<ApiResponse<List<User>>> cacheFollower(User currentUser) async {
    ApiResponse<List<User>> apiResponse = ApiResponse();

    var _apiFlavor = ApiProvider.apiFlavour;
    var resp = await  ApiProvider.profileApi.getFollower(currentUser);

    switch (_apiFlavor) {
      case ApiFlavor.FIREBASE:
        var apiResp = await fetchUsrByConnection(currentUser, resp.success, following: false);
        apiResponse.success = apiResp.success;
        break;
      case ApiFlavor.NETWORK:
      // TODO: Handle this case.
        break;
    }
//
//    //INSERT INTO DATABASE
//    var friendDao = UserDao();
//    friendDao.deleteAll();
//
//    developerLog("Follower", apiResponse.success.length);
//    apiResponse.success.forEach((user) async{
//      var entity = UserEntity.fromUser(user, AppConstant.FOLLOWER);
//         await friendDao.insert(entity);
//    });


    return apiResponse;
  }


  static Future<ApiResponse<List<User>>> fetchUsrByConnection(User currentUser, List<Connection> connections, {@required bool following}) async {
    ApiResponse<List<User>> apiResponse = ApiResponse();

    var listUser = <User>[];
    var followingIds = <String>[];

    if(connections.length == 0) {

    }

    connections.forEach((con) {
      followingIds.add(following ? con.following: con.follower);
    });

    print(("IDs are : $followingIds"));

    var ref = await FirestoreManager.getCollectionRef(Collection.USER);
    var snap = await ref.where("id", whereIn: followingIds).getDocuments();

    print("List of User ${snap.documents.length}");
    snap.documents.forEach((f) {
      print(("Users are : " + User.fromMap(f.data).name));
      listUser.add(User.fromMap(f.data));
    });

    //apiResponse.hasError = listUser.length == 0;
    apiResponse.success = listUser;


    return apiResponse;
  }

  static Future<List<User>> loadFriends() async {
    var resp =
    await ApiProvider.profileApi.getFollowing(SessionManager.currentUser);
    if (!resp.hasError) {
      var respUsers = await SessionManager.fetchUsrByConnection(
          SessionManager.currentUser, resp.success,
          following: true);
      friendsList = respUsers.success;
      return respUsers.success;
    }
    return await ConnectionDao().getFollowing(SessionManager.currentUser.id);
  }
}
