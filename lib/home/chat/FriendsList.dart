import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/home/chat/ChatActionNotifier.dart';
import 'package:solo/models/user.dart';

import '../../utils.dart';
import 'chat_screen.dart';

class FriendsListPage extends StatelessWidget {

  final User currentUser;

  FriendsListPage(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: Scaffold(
        appBar: appBar(context),
        body: _FriendsPageBody(currentUser),
      ), create: (BuildContext context) => ChatActionNotifier(currentUser),
    );
  }

  Widget appBar(context) {
    return PreferredSize(
      child: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shape: appBarRounded,
        backgroundColor: Color(0xffefefef),
        centerTitle: true,
        title: Text(
          "Friends",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      preferredSize: Size.fromHeight(60),
    );
  }
}

class _FriendsPageBody extends StatelessWidget {

  final User currentUser;

  _FriendsPageBody(this.currentUser);

  @override
  Widget build(BuildContext context) {

    var value = Provider.of<ChatActionNotifier>(context);

    if(value.loader) {
      return Center(child: CircularProgressIndicator());
    }

    if(value.myFollowings == null) {
      return Center(child:Text("No Friends"));
    }

    return Container(
      child: ListView.builder(
          itemCount: value.myFollowings.length,
            itemBuilder: (context,index) {
              return Container(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ChatScreenPage(
                                    currentUser, value.myFollowings[index])));
                  },
                  leading: userImage(
                      imageUrl: value.myFollowings[index].photoUrl, radius: 20),
                  title: Text(
                    value.myFollowings[index].name,
                    style: TextStyle(fontSize: FONT_NORMAL),
                  ),
                ),
              );
        })
    );
  }
}

