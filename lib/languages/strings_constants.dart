import 'package:flutter/widgets.dart';
import 'package:solo/languages/en.dart';

String getString(BuildContext context, key) {
  return AppLocalization.of(context).getString(key);
}

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegates();

  static Map<String, Map<String, String>> _localizedValues = {'en': english};

  String getString(String key) => _localizedValues[locale.languageCode][key];
}

class _AppLocalizationDelegates extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegates();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    return AppLocalization(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return false;
  }
}

//KEYS
const String STR_EMAIL = "email";
const String STR_EMAIL_MOBILE = "email_mobile";
const String STR_PASSWORD = "password";
const String STR_CONFIRM_PASSWORD = "confirm_Password";
const String STR_LOGIN = "login";
const String STR_FORGOT_PASSWORD = "forgot_password?";
const String STR_SIGN_UP = "sign_Up";
const String STR_NAME = "name";
const String STR_CREATE_ACCOUNT = "create_account";
const String STR_I_AGREE_TO_SOLO = "i_agree_to_the_solo";
const String STR_TERMS_AND_SERVICE = "terms_and_service";
const String STR_AND = "and";
const String STR_PRIVACY_POLICY = "privacy_policy";
const String STR_ADD_PROFILE_PICTURE = "add_a_profile_picture";
const String STR_ADD_PHOTO_FRIEND_FIND = "add_a_photo";
const String STR_CHOOSE_PHOTO = "choose_photo";
const String STR_TAKE_PHOTO = "take_photo";
const String STR_SKIP = "skip";
const String STR_SEND_RESET = "sent_reset";
const String STR_USER_NOT_FOUND = "user_not_found";
const String STR_EMAIL_EMPTY = "email_empty";
const String STR_EMAIL_INVALID = "email_invalid";
const String STR_PASS_EMPTY= "pass_empty";
const String STR_NAME_EMPTY= "name_empty";
const String STR_PASS_VALIDATE= "pass_validate";
const String STR_PASS_NOT_MATCHED= "pass_not_matched";
const String STR_PLEASE_ACCEPT_AGREEMENT= "accept_tnc";
const String STR_NEXT= "next";
const String STR_CONGRATULATIONS= "congratulations";
