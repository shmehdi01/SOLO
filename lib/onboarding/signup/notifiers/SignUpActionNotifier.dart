
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/languages/strings_constants.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/utils.dart';

import '../../enums.dart';
import '../add_profile.dart';

class SignUpActionNotifier with ChangeNotifier {
  Gender _gender = Gender.MALE;
  int _accountType = Privacy.public;
  bool _agreePolicy = true;
  bool goToNext = false;
  bool _loader = false;

  bool get loader => _loader;

  set gender(Gender gender) {
    _gender = gender;
    notifyListeners();
  }

  Gender get gender => _gender;

  set accountType(int accountType) {
    _accountType = accountType;
    notifyListeners();
  }

  int get accountType => _accountType;

  set agreePolicy(bool agree) {
    _agreePolicy = agree;
    notifyListeners();
  }

  bool get agreePolicy => _agreePolicy;

  void gotToNext() {
    goToNext = true;
    notifyListeners();
  }

  void createUser(BuildContext context, User user, String password,
      String confirmPassword) async {

    if (_validated(context, user, password, confirmPassword)) {
      _loader = true;
      notifyListeners();

      var apiResponse = await ApiProvider.signUpApi.signUp(user, password);
      if (!apiResponse.hasError) {
        var u = apiResponse.success;
        print("User: ${u.name}");
        var verifyResp = await apiResponse.success.sendEmailVerification();
        if(!verifyResp.hasError) {
          showAlertDialog(
            context, getString(context, STR_CONGRATULATIONS), verifyResp.success,
            actions: [
              dialogButton(buttonText: getString(context, STR_NEXT), onPressed: () {
                Navigator.pop(context);

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AddProfilePage(apiResponse.success)));
              }, )
            ] ,cancelable: false,);
        }
        else {
          _showError(context, verifyResp.error.errorMsg);
        }

      } else {
        _showError(context, apiResponse.error.errorMsg);
      }

      _loader = false;
      notifyListeners();
    }
  }

  bool _validated(context, User user, String password, String confirmPassword) {
    if (user.name.isEmpty) {
      showSnack(context, getString(context, STR_NAME_EMPTY));
      return false;
    } else if (user.email.isEmpty) {
      showSnack(context, getString(context, STR_EMAIL_EMPTY));
      return false;
    } else if (!isValidEmail(user.email)) {
      showSnack(context, getString(context, STR_EMAIL_INVALID));
      return false;
    } else if (password.isEmpty) {
      showSnack(context, getString(context, STR_PASS_EMPTY));
      return false;
    } else if (password.length < MAX_PASS_LIMIT) {
      showSnack(context, getString(context, STR_PASS_VALIDATE));
      return false;
    } else if (password != confirmPassword) {
      showSnack(context,getString(context, STR_PASS_NOT_MATCHED));
      return false;
    } else if (!agreePolicy) {
      showSnack(context, getString(context, STR_PLEASE_ACCEPT_AGREEMENT), error: true);
      return false;
    }
    return true;
  }

  _showError(context, errorMsg) {
    showSnack(context, errorMsg, error: true);
  }
}
