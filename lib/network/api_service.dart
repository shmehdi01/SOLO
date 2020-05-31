import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:solo/home/chat/chat_page.dart';
import 'package:solo/home/chat/chat_screen.dart';
import 'package:solo/models/chat_model.dart';
import 'package:solo/models/connections.dart';
import 'package:solo/models/follow_detail.dart';
import 'package:solo/models/notification_detail.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/session_manager.dart';

///[ApiResponse] is use in whole app to calling api and getting response
///[T] is generic data type is use to get success from api
///[hasError] will tell you either it has an error or not.
///[error] contains all the information related to ApiError.
class ApiResponse<T> {
  T success;
  ApiError error;
  bool hasError = false;
}

///To get error in api used [ApiError] to find
///errorMessage[errorMsg] and errorCode[errorCode] respectively
class ApiError {
  final String errorMsg;
  final String errorCode;

  ApiError(this.errorMsg, this.errorCode);

  factory ApiError.fromFirebaseError(onError) {
    return ApiError("${onError.message}", "${onError.code}");
  }
}

///[LoginApi] use to implement your logic for Login.
abstract class LoginApi {
  Future<ApiResponse<User>> login(String email, String password);

  Future<ApiResponse<String>> resetPassword(String email);

  Future<ApiResponse<User>> googleSignInApp();

  Future<ApiResponse<User>> facebookLogin();
}

///[SignUpApi] use to implement your logic for SignUp.
abstract class SignUpApi {
  Future<ApiResponse<User>> signUp(User user, String password);

  Future<ApiResponse<String>> sendEmailVerification();
}

///[SessionApi] implement to manage session according to flavour configuration.
abstract class SessionApi {
  @deprecated
  Future<bool> isUserLoggedIn();

  Future<User> getUser();

  @deprecated
  Future<bool> isEmailVerified();

  Future<void> signOut();

  Future<ApiResponse<String>> updateImage(File imgUrl);

  Future<ApiResponse<void>> uploadProfile(User user);

  Future<ApiResponse<void>> updatePassword(String password);

  Future<ApiResponse<void>> updateEmail(String email);
}

///[ProfileApi] implement to manage your profile logic
abstract class ProfileApi {
  Future<ApiResponse<Connection>> followUser(Connection connection);

  Future<ApiResponse<void>> unFollowUser(Connection connection);

  Future<ApiResponse<Connection>> isFollowing(User follower, User following);

  Future<ApiResponse<List<Connection>>> getFollower(User currentUser);

  Future<ApiResponse<List<Connection>>> getFollowing(User currentUser);

  Future<ApiResponse<void>> getPhotos(User currentUser);

  Future<ApiResponse<void>> updatePushToken(User user);

  Future<ApiResponse<void>> updateBio(User user, String bio);

  Future<ApiResponse<void>> changeBackground(User user, File file);

  Future<ApiResponse<void>> deleteAccount();
}

///[ExploreApi] implement explore api
abstract class ExploreApi {
  Future<ApiResponse<List<User>>> searchUser({@required String query});
}


///[NotificationApi]
abstract class NotificationApi {
  Future<ApiResponse<bool>> createNotification(NotificationDetail notificationDetail);

  Future<ApiResponse<List<NotificationDetail>>> fetchNotification(User user);

  Stream<List<NotificationDetail>> fetchNotificationStream(User user);

  Future<ApiResponse<bool>> updateNotification(NotificationDetail notificationDetail);
}

///[ChatApi]
abstract class ChatApi {
  Stream<List<ChatModel>> fetchChat(String chatID);
  Future<void> sendMessage(String userID, ChatModel chatModel, String chatID);
  Future<void> clearChat(String userID, String chatID);
  Future<void> clearChatByID(String userID, String chatID, String msgID);
  Future<void> deleteChat(String userID, String chatID);
  Stream<List<ChatListModel>> fetchAllChat(String userID);
  Future<void> setChatList(ChatListModel chatListModel, chatID, String userID);
  Future<void> updateChatList(Map<String, dynamic> map, chatID, String userID);
}


abstract class HomeApi {
  Future<ApiResponse<User>> fetchUserByID(String id);
  Future<ApiResponse<void>> createPost(PostModel postModel, File imageFile);
  Future<ApiResponse<List<PostModel>>> fetchPosts();
  Stream<List<PostModel>> fetchPostsStream({String onlyForID = ""});
  Future<ApiResponse<void>> likePost(User user, PostModel postModel, {bool removeLike = false});
  Future<ApiResponse<void>> commentPost(User user, PostModel postModel, Comment comment);
  Future<ApiResponse<void>> deletePost(PostModel postModel);
  Future<ApiResponse<void>> deleteComment(PostModel postModel, Comment comment);
  Stream<ApiResponse<PostModel>> fetchSinglePost(String postId);
}


