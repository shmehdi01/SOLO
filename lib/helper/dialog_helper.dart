import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

class DialogHelper {

  static void changePassword(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
        context: context,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Change Password",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
                ),
                verticalGap(gap: 8),
                TextField(
                  controller: currentPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: PRIMARY_COLOR),
                      labelText: "Current Password"),
                ),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: PRIMARY_COLOR),
                      labelText: "New Password"),
                ),
                TextField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: PRIMARY_COLOR),
                      labelText: "Confirm Password"),
                ),
                verticalGap(gap: 8),
                MaterialButton(
                  color: PRIMARY_COLOR,
                  onPressed: () async {
                    if (Utils.validatePassword(currentPassController.text,
                        newPassController.text, confirmPassController.text)) {
                      progressDialog(context, "Please wait..");

                      final resp = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: SessionManager.currentUser.email,
                              password: currentPassController.text)
                          .catchError((onError) {
                        Navigator.pop(context);
                        if (onError is PlatformException) {
                          Fluttertoast.showToast(msg: "${onError.message}");
                        }
                      });

                      if (resp != null) {
                        await resp.user.updatePassword(newPassController.text);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: "Password change sussesfully!!");
                      }
                    }
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  static void addLocation(BuildContext context, Function(String) onLocation) {
    final locationCtrl = TextEditingController();

    showDialog(
        context: context,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Location",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
                ),
                verticalGap(gap: 8),
                TextField(
                  controller: locationCtrl,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: PRIMARY_COLOR),
                      labelText: "Enter Location"),
                ),
                verticalGap(gap: 8),
                MaterialButton(
                  color: PRIMARY_COLOR,
                  onPressed: () async {

                    String location = locationCtrl.text;
                    onLocation(location);
                    Navigator.pop(context);
//                    if(location.isNotEmpty) {
//
//                    }
                  },
                  child: Text(
                    "Add Location",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  static void reLogin(BuildContext context, Function(bool) onSuccess) {
    final locationCtrl = TextEditingController();

    showDialog(
        context: context,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Authentication",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
                ),
               Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   verticalGap(gap: 8),
                   TextField(
                     controller: locationCtrl,
                     obscureText: true,
                     decoration: InputDecoration(
                         labelStyle: TextStyle(color: PRIMARY_COLOR),
                         labelText: "Enter Password"),
                   ),
                   verticalGap(gap: 8),
                   MaterialButton(
                     color: PRIMARY_COLOR,
                     onPressed: () async {

                       //await ApiProvider.loginApi.login(email, password)

                       String location = locationCtrl.text;
                       onSuccess(true);
                       Navigator.pop(context);
//                    if(location.isNotEmpty) {
//
//                    }
                     },
                     child: Text(
                       "Login",
                       style: TextStyle(color: Colors.white),
                     ),
                   ),
                 ],
               ),
                verticalGap(gap: 8),
                Text("-- OR --"),
                verticalGap(gap: 8),
                Row(
                  children: [
                    FlatButton(
                      color: Colors.redAccent,
                      onPressed: () {

                      },
                      child: Text("Login with Gmail", style: TextStyle(color: Colors.white),),),
                    horizontalGap(gap: 12),
                    FlatButton(
                      color: Colors.blueAccent,
                      onPressed: () {

                      },
                      child: Text("Login with FB", style: TextStyle(color: Colors.white),), ),
                  ],
                ),

              ],
            ),
          ),
        ));
  }

  static void addBioDialog(
      BuildContext context, String bio, Function(String) onUpdate) {
    final bioEditCtrl = TextEditingController();
    bioEditCtrl.text = bio;

    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Container(
                padding: dimenAll(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("${bio.isNotEmpty ? "Change Bio" : "Add Bio"}"),
                    verticalGap(gap: 8),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
                      maxLength: 30,
                      controller: bioEditCtrl,
                      decoration: InputDecoration(hintText: "Write Bio"),
                    ),
                    verticalGap(gap: 8),
                    MaterialButton(
                        color: PRIMARY_COLOR,
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (bioEditCtrl.text.isNotEmpty) {
                            onUpdate(bioEditCtrl.text);
                          }
                          Navigator.pop(context);
                        })
                  ],
                ),
              ),
            ));
  }

  static void postItemOption(BuildContext context, List<String> postItemOptions,
      {@required Function(String) onAction}) {
    showDialog(
        context: context,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: postItemOptions
                    .map((e) => Container(
                          width: MATCH_PARENT,
                          child: FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onAction(e);
                              },
                              child: Text(e)),
                        ))
                    .toList()),
          ),
        ));
  }


  static void userList(BuildContext context, String header, List<User> users,
      {@required Function(User) onAction}) {
    showDialog(
        context: context,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(header, style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: users
                        .map((e) => Container(
                      width: MATCH_PARENT,
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                           if(onAction != null) onAction(e);
                          },
                          child: ListTile(leading: userImage(imageUrl: e.photoUrl, radius: 15 ), title: Text(e.name),)),
                    ))
                        .toList()),
              ],
            ),
          ),
        ));
  }

  static void customAlertDialog(BuildContext context, {@required String title, @required content, String positiveButton, String negativeButton, @required Function() onConfrim }) {
    showDialog(
        context: context,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize:  FONT_MEDIUM),),
                verticalGap(gap: 12),
                Text(content, style: TextStyle(fontWeight: FontWeight.normal, fontSize:  FONT_SMALL, color: Colors.black54),),
                verticalGap(gap: 25),
                Divider(),
                InkWell(
                  onTap: (){
                    onConfrim();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    width: MATCH_PARENT,
                    child: Center(child: Text(positiveButton, style: TextStyle(color: PRIMARY_COLOR, fontSize: 13, fontWeight: FontWeight.bold),)),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    width: MATCH_PARENT,
                    child: InkWell(
                      child: Center(child: Text(negativeButton, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }


  static void deleteAlertDialog(BuildContext context, {@required String title, @required content, String positiveButton, String negativeButton, @required Function() onConfrim }) {
    showDialog(
        context: context,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize:  FONT_MEDIUM),)),
                verticalGap(gap: 12),
                Center(child: Text(content, textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.normal, fontSize:  FONT_SMALL, color: Colors.black54),)),
                verticalGap(gap: 25),
                Divider(),
                InkWell(
                  onTap: (){
                    onConfrim();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    width: MATCH_PARENT,
                    child: Center(child: Text(positiveButton, style: TextStyle(color: PRIMARY_COLOR, fontSize: 13, fontWeight: FontWeight.bold),)),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    width: MATCH_PARENT,
                    child: InkWell(
                      child: Center(child: Text(negativeButton, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
