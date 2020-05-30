import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:solo/home/profile/profile_page.dart';
import 'package:solo/location/locationPage.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
//import 'package:zoomable_image/zoomable_image.dart';

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
            prefixIcon: userImage(imageUrl: currentUser.photoUrl,radius: 12),
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
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

  Widget likeWidget() {
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
              Text("${postModel.likes.length} ${postModel.likes.length > 1 ? "Likes" : "Like"}", style: TextStyle(color: isLikedByMe ? likeColor : Colors.black87),),
              SizedBox(
                width: 10,
              ),
              Container(
                padding: dimenAll(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:  isLikedByMe ? likeColor : Colors.blueGrey,
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
      child: Hero(
        child: rectImage(imageUrl: postModel.imageUrl), tag: "image",),
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

  Widget captionWidget() {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 240,
                child: Text("${postModel.caption}")),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget singleComments(BuildContext context, Comment comment) {
    return  Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xffF6F7F9),
        borderRadius: BorderRadius.all(Radius.circular(23))

      ),
      child: ListTile(
        onTap: () {
          _Utils.openCommentPage(context, postModel, this);
        },
        leading: userImage(imageUrl: comment.user.photoUrl, radius: 18),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(comment.user.name, style: TextStyle(fontSize: FONT_SMALL, color: Colors.black, fontWeight: FontWeight.w700)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(comment.comments, style: TextStyle(fontSize: FONT_NORMAL,)),
            verticalGap(gap: 4),
            if(comment.timestamp != null) Text(Utils.displayDate(comment.timestamp), style: TextStyle(fontSize: FONT_SMALL,)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            imageUrl: postModel.user.photoUrl, radius: 20),
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
                                  fontSize: FONT_SMALL, color: Colors.grey),
                            )
                          ],
                        ),
                        IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: null)
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
                            captionWidget(),
                          postModel.imageUrl == null ||
                                  postModel.imageUrl.isEmpty
                              ? Container()
                              : InkWell(
                            onTap: () {
                              showImageViewerDialog(context, postModel.imageUrl);
                            },
                              child: imageWidget()),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              width: 175,
                              child: InkWell(
                                  onTap: () {
                                    _Utils.openCommentPage(context, postModel, this);
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
                      Positioned(bottom: 30, right: 0, child: likeWidget())
                    ],
                  ),
                 // if (postModel.imageUrl.isNotEmpty) captionWidget(),
                  SizedBox(
                    height: 12,
                  ),
                  if(postModel.comments.length > 0) singleComments(context,postModel.comments[postModel.comments.length-1]),
                  commentEditField(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class BottomSheetComment extends StatelessWidget {
  final PostModel postModel;
  final ItemFeedPost itemFeedPost;


  BottomSheetComment(this.postModel, this.itemFeedPost);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 40, left: 8,right: 8,bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${postModel.caption}",
                style:
                    TextStyle(fontSize: FONT_MEDIUM, fontWeight: FontWeight.w700),
              ),
              verticalGap(gap: 8),
              Row(
                children: <Widget>[
                  Text("${postModel.likes.length} Likes",
                      style: TextStyle(
                        fontSize: FONT_SMALL,
                      )),
                  horizontalGap(gap: 12),
                  Text("${postModel.comments.length} Commetns",
                      style: TextStyle(
                        fontSize: FONT_SMALL,
                      )),
                ],
              ),
              postModel.comments.length > 0
                  ? Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 22),
                        child: ListView.builder(
                            itemCount: postModel.comments.length,
                            itemBuilder: (context, index) {
                              final comment = postModel.comments[index];

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
                                            currentUser: SessionManager.currentUser,
                                          ));
                                    },
                                      child: userImage(imageUrl: comment.user.photoUrl, radius: 18)),
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(comment.user.name, style: TextStyle(fontSize: FONT_SMALL, color: Colors.black, fontWeight: FontWeight.w700)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(comment.comments, style: TextStyle(fontSize: FONT_NORMAL,)),
                                      verticalGap(gap: 4),
                                      Text(Utils.displayDate(comment.timestamp), style: TextStyle(fontSize: FONT_SMALL,)),
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
              itemFeedPost.commentEditField(context)
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
      body: Hero(
        child: Container(
          color: Colors.black,
            child: Center(
              child: PhotoView(
                enableRotation: true,
                 imageProvider: CachedNetworkImageProvider(url),
              ),
            )), tag: "image",
      ),
    ),
  );
}


class _Utils {
  
  static openCommentPage(context, postModel,itemFeedPost) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) =>
            BottomSheetComment(postModel,itemFeedPost));
  }
}
