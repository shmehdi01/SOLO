import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solo/home/home.dart';
import 'package:solo/home/notifications/api/push_notification_manager.dart';
import 'package:solo/languages/strings_constants.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/service/sync_service.dart';
import 'package:solo/session_manager.dart';

import '../../utils.dart';

class LoginActionNotifier with ChangeNotifier {
  bool _hidePassword = true;
  String _labelShow = "Show";
  bool _loader = false;

  bool get hidePassword => _hidePassword;

  String get labelShow => _labelShow;

  bool get loader => _loader;

  set updateHidePassword(bool hide) {
    _hidePassword = hide;
    _labelShow = hide ? "Show" : "Hide";
    notifyListeners();
  }

  void performLogin(BuildContext context, String email, String password) async {
    if (_validated(context, email, password)) {
      _loader = true;
      notifyListeners();

      var response =  await ApiProvider.loginApi.login(email.trim(), password.trim());
      if (!response.hasError) {
        //UPDATE SESSION
        SessionManager.currentUser = response.success;

        //UPDATE TOKEN TO USER
        PushNotificationsManager.instance.updateUserToken(response.success);

        //GO TO HOMEPAGE
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HomePage(
                      user: response.success,
                    )));
      } else {
        showSnack(context, response.error.errorMsg, error: true);
      }

      _loader = false;
      notifyListeners();
    }
  }

  void performGoogleSignIn(BuildContext context) async {
    _loader = true;
    notifyListeners();

    var response = await ApiProvider.loginApi.googleSignInApp();

    if (!response.hasError) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(
                    user: response.success,
                  )));
    } else {
      showSnack(context, response.error.errorMsg, error: true);
    }

    _loader = false;
    notifyListeners();
  }

  void performFacebookIn(BuildContext context) async {
    _loader = true;
    notifyListeners();

    var response = await ApiProvider.loginApi.facebookLogin();

    if (!response.hasError) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(
                    user: response.success,
                  )));
    } else {
      showSnack(context, response.error.errorMsg, error: true);
    }

    _loader = false;
    notifyListeners();
  }

  bool _validated(context, email, password) {
    if (email.isEmpty) {
      showSnack(context, getString(context, STR_EMAIL_EMPTY));
      return false;
    } else if (!isValidEmail(email)) {
      showSnack(context, getString(context, STR_EMAIL_INVALID));
      return false;
    } else if (password.isEmpty) {
      showSnack(context, getString(context, STR_PASS_EMPTY));
      return false;
    }

    return true;
  }
}

typedef LoginCallback = Function(AuthResult result, String errorMsg);
