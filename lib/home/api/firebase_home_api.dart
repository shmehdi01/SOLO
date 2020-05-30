import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solo/home/notifications/api/push_notification.dart';
import 'package:solo/home/notifications/api/push_notification_manager.dart';
import 'package:solo/location/locationPage.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/notification_detail.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/network/firebase/firebase_storage_manager.dart';
import 'package:solo/network/firebase/firestore_manager.dart';
import 'package:solo/session_manager.dart';

import '../../utils.dart';

class FirebaseHomeApi extends HomeApi {
  @override
  Future<ApiResponse<User>> fetchUserByID(String id) {
    return FirestoreManager.readUserByID(id);
  }

  @override
  Future<ApiResponse<void>> createPost(
      PostModel postModel, File imageFile) async {
    var apiResponse = ApiResponse<void>();

    if (imageFile != null) {
      postModel.imageUrl = await FirebaseStorageManager.upload(
              "${Collection.POST_STORAGE_LOCATION}/${SessionManager.currentUser.id}/${postModel.id}",
              imageFile)
          .catchError((onError) {
        apiResponse.hasError = true;
        apiResponse.error = ApiError.fromFirebaseError(onError);
      });
    }

    print("POST JSON : ${postModel.toMap()}");

    var docRef = await Firestore.instance
        .collection(Collection.POSTS)
        .add(postModel.toMap())
        .catchError((onError) {
      apiResponse.hasError = true;
      print("Create POST : ERROR : ${onError}");
      //apiResponse.error = ApiError.fromFirebaseError(onError);
    });

    if (!apiResponse.hasError) {
      var map = Map<String, dynamic>();
      map["documentID"] = docRef.documentID;
      docRef.updateData(map);

      postModel.tagsUser.forEach((user) {
        PushNotificationBuilder(
                title:
                    "${SessionManager.currentUser.name} is tagged you in a post",
                message: "${postModel.caption}",
                image: postModel.imageUrl,
                token: user.pushToken)
            .createToken()
            .sendNotification();

        //UPLOAD TO FIRE STORE NOTIFICATION
        ApiProvider.notificationApi.createNotification(NotificationDetail(
          message: "${SessionManager.currentUser.name} is tagged you in a post",
          type: NotificationType.POST,
          id: user.id,
          intentId: postModel.id,
          isRead: false,
          fromId: SessionManager.currentUser.id,
          timestamp: Utils.timestamp(), imageUrl: postModel.imageUrl, addtionalMsg: postModel.caption,
        ));
      });
    }

    return apiResponse;
  }

  @override
  Future<ApiResponse<List<PostModel>>> fetchPosts() async {
    final apiResponse = ApiResponse<List<PostModel>>();

    var myfriends = SessionManager.friendsList;

    if (myfriends.isEmpty) {
      myfriends = await SessionManager.loadFriends();
    }

    print("USER TO FETCH POST : ${myfriends.length}");

    final ids = myfriends.map<String>((user) {
      return user.id;
    }).toList();

    ids.add(SessionManager.currentUser.id);

    final resp = await Firestore.instance
        .collection(Collection.POSTS)
        .where("userId", whereIn: ids)
        .getDocuments();

    print("RESP ${resp.documents.length}");

    final list = <PostModel>[];
    resp.documents.forEach((doc) {
      list.add(PostModel.fromJson(doc.data));
    });

    list.sort((o1, o2) {
      return int.parse(o2.timestamp) - int.parse(o1.timestamp);
    });

    apiResponse.success = list;
    print("Post SIZE IS ${list.length}");

    return apiResponse;
  }

  @override
  Stream<List<PostModel>> fetchPostsStream() {
    var myfriends = SessionManager.friendsList;

//    if (myfriends.isEmpty) {
       SessionManager.loadFriends();
//    }

    print("USER TO FETCH POST : ${myfriends.length}");

    final ids = myfriends.map<String>((user) {
      return user.id;
    }).toList();

    ids.add(SessionManager.currentUser.id);

    final resp = Firestore.instance
        .collection(Collection.POSTS)
        .where("userId", whereIn: ids)
        .snapshots();

    var x = resp.map((convert) {
      final list = <PostModel>[];
      if (convert.documents.isEmpty) {
        return list;
      }
      convert.documents.forEach((doc) {
        list.add(PostModel.fromJson(doc.data));
      });

      list.sort((o1, o2) {
        return int.parse(o2.timestamp) - int.parse(o1.timestamp);
      });

      return list;
    });

    return x;
  }

  @override
  Future<ApiResponse<void>> commentPost(User user, PostModel postModel, Comment comment) async {
    final apiResponse = ApiResponse<void>();

    postModel.comments.add(comment);

    await Firestore.instance.collection(Collection.POSTS).document(postModel.documentID)
    .updateData(postModel.toMap()).catchError((onError) {
      apiResponse.hasError = true;
    });

    if(postModel.userId != user.id) {
      fetchUserByID(postModel.userId).then((postUser) {
        PushNotificationBuilder(
            title: "${user.name} is commented on your post",
            message: "${comment.comments}",
            image: postModel.imageUrl,
            token: postUser.success.pushToken)
            .createToken()
            .sendNotification();

        //SUBSCRIBE POST ALSO
        PushNotificationsManager.instance.subscribeToTopic(postModel.id);

        //UPLOAD TO FIRE STORE NOTIFICATION
        ApiProvider.notificationApi.createNotification(NotificationDetail(
          message: "${user.name} is commented on your post",
          type: NotificationType.POST,
          id: postUser.success.id,
          intentId: postModel.id,
          isRead: false,
          fromId: SessionManager.currentUser.id,
          timestamp: Utils.timestamp(), imageUrl: postModel.imageUrl, addtionalMsg: comment.comments,
        ));
      });
    }


    PushNotificationBuilder(
        title: "${user.name} is commented on post",
        message: "${comment.comments}",
        image: postModel.imageUrl,
        topic: postModel.id)
        .createTopic()
        .sendNotification();


    return apiResponse;
  }

  @override
  Future<ApiResponse<void>> likePost(User user, PostModel postModel,
      {bool removeLike = false}) async {
    final apiResponse = ApiResponse<void>();

    if (!removeLike) {
      final like = Like(id: Uuid().generateV4(), user: user);
      postModel.likes.add(like);

      //IF NOT MY POST
      if(user.id != postModel.userId) {
        //CREATE NOTIFICATION;

        fetchUserByID(postModel.userId).then((postUser) {
          PushNotificationBuilder(
              title: "1 New Like",
              message: "${user.name} liked your post ${postModel.caption}",
              image: postModel.imageUrl,
              token: postUser.success.pushToken)
              .createToken()
              .sendNotification();

          //UPLOAD TO FIRE STORE NOTIFICATION
          ApiProvider.notificationApi.createNotification(NotificationDetail(
            message: "${SessionManager.currentUser.name} liked your post",
            type: NotificationType.POST,
            id: postUser.success.id,
            intentId: postModel.id,
            isRead: false,
            fromId: SessionManager.currentUser.id,
            timestamp: Utils.timestamp(), imageUrl: postModel.imageUrl, addtionalMsg: postModel.caption,
          ));
        });

      }

    } else {
      final index = postModel.likes.indexOf(Like(id: "", user: user));
      postModel.likes.removeAt(index);
    }

    print("Liking");
    print(postModel.toMap());

    await Firestore.instance
        .collection(Collection.POSTS)
        .document(postModel.documentID)
        .updateData(postModel.toMap())
        .catchError((onError) {
      print(onError);
      apiResponse.hasError = true;
    });

    return apiResponse;
  }
}
