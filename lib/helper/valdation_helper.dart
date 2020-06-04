class Validator {
  static const NAME_REGEX = "^[A-Za-z\s]{1,}[\.]{0,1}[A-Za-z\s]{0,}";
  static const EMAIL_REGEX =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const USERNAME_REGEX =
      r"^[^0-9|@#?!.*?$%ˆ&()-+=\\/,][a-zA-Z0-9_]{3,16}$";
  static const HASH_TAG_REGEX = r"#(\w+)";
  
  static const LINK_REGEX = r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)";
  
  

  static bool isEmail(String email) {
    return RegExp(EMAIL_REGEX).hasMatch(email);
  }

  static bool isLink(String link) {
    return RegExp(LINK_REGEX).hasMatch(link);
  }
  
  static bool isName(String name) {
    return RegExp(NAME_REGEX).hasMatch(name);
  }

  static bool isUsername(String username) {
    return RegExp(USERNAME_REGEX).hasMatch(username);
  }

  static List<String> splitHashTags(String s) {
    final list = <String>[];
    RegExp(HASH_TAG_REGEX).allMatches(s).forEach((element) {
      list.add(element.group(0));
    });
    return list;
  }
}
