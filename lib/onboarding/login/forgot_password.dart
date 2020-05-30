import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/languages/strings_constants.dart';
import 'package:solo/network/api_provider.dart';

import '../../utils.dart';

class ForgotPassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ForgotPassBody(),
    );
  }
}

class ForgotPassBody extends StatelessWidget {
  final _radius = Radius.circular(25);
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          defaultBgWidget,
          Container(
            margin: EdgeInsets.only(right: 70),
            //color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.only(left: 12, right: 20, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: PRIMARY_COLOR,
                      borderRadius:
                          BorderRadius.only(topRight: _radius, bottomRight: _radius)),
                  child: Text(
                    getString(context, STR_FORGOT_PASSWORD),
                    style: TextStyle(color: Colors.white, fontSize: FONT_NORMAL),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Opacity(
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: getString(context, STR_EMAIL),
                      filled: true,
                      fillColor: Color(0xffefefef),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topRight: _radius, bottomRight: _radius),
                        borderSide: BorderSide(
                          width: 0.4,
                          color: PRIMARY_COLOR,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ), opacity: 0.8,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MaterialButton(onPressed: () async {
                      String email = emailController.text;
                      if(email.isEmpty) {
                        showSnack(context, getString(context, STR_EMAIL_EMPTY));
                      }
                      else if(!isValidEmail(email)) {
                        showSnack(context, getString(context, STR_EMAIL_INVALID));
                      }
                      else {
//                        FirebaseAuth.instance.sendPasswordResetEmail(email: email)
//                        .then((onValue) {
//                          emailController.text = "";
//                          showSnack(context, "A Email has been send to you $email");
//                        }).catchError((onError)  {
//                          print("Error Code: ${onError.code}");
//                              showSnack(context, onError.message);
//                        });
                      var response = await ApiProvider.loginApi.resetPassword(email);

                      if(!response.hasError)
                        showSnack(context, response.success);
                      else
                        showSnack(context, response.error.errorMsg);

                      }
                    },
                      height: 50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: PRIMARY_COLOR,

                    textColor: Colors.white,
                    child: Text(getString(context, STR_SEND_RESET)),),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
