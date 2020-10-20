import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solo/database/dao/SearchKeywordDao.dart';
import 'package:solo/database/entity/search_keywords.dart';
import 'package:solo/hashtag/hash_tag_page.dart';
import 'package:solo/home/profile/profile_page.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';

import '../../utils.dart';
import '../view_post_page.dart';

class PhotoShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xffdadada),
      highlightColor: Color(0xffefefef),
      child: Container(
        color: Color(0xffdadada),
        height: 100,
        width: 100,
      ),
    );
  }
}


class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Map<String, List<PostModel>> trendingTags;

  Future<List<PostModel>> loadExplore() async {
    final resp = await ApiProvider.exploreApi
        .explorePost(Utils.getBeforeTimestamp(hours: 45));
    List<PostModel> models = [];
    resp.success.forEach((element) {
      if (element.imageUrl.isNotEmpty) models.add(element);
    });
    return models;
  }

  Future<List<String>> loadTrendingTags() async {
    final map = await ApiProvider.exploreApi
        .trendingTags(Utils.getBeforeTimestamp(hours: 12));
    trendingTags = map.success;
    return map.success.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder(
          future: loadTrendingTags(),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            print(snapshot.data);
            if (!snapshot.hasData) {
              return Center();
            }

            if (snapshot.data.isEmpty) {
              debugPrint("No Trending tags");
              return horizontalGap(gap: 8);
            }

            return trendingCard(snapshot.data);
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: loadExplore(),
            builder: (BuildContext context,
                AsyncSnapshot<List<PostModel>> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.only(top: 12),
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    itemCount: 300,
                    itemBuilder: (BuildContext context, int index) {

                      return PhotoShimmer();
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.count(
                        index % 5 == 0 ? 2 : 1, (index % 10 == 0 ? 2 : 1)),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                );
              }

              final list = snapshot.data;

              if (list.isEmpty)
                return Center(
                  child: Text("No photos"),
                );

              return Container(
                padding: const EdgeInsets.only(top: 12),
                child: StaggeredGridView.countBuilder(
                  crossAxisCount: 4,
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    final postModel = list[index];

                    return Container(
                        padding: const EdgeInsets.all(1),
                        child: imageWidget(context, postModel));
                  },
                  staggeredTileBuilder: (int index) => StaggeredTile.count(
                      index % 5 == 0 ? 2 : 1, (index % 10 == 0 ? 2 : 1)),
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget imageWidget(BuildContext context, PostModel postModel) {
    return Container(
      child: InkWell(
          onTap: () {
            goToPage(
                context,
                ViewPostPage(
                  postID: postModel.id,
                ));
          },
          child: squareImage(imageUrl: postModel.imageUrl)),
    );
  }


  double height = 200;

  Widget trendingCard(List<String> data) {
    return Card(
      color: Color(0xfffefefe),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Container(
        height: data.length > 2 ? 200: 150,
        padding: const EdgeInsets.only(top: 20, bottom: 8, right: 20, left: 20),
        width: MATCH_PARENT,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Trending Tags",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: FONT_NORMAL),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                  itemCount: data.length > 2 ? data.sublist(0, 3).length : data.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            goToPage(context, HashTagPage(data[index]));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              data[index],
                              style: TextStyle(
                                  color: Colors.blue, fontSize: FONT_NORMAL, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        horizontalGap(gap: 4),
                        Text(
                          "Latests (${trendingTags[data[index]].length} posts)",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 8,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  )),
            ),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                   goToPage(context, AllHashTagPageList(trendingTags), fullScreenDialog: true);
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "View More",
                      style: TextStyle(color: Colors.black, fontSize: FONT_SMALL),
                    ),
                    Icon(Icons.keyboard_arrow_down)
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class AllHashTagPageList extends StatelessWidget {

  final Map<String, List<PostModel>> trendingTags;

  AllHashTagPageList(this.trendingTags);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: appBarRounded,
        centerTitle: true,
        title: Text("Trending Tags", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        padding: const EdgeInsets.all(45),
        child: ListView.builder(
          itemCount:  trendingTags.keys.toList().length,
          itemBuilder: (BuildContext context, int index) {

          final tags = trendingTags.keys.toList()[index];

          return ListTile(
            onTap: () {
              goToPage(context, HashTagPage(tags));
            },
            title: Text(tags, style: TextStyle(color: Colors.blue, fontSize: FONT_NORMAL, fontWeight: FontWeight.bold),), subtitle:
          Text("Latests ${trendingTags[tags].length} posts", style: TextStyle(color: Colors.black54, fontSize: FONT_SMALL),),);
        },),
      ),
    );
  }
}


enum SEARCH_TYPE {
  ALL,
  TOPICS,
  PROFILES
}

class SearchUser extends SearchDelegate {
  final User _currentUser;
  static SEARCH_TYPE search_type = SEARCH_TYPE.PROFILES;
  final SearchKeywordDao searchKeywordDao = SearchKeywordDao();

  SearchUser(this._currentUser) {
    searchKeywordDao.getAll().then((value) {
      print(value.length);
    });
  }

  Future<List<User>> searchUser(query) async {
    var list = await ApiProvider.exploreApi.searchUser(query: query);
    return list.success;
  }

  Future<List<User>> searchTopic(query) async {
    var list = await ApiProvider.exploreApi.searchUser(query: query);
    return list.success;
  }

  Future<List<User>> searchRecent() async {
    List<SearchKeyword> keywords = await searchKeywordDao.getAllByType(SEARCH_TYPE.PROFILES.toString());
    List<String> ids = [];
    keywords.forEach((element) {
      ids.add(element.keyword);
    });

    final snap = await Firestore.instance.collection(Collection.USER).where("id", whereIn: ids.length > 10 ? ids.sublist(0,10) : ids).getDocuments();

    List<User> users = [];
    snap.documents.forEach((element) {
      users.add(User.fromMap(element.data));
    });

    return users.reversed.toList();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("Found");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return FutureBuilder(
            future: searchRecent(),
            builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data == null) {
                return Center(child: Text("Search User"));
              }

              return ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(bottom: 1),
                    child: ListTile(
                      onTap: () {
                        Utils.openProfilePage(context, snapshot.data[index]);
                      },
                      trailing: IconButton(icon: Icon(Icons.close), onPressed: () async {
                        await searchKeywordDao.delete(where: "keyword = ?", whereArgs: [snapshot.data[index].id]);
                        setState((){});
                      },),
                      leading: userImage(imageUrl: snapshot.data[index].photoUrl),
                      title: Text(snapshot.data[index].name),
                      subtitle: snapshot.data[index].bio != null
                          ? Text(snapshot.data[index].bio)
                          : Container(),
                    ),
                  );
                },
                itemCount: snapshot.data.length,
              );
            },
          );
        },

      );
    }
    else if(search_type == SEARCH_TYPE.PROFILES) {
      return FutureBuilder(
        future: searchUser(query),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null) {
            return Center(child: Text("No Result Found"));
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 1),
                child: ListTile(
                  onTap: ()  {
                    searchKeywordDao.insert(SearchKeyword(keyword: snapshot.data[index].id, type: search_type.toString(), timestamp: Utils.timestamp()));
                    Utils.openProfilePage(context, snapshot.data[index]);
                  },
                  leading: userImage(imageUrl: snapshot.data[index].photoUrl),
                  title: Text(snapshot.data[index].name),
                  subtitle: snapshot.data[index].bio != null
                      ? Text(snapshot.data[index].bio)
                      : Container(),
                ),
              );
            },
            itemCount: snapshot.data.length,
          );
        },
      );
    }
    else if(search_type == SEARCH_TYPE.TOPICS) {
      return FutureBuilder(
        future: searchTopic(query),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null) {
            return Center(child: Text("No Result Found"));
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 1),
                child: ListTile(
                  onTap: () {
                    Utils.openProfilePage(context, snapshot.data[index]);
                  },
                  leading: userImage(imageUrl: snapshot.data[index].photoUrl),
                  title: Text(snapshot.data[index].name),
                  subtitle: snapshot.data[index].bio != null
                      ? Text(snapshot.data[index].bio)
                      : Container(),
                ),
              );
            },
            itemCount: snapshot.data.length,
          );
        },
      );
    }
    else  {
      return FutureBuilder(
        future: searchUser(query),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null) {
            return Center(child: Text("No Result Found"));
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 1),
                child: ListTile(
                  onTap: () {
                    Utils.openProfilePage(context, snapshot.data[index]);
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (BuildContext context) => ProfilePage(
//                                  snapshot.data[index],
//                                  currentUser: _currentUser,
//                                  otherProfile: _currentUser.id !=
//                                      snapshot.data[index].id,
//                                )));
                  },
                  leading: userImage(imageUrl: snapshot.data[index].photoUrl),
                  title: Text(snapshot.data[index].name),
                  subtitle: snapshot.data[index].bio != null
                      ? Text(snapshot.data[index].bio)
                      : Container(),
                ),
              );
            },
            itemCount: snapshot.data.length,
          );
        },
      );
    }
  }
}

class SearchHomePage extends StatefulWidget {
  @override
  _SearchHomePageState createState() => _SearchHomePageState();
}

class _SearchHomePageState extends State<SearchHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  final darkGreyColor = Color(0xff68708A);

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      int index = _tabController.index;
      if(index == 0) {
        SearchUser.search_type = SEARCH_TYPE.ALL;
      }
      else if(index == 1) {
        SearchUser.search_type = SEARCH_TYPE.TOPICS;
      }
      else {
        SearchUser.search_type = SEARCH_TYPE.PROFILES;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(color: Color(0xffdadada), width: 0.5))),
            child: TabBar(
                labelColor: darkGreyColor,
                indicatorColor: darkGreyColor,
                controller: _tabController,

                tabs: [
                  Tab(
                    child: Text(
                      "All",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Topics",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Profiles",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
          ),
          preferredSize: Size.fromHeight(50),
        ),
        body: TabBarView(controller: _tabController, children: [
          allPage(),
          Tab(
            text: "Topics",
          ),
          Tab(
            text: "Profiles",
          ),
        ]));
  }

  Widget allPage() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header("TOP RESULTS"),
            verticalGap(gap: 8),
            hashTagTab("Design"),
            verticalGap(gap: 20),
            header("Topics"),
            verticalGap(gap: 8),
            hashTagTab("Creativity"),
            verticalGap(gap: 8),
            hashTagTab("Product Managment"),
            verticalGap(gap: 8),
            hashTagTab("UX Design"),
            verticalGap(gap: 8),
            hashTagTab("Education"),
            verticalGap(gap: 20),
            header("See More Topics"),
            verticalGap(gap: 20),
            header("Stories"),
            verticalGap(gap: 8),
            Divider(),
            ListTile(
              leading: userImage(imageUrl: null),
              title: Text(
                "Stories matching \" design thinking \" ",
                style: TextStyle(
                    fontSize: FONT_NORMAL,
                    color: darkGreyColor,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Browse stories, images and videos"),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Widget header(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: FONT_NORMAL, color: darkGreyColor),
    );
  }

  Widget hashTagTab(String title) {
    return Container(
      decoration: BoxDecoration(
          color: darkGreyColor,
          borderRadius: BorderRadius.all(Radius.circular(4))),
      padding: const EdgeInsets.all(12.0),
      child: Text(
        "#$title",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FONT_NORMAL,
            color: Colors.white),
      ),
    );
  }
}
