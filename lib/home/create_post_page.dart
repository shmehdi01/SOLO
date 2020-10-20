import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/home/create_post_notifier.dart';
import 'package:solo/models/user.dart';
import 'package:solo/session_manager.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';

class CreatePostPage extends StatelessWidget {
  final body = _CreatePostBody();

  final File selectedImage;

  CreatePostPage({this.selectedImage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: Scaffold(
        appBar: appBar(context, () {
          body.sharePost();
        }),
        body: body,
      ),
      create: (BuildContext context) => CreatePostNotifier(selectedImage),
    );
  }

  Widget appBar(context, Function() share) {
    return PreferredSize(
      child: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shape: appBarRounded,
        backgroundColor: Color(0xffefefef),
        centerTitle: true,
        title: Text(
          "New Post",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.all(8),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              textColor: Colors.white,
              color: PRIMARY_COLOR,
              child: Text("Share"),
              onPressed: () {
                share();
              },
            ),
          ),
        ],
      ),
      preferredSize: Size.fromHeight(60),
    );
  }
}

class _CreatePostBody extends StatelessWidget {
  final colorDarkGrey = Color(0xff68708A);
  final colorBackground = Color(0xffEFF1F8);
  final postController = TextEditingController();

  CreatePostNotifier value;
  BuildContext context;

  void sharePost() async {
    if (postController.text.isNotEmpty) {
      progressDialog(context, "Creating Post..");
      await value.sharePost(postController.text);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostNotifier>(
      builder: (BuildContext context, CreatePostNotifier value, Widget child) {
        this.value = value;
        this.context = context;

        return Container(
          color: colorBackground,
          child: Column(
            children: <Widget>[
              postWidget(context),
              Container(
                padding: const EdgeInsets.all(12),
                height: 50,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Text(
                        "Tag People",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
                      ),
                      onTap: () {
                        pickFriendDialog(context, value.selectedTags, () {
                          value.createTagNames();
                        });
                      },
                    ),
                    Text(
                      value.tagNames,
                      maxLines: 30,
                      style:
                          TextStyle(color: Colors.grey, fontSize: FONT_NORMAL),
                    )
                  ],
                ),
              ),
              verticalGap(gap: 1),
              InkWell(
                onTap: () {
                  //goToPage(context, RoutesWidget());
                  DialogHelper.addLocation(context, (location) {
                    value.setLocation = location;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  height: 50,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        value.location.isNotEmpty ? value.location :  "Add Location",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
                      ),
                    ],
                  ),
                ),
              ),
              if(value.selectedVideo != null) Container(
                height: 300,
                color: Colors.blue,
                child: AspectRatio(
                  aspectRatio: value.videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(value.videoPlayerController),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget postWidget(context) {
    return Consumer<CreatePostNotifier>(
      builder: (BuildContext context, CreatePostNotifier value, Widget child) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              userImage(
                  imageUrl: SessionManager.currentUser.photoUrl, radius: 25),
              horizontalGap(gap: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: postController,
                  decoration: InputDecoration(
                      hintText: "Write a caption",
                      filled: true,
                      fillColor: colorBackground,
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                ),
              ),
              FlatButton(onPressed: ()  {
                value.testVideo();
              },
              child: Text("Record Video"),),
              horizontalGap(gap: 8),
              InkWell(
                onTap: () {
                  value.addImage(context);
                },
                child: value.selectedImage == null
                    ? Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: colorDarkGrey,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        padding: EdgeInsets.all(20),
                        child: Image.asset(
                          "$IMAGE_ASSETS/img_placeholder.png",
                          color: Colors.white,
                        ),
                        //child: Image.asset(name),
                      )
                    : Container(
                        height: 60,
                        width: 60,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: colorDarkGrey,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Image.file(
                          value.selectedImage,
                          fit: BoxFit.cover,
                        ),
                      ),
              )
            ],
          ),
        );
      },
    );
  }
}

void pickFriendDialog(
    BuildContext context, List<User> selectedTagsUser, Function() done) {
  showDialog(
      barrierDismissible: false,
      context: context,
      child: Dialog(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Tag Friends",
                  style: TextStyle(
                      fontWeight: FontWeight.w500, fontSize: FONT_MEDIUM),
                ),
                FutureBuilder(
                  future: SessionManager.loadFriends(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<User>> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data.isEmpty) {
                      return Center(
                        child: Text("No Friends"),
                      );
                    }

                    return Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              var myFollowings = snapshot.data;
                              var user = snapshot.data[index];

                              return Container(
                                margin: const EdgeInsets.all(1),
                                color: selectedTagsUser.contains(user)
                                    ? Color(0xffdadada)
                                    : Colors.white,
                                padding: const EdgeInsets.all(8),
                                child: ListTile(
                                  onTap: () {
                                    if (selectedTagsUser.contains(user)) {
                                      selectedTagsUser.remove(user);
                                    } else {
                                      selectedTagsUser.add(user);
                                    }
                                    setState(() {});
                                  },
                                  leading: userImage(
                                      imageUrl: myFollowings[index].photoUrl,
                                      radius: 20),
                                  title: Text(
                                    myFollowings[index].name,
                                    style: TextStyle(fontSize: FONT_NORMAL),
                                  ),
                                ),
                              );
                            }));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "Clear",
                        style: TextStyle(
                            color: PRIMARY_COLOR,
                            fontSize: FONT_MEDIUM,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        selectedTagsUser.clear();
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: PRIMARY_COLOR,
                            fontSize: FONT_MEDIUM,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        done();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ));
}
