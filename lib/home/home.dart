import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solo/helper/image_picker_helper.dart';
import 'package:solo/home/HomeActionNotifier.dart';
import 'package:solo/home/chat/FriendsList.dart';
import 'package:solo/home/chat/chat_page.dart';
import 'package:solo/home/explore/explore_page.dart';
import 'package:solo/home/notifications/notification_page.dart';
import 'package:solo/home/profile/profile_page.dart';
import 'package:solo/home/verify_page.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

import 'create_post_page.dart';
import 'item_post_feed.dart';

class HomeDashboard extends StatelessWidget {
  final User user;
  final User otherUser;
  final HomePageState homePageState;

  HomeDashboard(
      {@required this.user,
      this.otherUser,
      this.homePageState = HomePageState.HOME});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) =>
            HomeActionNotifier(user: user, otherUser: otherUser, homePageState: homePageState),
        child: Scaffold(
          body: user.isEmailVerified ? HomePage(
            user: user,
            homePageState: homePageState,
          ): EmailVerifyPage(),
        ));
  }
}

class HomePage extends StatefulWidget {
  final User user;
  final HomePageState homePageState;

  HomePage({@required this.user, this.homePageState = HomePageState.HOME});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void didUpdateWidget(HomePage oldWidget) {
    WidgetsFlutterBinding.ensureInitialized();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeActionNotifier>(
      builder: (BuildContext context, HomeActionNotifier value, Widget child) {
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: BottomAppBar(
            color: Colors.black.withOpacity(0.85),
            shape: CircularNotchedRectangle(),
            notchMargin: 5.0,
            elevation: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // SizedBox(width: 20,),
                IconButton(
                  onPressed: () {
                    Provider.of<HomeActionNotifier>(context, listen: false)
                        .updatePage = HomePageState.HOME;

                    //value.scrollController.jumpTo(0);
//                    value.scrollController.animateTo(
//                        0,
//                        duration: Duration(milliseconds: 300),
//                        curve: Curves.easeOut);

                  },
                  icon: Icon(
                    Icons.home,
                    color: value.pageState == HomePageState.HOME
                        ? PRIMARY_COLOR
                        : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Provider.of<HomeActionNotifier>(context, listen: false)
                        .updatePage = HomePageState.EXPLORE;
                  },
                  icon: Icon(
                    Icons.whatshot,
                    color: value.pageState == HomePageState.EXPLORE
                        ? PRIMARY_COLOR
                        : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Provider.of<HomeActionNotifier>(context, listen: false)
                        .updatePage = HomePageState.CHAT;
                  },
                  icon: Stack(
                    children: <Widget>[
                      Icon(
                        Icons.chat_bubble_outline,
                        color: value.pageState == HomePageState.CHAT
                            ? PRIMARY_COLOR
                            : Colors.grey,
                      ),
                      if (value.unReadMessage != 0)
                        Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Center(
                              child: Text(
                            "${value.unReadMessage}",
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          )),
                        )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Provider.of<HomeActionNotifier>(context, listen: false)
                        .updatePage = HomePageState.PROFILE;
                  },
                  icon: Icon(
                    Icons.person,
                    color: value.pageState == HomePageState.PROFILE
                        ? PRIMARY_COLOR
                        : Colors.grey,
                  ),
                )
              ],
            ),
          ),
          resizeToAvoidBottomPadding: false,
          floatingActionButton: value.pageState == HomePageState.HOME
              ? FloatingActionButton(
                  heroTag: "CreatePost",
                  child: Icon(Icons.add),
                  onPressed: () {
                    goToPage(context, CreatePostPage(),);
                    //Navigator.push(context, createRoute(CreateUserPost()));
                  },
                )
              : Container(),
          appBar: getAppByState(value),
          resizeToAvoidBottomInset: true,
          body: Consumer<HomeActionNotifier>(
            builder:
                (BuildContext context, HomeActionNotifier value, Widget child) {
              Widget page;
              switch (value.pageState) {
                case HomePageState.HOME:
                  page = HomeBodyOriginal();
                  break;
                case HomePageState.EXPLORE:
                  page = ExplorePage();
                  break;
                case HomePageState.CHAT:
                  page = ChatPage(value.currentUser);
                  break;
                case HomePageState.PROFILE:
                  page = ProfilePage(
                    value.otherUser != null
                        ? value.otherUser
                        : value.currentUser,
                    otherProfile: value.otherUser != null,
                    currentUser: value.currentUser,
                  );
                  break;
              }
              return page;
            },
          ),
        );
      },
    );
  }

  Widget appBar() {
    return PreferredSize(
      child: AppBar(
        leading: MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25))),
          //color: Color(0xffdadada),
          child: Icon(
            Icons.camera_alt,
            color: Colors.black,
          ),
          onPressed: () {
            //exit(0);
            ImagePickerHelper.showImagePickerDialog(context, (image) async {
              File cropped = await MyImageCropper.openSquare(image);
              goToPage(
                  context,
                  CreatePostPage(
                    selectedImage: cropped,
                  ),
                  fullScreenDialog: true);
            }, header: "Create Post");
          },
        ),
        centerTitle: true,
        shape: appBarRounded,
        backgroundColor: Color(0xffefefef),
        title: Image.asset(
          "$IMAGE_ASSETS/logo2.png",
          height: 30,
        ),
        actions: <Widget>[
          MaterialButton(
            minWidth: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25))),
            //color: Color(0xffdadada),
            child: Consumer<HomeActionNotifier>(
              builder: (context, HomeActionNotifier value, w) => Stack(
                children: <Widget>[
                  Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                  if (value.notificationCount != 0)
                    Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Center(
                          child: Text(
                        "${value.notificationCount}",
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      )),
                    )
                ],
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          NotificationPage(SessionManager.currentUser)));
            },
          ),
        ],
      ),
      preferredSize: Size.fromHeight(60),
    );
  }

  Widget exploreAppBar() {
    return PreferredSize(
      child: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: () {
            showSearch(
                context: context,
                delegate: SearchUser(SessionManager.currentUser));
          },
        ),
        centerTitle: true,
        shape: appBarRounded,
        backgroundColor: Color(0xffefefef),
        title: Text(
          "Explore",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      preferredSize: Size.fromHeight(60),
    );
  }

  Widget chatAppBar(HomeActionNotifier value) {
    return PreferredSize(
      child: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            value.updatePage = HomePageState.HOME;
          },
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.all(8),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              textColor: Colors.white,
              color: PRIMARY_COLOR,
              child: Text(
                "New",
              ),
              onPressed: () {
                goToPage(context, FriendsListPage(widget.user));
              },
            ),
          ),
        ],
        centerTitle: true,
        shape: appBarRounded,
        backgroundColor: Color(0xffefefef),
        title: Text(
          "Chats",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      preferredSize: Size.fromHeight(60),
    );
  }

  Widget getAppByState(HomeActionNotifier value) {
    var state = value.pageState;
    Widget toolbar;
    switch (state) {
      case HomePageState.HOME:
        toolbar = appBar();
        break;
      case HomePageState.EXPLORE:
        toolbar = exploreAppBar();
        break;
      case HomePageState.CHAT:
        toolbar = chatAppBar(value);
        break;
      case HomePageState.PROFILE:
        toolbar = PreferredSize(
          child: Container(),
          preferredSize: Size.fromHeight(0),
        );
        break;
    }

    return toolbar;
  }
}

class HomeBodyOriginal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeActionNotifier>(
      builder: (BuildContext context, HomeActionNotifier value, Widget child) =>
          Container(
        child: Column(
          children: <Widget>[
            //Container(margin: dimenAll(12), child: trendingCard()),
            Expanded(
              child: RefreshIndicator(
                child: StreamBuilder(
                    stream: ApiProvider.homeApi.fetchPostsStream(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<PostModel>> snapshot) {

                      print(snapshot);

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                            width: MATCH_PARENT,
                            child: ListView(
                              children: <Widget>[
                                ShimmerLoader(),
                                ShimmerLoader(),
                                ShimmerLoader(),
                                verticalGap(gap: 8),
                              ],
                            ));
                      }

                      if (snapshot.data.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      userImage(imageUrl: null, placeholder: "$IMAGE_ASSETS/icon_circle.png"),
                                      verticalGap(gap: 12),
                                      Text("Welcome To Solo", style: TextStyle(fontSize: FONT_LARGE, fontWeight: FontWeight.bold),),
                                      verticalGap(gap: 8),
                                      Text("When you follow people, you'll see the photos and text they are post here",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      verticalGap(gap: 12),
                                      MaterialButton(
                                        color: Colors.blue,
                                        textColor: Colors.white,
                                        child: Text("Find People to Follow"),
                                        onPressed: () {
                                          showSearch(
                                              context: context,
                                              delegate: SearchUser(SessionManager.currentUser));
                                      },)
                                    ],
                                  ),
                                ),
                              ),
                              verticalGap(gap: 12),

                              Text("No Post Yet", style: TextStyle(color: Colors.grey),)
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: value.scrollController,
                          itemCount: snapshot.data.length,
                          itemBuilder: (ctx, index) =>
                              ItemFeedPost(snapshot.data[index]));
                    }),
                onRefresh: () async {
                  await SessionManager.loadFriends();
                  value.refreshUI();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget trendingCard() {
    return Card(
      color: Color(0xfffefefe),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Container(
        padding: const EdgeInsets.only(top: 20, bottom: 8, right: 20, left: 20),
        width: MATCH_PARENT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Trending Tags",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: FONT_MEDIUM),
            ),
            Divider(),
            Container(
              height: 80,
              child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: <Widget>[
                            Text("${index + 1}."),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "#hashtag",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                    onPressed: () {},
                    child: Column(
                      children: <Widget>[
                        Text("View More"),
                        Icon(Icons.keyboard_arrow_down)
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CreateUserPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: PRIMARY_COLOR,
        appBar: AppBar(
          shape: appBarRounded,
          backgroundColor: appBarColor,
          centerTitle: true,
          leading: Icon(
            Icons.close,
            color: appBarColor,
          ),
          title: Text(
            "Create New Post",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          //color: Colors.red,
          width: MATCH_PARENT,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 2,
                // color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        postWidget(
                            "Live", "Create a live show", Icons.videocam),
                        InkWell(
                            onTap: () {
                              goToPage(context, CreatePostPage(),
                                  replace: true);
                            },
                            child: postWidget(
                                "Post", "Create a new Post", Icons.add)),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                  width: 160,
                  child: Text(
                    "Share your story with the Solo by posting images or videos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal),
                  )),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.close,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget postWidget(String title, String desc, IconData iconData) {
    return Column(
      children: <Widget>[
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white), shape: BoxShape.circle),
          child: Icon(
            iconData,
            size: 30,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: FONT_MEDIUM,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          desc,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}

class ShimmerLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xffdadada),
      highlightColor: Color(0xffefefef),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white30,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        width: MATCH_PARENT,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
        height: 470,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              children: <Widget>[
                userImage(imageUrl: null),
                horizontalGap(gap: 10),
                Container(
                  height: 30,
                  width: 200,
                  color: Color(0xffdadada),
                ),
                horizontalGap(gap: 30),
                Container(
                  height: 30,
                  width: 10,
                  color: Color(0xffdadada),
                )
              ],
            ),
            verticalGap(gap: 12),
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                  color: Color(0xffdadada),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            verticalGap(gap: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffdadada),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  height: 40,
                  width: 300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
