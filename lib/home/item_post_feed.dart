import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:solo/database/app_constants.dart';
import 'package:solo/hashtag/HashTagText.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/hashtag/hash_tag_page.dart';
import 'package:solo/home/profile/profile_page.dart';
import 'package:solo/home/report/report_dialogs.dart';
import 'package:solo/location/locationPage.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/report_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';

import '../session_manager.dart';
import '../utils.dart';

class ItemFeedPost extends StatelessWidget {
  final PostModel postModel;
  final User currentUser = SessionManager.currentUser;
  final commentEditController = TextEditingController();

  final likeColor = Color(0xffFE375F);

  ItemFeedPost(this.postModel);

  Widget commentEditField(context) {
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(25)),
      elevation: 2,
      child: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: commentEditController,
        decoration: InputDecoration(
            prefixIcon: userImage(imageUrl: currentUser.photoUrl, radius: 12),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.send,
                color: PRIMARY_COLOR,
              ),
              onPressed: () {
                if (commentEditController.text.isNotEmpty) {
                  Comment comment = Comment(
                      id: Uuid().generateV4(),
                      timestamp: Utils.timestamp(),
                      comments: commentEditController.text,
                      user: currentUser);
                  ApiProvider.homeApi
                      .commentPost(currentUser, postModel, comment);
                  commentEditController.clear();
                  hideKeyboard(context);
                }
              },
            ),
            contentPadding: EdgeInsets.all(12),
            hintText: "Comments ?",
            prefixText: "  ",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                borderSide: BorderSide.none)),
      ),
    );
  }

  Widget likeWidget(BuildContext context) {
    bool isLikedByMe = postModel.likes.contains(currentUser);

    return InkWell(
      onTap: () {
        if (isLikedByMe) {
          //Unlike
          print("Tap Unlike");
          ApiProvider.homeApi
              .likePost(currentUser, postModel, removeLike: true);
        } else {
          //Like
          print("Tap Like");
          ApiProvider.homeApi.likePost(currentUser, postModel);
        }
      },
      onLongPress: () {
        if(postModel.likes.length > 0) {
          final users = <User>[];
          postModel.likes.forEach((element) {
            users.add(element.user);
          });
          DialogHelper.userList(context, "Liked By", users , onAction: (user) {
            goToPage(
                context,
                ProfilePage(
                  user,
                  otherProfile: user.id !=
                      SessionManager.currentUser.id,
                  currentUser: SessionManager.currentUser,
                ));
          });
        }
      },
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: Colors.white,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 15,
              ),
              Text(
                "${postModel.likes.length} ${postModel.likes.length > 1 ? "Likes" : "Like"}",
                style:
                    TextStyle(color: isLikedByMe ? likeColor : Colors.black87),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                padding: dimenAll(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLikedByMe ? likeColor : Colors.blueGrey,
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageWidget() {
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      elevation: 2,
      child: rectImage(imageUrl: postModel.imageUrl),
    );
  }

  Widget commentWidget() {
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(25)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: dimenAll(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PRIMARY_COLOR,
              ),
              child: Icon(
                Icons.chat_bubble,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text("View Comments"),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget captionWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: 240,
                child: HashTagText(
                  text: postModel.caption,
                  onHashTagClick: (tag) {
                    goToPage(context, HashTagPage(tag));
                  },
                )),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget singleComments(BuildContext context, Comment comment) {
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Color(0xffF6F7F9),
            borderRadius: BorderRadius.all(Radius.circular(23))),
        child: ListTile(
          onTap: () {
            _Utils.openCommentPage(context, postModel, this);
          },
          leading: userImage(imageUrl: comment.user.photoUrl, radius: 18),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(comment.user.name,
                style: TextStyle(
                    fontSize: FONT_SMALL,
                    color: Colors.black,
                    fontWeight: FontWeight.w700)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HashTagText(
                onHashTagClick: (tag) {
                  goToPage(context, HashTagPage(tag));
                },
                text: comment.comments,
                hashTagStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.blue),
                normalTextStyle:
                    TextStyle(fontSize: FONT_NORMAL, color: Colors.black54),
              ),
              verticalGap(gap: 4),
              if (comment.timestamp != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(Utils.displayDate(comment.timestamp),
                        style: TextStyle(
                          fontSize: FONT_SMALL,
                        )),
                    horizontalGap(gap: 12),
                    if (comment.user.id == SessionManager.currentUser.id)
                      InkWell(
                          onTap: () {
                            showAlertDialog(
                                context, "Delete Comment?", comment.comments,
                                actions: [
                                  dialogButton(
                                      buttonText: "Delete",
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ApiProvider.homeApi
                                            .deleteComment(postModel, comment);
                                      })
                                ]);
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Colors.red, fontSize: FONT_SMALL),
                          ))
                  ],
                ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final init = ApiResponse<User>();
    init.success = postModel.user;

    return FutureBuilder(
        initialData: init,
        future: ApiProvider.homeApi.fetchUserByID(postModel.userId),
        builder:
            (BuildContext context, AsyncSnapshot<ApiResponse<User>> snapshot) {
          postModel.user = snapshot.data.success;

          return Container(
            margin: dimenAll(12),
            width: MATCH_PARENT,
            child: Stack(
              children: <Widget>[
                Card(
                  color: Color(0xfffefefe),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Container(
                    //color: Colors.redAccent,
                    padding: dimenAll(12),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            goToPage(
                                context,
                                ProfilePage(
                                  postModel.user,
                                  otherProfile: postModel.user.id !=
                                      SessionManager.currentUser.id,
                                  currentUser: SessionManager.currentUser,
                                ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              userImage(
                                  imageUrl: postModel.user.photoUrl,
                                  radius: 20),
                              Column(
                                children: <Widget>[
                                  Text(
                                    postModel.user.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: FONT_MEDIUM),
                                  ),
                                  verticalGap(gap: 4),
                                  Text(
                                    Utils.displayDate(postModel.timestamp),
                                    style: TextStyle(
                                        fontSize: FONT_SMALL,
                                        color: Colors.grey),
                                  )
                                ],
                              ),
                              IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {
                                    DialogHelper.postItemOption(
                                        context,
                                        postModel.userId == currentUser.id
                                            ? postItemMyOptions
                                            : postItemOtherOptions,
                                        onAction: (str) {
                                      if (str == AppConstant.DELETE_POST) {
                                        DialogHelper.customAlertDialog(context,
                                            title: "Confirm Deletion",
                                            content: "Delete this post?",
                                            positiveButton: "Delete",
                                            negativeButton: "Don't Delete",
                                            onConfrim: () async {
                                          final resp = await ApiProvider.homeApi
                                              .deletePost(postModel);
                                          if (resp.hasError == false) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Post Deleted Successfully");
                                          }
                                        });
                                        //DELETE POST
                                      } else if (str ==
                                          AppConstant.REPORT_POST) {
                                        BottomSheetReport.show(context,
                                            reportType: ReportType.POST,
                                            reportingID: postModel.id,
                                            user: SessionManager.currentUser);
                                        //REPORT
                                      }
                                    });
                                  })
                            ],
                          ),
                        ),
                        Divider(),
                        SizedBox(
                          height: 12,
                        ),
                        Stack(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
//                          if (postModel.imageUrl == null ||
//                              postModel.imageUrl.isEmpty)
                                captionWidget(context),
                                postModel.imageUrl == null ||
                                        postModel.imageUrl.isEmpty
                                    ? Container()
                                    : InkWell(
                                        onTap: () {
                                          showImageViewerDialog(
                                              context, postModel.imageUrl);
                                        },
                                        child: imageWidget()),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    width: 175,
                                    child: InkWell(
                                        onTap: () {
                                          _Utils.openCommentPage(
                                              context, postModel, this);
//                                    Navigator.of(context).push(MaterialPageRoute(
//                                        builder: (BuildContext context) {
//                                          return BottomSheetComment(postModel,this);
//                                        },
//                                        fullscreenDialog: true
//                                    ));
                                        },
                                        child: commentWidget())),
                              ],
                            ),
                            Positioned(
                                bottom: 30, right: 0, child: likeWidget(context))
                          ],
                        ),
                        // if (postModel.imageUrl.isNotEmpty) captionWidget(),
                        SizedBox(
                          height: 12,
                        ),
                        if (postModel.comments.length > 0)
                          singleComments(
                              context,
                              postModel
                                  .comments[postModel.comments.length - 1]),
                        commentEditField(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class BottomSheetComment extends StatefulWidget {
  final PostModel postModel;
  final ItemFeedPost itemFeedPost;

  BottomSheetComment(this.postModel, this.itemFeedPost);

  @override
  _BottomSheetCommentState createState() => _BottomSheetCommentState();
}

class _BottomSheetCommentState extends State<BottomSheetComment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 40, left: 8, right: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HashTagText(
                onHashTagClick: (tag) {
                  goToPage(context, HashTagPage(tag));
                },
                text: "${widget.postModel.caption}",
                normalTextStyle: TextStyle(
                  color: Colors.black,
                    fontFamily: "Gothom",
                    fontSize: FONT_MEDIUM, fontWeight: FontWeight.w700),
              ),
              verticalGap(gap: 8),
              Row(
                children: <Widget>[
                  Text("${widget.postModel.likes.length} Likes",
                      style: TextStyle(
                        fontSize: FONT_SMALL,
                      )),
                  horizontalGap(gap: 12),
                  Text("${widget.postModel.comments.length} Commetns",
                      style: TextStyle(
                        fontSize: FONT_SMALL,
                      )),
                ],
              ),
              widget.postModel.comments.length > 0
                  ? Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 22),
                        child: ListView.builder(
                            itemCount: widget.postModel.comments.length,
                            itemBuilder: (context, index) {
                              final comment = widget.postModel.comments[index];

                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: ListTile(
                                  leading: InkWell(
                                      onTap: () {
                                        goToPage(
                                            context,
                                            ProfilePage(
                                              comment.user,
                                              otherProfile: comment.user.id !=
                                                  SessionManager.currentUser.id,
                                              currentUser:
                                                  SessionManager.currentUser,
                                            ));
                                      },
                                      child: userImage(
                                          imageUrl: comment.user.photoUrl,
                                          radius: 18)),
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(comment.user.name,
                                        style: TextStyle(
                                            fontSize: FONT_SMALL,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      HashTagText(
                                        onHashTagClick: (tag) {
                                          goToPage(context, HashTagPage(tag));
                                        },
                                        text: comment.comments,
                                        hashTagStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.blue),
                                        normalTextStyle:
                                        TextStyle(fontSize: FONT_NORMAL, color: Colors.black54),
                                      ),
                                      verticalGap(gap: 4),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              Utils.displayDate(
                                                  comment.timestamp),
                                              style: TextStyle(
                                                fontSize: FONT_SMALL,
                                              )),
                                          horizontalGap(gap: 12),
                                          if (comment.user.id ==
                                              SessionManager.currentUser.id)
                                            InkWell(
                                                onTap: () {
                                                  showAlertDialog(
                                                      context,
                                                      "Delete Comment?",
                                                      comment.comments,
                                                      actions: [
                                                        dialogButton(
                                                            buttonText:
                                                                "Delete",
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              ApiProvider
                                                                  .homeApi
                                                                  .deleteComment(
                                                                      widget
                                                                          .postModel,
                                                                      comment);

                                                              setState(() {});
                                                            })
                                                      ]);
                                                },
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: FONT_SMALL),
                                                ))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    )
                  : Expanded(
                      child: Center(
                      child: Text("No Comments"),
                    )),
              widget.itemFeedPost.commentEditField(context)
            ],
          ),
        ),
      ),
    );
  }
}

void showImageViewerDialog(BuildContext context, String url) {
  showDialog(
    context: context,
    child: Scaffold(
      body: Container(
          color: Colors.black,
          child: Center(
            child: PhotoView(
              enableRotation: true,
              imageProvider: CachedNetworkImageProvider(url),
            ),
          )),
    ),
  );
}

class _Utils {
  static openCommentPage(context, postModel, itemFeedPost) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => BottomSheetComment(postModel, itemFeedPost));
  }
}
