
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/connections.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/network/firebase/firebase_storage_manager.dart';
import 'package:solo/network/firebase/firestore_manager.dart';

class FirebaseProfileApi extends ProfileApi {
  @override
  Future<ApiResponse<Connection>> followUser(Connection connection) async {
    var apiResponse = ApiResponse<Connection>();

    var insertResp = await FirestoreManager.insert(
        collection: Collection.CONNECTION, data: connection.toMap());

    if (insertResp.success) {
      apiResponse.success = connection;
    } else {
      apiResponse.hasError = insertResp.hasError;
      apiResponse.error = insertResp.error;
    }

    return apiResponse;
  }

  @override
  Future<ApiResponse<List<Connection>>> getFollower(User currentUser) async {
    var apiRef = ApiResponse<List<Connection>>();

    print("test Follower");

    var ref = await FirestoreManager.getCollectionRef(Collection.CONNECTION)
        .catchError((onError) {
      apiRef.hasError = true;
      apiRef.error = ApiError.fromFirebaseError(onError);
    });

    var snapshot = await ref
        .where("following", isEqualTo: currentUser.id)
        .getDocuments()
        .catchError((onError) {
      apiRef.hasError = true;
      apiRef.error = ApiError.fromFirebaseError(onError);
    });

    print("test Follower ${snapshot.documents.length}");

    var list = List<Connection>();

    snapshot.documents.forEach((f) {
      Connection connection = Connection.fromMap(f.data);
      list.add(connection);
    });

    apiRef.success = list;

    return apiRef;
  }

  @override
  Future<ApiResponse<List<Connection>>> getFollowing(User currentUser) async {
    var apiRef = ApiResponse<List<Connection>>();

    print("test Following");

    var ref = await FirestoreManager.getCollectionRef(Collection.CONNECTION)
        .catchError((onError) {
      apiRef.hasError = true;
      apiRef.error = ApiError.fromFirebaseError(onError);
    });

    var snapshot = await ref
        .where("follower", isEqualTo: currentUser.id)
        .getDocuments()
        .catchError((onError) {
      apiRef.hasError = true;
      apiRef.error = ApiError.fromFirebaseError(onError);
    });

    print("test Following ${snapshot.documents.length}");

    var list = List<Connection>();

    snapshot.documents.forEach((f) {
      Connection connection = Connection.fromMap(f.data);
      list.add(connection);
    });

    apiRef.success = list;

    return apiRef;
  }

  @override
  Future<ApiResponse<void>> getPhotos(User currentUser) {
    // TODO: implement getPhotos
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Connection>> isFollowing(
      User currentUser, User otherUser) async {
    var apiRef = ApiResponse<Connection>();

    print("test lro");

    var ref = await FirestoreManager.getCollectionRef(Collection.CONNECTION)
        .catchError((onError) {
      apiRef.hasError = true;
      apiRef.error = ApiError.fromFirebaseError(onError);
    });

    var snapshot = await ref
        .where("follower", isEqualTo: currentUser.id)
        .where("following", isEqualTo: otherUser.id)
        .getDocuments()
        .catchError((onError) {
      apiRef.hasError = true;
      apiRef.error = ApiError.fromFirebaseError(onError);
    });

    print("test lro2 ${snapshot.documents}");

    if (snapshot.documents.length > 0) {
      Connection connection = Connection.fromMap(snapshot.documents[0].data);
      apiRef.success = connection;
    } else {
      apiRef.success = null;
    }

    return apiRef;
  }

  @override
  Future<ApiResponse<void>> unFollowUser(Connection connection) async {
    var apiResp = ApiResponse<void>();

    var ref = await FirestoreManager.getCollectionRef(Collection.CONNECTION);

    var snapshot = await ref
        .where("follower", isEqualTo: connection.follower)
        .where("following", isEqualTo: connection.following)
        .getDocuments()
        .catchError((onError) {
      apiResp.hasError = true;
      apiResp.error = ApiError.fromFirebaseError(onError);
    });

    var docID = snapshot.documents[0].documentID;
    ref.document(docID).delete();

    return apiResp;
  }

  @override
  Future<ApiResponse<void>> updatePushToken(User user) async {
    Map<String,dynamic> map = Map();
    map['pushToken'] = user.pushToken;

    FirestoreManager.updateWithDocuments(collection: Collection.USER, document: user.id, data: map);

    return null;
  }

  @override
  Future<ApiResponse<void>> updateBio(User user, String bio) async {
    Map<String,dynamic> map = Map();
    map['bio'] = bio;

    FirestoreManager.updateWithDocuments(collection: Collection.USER, document: user.id, data: map);

    return null;
  }

  @override
  Future<ApiResponse<void>> changeBackground(User user, File file) async{

    final response = ApiResponse<void>();

    final downloadUrl = await FirebaseStorageManager.upload("${Collection.BANNERS_STORAGE}/${user.id}", file)
    .catchError((onError) {
      response.hasError = true;
      response.error = ApiError.fromFirebaseError(onError);

    });

    user.bannerUrl = downloadUrl;
     await Firestore.instance.collection(Collection.USER).document(user.id).updateData(user.toMap())
        .catchError((onError) {
      response.hasError = true;
      response.error = ApiError.fromFirebaseError(onError);

    });

    return response;
  }

  @override
  Future<ApiResponse<void>> deleteAccount() {

  }

}
