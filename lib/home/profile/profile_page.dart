import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/home/chat/chat_screen.dart';
import 'package:solo/home/profile/ProfileActionNotifier.dart';
import 'package:solo/home/profile/edit_profile_page.dart';
import 'package:solo/home/profile/post_page.dart.dart';
import 'package:solo/home/settings/setting_page.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';

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
          body: _ProfilePageState(this)),
      create: (BuildContext context) => ProfileActionNotifier(
          otherUser: otherProfile ? _user : null,
          currentUser: otherProfile ? currentUser : _user),
    );
  }
}

class _ProfilePageState extends StatefulWidget {
  final ProfilePage widget;

  _ProfilePageState(this.widget);

  @override
  __ProfilePageStateState createState() => __ProfilePageStateState();
}

class __ProfilePageStateState extends State<_ProfilePageState>
    with WidgetsBindingObserver {
  final bannerHeight = 250.0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var notifier = Provider.of<ProfileActionNotifier>(context, listen: false);
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
                              if(!widget.widget.otherProfile) {
                                goToPage(context, EditProfilePage(),fullScreenDialog: true);
                              }
                            },
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: appBarColor,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    widget.widget._user.photoUrl == null
                                        ? AssetImage("$IMAGE_ASSETS/default_dp.png")
                                        : CachedNetworkImageProvider(
                                            widget.widget._user.photoUrl),
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
                                "${widget.widget._user.name}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: FONT_LARGE,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              if(widget.widget._user.username != null && widget.widget._user.username.isNotEmpty)
                                Text(
                                "@${widget.widget._user.username}",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: FONT_NORMAL),
                              ),
                              verticalGap(gap: 8),
                              bioWidget()
                            ],
                          ),
                        ),
                        if (!widget.widget.otherProfile)
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
                    if (!widget.widget.otherProfile)
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
                widget.widget.otherProfile
                    ? OutlineButton(
                        onPressed: () {
                          if (!value.isFollowing) {
                            notifier.followUser(
                                context,
                                widget.widget.currentUser.id,
                                widget.widget._user);
                          } else {
                            //UnFollow
                            showAlertDialog(context, null,
                                "Unfollow ${widget.widget._user.name} ?",
                                actions: [
                                  dialogButton(
                                      buttonText: "Unfollow",
                                      onPressed: () {
                                        Navigator.pop(context);
                                        notifier.unFollowUser(
                                            value.followingConnection, context);
                                      })
                                ]);
                          }
                        },
                        child: Text(value.isFollowing ? "Following" : "Follow"))
                    : Container(),
                SizedBox(
                  height: widget.widget.otherProfile ? 10 : 0,
                ),

                Material(
                  elevation: 5,
                    child: tabSection(value)),
                Expanded(
                  child: getPage(value.getTopAction, value),
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
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: widget.widget._user.bannerUrl != null
                                  ? CachedNetworkImageProvider(
                                      widget.widget._user.bannerUrl)
                                  : AssetImage(("$IMAGE_ASSETS/login_bg.jpeg")),
                              fit: BoxFit.cover)),
                    )),
              ),
            ];
          },
        );
      },
    );
  }

  Widget getPage(int index, ProfileActionNotifier notifier) {
    var page;

    if (index == 1)
      page = PostPage(widget.widget._user);
    else if (index == 2)
      page = _Following(notifier.myFollowers, widget.widget._user,
          widget.widget.otherProfile, widget.widget.currentUser);
    else if (index == 3)
      page = _Following(notifier.myFollowings, widget.widget._user,
          widget.widget.otherProfile, widget.widget.currentUser);

    return page;
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

  Widget bioWidget() {
    return widget.widget.otherProfile
        ? widget.widget._user.bio != null
        ? Text(widget.widget._user.bio)
        : Container()
        : widget.widget._user.bio == null
        ? OutlineButton(
        onPressed: () {
          DialogHelper.addBioDialog(context, "", (text) {
            widget.widget._user.bio = text;
            ApiProvider.profileApi
                .updateBio(widget.widget._user, text);
            setState(() {});
          });
        },
        child: Text("+ Add Bio"))
        : InkWell(
      onTap: () {
        DialogHelper.addBioDialog(
            context, widget.widget._user.bio, (text) {
          widget.widget._user.bio = text;
          ApiProvider.profileApi
              .updateBio(widget.widget._user, text);
          setState(() {});
        });
      },
      child: Text(
        widget.widget._user.bio,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Following extends StatefulWidget {
  final List<User> myFollowings;
  List<bool> isFollowing = [];
  ConnectionDao connectionDao = ConnectionDao();

  final User _user;
  final bool otherProfile;
  final User currentUser;

  User loggedInUser;

  _Following(
      this.myFollowings, this._user, this.otherProfile, this.currentUser) {
    loggedInUser = otherProfile ? currentUser : _user;
    create();
  }

  create() {
//    this.myFollowings.forEach((user) async {
//      print("check $user");
//      //var resp = await ApiProvider.profileApi.isFollowing(loggedInUser, user);
//      var con = connectionDao.isFollowing(loggedInUser.id, user.id);
//      isFollowing.add(con != null);
//    });
  }

  @override
  __FollowingState createState() => __FollowingState();
}

class __FollowingState extends State<_Following> {
  @override
  Widget build(BuildContext context) {
    var notifier = Provider.of<ProfileActionNotifier>(context, listen: false);

    return Container(
      child: ListView.builder(
          itemCount: widget.myFollowings.length,
          itemBuilder: (context, index) {
            User user = widget.myFollowings[index];

            return Container(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ProfilePage(
                                user,
                                otherProfile: user.id != widget.loggedInUser.id,
                                currentUser: widget.loggedInUser,
                              )));
                },
                leading: userImage(
                    imageUrl: widget.myFollowings[index].photoUrl, radius: 20),
                title: Text(
                  widget.myFollowings[index].name,
                  style: TextStyle(fontSize: FONT_NORMAL),
                ),
                trailing: widget.otherProfile
                    ? widget.otherProfile &&
                            user.id ==
                                widget.loggedInUser
                                    .id //CHECK IF OTHER PERSON SE WATCHING OWN PROFILE
                        ? null
                        : null
                    : OutlineButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ChatScreenPage(
                                          widget.loggedInUser, user)));
                        },
                        child: Text("Message"),
                      ),
              ),
            );
          }),
    );
  }
}
