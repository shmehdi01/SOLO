import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solo/utils.dart';

class ImagePickerHelper {
  static Future<File> pickImageFromGallery() {
    return ImagePicker.pickImage(source: ImageSource.gallery);
  }

  static Future<File> pickImageFromCamera() {
    return ImagePicker.pickImage(source: ImageSource.camera);
  }

  static void showImagePickerDialog(BuildContext context, Function(File image) onClick, {String header = "Choose Image"}) {
     showDialog(
        context: context,
        child: Dialog(
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  Text("$header", style: TextStyle(fontSize: FONT_MEDIUM, fontWeight: FontWeight.bold),),
                  verticalGap(gap: 12),
                  FlatButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        var file = await pickImageFromGallery();
                        onClick(file);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.image),
                          horizontalGap(gap: 8),
                          Text("Gallery"),
                        ],
                      )),
                  verticalGap(gap: 4),
                  FlatButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        var file = await pickImageFromCamera();
                        onClick(file);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.camera_alt),
                          horizontalGap(gap: 8),
                          Text("Camera"),
                        ],
                      ))
                ],
              ),
            ),
          ),
        );
  }
}

class MyImageCropper {

  static Future<File> open(File file) async {
    return await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: appBarColor,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );
  }


  static Future<File> openSquare(File file) async {
   return await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: appBarColor,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );
  }
}
