import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/home/profile/edit_profile_page.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/onboarding/login/login.dart';
import 'package:solo/utils.dart';

import '../../main.dart';
import '../../session_manager.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            goToPage(context, EditProfilePage(), fullScreenDialog: true);
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
//          Divider(),
//          _textWidget("Delete Account", textColor: Colors.red, onTap: () {
//           // goToPage(context, DeleteAccountPage());
//            DialogHelper.deleteAlertDialog(context,
//                title: "Delete Account",
//                negativeButton: "Don't Delete",
//                positiveButton: "Yes, Delete",
//                content:
//                    "Your account will be deleted permanently\nAnd all data will be erased",
//                onConfrim: () async {
//
//              FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
//              //password //google.com //
//              Fluttertoast.showToast(msg: "${firebaseUser.providerData[0].providerId}");
//
//              await ApiProvider.homeApi.deleteAccount();
//
//              Navigator.pushReplacement(
//                  context,
//                  MaterialPageRoute(
//                      builder: (BuildContext context) => LoginPage()));
//            });
//          }),
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

class DeleteAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      //padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.redAccent,
            height: 200,
          ),
          verticalGap(gap: 12),
          Center(child: Text("Delete My Account", style: TextStyle(fontSize: FONT_MEDIUM, fontWeight: FontWeight.bold),)),
          Text("Login Required", style: TextStyle(fontSize: FONT_MEDIUM, fontWeight: FontWeight.bold),)
        ],
      ),
    ));
  }
}
