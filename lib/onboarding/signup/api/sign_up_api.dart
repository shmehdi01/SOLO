import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_error_code.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/network/firebase/firestore_manager.dart';

class FirebaseSignUp implements SignUpApi {
  @override
  Future<ApiResponse<User>> signUp(User user, String password) async {
    ApiResponse<User> apiResponse = ApiResponse();

    AuthResult result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: user.email, password: password)
        .catchError((onError) {
      apiResponse.hasError = true;
      apiResponse.error = ApiError.fromFirebaseError(onError);
    });

    if (result != null) {
      FirebaseUser firebaseUser = result.user;
      UserUpdateInfo userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.displayName = user.name;
      await firebaseUser.updateProfile(userUpdateInfo).catchError((onError) {
        apiResponse.hasError = true;
        apiResponse.error = ApiError.fromFirebaseError(onError);
      });
      var newUser = User.fromFirebaseUser(firebaseUser);

      newUser.name = user.name;

      //INSERT USER INFORMATION TO FIRE STORE DATABASE
      var insertRes = await FirestoreManager.insert(
          collection: Collection.USER,
          document: newUser.id,
          data: newUser.toMap());

      apiResponse.hasError = insertRes.hasError;
      apiResponse.error = insertRes.error;

      //IF INSERTION THROW ANY ERROR DELETE USER FROM AUTH
      if (insertRes.hasError) {
        firebaseUser.delete();
        print("User Deleted (${firebaseUser.email})");
      }

      apiResponse.success = newUser;
    } else
      apiResponse.success = null;

    return apiResponse;
  }

  @override
  Future<ApiResponse<String>> sendEmailVerification() async {
    ApiResponse<String> apiResponse = ApiResponse();

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      apiResponse.hasError = true;
      apiResponse.error =
          ApiError("User not logged in", ErrorCode.USER_NOT_LOGGED_IN);
    } else {
      await user.sendEmailVerification().catchError((onError) {
        apiResponse.hasError = true;
        apiResponse.error = ApiError.fromFirebaseError(onError);
      });

      apiResponse.success =
          "A verification link has been sent your ${user.email}";
    }

    return apiResponse;
  }

  @override
  Future<bool> checkUserNameAvailability(String username) async {
    bool isAvailable = true;
    final s = await Firestore.instance
        .collection(Collection.USER)
        .where("username", isEqualTo: username)
        .getDocuments();
    isAvailable = s.documents.length == 0;

    return isAvailable;
  }
}
