import 'package:solo/helper/valdation_helper.dart';

void main() {
  print(Validator.getEmoji("0x1F600"));
}

List<String> splitHashTag(String captions) {
  String s = captions + " ";

  List<String> list = [];

  while (s.contains("#") && s.contains("@")) {

    if (s.contains("#")) {

      String preHash = s.substring(0, s.indexOf("#"));
      s = s.substring(s.indexOf("#"));
      String hashTag = s;

      if (preHash.isNotEmpty) list.add(preHash);

      if (s.contains(' ')) {
        hashTag = s.substring(0, s.indexOf(' '));
        s = s.substring(s.indexOf(' '));

        hashTag.trim();
        if (hashTag.isNotEmpty) list.add(hashTag);
      }
    }

    if(s.contains("@")) {
      String preAt = s.substring(0, s.indexOf("@"));
      s = s.substring(s.indexOf("@"));
      String at = s;

      if(preAt.isEmpty) list.add(preAt);

      if (s.contains(' ')) {
        at = s.substring(0, s.indexOf(' '));
        s = s.substring(s.indexOf(' '));

        at.trim();
        if (at.isNotEmpty) list.add(at);
      }
    }
  }

  s.trim();
  if (s.isNotEmpty) list.add(s);

  return list;
}
