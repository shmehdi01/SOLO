import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:solo/home/item_post_feed.dart';
import 'package:solo/home/view_post_page.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/utils.dart';

class HashTagPage extends StatefulWidget {
  final String hashTag;

  HashTagPage(this.hashTag);

  @override
  _HashTagPageState createState() => _HashTagPageState();
}

class _HashTagPageState extends State<HashTagPage>
    with SingleTickerProviderStateMixin {
  var postCount = 0;
  TabController _tabController;
  List<PostModel> list = <PostModel>[];
  List<PostModel> posts = <PostModel>[];

  @override
  void initState() {
    TabController(
      vsync: this,
      length: 2,
    );
    loadTagsPost();
    super.initState();
  }

  Future<ApiResponse<List<PostModel>>> loadTagsPost() async {
    final resp = await ApiProvider.hashTagApi.fetchHashTagPost(widget.hashTag.replaceAll(RegExp(r"[\u1000-\uFFFF]+"),""));
    setState(() {
      postCount = resp.success.length;
      posts = resp.success;
      posts.forEach((element) {
        if (element.imageUrl.isNotEmpty) list.add(element);
      });
    });
    return resp;
  }

  @override
  Widget build(BuildContext context) {

    debugPrint("HashTag: ${widget.hashTag.replaceAll(RegExp(r"[\u1000-\uFFFF]+"), "")}");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(178),
            child: Container(
              padding: EdgeInsets.all(12),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            verticalGap(gap: 8),
                            Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      AssetImage("$IMAGE_ASSETS/logo_bg.png"),
                                  child: Text(
                                    "#",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 35),
                                  ),
                                ),
                                horizontalGap(gap: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(widget.hashTag,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    verticalGap(gap: 4),
                                    Text(
                                      "See post related to ${widget.hashTag}",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: FONT_SMALL,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                           if(false) Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                OutlineButton(
                                  color: PRIMARY_COLOR,
                                  onPressed: () {},
                                  child: Text(
                                    "Follow",
                                  ),
                                ),
                                horizontalGap(gap: 12),
                                RichText(
                                  text: TextSpan(
                                      text: "$postCount",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: FONT_MEDIUM),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: " posts",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: FONT_NORMAL,
                                              fontWeight: FontWeight.normal),
                                        )
                                      ]),
                                ),
                              ],
                            ),
                            verticalGap(gap: 8),
                            Divider(),
                            TabBar(
                              controller: _tabController,
                              tabs: <Widget>[
                                Tab(
                                  text: "${list.length} Photos",
                                ),
                                Tab(
                                  text: "${posts.length} Posts",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              StaggeredGridView.countBuilder(
                crossAxisCount: 4,
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
              final postModel = list[index];

              if(list.isEmpty)
                return Center(child: Text("No photos related to ${widget.hashTag}"),);

              return imageWidget(context, postModel);
                },
                staggeredTileBuilder: (int index) => StaggeredTile.count(
                index % 5 == 0 ? 2 : 1, index % 5 == 0 ? 2 : 1),
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return ItemFeedPost(posts[index]);
                  })
            ],
          )),
    );
  }

  Widget captionWidget(String caption) {
    return Container(
      child: Text(caption),
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
}

//Expanded(
//child: FutureBuilder(
//future: loadTagsPost(),
//builder: (BuildContext context,
//    AsyncSnapshot<ApiResponse<List<PostModel>>> snapshot) {
//if (!snapshot.hasData) {
//return Center(
//child: CircularProgressIndicator(),
//);
//}
//
//if (snapshot.data.success.isEmpty) {
//return Center(
//child: Text("No post related to ${widget.hashTag}"),
//);
//}
//
//final list = snapshot.data.success;
//
//return StaggeredGridView.countBuilder(
//crossAxisCount: 4,
//itemCount: list.length,
//itemBuilder: (BuildContext context, int index) {
//final postModel = list[index];
//
//return imageWidget(context, postModel);
//},
//staggeredTileBuilder: (int index) => StaggeredTile.count(index % 5 == 0 ? 2 : 1, index % 5 == 0 ? 2 : 1),
//mainAxisSpacing: 4.0,
//crossAxisSpacing: 4.0,
//);
//},
//),
//)

//Container(
//padding: const EdgeInsets.all(12),
//child: Center(
//child: Column(
//crossAxisAlignment: CrossAxisAlignment.start,
//children: <Widget>[
//verticalGap(gap: 8),
//Row(
//children: <Widget>[
//CircleAvatar(
//radius: 25,
//backgroundImage:
//AssetImage("$IMAGE_ASSETS/logo_bg.png"),
//child: Text(
//"#",
//style: TextStyle(color: Colors.white, fontSize: 35),
//),
//),
//horizontalGap(gap: 12),
//Column(
//crossAxisAlignment: CrossAxisAlignment.start,
//children: <Widget>[
//Text(widget.hashTag,
//style: TextStyle(
//fontWeight: FontWeight.bold, fontSize: 18)),
//horizontalGap(gap: 12),
//],
//),
//],
//),
//Row(
//mainAxisAlignment: MainAxisAlignment.center,
//children: <Widget>[
//OutlineButton(
//color: PRIMARY_COLOR,
//onPressed: () {},
//child: Text(
//"Follow",
//),
//),
//horizontalGap(gap: 12),
//RichText(
//text: TextSpan(
//text: "$postCount",
//style: TextStyle(
//color: Colors.black,
//fontWeight: FontWeight.bold,
//fontSize: FONT_MEDIUM),
//children: <TextSpan>[
//TextSpan(
//text: " posts",
//style: TextStyle(
//color: Colors.black54,
//fontSize: FONT_NORMAL,
//fontWeight: FontWeight.normal),
//)
//]),
//),
//],
//),
//verticalGap(gap: 12),
//Center(
//child: Text(
//"See post related to ${widget.hashTag}",
//style: TextStyle(
//color: Colors.black54,
//fontSize: FONT_SMALL,
//fontWeight: FontWeight.normal),
//),
//),
//verticalGap(gap: 12),
//Divider(),
//TabBar(
//controller: _tabController,
//tabs: <Widget>[
//Tab(
//text: "1",
//),
//Tab(
//text: "2",
//),
//],
//),
//],
//),
//),
//),
