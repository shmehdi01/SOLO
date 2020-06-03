import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:solo/hashtag/hastag_utils.dart';

class SmartText extends StatelessWidget {
  final String text;

  final TextStyle normalTextStyle;
  final TextStyle hashTagStyle;
  final TextStyle linkStyle;
  final TextStyle tagStyle;
  final Function(String) onHashTagClick;
  final Function(String) onLinkClick;
  final Function(String) onTagClick;

  SmartText(
      {@required this.text,
      this.normalTextStyle,
      this.hashTagStyle,
      this.linkStyle,
      this.tagStyle,
      this.onLinkClick,
      this.onTagClick,
      this.onHashTagClick});

  @override
  Widget build(BuildContext context) {
    if (!_validate(text)) {
      return Text(
        text,
        style: normalTextStyle == null
            ? TextStyle(color: Colors.black)
            : normalTextStyle,
      );
    }

    final captions = text.split(" ");
    return RichText(
      text: TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onHashTagClick != null && HasTagUtils.hasTag(captions[0])) {
                onHashTagClick(captions[0]);
              }
              if (onTagClick != null && _isTag(captions[0])) {
                onTagClick(captions[0]);
              }
              if (onLinkClick != null && _isLink(captions[0])) {
                onLinkClick(captions[0]);
              }
            },
          text: captions[0],
          style: _isHashTag(captions[0])
              ? hasTagStyle()
              : _isTag(captions[0])
                  ? tagsStyle()
                  : _isLink(captions[0]) ? linksStyle() : normalStyle(),
          children: captions
              .sublist(1, captions.length - 1)
              .map((e) => TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (onHashTagClick != null && HasTagUtils.hasTag(e)) {
                          onHashTagClick(e);
                        }
                        if (onTagClick != null && _isTag(e)) {
                          onTagClick(captions[0]);
                        }
                        if (onLinkClick != null && _isLink(e)) {
                          onLinkClick(captions[0]);
                        }
                      },
                    text: e,
                    style: _isHashTag(e)
                        ? hasTagStyle()
                        : _isTag(e)
                            ? tagsStyle()
                            : _isLink(e) ? linksStyle() : normalStyle(),
                  ))
              .toList()),
    );
  }

  bool _isHashTag(String s) => s.contains("#");

  bool _isTag(String s) => s.contains("@");

  bool _isLink(String s) => s.contains("LINK REGEX");

  bool _validate(s) => _isTag(s) && _isHashTag(s) && _isLink(s);

  TextStyle hasTagStyle() => hashTagStyle == null
      ? TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
      : hashTagStyle;

  TextStyle tagsStyle() => tagStyle == null
      ? TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
      : tagStyle;

  TextStyle linksStyle() => linkStyle == null
      ? TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
      : linkStyle;

  TextStyle normalStyle() => normalTextStyle == null
      ? TextStyle(color: Colors.black, fontWeight: FontWeight.normal)
      : normalTextStyle;
}
