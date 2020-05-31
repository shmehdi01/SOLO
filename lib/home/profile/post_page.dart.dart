import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/home/item_post_feed.dart';
import 'package:solo/home/profile/ProfileActionNotifier.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';

class PostPage extends StatelessWidget {

  final User user;

  PostPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileActionNotifier>(
      builder: (BuildContext context, ProfileActionNotifier value, Widget child) {
        return Container(
            child: StreamBuilder(
              stream: ApiProvider.homeApi.fetchPostsStream(onlyForID: user.id),
              builder: (BuildContext context, AsyncSnapshot<List<PostModel>> snapshot) {

                if(!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(),);
                }

                value.postCount = snapshot.data.length;

                if (snapshot.data.isEmpty) {
                  return Center(
                    child: Text("No Post Yet"),
                  );
                }

                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) =>
                        ItemFeedPost(snapshot.data[index]));
              },
            ));
      },

    );
  }
}
