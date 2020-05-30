import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/home/chat/chat_screen.dart';
import 'package:solo/home/profile/ProfileActionNotifier.dart';
import 'package:solo/main.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/onboarding/login/login.dart';
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("koi v state $state");
    if (state == AppLifecycleState.resumed) {
      print("Resume hua hau");
    }

    //super.didChangeAppLifecycleState(state);
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
        return Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                height: bannerHeight,
                child: Stack(
                  children: <Widget>[
                    widget.widget._user.bannerUrl == null
                        ? Container(
                            color: Colors.grey,
                            height: bannerHeight,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.widget._user.bannerUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) =>
                                Image.asset("$IMAGE_ASSETS/default_dp.png"),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                    if (!widget.widget.otherProfile)
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    if (!widget.widget.otherProfile)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 61,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                widget.widget._user.photoUrl == null
                                    ? AssetImage("$IMAGE_ASSETS/default_dp.png")
                                    : CachedNetworkImageProvider(
                                        widget.widget._user.photoUrl),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "${widget.widget._user.name}",
                          style: TextStyle(
                              color: Colors.white, fontSize: FONT_LARGE),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${widget.widget._user.email}",
                          style: TextStyle(
                              color: Colors.white, fontSize: FONT_NORMAL),
                        ),
                      ],
                    ))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
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
              widget.widget.otherProfile
                  ? widget.widget._user.bio != null
                      ? Text(widget.widget._user.bio)
                      : Container()
                  : widget.widget._user.bio == null
                      ? OutlineButton(
                          onPressed: () {
                            AddBioDialog(context, "", (text) {
                              widget.widget._user.bio = text;
                              ApiProvider.profileApi
                                  .updateBio(widget.widget._user, text);
                              setState(() {});
                            });
                          },
                          child: Text("+ Add Bio"))
                      : InkWell(
                          onTap: () {
                            AddBioDialog(context, widget.widget._user.bio,
                                (text) {
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
                        ),
              SizedBox(
                height: widget.widget.otherProfile
                    ? widget.widget._user.bio != null ? 30 : 0
                    : 20,
              ),
              tabSection(value),
              Expanded(
                child: getPage(value.getTopAction, value),
              ),
              FlatButton(
                child: Text("Logout"),
                onPressed: () {
                  SessionManager().signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => StartHome()));
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget getPage(int index, ProfileActionNotifier notifier) {
    var page;

    if (index == 1)
      page = _Photo();
    else if (index == 2)
      page = _Following(notifier.myFollowers, widget.widget._user,
          widget.widget.otherProfile, widget.widget.currentUser);
    else if (index == 3)
      page = _Following(notifier.myFollowings, widget.widget._user,
          widget.widget.otherProfile, widget.widget.currentUser);

    return page;
  }

  Widget tabSection(ProfileActionNotifier value) {
    return Row(
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
}

class _Photo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Photos"),
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

void AddBioDialog(BuildContext context, String bio, Function(String) onUpdate) {
  final bioEditCtrl = TextEditingController();
  bioEditCtrl.text = bio;

  showDialog(
      context: context,
      builder: (context) => Dialog(
            child: Container(
              padding: dimenAll(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("${bio.isNotEmpty ? "Change Bio" : "Add Bio"}"),
                  verticalGap(gap: 8),
                  TextField(
                    controller: bioEditCtrl,
                    decoration: InputDecoration(hintText: "Write Bio"),
                  ),
                  verticalGap(gap: 8),
                  MaterialButton(
                      color: PRIMARY_COLOR,
                      child: Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (bioEditCtrl.text.isNotEmpty) {
                          onUpdate(bioEditCtrl.text);
                        }
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
          ));
}