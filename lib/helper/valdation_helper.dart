class Validator {

  static const NAME_REGEX = "^[A-Za-z\s]{1,}[\.]{0,1}[A-Za-z\s]{0,}";
  static const EMAIL_REGEX = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const USERNAME_REGEX = r"^[^0-9|@#?!.*?$%ˆ&()-+=\\/,][a-zA-Z0-9_]{3,16}$";

  static bool isEmail(String email) {
    return RegExp(EMAIL_REGEX).hasMatch(email);
  }

  static bool isName(String name) {
    return RegExp(NAME_REGEX).hasMatch(name);
  }

  static bool isUsername(String username) {
    return RegExp(USERNAME_REGEX).hasMatch(username);
  }
}
