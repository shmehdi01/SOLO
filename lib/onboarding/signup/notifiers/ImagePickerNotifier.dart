import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solo/home/HomeActionNotifier.dart';
import 'package:solo/home/home.dart';
import 'package:solo/models/user.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

class ImagePickerNotifier with ChangeNotifier {


  bool changeDP = false;

  File _imageFile;
  User _user;
  bool _loader = false;

  bool get loader => _loader;
  File get imageFile => _imageFile;

  User get user => _user;

  set user(User user) => _user = user;

  Future<Null> pickImageFromGallery(BuildContext context) async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    notifyListeners();

    _uploadProfile(context,_imageFile);
  }

  Future<Null> pickImageFromCamera(BuildContext context) async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    notifyListeners();

    //_uploadProfile(context,_imageFile);
  }

  _uploadProfile(BuildContext context, File file) async {
    _loader = true;
    notifyListeners();

    var response = await SessionManager().updateImage(file);
    if(!response.hasError) {
      print("Image Upload Success");
      _user.photoUrl = response.success;

      if(changeDP) {
        SessionManager.currentUser.photoUrl = response.success;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    HomePage(user: SessionManager.currentUser, homePageState: HomePageState.PROFILE,)));
      }else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    HomePage(user: _user,)));
      }
    }
    else {
      print(response.error.errorMsg);
      showSnack(context, response.error.errorMsg,error: true);
    }

    _loader = false;
    notifyListeners();
  }

  ImagePickerNotifier(this._user, this.changeDP);
}