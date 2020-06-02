

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:solo/helper/image_picker_helper.dart';
import 'package:solo/location/locationPage.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/session_manager.dart';

import '../utils.dart';

class CreatePostNotifier extends ChangeNotifier {


  File selectedImage;
  final _selectedTagsUser = <User>[];
  var _tagNames = "";


  CreatePostNotifier(this.selectedImage);

  List<User> get selectedTags => _selectedTagsUser;
  String get tagNames => _tagNames;

  void addImage(context) {
    ImagePickerHelper.showImagePickerDialog(context, (file) async {
      selectedImage = await MyImageCropper.openSquare(file);
      notifyListeners();
    });
  }

  void updateUI() {
    notifyListeners();
  }


  void createTagNames() {
    _tagNames = "";

    _selectedTagsUser.forEach((user) {
      if(_tagNames.isEmpty) {
        _tagNames = user.name;
      }
      else {
        _tagNames += ", ${user.name}";
      }
    });

    notifyListeners();
  }

  Future<void> sharePost(String captions) async {
    return _createPost(captions, _selectedTagsUser,selectedImage);
  }

  Future<void> _createPost(String captions, List<User> tags, File imageFile) async {
    var postModel = PostModel(
        id: Uuid().generateV4(),
        userId: SessionManager.currentUser.id,
        user: SessionManager.currentUser,
        caption: captions,
        imageUrl: "",
        tagsUser: tags,
        locations: "",
        likes: [],
        comments: [],
        timestamp: Utils.timestamp());

   await ApiProvider.homeApi.createPost(postModel, imageFile);
  }
}