import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/helper/image_picker_helper.dart';
import 'package:solo/home/profile/edit_profile_state_manager.dart';
import 'package:solo/session_manager.dart';

import '../../utils.dart';

class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => EditProfileStateManager(),
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text("Edit Profile"),
          ),
          body: _BodyEdit()),
    );
  }
}

class _BodyEdit extends StatelessWidget {
  final bannerHeight = 120.0;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final userNameController = TextEditingController();

  _BodyEdit() {
    nameController.text = SessionManager.currentUser.name;
    emailController.text = SessionManager.currentUser.email;
    userNameController.text = SessionManager.currentUser.username;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileStateManager>(
      builder:
          (BuildContext context, EditProfileStateManager value, Widget child) {
        return Stack(
          children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: bannerHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: value.coverFile != null
                                ? FileImage(value.coverFile)
                                : value.user.bannerUrl != null
                                    ? CachedNetworkImageProvider(
                                        value.user.bannerUrl)
                                    : AssetImage(
                                        ("$IMAGE_ASSETS/login_bg.jpeg")),
                            fit: BoxFit.cover)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          ImagePickerHelper.showImagePickerDialog(context,
                              (image) {
                            value.setCoverImage = image;
                          }, header: "Choose Cover Image");
                        },
                        child: Text(
                          "Change Cover",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_SMALL),
                        ),
                      ),
                    ],
                  ),
                  verticalGap(gap: 12),
                  Padding(
                    padding: _editTextPadding(),
                    child: TextField(
                        controller: nameController,
                        decoration: _inputDecoration("Full Name")),
                  ),
                  Padding(
                    padding: _editTextPadding(),
                    child: TextField(
                        controller: userNameController,
                        enabled: value.username.isEmpty,
                        decoration: _inputDecoration("Username")),
                  ),
                  if(value.username.isEmpty)  Padding(
                    padding: _editTextPadding(),
                    child: Row(
                      children: <Widget>[
                        FlatButton(onPressed: () {
                          value.checkAvailability(userNameController.text);
                        },
                          color: appBarColor,
                          child: Text("Check Availability", style: TextStyle(color: Colors.black),),),
                        horizontalGap(gap: 12),
                        Text(value.hintText, style: TextStyle(color: value.isUserNameAvailable ? Colors.green: Colors.red),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: _editTextPadding(),
                    child: TextField(
                        controller: emailController,
                        enabled: false,
                        decoration: _inputDecoration("Email")),
                  ),
                  FutureBuilder(
                      future: FirebaseAuth.instance.currentUser(),
                      builder: (BuildContext context,
                          AsyncSnapshot<FirebaseUser> snapshot) {
                        if(snapshot.hasData == false) {
                          return verticalGap(gap: 1);
                        }
                        if(snapshot.data.isEmailVerified) {
                          return verticalGap(gap: 1);
                        }
                        return Padding(
                          padding: _editTextPadding(),
                          child: RichText(
                              text: TextSpan(
                                  text: "Email is not verified,  ",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: FONT_SMALL),
                                  children: [
                                TextSpan(
                                    text: "Verify Now",
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        print("Send Email");
                                        snapshot.data.sendEmailVerification();
                                        Fluttertoast.showToast(
                                            msg:
                                                "Email has been send to ${snapshot.data.email}");
                                      },
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline))
                              ])),
                        );
                      }),
                  verticalGap(gap: 8),
                  Padding(
                    padding: _editTextPadding(),
                    child: Text(
                      "Gender",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  Padding(
                    padding: _editTextPadding(),
                    child: DropdownButton(
                        isExpanded: true,
                        value: value.selectedGender,
                        items: value.gender
                            .map<DropdownMenuItem>((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (text) {
                          value.setGender = text;
                        }),
                  ),
                  verticalGap(gap: 8),
                  Center(
                    child: FlatButton(
                      onPressed: () {
                        DialogHelper.changePassword(context);
                      },
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: FONT_NORMAL),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  if (value.loader)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  verticalGap(gap: 4),
                  Center(
                      child: MaterialButton(
                    color: PRIMARY_COLOR,
                    height: 45,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    onPressed: () {
                      if (nameController.text.isEmpty) {
                        showSnack(context, "Name should not be empty");
                      } else if (nameController.text.length < 4) {
                        showSnack(context, "Name must be at least 4 character");
                      } else {
                        value.updateProfile(context, nameController.text, userNameController.text);
                      }
                    },
                    child: Text(
                      "Save Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
                  verticalGap(gap: 20)
                ],
              ),
            ),
            Positioned(
                left: 10,
                top: bannerHeight - 52,
                child: InkWell(
                  onTap: () {
                    ImagePickerHelper.showImagePickerDialog(context, (image) {
                      value.setProfileImage = image;
                    }, header: "Choose Profile Image");
                  },
                  child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: value.photoFile != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(value.photoFile),
                            )
                          : userImage(
                              imageUrl: value.user.photoUrl, radius: 50)),
                ))
          ],
        );
      },
    );
  }

  _editTextPadding() {
    return const EdgeInsets.only(left: 20, right: 20, top: 8);
  }

  _inputDecoration(String hint) {
    return InputDecoration(
        labelText: "$hint",
        labelStyle: TextStyle(color: Colors.black54),
        floatingLabelBehavior: FloatingLabelBehavior.always);
  }
}
