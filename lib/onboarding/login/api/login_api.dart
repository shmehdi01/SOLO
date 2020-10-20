import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:solo/home/notifications/api/push_notification_manager.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_error_code.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/network/firebase/firestore_manager.dart';

import '../../../utils.dart';

class FirebaseLogin implements LoginApi {
  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    ApiResponse<User> apiResponse = ApiResponse();

    AuthResult result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((onError) {
      apiResponse.hasError = true;
      apiResponse.error = ApiError(onError.message, onError.code);
    });

    if (result != null) {
      //READING FROM FIRE STORE DATABASE
      var readResp = await FirestoreManager.readUserByID(result.user.uid);
      readResp.success.isEmailVerified = result.user.isEmailVerified;
      apiResponse.error = readResp.error;
      apiResponse.hasError = readResp.hasError;

      apiResponse.success = readResp.success;  //User.fromFirebaseUser(result.user);
    }
    else
      apiResponse.success = null;


    return apiResponse;
  }

  @override
  Future<ApiResponse<String>> resetPassword(String email) async {
    ApiResponse<String> apiResponse = ApiResponse();

    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .catchError((onError) {
      apiResponse.hasError = true;
      apiResponse.error = ApiError(onError.message, onError.code);
    });

    apiResponse.success = "A Email has been send to you $email";

    return apiResponse;
  }

  @override
  Future<ApiResponse<User>> googleSignInApp() async {
    ApiResponse<User> apiResponse = ApiResponse();
    log(1);
    final GoogleSignInAccount googleSignInAccount =
        await GoogleSignIn().signIn().catchError((onError) {
      apiResponse.hasError = true;
      print("yaha aya ${onError.code}");
      apiResponse.error = ApiError("${onError.message}", onError.code);
    });
    print(googleSignInAccount);
    if (googleSignInAccount == null) {
      apiResponse.hasError = true;
      apiResponse.error = ApiError("Cancelled by You", ErrorCode.CANCELLED_BY_USER);
      return apiResponse;
    }
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication.catchError((onError) {
      apiResponse.hasError = true;
      apiResponse.error = ApiError("${onError.message}", onError.code);
    });
    log(3);
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    log(4);
    final FirebaseAuth _auth = FirebaseAuth.instance;


    AuthResult result =
        await _auth.signInWithCredential(credential).catchError((onError) {
      apiResponse.hasError = true;
      apiResponse.error = ApiError(onError.message, onError.code);
    });


    if (result != null) {

      //CHECK IF ALREADY USER OR NOT
      var readResp = await FirestoreManager.readUserByID(result.user.uid);
      if(readResp.hasError && readResp.error.errorCode == ErrorCode.USER_NOT_FOUND) {

        var newUser = User.fromFirebaseUser(result.user);

        //INSERT USER INFORMATION TO FIRE STORE DATABASE
        var insertRes = await FirestoreManager.insert(collection: Collection.USER, document: newUser.id, data: newUser.toMap());

        apiResponse.hasError = insertRes.hasError;
        apiResponse.error = insertRes.error;

        //IF INSERTION THROW ANY ERROR DELETE USER FROM AUTH
        if(insertRes.hasError) {
          result.user.delete();
          print("User Deleted (${result.user.email})");
        }

        newUser.isEmailVerified = result.user.isEmailVerified;
        apiResponse.success = newUser;
      }

      else {
        apiResponse.success = readResp.success;
      }


     }

    else {
      apiResponse.hasError = true;
      apiResponse.error = ApiError("User not found", ErrorCode.USER_NOT_FOUND);
    }

    return apiResponse;
  }

  @override
  Future<ApiResponse<User>> facebookLogin() async {
    ApiResponse<User> apiResponse = ApiResponse();

    FacebookLogin facebookLogin = FacebookLogin();
    FacebookLoginResult fbResult =
        await facebookLogin.logIn(['email', 'public_profile']);

    switch (fbResult.status) {
      case FacebookLoginStatus.loggedIn:
        final FirebaseAuth _auth = FirebaseAuth.instance;

        AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: fbResult.accessToken.token);

        AuthResult result =
            await _auth.signInWithCredential(credential).catchError((onError) {
          apiResponse.hasError = true;
          apiResponse.error = ApiError(onError.message, onError.code);
        });

        if (result != null) {

          //CHECK IF ALREADY USER OR NOT
          var readResp = await FirestoreManager.readUserByID(result.user.uid);
          if(readResp.hasError && readResp.error.errorCode == ErrorCode.USER_NOT_FOUND) {

            var newUser = User.fromFirebaseUser(result.user);

            //INSERT USER INFORMATION TO FIRE STORE DATABASE
            var insertRes = await FirestoreManager.insert(collection: Collection.USER, document: newUser.id, data: newUser.toMap());

            apiResponse.hasError = insertRes.hasError;
            apiResponse.error = insertRes.error;

            //IF INSERTION THROW ANY ERROR DELETE USER FROM AUTH
            if(insertRes.hasError) {
              result.user.delete();
              print("User Deleted (${result.user.email})");
            }

            newUser.isEmailVerified = result.user.isEmailVerified;
            apiResponse.success = newUser;
          }

          else {
            apiResponse.success = readResp.success;
          }


        }
        else {
          apiResponse.hasError = true;
          apiResponse.error = ApiError("User not found", ErrorCode.USER_NOT_FOUND);
        }

        break;
      case FacebookLoginStatus.cancelledByUser:
        apiResponse.hasError = true;
        apiResponse.error = ApiError("Cancelled By User", ErrorCode.CANCELLED_BY_USER);
        break;
      case FacebookLoginStatus.error:
        apiResponse.hasError = true;
        apiResponse.error = ApiError("Facebook Login Error", ErrorCode.FB_ERROR);
        break;
    }

    return apiResponse;
  }
}
