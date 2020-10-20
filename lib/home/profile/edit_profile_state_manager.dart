

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:solo/helper/valdation_helper.dart';
import 'package:solo/home/home.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

class EditProfileStateManager extends ChangeNotifier {

  User user = SessionManager.currentUser;

  bool loader = false;

  File photoFile;
  File coverFile;

  String selectedGender = "";
  String username = "";
  bool isUserNameAvailable = false;
  String hintText = "";

  final gender = <String>["Not Specified", "Male", "Female", "Other"];

  EditProfileStateManager() {
    selectedGender = user.gender;
    username = user.username;

    if (selectedGender == null || selectedGender.isEmpty) {
      selectedGender = gender[0];
    }

    if (username == null || username.isEmpty) {
      username = "";
    }
  }

  set setGender(String gender) {
    this.selectedGender = gender;
    notifyListeners();
  }

  set setProfileImage(File file) {
    photoFile = file;
    notifyListeners();
  }

  set setCoverImage(File file) {
    coverFile = file;
    notifyListeners();
  }

  void updateProfile(context, String name, String username) async {
    if(username.trim().isNotEmpty) {
      bool b = await checkAvailability(username);
      if(!b && username.isEmpty) {
        return;
      }
    }

    loader= true;
    notifyListeners();


    if(coverFile != null) {
      await ApiProvider.profileApi.changeBackground(user, coverFile);
    }

    if(photoFile != null) {
      final resp = await SessionManager().updateImage(photoFile);
      user.photoUrl = resp.success;
    }


    user.name = name;
    user.username = username;
    user.gender = selectedGender;

    SessionManager.currentUser.name = name;
    SessionManager.currentUser.username = username;

    await SessionManager().uploadProfile(user);

    loader = false;
    notifyListeners();

    Navigator.pop(context);
    goToPage(context, HomeDashboard(user: SessionManager.currentUser), replace: true);
    Fluttertoast.showToast(msg: "Profile updated Successfully");
  }

  Future<bool> checkAvailability(String username) async {
    if(username.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter username");
      return false;
    }

    if(!Validator.isUsername(username)) {
      Fluttertoast.showToast(msg: "Please enter valid username");
      return false;
    }

    if(username.length < 4) {
      Fluttertoast.showToast(msg: "Username length should be minimum 4");
      return false;
    }

    isUserNameAvailable = await ApiProvider.signUpApi.checkUserNameAvailability(username);
    hintText = isUserNameAvailable ? "$username available" : "$username not available";

    notifyListeners();

    return isUserNameAvailable;
  }
}