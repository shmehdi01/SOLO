import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:solo/hashtag/hastag_utils.dart';

class HashTagText extends StatelessWidget {
  final String text;

  final TextStyle normalTextStyle;
  final TextStyle hashTagStyle;
  final Function(String) onHashTagClick;

  HashTagText(
      {@required this.text,
      this.normalTextStyle,
      this.hashTagStyle,
      this.onHashTagClick});

  @override
  Widget build(BuildContext context) {
    if (!HasTagUtils.hasTag(text)) {
      return Text(
        text,
        style: normalTextStyle == null
            ? TextStyle(color: Colors.black)
            : normalTextStyle,
      );
    }

    return FutureBuilder(
      future: HasTagUtils.splitHashTag(text),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (!snapshot.hasData) {
          return Text(
            text,
            style: normalTextStyle == null
                ? TextStyle(color: Colors.black)
                : normalTextStyle,
          );
        }

        final captions = snapshot.data;

        return RichText(
          text: TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (onHashTagClick != null &&
                      HasTagUtils.hasTag(captions[0])) {
                    onHashTagClick(captions[0]);
                  }
                },
              text: captions[0],
              style: HasTagUtils.hasTag(captions[0])
                  ? hashTagStyle != null
                      ? hashTagStyle
                      : TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                  : normalTextStyle != null
                      ? normalTextStyle
                      : TextStyle(color: Colors.black),
              children: captions
                  .sublist(1, captions.length - 1)
                  .map((e) => TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (onHashTagClick != null &&
                                HasTagUtils.hasTag(e)) {
                              onHashTagClick(e);
                            }
                          },
                        text: e,
                        style: HasTagUtils.hasTag(e)
                            ? hashTagStyle != null
                                ? hashTagStyle
                                : TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                            : normalTextStyle != null
                                ? normalTextStyle
                                : TextStyle(color: Colors.black),
                      ))
                  .toList()),
        );
      },
    );
  }
}
