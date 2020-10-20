import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_error_code.dart';
import 'package:solo/network/api_service.dart';

class FirebaseExploreApi extends ExploreApi {
  @override
  Future<ApiResponse<List<User>>> searchUser({String query}) async {
    var apiResponse = ApiResponse<List<User>>();

    var snapshot =
        await Firestore.instance.collection(Collection.USER).getDocuments();

    var list = List<User>();

    snapshot.documents.forEach((f) {
      if (f.data['name']
              .toString()
              .toLowerCase()
              .startsWith(query.toLowerCase()) ||
          f.data['email']
              .toString()
              .toLowerCase() == (query.toLowerCase()) ||
          f.data['username']
              .toString()
              .toLowerCase() == (query.toLowerCase())) {
        list.add(User.fromMap(f.data));
      }
     // list.add(User.fromMap(f.data));
    });

    if(list.isNotEmpty) {
      apiResponse.success = list;
    }
    else {
      apiResponse.hasError = true;
      apiResponse.error = ApiError("No Result Found", ErrorCode.NO_RESULT_FOUND);
    }

    return apiResponse;
  }

  @override
  Future<ApiResponse<List<PostModel>>> explorePost(String time) async {

    debugPrint("fetching time : $time");

    final response = ApiResponse<List<PostModel>>();

    final snap = await Firestore.instance.collection(Collection.POSTS)
    .where("timestamp", isGreaterThan: time)
    .orderBy("timestamp", descending: true)
    .getDocuments();

    final list = <PostModel>[];
    snap.documents.forEach((element) {
      list.add(PostModel.fromJson(element.data));
    });

    response.success = list;


    list.sort((a,b) {
      return b.likes.length.compareTo(a.likes.length) ;
    });


    return response;
  }

  @override
  Future<ApiResponse<Map<String,List<PostModel>>>> trendingTags(String time) async {
    final response = await explorePost(time);
    final map = Map<String,List<PostModel>>();

    response.success.forEach((post) {
      if(post.hashTags != null) {
        post.hashTags.forEach((tag) {
          if(tag != null)  {
            if(map.containsKey(tag)) {
              final list = map[tag];
              list.add(post);
            }
            else {
              map[tag] = List()..add(post);
            }
          }
        });
      }
    });

    return ApiResponse<Map<String,List<PostModel>>>()..success = map;
  }

  @override
  Future<ApiResponse<List<String>>> searchTopic({String query}) async {
    final response = ApiResponse<List<String>>();

    final doc = await Firestore.instance.collection(Collection.POSTS)
    .where("hashTags", arrayContains: "#$query")
    .getDocuments();

    final map = HashMap<String,String>();

    final list = <String>[];

    doc.documents.forEach((element) {

      final model = PostModel.fromJson(element.data);
//
//      if(!map.containsKey(element)) {
//        list.add(element.);
//      }
    });

    return response;
  }
}
