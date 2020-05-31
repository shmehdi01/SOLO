import 'package:flutter/material.dart';
import 'package:solo/home/item_post_feed.dart';
import 'package:solo/models/post_model.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/utils.dart';

class ViewPostPage extends StatelessWidget {

  final String postID;

  ViewPostPage({@required this.postID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: ApiProvider.homeApi.fetchSinglePost(postID),
            builder: (BuildContext context,
                AsyncSnapshot<ApiResponse<PostModel>> snapshot) {
              if (snapshot.hasData == false) {
                return Center(child: CircularProgressIndicator(),);
              }

              if(snapshot.data.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.warning, size: 60, color: Colors.black54,),
                    verticalGap(gap: 8),
                    Center(child: Text("Opps !! ${snapshot.data.error.errorMsg}", style: TextStyle(fontSize: FONT_EXTRA_LARGE),),),
                    FlatButton(onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Go Back", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),),)
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ItemFeedPost(snapshot.data.success),
                ],
              );
            },),
        ),
      ),
    );
  }
}
