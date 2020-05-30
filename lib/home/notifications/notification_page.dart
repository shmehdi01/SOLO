import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/home/notifications/NotificationActionNotifier.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';

import '../../utils.dart';

class NotificationPage extends StatelessWidget {
  final User user;

  NotificationPage(this.user);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: Scaffold(appBar: appBar(context), body: NotificationBody(user)),
      create: (BuildContext context) =>
          NotificationActionNotifier(user, (apiError) {
        showSnack(context, apiError.errorMsg);
      }),
    );
  }

  Widget appBar(context) {
    return PreferredSize(
      child: AppBar(
        leading: MaterialButton(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        shape: appBarRounded,
        backgroundColor: Color(0xffefefef),
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      preferredSize: Size.fromHeight(60),
    );
  }
}

class NotificationBody extends StatelessWidget {
  final User _user;

  NotificationBody(this._user);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationActionNotifier>(
      builder: (BuildContext context, NotificationActionNotifier value,
          Widget child) {

        if(value.loading) {
          return Center(
            child: CircularProgressIndicator()
          );
        }

        if (value.notifications.isEmpty) {
          return Center(
            child: Text("No Notifications"),
          );
        }

        return Container(
          child: ListView.builder(
              itemCount: value.notifications.length,
              itemBuilder: (context, index) {
                return Container(
                  color: value.notifications[index].isRead
                      ? Colors.white
                      : Color(0xffefefef),
                  child: ListTile(
                    onTap: () {
                      value.markAsRead(value.notifications[index]);
                    },
                    leading: FutureBuilder(
                      future: ApiProvider.homeApi
                          .fetchUserByID(value.notifications[index].fromId),
                      builder: (BuildContext context,
                          AsyncSnapshot<ApiResponse<User>> snapshot) {
                        return userImage(
                            imageUrl: snapshot.data.success.photoUrl,
                            radius: 18);
                      },
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        value.notifications[index].message,
                        style: TextStyle(fontSize: FONT_NORMAL),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          value.notifications[index].addtionalMsg,
                          style: TextStyle(fontSize: FONT_NORMAL),
                        ),
                        verticalGap(gap: 4),
                        Text(
                         Utils.displayDate( value.notifications[index].timestamp),
                          style: TextStyle(fontSize: FONT_SMALL),
                        ),
                      ],
                    ),
                    trailing: value.notifications[index].imageUrl != null && value.notifications[index].imageUrl.isNotEmpty
                        ? squareImage(
                            imageUrl: value.notifications[index].imageUrl,
                            size: 40)
                        : horizontalGap(gap: 8),
                  ),
                );
              }),
        );
      },
    );
  }
}
