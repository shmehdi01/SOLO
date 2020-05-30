import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/models/user.dart';
import 'package:solo/onboarding/signup/notifiers/SignUpActionNotifier.dart';

import '../../languages/strings_constants.dart';
import '../../utils.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpActionNotifier>(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SignUpBody(),
      ),
      create: (BuildContext context) => SignUpActionNotifier(),
    );
  }
}

class SignUpBody extends StatelessWidget {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _radius = Radius.circular(25);
  final _radius2 = Radius.circular(10);

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {

    var notifier = Provider.of<SignUpActionNotifier>(context);

    return  SafeArea(
      child: Stack(
        children: <Widget>[
          defaultBgWidget,
          Container(
            // color: Colors.red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(
                      left: 12, right: 20, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: PRIMARY_COLOR,
                      borderRadius: BorderRadius.only(
                          topRight: _radius, bottomRight: _radius)),
                  child: Text(
                    getString(context, STR_SIGN_UP),
                    style: TextStyle(color: Colors.white, fontSize: FONT_NORMAL),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 340,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(right: 60),
                        child: Stack(
                          children: <Widget>[
                            Opacity(
                              child: Container(
                                height: 320,
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.only(topRight: _radius, bottomRight: _radius)),
                              ),
                              opacity: 0.4,
                            ),
                            getFormWidgetNew(context),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 20,
                        child: MaterialButton(
                          onPressed: () {
                            var user = User(name: _nameController.text, email: _emailController.text);
                            notifier.createUser(context, user, _passwordController.text, _confirmPasswordController.text);
                          },
                          height: 50,
                          color: PRIMARY_COLOR,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          child:  Text(
                            getString(context, STR_CREATE_ACCOUNT),
                            style: TextStyle(color: Colors.white, fontSize: FONT_NORMAL,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          loader
        ],
      ),
    );
  }

  Widget get loader {
    return Consumer<SignUpActionNotifier>(builder: (BuildContext context, SignUpActionNotifier value, Widget child) {
      return value.loader ? Center(child: CircularProgressIndicator()) : Container();
    },);
  }

  Widget policyWidget(BuildContext context) {

    var notifier = Provider.of<SignUpActionNotifier>(context);

    return Row(
      children: <Widget>[
        Consumer<SignUpActionNotifier>(
          builder: (BuildContext context, SignUpActionNotifier action,
              Widget child) {
            return Checkbox(
              value: notifier.agreePolicy,
              onChanged: (bool value) {
                action.agreePolicy = value;
              },
            );
          },
        ),
        Flexible(
            child: RichText(
              text: TextSpan(
                  style: TextStyle(
                      fontSize: 12, color: Colors.black87, fontFamily: 'Gothom', fontWeight: FontWeight.bold),
                  text: "${getString(context, STR_I_AGREE_TO_SOLO)} ",
                  children: [
                    TextSpan(
                      style: TextStyle(
                          color: Colors.black, decoration: TextDecoration.underline, fontFamily: ''),
                      text: getString(context, STR_TERMS_AND_SERVICE),
                    ),
                    TextSpan(text: " ${getString(context, STR_AND)} "),
                    TextSpan(
                        style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,fontFamily: ''),
                        text: getString(context, STR_PRIVACY_POLICY))
                  ]),
            ))
      ],
    );
  }

  Widget getFormWidgetOld(BuildContext context, SignUpActionNotifier notifier) {
    return Opacity(
      opacity: 0.8,
      child: Container(
        margin: const EdgeInsets.only(top: 10, right: 10),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  hintText: getString(context, STR_NAME),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      _radius2,
                    ),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  hintText: getString(context,STR_EMAIL),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      _radius2,
                    ),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  hintText: getString(context, STR_PASSWORD),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      _radius2,
                    ),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  )),
              obscureText: true,
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  hintText: getString(context, STR_CONFIRM_PASSWORD),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      _radius2,
                    ),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  )),
              obscureText: true,
            ),
            SizedBox(
              height: 10,
            ),
            policyWidget(context),
          ],
        ),
      ),
    );
  }

  Widget getFormWidgetNew(BuildContext context) {
    return Opacity(
      child: Container(
        margin: const EdgeInsets.only(top: 25, right: 25),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: getString(context, STR_NAME),
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
                FocusScope.of(context).requestFocus(_emailFocusNode);
              },
            ),
            SizedBox(
              height: 0.4,
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
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
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            SizedBox(
              height: 0.4,
            ),
            TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.next,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: getString(context, STR_PASSWORD),
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
              obscureText: true,
              onFieldSubmitted: (v){
                FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
              },
            ),
            SizedBox(
              height: 0.4,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: getString(context, STR_CONFIRM_PASSWORD),
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
              obscureText: true,
              onFieldSubmitted: (v){
                // FocusScope.of(context).requestFocus(passwordFocusNode);
              },
            ),
            SizedBox(
              height: 0.4,
            ),
            policyWidget(context),
          ],
        ),
      ), opacity: 0.8,
    );
  }
}




