import 'package:flutter/material.dart';
import 'package:solo/home/home.dart';
import 'package:solo/main.dart';
import 'package:solo/onboarding/login/login.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

class EmailVerifyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              "Your Email is not verified",
              style: TextStyle(color: Colors.white, fontSize: FONT_LARGE),
            )),
            verticalGap(gap: 8),
            Center(
                child: Text(
              "A verification link is sent to your email ${SessionManager.currentUser.email}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            )),
            Center(
                child: FlatButton(
                    onPressed: () async {
                      await SessionManager.currentUser.sendEmailVerification();
                      showSnack(context, "A verification link is has been sent to your email ${SessionManager.currentUser.email}");
                    },
                    child: Text(
                      "Send Verification Link",
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    ))),
            Center(
                child: FlatButton(
                    onPressed: () async {
                      goToPage(context, LoginPage(), replace: true);
                    },
                    child: Text(
                      "Re-Login",
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    )))
          ],
        ),
      ),
    );
  }
}
