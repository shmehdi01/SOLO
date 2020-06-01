import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solo/models/Collection.dart';
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
}
