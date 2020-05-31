

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  final gender = <String>["Not Specified", "Male", "Female", "Other"];

  EditProfileStateManager() {
    selectedGender = user.gender;

    if (selectedGender == null || selectedGender.isEmpty) {
      selectedGender = gender[0];
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

  void updateProfile(context, String name) async {
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
    user.gender = selectedGender;
    SessionManager.currentUser.name = name;
    await SessionManager().uploadProfile(user);

    loader = false;
    notifyListeners();

    Navigator.pop(context);
    goToPage(context, HomeDashboard(user: SessionManager.currentUser), replace: true);
    Fluttertoast.showToast(msg: "Profile updated Successfully");
  }
}