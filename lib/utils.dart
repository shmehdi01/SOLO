import 'dart:collection';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:solo/database/app_constants.dart';

const double FONT_VERY_SMALL = 10;
const double FONT_SMALL = 12;
const double FONT_NORMAL = 14;
const double FONT_MEDIUM = 16;
const double FONT_LARGE = 18;
const double FONT_EXTRA_LARGE = 20;

const Color PRIMARY_COLOR = Colors.blue;
const int MAX_PASS_LIMIT = 8;
const int MAX_PASS_LIMIT_DEBUG = 2;

const String IMAGE_ASSETS = "assets/images";

void showSnack(BuildContext context, message,
    {bool error = false, Color customColor = Colors.black87}) {
  Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: error ? Colors.red : customColor,
      content: Text('$message')));
}

bool isValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

void hideKeyboard(context) => FocusScope.of(context).unfocus();

Widget get defaultBgWidget => Opacity(
      child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  colorFilter: new ColorFilter.mode(
                      PRIMARY_COLOR.withOpacity(1.0), BlendMode.softLight),
                  image: AssetImage("assets/images/login_bg.jpeg"),
                  fit: BoxFit.cover))),
      opacity: 0.8,
    );

ShapeBorder get appBarRounded => RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12)));

Color get appBarColor => const Color(0xffefefef);

showAlertDialog(context, String title, String content,
    {List<Widget> actions, bool cancelable = true, bool platformIos = false}) {
  showDialog(
      barrierDismissible: cancelable,
      context: context,
      child: platformIos || Platform.isIOS
          ? CupertinoAlertDialog(
              title: title != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
              content: Text(content),
              actions: actions)
          : AlertDialog(
              title: title != null
                  ? Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
                      ),
                    )
                  : null,
              content: Text(content, style: TextStyle(fontSize: FONT_SMALL),),
              actions: actions));
}

dialogButton({@required String buttonText, @required Function() onPressed, bool platformIos = false}) {
  return platformIos || Platform.isIOS
      ? CupertinoButton(
          onPressed: onPressed,
          child: Text(buttonText),
        )
      : MaterialButton(
    elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          textColor: Colors.white70,
          color: PRIMARY_COLOR,
          onPressed: onPressed,
          child: Text(buttonText),
        );
}

log(int line) {
  print("Step $line");
}

const MATCH_PARENT = double.infinity;

EdgeInsetsGeometry dimenAll(double value) => EdgeInsets.all(value);

EdgeInsetsGeometry dimenOnly(
        {double top, double bottom, double left, double right}) =>
    EdgeInsets.only(top: top, bottom: bottom, left: left, right: right);

const Color bgColor = Color(0xffefefef);
const Color bgColorAbove = Color(0xffefefef);

Route createRoute(page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration(milliseconds: 700),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Widget userImage({@required String imageUrl, double radius = 30}) {
  return CircleAvatar(
    radius: radius,
    backgroundImage: imageUrl == null
        ? AssetImage("$IMAGE_ASSETS/default_dp.png")
        : CachedNetworkImageProvider(imageUrl),
  );
}

Widget squareImage(
    {@required String imageUrl,
    double size = 100,
    double radius = 4,
    BoxFit fit = BoxFit.cover}) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      image: DecorationImage(
          fit: fit,
          image: imageUrl == null || imageUrl.isEmpty
              ? AssetImage("$IMAGE_ASSETS/default_dp.png")
              : CachedNetworkImageProvider(imageUrl)),
    ),
  );
}

Widget rectImage(
    {@required String imageUrl,
    double height = 340,
    double width = 350,
    double radius = 4,
    BoxFit fit = BoxFit.cover}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      image: DecorationImage(
          fit: fit,
          image: imageUrl == null || imageUrl.isEmpty
              ? AssetImage("$IMAGE_ASSETS/default_dp.png")
              : CachedNetworkImageProvider(imageUrl)),
    ),
  );
}

Widget verticalGap({@required double gap}) {
  return SizedBox(
    height: gap,
  );
}

Widget horizontalGap({@required double gap}) {
  return SizedBox(
    width: gap,
  );
}

void goToPage(context, page,
    {bool replace = false, bool fullScreenDialog = false}) {
  if (replace)
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => page,
            fullscreenDialog: fullScreenDialog));
  else
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => page,
            fullscreenDialog: fullScreenDialog));
}

String chatTimeFormat(String mills) {
  String m =
      DateTime.fromMillisecondsSinceEpoch(int.parse(mills)).minute.toString();
  String h =
      DateTime.fromMillisecondsSinceEpoch(int.parse(mills)).hour.toString();
  String s =
      DateTime.fromMillisecondsSinceEpoch(int.parse(mills)).second.toString();

  return "$h:$m:$s";
}

developerLog(String tag, Object log) {
  debugPrint("$tag: $log");
}

void progressDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      barrierDismissible: false,
      child: Dialog(
        child: Container(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: CircularProgressIndicator(),
              ),
              verticalGap(gap: 12),
              Text(message)
            ],
          ),
        ),
      ));
}

const String DATE_TIME_FORMAT = "dd MM yyyy hh:mm:ss";
const String TIME_FORMAT = "hh:mm:ss";
const String DATE_FORMAT = "dd MM yyyy";

class Utils {
  static String timestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static String displayDate(String millis) {
    if (millis == null || millis.isEmpty) {
      return "While ago";
    }

    DateTime dateTime = fromMills(millis);
    DateTime now = DateTime.now();
    final int diffInDays = DateTime.parse(dateTimeByFormat("yyyy-MM-dd", now))
        .difference(DateTime.parse(dateTimeByFormat("yyyy-MM-dd", dateTime)))
        .inDays;

    if (diffInDays == 0) {
      //Today
      final int diffInHours = now.difference(dateTime).inHours;

      if (diffInHours == 0) {
        //minutes
        final int diffInMinute = now.difference(dateTime).inMinutes;
        if (diffInMinute == 0) {
          //sec
          return "Just Now";
        } else {
          return "$diffInMinute minutes ago";
        }
      } else if (diffInHours < 5) {
        return "$diffInHours hours ago";
      } else {
        return "Today at " + DateFormat("hh:mm a").format(dateTime);
      }
    } else if (diffInDays == 1) {
      //Yesterday
      return "Yesterday at " + DateFormat("hh:mm a").format(dateTime);
    } else {
      //Date
      return DateFormat("dd MMM yyyy 'at' hh:mm a").format(dateTime);
    }
  }

  static String dateTimeByFormat(String format, DateTime dateTime) {
    return DateFormat(format).format(dateTime);
  }

  static String currentDateTime() {
    return DateFormat(DATE_TIME_FORMAT).format(DateTime.now());
  }

  static String currentTime() {
    return DateFormat(TIME_FORMAT).format(DateTime.now());
  }

  static String currentDate() {
    return DateFormat(DATE_FORMAT).format(DateTime.now());
  }

  static DateTime fromMills(String millis) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(millis));
  }

  static bool validatePassword(String current, String newPass, String confirm) {
    final maxLimit = MAX_PASS_LIMIT_DEBUG;
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      Fluttertoast.showToast(msg: "Field should not be empty");
      return false;
    } else if (newPass.length < maxLimit || confirm.length < maxLimit) {
      Fluttertoast.showToast(
          msg: "Password length must be greater that $maxLimit");
      return false;
    } else if (newPass != confirm) {
      Fluttertoast.showToast(msg: "Password not matched");
      return false;
    }
    return true;
  }
}

final postItemMyOptions = [AppConstant.DELETE_POST, AppConstant.REPORT_POST];
final postItemOtherOptions = [AppConstant.REPORT_POST];

//if(s.contains("#")) {
//String preHash = s.substring(0,s.indexOf("#"));
//String postHash = s.substring(s.indexOf("#"));
//String other = "";
//String hashTag = postHash;
//
//if(postHash.contains(' ')) {
//hashTag =  postHash.substring(0,postHash.indexOf(' '));
//other = postHash.substring(postHash.indexOf(' '));
//}
//
//print(preHash);
//print(hashTag);
//print(other);