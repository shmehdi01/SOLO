import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:solo/onboarding/login/LoginActionNotifier.dart';
import 'package:solo/onboarding/login/forgot_password.dart';
import 'package:solo/onboarding/signup/signup.dart';
import 'package:solo/languages/strings_constants.dart';

import '../../utils.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//      statusBarColor: Color(0xff7aafbc), //or set color with: Color(0xFF0000FF)
//    ));

//    SystemChrome.setEnabledSystemUIOverlays ([]);

    return ChangeNotifierProvider<LoginActionNotifier>(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LoginBody(),
      ),
      create: (BuildContext context) {
        return LoginActionNotifier();
      },
    );
  }
}

class LoginBody extends StatelessWidget {
  final _radius = Radius.circular(30);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var actionNotifier = Provider.of<LoginActionNotifier>(context);

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Opacity(
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        colorFilter: new ColorFilter.mode(
                            PRIMARY_COLOR.withOpacity(1.0), BlendMode.softLight),
                        image: AssetImage("assets/images/login_bg.jpeg"),
                        fit: BoxFit.cover))),
            opacity: 0.8,
          ),
          Container(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Image(
                  image: AssetImage("assets/images/logo1.png"),
                  width: 220,
                )),
                SizedBox(
                  height: 100,
                ),
                Container(
                  child: Stack(
                    children: <Widget>[
                      Opacity(
                        child: Container(
                          margin: const EdgeInsets.only(right: 80),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  hintText: getString(context, STR_EMAIL),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: _radius, bottomRight: _radius),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (v){
                                  FocusScope.of(context).requestFocus(passwordFocusNode);
                                },
                              ),
                              SizedBox(
                                height: 0.4,
                              ),
                              Stack(
                                children: <Widget>[
                                  Consumer<LoginActionNotifier>(
                                    builder: (BuildContext context,
                                        LoginActionNotifier value, Widget child) {
                                      return TextFormField(
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.vpn_key),
                                          hintText: getString(context, STR_PASSWORD),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: _radius,
                                                bottomRight: _radius),
                                            borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                        obscureText: value.hidePassword,
                                        focusNode: passwordFocusNode,
                                      );
                                    },
                                  ),
                                  Positioned(
                                      right: 40,
                                      top: 20,
                                      child: GestureDetector(
                                        onTap: () {
                                          print("Tap");
                                          actionNotifier.updateHidePassword =
                                              !actionNotifier.hidePassword;
                                        },
                                        child: Consumer<LoginActionNotifier>(
                                          builder: (BuildContext context,
                                                  LoginActionNotifier value,
                                                  Widget child) =>
                                              Text(
                                            value.labelShow,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ), opacity: 0.8,
                      ),
                      Consumer<LoginActionNotifier>(builder: (BuildContext context, LoginActionNotifier value, Widget child) {
                        return value.loader ? Positioned(
                            right: 40,
                            top: 20,
                            child: Container(
                                height: 75,
                                width: 75,
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                ))) : Container();
                      },

                      ),
                      Positioned(
                        right: 40,
                        top: 20,
                        child: Container(
                          height: 75,
                          width: 75,
                          child: FloatingActionButton(
                            heroTag: "btn1",
                            child: Text(
                              getString(context, STR_LOGIN),
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {

                              hideKeyboard(context);

                              String email = emailController.text;
                              String pass = passwordController.text;

                              actionNotifier.performLogin(context, email, pass);

                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    Icon(
                      Icons.help,
                      color: Colors.white,
                    ),
                    FlatButton(
                      child: Text(
                        "${getString(context, STR_FORGOT_PASSWORD)}?",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ForgotPassPage(), fullscreenDialog: true));
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 12, right: 20),
                          height: 45,
                          decoration: BoxDecoration(
                              color: PRIMARY_COLOR,
                              borderRadius: BorderRadius.only(
                                  topRight: _radius, bottomRight: _radius)),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                getString(context, STR_SIGN_UP),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: FloatingActionButton(
                              heroTag: "btn3",

                              child: Text(
                                "f",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                              onPressed: () {
                                actionNotifier.performFacebookIn(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Container(
                            height: 50,
                            child: FloatingActionButton(
                              heroTag: "btn2",
                              child: Text(
                                "G",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                              onPressed: () {
                                actionNotifier.performGoogleSignIn(context);
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
