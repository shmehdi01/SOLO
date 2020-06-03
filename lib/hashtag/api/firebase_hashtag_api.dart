import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/network/api_service.dart';

class FirebaseHashTagApi extends HashTagApi {
  @override
  Future<ApiResponse<List<PostModel>>> fetchHashTagPost(String hashTag) async {
    final response = ApiResponse<List<PostModel>>();

    final snap = await Firestore.instance
        .collection(Collection.POSTS)
        .where("hashTags", arrayContains: hashTag)
        .getDocuments();

    final list = <PostModel>[];
    snap.documents.forEach((element) {
      list.add(PostModel.fromJson(element.data));
    });
    response.success = list;

    return response;
  }
}
