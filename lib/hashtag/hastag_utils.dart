import 'package:flutter/cupertino.dart';

class HasTagUtils {

  static Future<List<String>> splitHashTag(String captions) async {

    String s = captions + " ";

    List<String> list = [];

    while (s.contains("#")) {

      if (s.contains("#")) {

        String preHash = s.substring(0, s.indexOf("#"));
        s = s.substring(s.indexOf("#"));
        String hashTag = s;

        if(preHash.isNotEmpty)
           list.add(preHash);

        if (s.contains(' ')) {
          hashTag = s.substring(0, s.indexOf(' '));
          s = s.substring(s.indexOf(' '));

          hashTag.trim();
          if(hashTag.isNotEmpty)
            list.add(hashTag);
        }
      }
    }

    s.trim();
    if(s.isNotEmpty)
      list.add(s);

    debugPrint("$list");

    return list;
  }

  static bool hasTag(String s) {
    return s.contains("#");
  }
}