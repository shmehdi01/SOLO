
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_error_code.dart';
import 'package:solo/network/api_service.dart';


class FirestoreManager {

   // ignore: avoid_init_to_null
   static Future<ApiResponse<bool>> insert({@required String collection, String document = null, @required Map<String, dynamic> data}) async {
     var apiResponse = ApiResponse<bool>();
     if(document != null)
       Firestore.instance.collection(collection).document(document).setData(data).catchError((onError) {
         print("Error aya: " + onError.message);
         print("Error aya Code: " + onError.code);
         apiResponse.hasError = true;
         apiResponse.error = (ApiError("${onError.message}", "${onError.code}"));
         apiResponse.success = false;
       });

     else await Firestore.instance.collection(collection).add(data).catchError((onError) {
         print("Error aya: " + onError.message);
         print("Error aya Code: " + onError.code);
         apiResponse.hasError = true;
         apiResponse.error = (ApiError("${onError.message}", "${onError.code}"));
         apiResponse.success = false;
       });

       apiResponse.success = true;

     return apiResponse;
  }

  static Future<ApiResponse<bool>> updateWithDocuments({@required String collection, @required String document ,@required Map<String, dynamic> data}) async {
    var apiResponse = ApiResponse<bool>();

     Firestore.instance.collection(collection).document(document).updateData(data).catchError((onError) {
       print("Error aya: " + onError.message);
       print("Error aya Code: " + onError.code);
       apiResponse.hasError = true;
       apiResponse.error = (ApiError("${onError.message}", "${onError.code}"));
       apiResponse.success = false;
     });

    return apiResponse;
  }

  static Future<ApiResponse<User>> readUserByID(String id) async {
     var apiResponse = ApiResponse<User>();

     var snapshot = await Firestore.instance.collection(Collection.USER).document(id).get()
     .catchError((onError) {
       apiResponse.hasError = true;
       apiResponse.error = ApiError.fromFirebaseError(onError);
     });

     if(snapshot.exists) {
       apiResponse.success = User.fromMap(snapshot.data);
     }
     else {
       apiResponse.hasError = true;
       apiResponse.error = ApiError("User Not Found", ErrorCode.USER_NOT_FOUND);
     }

     return apiResponse;
  }

  static Future<List<DocumentSnapshot>> getDocuments(String collection) async {
     var snapshot = await Firestore.instance.collection(collection).getDocuments();
    return snapshot.documents;
  }

  static Future<CollectionReference> getCollectionRef(String collection) async {
     var collectionRef = Firestore.instance.collection(collection);
    return collectionRef;
  }

}