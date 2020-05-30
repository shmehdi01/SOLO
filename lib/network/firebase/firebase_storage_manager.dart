import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

const PROFILE = "profiles";

class FirebaseStorageManager {
  static Future<String> upload(String path, File file) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(path);
    final StorageUploadTask storageUploadTask = storageReference.putFile(file);
    StorageTaskSnapshot snapshot = await storageUploadTask.onComplete.catchError((onError) {
      print("Uploading Error ${onError.message}");
    });
    String downloadUrl = await snapshot.ref.getDownloadURL().catchError((onError) {
      print("DownloadUrl Error ${onError.message}");
    });
    print("Download Urls: $downloadUrl");
    return downloadUrl;
  }
}
