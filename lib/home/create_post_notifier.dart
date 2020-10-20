

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solo/helper/image_picker_helper.dart';
import 'package:solo/helper/valdation_helper.dart';
import 'package:solo/location/locationPage.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/session_manager.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';

class CreatePostNotifier extends ChangeNotifier {


  File selectedImage;
  File selectedVideo;
  VideoPlayerController videoPlayerController;
  final _selectedTagsUser = <User>[];
  var _tagNames = "";

  String location = "";

  CreatePostNotifier(this.selectedImage);

  List<User> get selectedTags => _selectedTagsUser;
  String get tagNames => _tagNames;

  set setLocation(String loc) {
    location = loc;
    notifyListeners();
  }

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
    return _createPost(captions, _selectedTagsUser,selectedVideo != null ? selectedVideo : selectedImage);
  }

  Future<void> _createPost(String captions, List<User> tags, File file) async {
    var postModel = PostModel(
        id: Uuid().generateV4(),
        userId: SessionManager.currentUser.id,
        user: SessionManager.currentUser,
        caption: captions,
        imageUrl: "",
        mediaType: selectedVideo != null ? "video" : selectedImage != null ? "image" : "text",
        tagsUser: tags,
        locations: location,
        likes: [],
        comments: [],
        hashTags: Validator.splitHashTags(captions),
        timestamp: Utils.timestamp());

   await ApiProvider.homeApi.createPost(postModel, file);
  }

  void testVideo() async {
    File selectedVideo  = await ImagePicker.pickVideo(source: ImageSource.gallery);
    print(selectedVideo.lengthSync());
//    if(selectedVideo.lengthSync() > 2*1024*1024) {
//      Fluttertoast.showToast(msg: "Video length is greaer than 2 MB");
//      return;
//    }

    this.selectedVideo = selectedVideo;
    videoPlayerController = VideoPlayerController.file(this.selectedVideo);
    await videoPlayerController.initialize();

    notifyListeners();
    videoPlayerController.play();


  }
}