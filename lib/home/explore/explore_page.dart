import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/home/profile/profile_page.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';

import '../../utils.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "Explore",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class SearchUser extends SearchDelegate {
  final User _currentUser;

  SearchUser(this._currentUser);

  Future<List<User>> searchUser(query) async {
    var list = await ApiProvider.exploreApi.searchUser(query: query);
    return list.success;
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
      return SearchHomePage();
    } else {
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ProfilePage(
                                  snapshot.data[index],
                                  currentUser: _currentUser,
                                  otherProfile: _currentUser.id != snapshot.data[index].id,
                                )));
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
