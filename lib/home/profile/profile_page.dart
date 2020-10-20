import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/helper/image_picker_helper.dart';
import 'package:solo/home/chat/chat_screen.dart';
import 'package:solo/home/profile/ProfileActionNotifier.dart';
import 'package:solo/home/profile/edit_profile_page.dart';
import 'package:solo/home/profile/post_page.dart.dart';
import 'package:solo/home/settings/setting_page.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/session_manager.dart';

import '../../utils.dart';

class ProfilePage extends StatelessWidget {
  final User _user;
  final bool otherProfile;
  final User currentUser;

  ProfilePage(this._user, {this.otherProfile = false, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: Scaffold(
          appBar: PreferredSize(
              child: Container(), preferredSize: Size.fromHeight(0)),
          body: _ProfileBody(this)),
      create: (BuildContext context) => ProfileActionNotifier(otherUser: otherProfile ? _user : null, currentUser: otherProfile ? currentUser : _user),
    );
  }
}


class _ProfileBody extends StatelessWidget {
  final bannerHeight = 250.0;
  final ProfilePage widget;

  _ProfileBody(this.widget);

  @override
  Widget build(BuildContext context) {
   // var notifier = Provider.of<ProfileActionNotifier>(context, listen: false);
    return Consumer<ProfileActionNotifier>(
      builder:
          (BuildContext context, ProfileActionNotifier value, Widget child) {
        return NestedScrollView(
          body: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              if(!widget.otherProfile) {
                                goToPage(context, EditProfilePage(),fullScreenDialog: true);
                              }
                            },
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: appBarColor,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    widget._user.photoUrl == null
                                        ? AssetImage("$IMAGE_ASSETS/default_dp.png")
                                        : CachedNetworkImageProvider(
                                            widget._user.photoUrl),
                              ),
                            ),
                          ),
                        ),
                        horizontalGap(gap: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "${widget._user.name}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: FONT_LARGE,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              if(widget._user.username != null && widget._user.username.isNotEmpty)
                                Text(
                                "@${widget._user.username}",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: FONT_NORMAL),
                              ),
                              verticalGap(gap: 8),
                              bioWidget(context, value)
                            ],
                          ),
                        ),
                        if (!widget.otherProfile)
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              goToPage(context, SettingPage(), fullScreenDialog: true);
                            },
                          ),
                      ],
                    ),
                    if (!widget.otherProfile)
                      Positioned(
                        bottom: 10,
                        left: 70,
                        child: Container(
                          decoration: BoxDecoration(
                              color: PRIMARY_COLOR,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          height: 20,
                          width: 20,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                Divider(),
                widget.otherProfile
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlineButton(
                            onPressed: () {
                              if (!value.isFollowing) {
                                value.followUser(
                                    context,
                                    widget.currentUser.id,
                                    widget._user);
                              } else {
                                //UnFollow
                                showAlertDialog(context, null,
                                    "Unfollow ${widget._user.name} ?",
                                    actions: [
                                      dialogButton(
                                          buttonText: "Unfollow",
                                          onPressed: () {
                                            Navigator.pop(context);
                                            value.unFollowUser(
                                                value.followingConnection, context);
                                          })
                                    ]);
                              }
                            },
                            child: Text(value.isFollowing ? "Following" : "Follow")),
                        if(value.isFollowing) horizontalGap(gap: 12),
                        if(value.isFollowing) OutlineButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChatScreenPage(
                                              SessionManager.currentUser, widget._user)));
                            },
                            child: Text("Message")),
                      ],
                    )
                    : Container(),
                SizedBox(
                  height: widget.otherProfile ? 10 : 0,
                ),

                Material(
                  elevation: 5,
                    child: tabSection(value)),
                Expanded(
                  child: value.getPage,
                ),
              ],
            ),
          ),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      child: widget._user.bannerUrl == null  && widget.otherProfile == false ?  Center(child: FlatButton(onPressed: () {
                        ImagePickerHelper.showImagePickerDialog(context, (image)  async {
                          File cropped = await MyImageCropper.open(image);
                          value.changeCoverImage(context, cropped);
                        }, header: "Choose Cover Image");
                      },
                      child: Text(" + Add New Cover"))) : null,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: widget._user.bannerUrl != null
                                  ? CachedNetworkImageProvider(
                                      widget._user.bannerUrl)
                                  : AssetImage(("$IMAGE_ASSETS/solo_bg.png")),
                              fit: BoxFit.cover)),
                    )),
              ),
            ];
          },
        );
      },
    );
  }


  Widget tabSection(ProfileActionNotifier value) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: tabAction(
                1, value.photoCount, "Posts", value.getTopAction == 1, (index) {
              value.setTopAction = index;
            }),
          ),
          Expanded(
            child: tabAction(
                2, value.followerCount, "Followers", value.getTopAction == 2,
                (index) {
              value.setTopAction = index;
            }),
          ),
          Expanded(
            child: tabAction(
                3, value.followingCount, "Followings", value.getTopAction == 3,
                (index) {
              value.setTopAction = index;
            }),
          ),
        ],
      ),
    );
  }

  Widget tabAction(int index, int total, String title, bool isSelected,
      Function(int) onTap) {
    return InkWell(
      onTap: () {
        onTap(index);
      },
      child: Column(
        children: <Widget>[
          Text(
            "$total",
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            "$title",
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: FONT_NORMAL),
          ),
          AnimatedContainer(
            margin: const EdgeInsets.only(top: 12),
            width: isSelected ? 100 : 0,
            color: isSelected ? PRIMARY_COLOR : Colors.white,
            height: 3,
            duration: Duration(milliseconds: 300),
          )
        ],
      ),
    );
  }

  Widget bioWidget(BuildContext context, ProfileActionNotifier value) {
    return widget.otherProfile
        ? widget._user.bio != null
        ? Text(widget._user.bio)
        : Container()
        : widget._user.bio == null
        ? OutlineButton(
        onPressed: () {
          DialogHelper.addBioDialog(context, "", (text) {
            widget._user.bio = text;
            value
                .updateBio(widget._user, text);
            //setState(() {});
          });
        },
        child: Text("+ Add Bio"))
        : InkWell(
      onTap: () {
        DialogHelper.addBioDialog(
            context, widget._user.bio, (text) {
          widget._user.bio = text;
          value
              .updateBio(widget._user, text);
         // setState(() {});
        });
      },
      child: Text(
        widget._user.bio,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
