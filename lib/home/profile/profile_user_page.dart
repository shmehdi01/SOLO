import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/home/chat/chat_screen.dart';
import 'package:solo/home/profile/profile_page.dart';
import 'package:solo/models/user.dart';

import '../../session_manager.dart';
import '../../utils.dart';

class UserPage extends StatelessWidget {

  final List<User> myFollowings;
  final List<bool> isFollowing = [];
  final ConnectionDao connectionDao = ConnectionDao();

  final bool otherProfile;
  final User currentUser;

  final User loggedInUser = SessionManager.currentUser;

  UserPage(this.myFollowings, this.otherProfile, this.currentUser);

  @override
  Widget build(BuildContext context) {

    return Container(
      child: ListView.builder(
          itemCount: myFollowings == null ? 0 : myFollowings.length,
          itemBuilder: (context, index) {
            User user = myFollowings[index];

            return Container(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                onTap: () {
                  Utils.openProfilePage(context, user);
//                  Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (BuildContext context) => ProfilePage(
//                            user,
//                            otherProfile: user.id != loggedInUser.id,
//                            currentUser: loggedInUser,
//                          )));
                },
                leading: userImage(
                    imageUrl: myFollowings[index].photoUrl, radius: 20),
                title: Text(
                  myFollowings[index].name,
                  style: TextStyle(fontSize: FONT_NORMAL),
                ),
                trailing: otherProfile
                    ? otherProfile &&
                    user.id ==
                        loggedInUser
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
                                    loggedInUser, user)));
                  },
                  child: Text("Message"),
                ),
              ),
            );
          }),
    );
  }
}