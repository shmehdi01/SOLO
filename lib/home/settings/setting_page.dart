import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/home/profile/edit_profile_page.dart';
import 'package:solo/utils.dart';

import '../../main.dart';
import '../../session_manager.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        shape: appBarRounded,
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _SettingBody(),
    );
  }
}

class _SettingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          verticalGap(gap: 12),
          _textWidget("Edit Profile", onTap: () {
            goToPage(context, EditProfilePage(),fullScreenDialog: true);
          }),
          Divider(),
          _textWidget("Change Password", onTap: () {
            DialogHelper.changePassword(context);
          }),
          Divider(),
          _textWidget("Logout", onTap: () {
            showAlertDialog(context, "Logout ?", "You will be logout from app.",
                actions: [
                  dialogButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        SessionManager().signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    StartHome()));
                      },
                      buttonText: "Logout")
                ]);
          }),
          Divider(),
          _textWidget("Delete Account", textColor: Colors.red),
          Divider(),
          Expanded(
            child: Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.normal,
                        fontSize: FONT_SMALL,
                        color: Colors.grey)),
              )
            ],
          ),
          verticalGap(gap: 8)
        ],
      ),
    );
  }

  _textWidget(String text, {Color textColor = Colors.black, Function() onTap}) {
    return ListTile(
        onTap: () {
          if (onTap != null) onTap();
        },
        trailing: Icon(Icons.chevron_right),
        title: Text("$text",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FONT_MEDIUM,
                color: textColor)));
  }
}
