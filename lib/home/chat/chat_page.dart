import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/database/dao/UsereDao.dart';
import 'package:solo/home/chat/chat_screen.dart';
import 'package:solo/models/chat_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/utils.dart';

class ChatPage extends StatefulWidget {
  final User currentUser;

  ChatPage(this.currentUser);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: ChatListBody(widget.currentUser),
        ),
      ),
    );
  }
}

class ChatListBody extends StatelessWidget {
  final User currentUser;

  ChatListBody(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: ApiProvider.chatAPi.fetchAllChat(currentUser.id),
        builder: (BuildContext context,
            AsyncSnapshot<List<ChatListModel>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data.isEmpty) {
            return Center(
              child: Text("No Chats"),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                bool isRead = snapshot.data[index].isRead;

                ChatListModel chatListModel = snapshot.data[index];
                if (isRead == null) isRead = false;

                bool isSentByMe = chatListModel.senderID == chatListModel.myID;

                return Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        fetchReceiverAndGoToChat(
                            context, snapshot.data[index]);
                      },
                      leading:
                          userImage(imageUrl: snapshot.data[index].userPhoto),
                      title: Text(
                        snapshot.data[index].userName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:  Text(
                        chatListModel.messageType == MessageType.TEXT ? snapshot.data[index].message
                        : isSentByMe ? "You sent an Image" : "Image",
                        style: TextStyle(
                            color: !isSentByMe && !isRead
                                ? Colors.black87
                                : Colors.grey,
                            fontWeight: !isSentByMe && !isRead
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            chatTimeFormat(snapshot.data[index].timestamp),
                            style:
                                TextStyle(fontSize: FONT_SMALL, color: Colors.grey),
                          ),
                          isSentByMe ? Text(
                            chatListModel.messageStatus,
                            style:
                            TextStyle(fontSize: FONT_SMALL, color: Colors.grey),
                          ) : verticalGap(gap: 2),
                        ],
                      ),
                    ),
                    Divider()
                  ],
                );
              });
        },
      ),
    );
  }

  void fetchReceiverAndGoToChat(BuildContext context, ChatListModel chatListModel) async {
    log(1);
    var resp = await ApiProvider.homeApi.fetchUserByID(chatListModel.id);
    if (!resp.hasError) {
      Map<String, dynamic> map = Map();
      map['isRead'] = true;
      ApiProvider.chatAPi.updateChatList(map, chatListModel.chatID, currentUser.id);
      goToPage(context, ChatScreenPage(currentUser, resp.success));
    }
//  final user = await UserDao().findEntityByID(chatListModel.id);
//  print("userrrrr $user");
//
//  if(user != null) {
//     Map<String, dynamic> map = Map();
//      map['isRead'] = true;
//      ApiProvider.chatAPi.updateChatList(map, chatListModel.chatID, currentUser.id);
//      goToPage(context, ChatScreenPage(currentUser,user));
//  }

  }
}

class ChatListModel {
  String id;
  String myID;
  String userName;
  String userPhoto;
  String message;
  String messageType;
  String messageStatus;
  String timestamp;
  String chatID;
  bool isRead;
  String senderID;
  int isSync;

  ChatListModel(
      {this.id,
      this.myID,
      this.userName,
      this.userPhoto,
      this.message,
      this.messageType,
      this.messageStatus,
      this.timestamp,
      this.chatID,
      this.isRead,
      this.senderID,
      this.isSync});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();

    map['id'] = id;
    map['myID'] = myID;
    map['userName'] = userName;
    map['userPhoto'] = userPhoto;
    map['message'] = message;
    map['messageType'] = messageType;
    map['messageStatus'] = messageStatus;
    map['timestamp'] = timestamp;
    map['chatID'] = chatID;
    map['isRead'] = isRead;
    map['senderID'] = senderID;
    map['isSync'] = isSync;

    return map;
  }

  factory ChatListModel.fromMap(Map<String, dynamic> map) {
    return ChatListModel(
      id: map['id'],
      myID: map['myID'],
      userName: map['userName'],
      userPhoto: map['userPhoto'],
      message: map['message'],
      messageType: map['messageType'],
      messageStatus: map['messageStatus'],
      timestamp: map['timestamp'],
      chatID: map['chatID'],
      isRead: map['isRead'],
      senderID: map['senderID'],
      isSync: map['isSync'],
    );
  }

  factory ChatListModel.forMe(ChatModel chatModel, String chatID) {
    return ChatListModel(
        id: chatModel.receiverID,
        myID: chatModel.senderID,
        userName: chatModel.receiverName,
        userPhoto: chatModel.receiverPhoto,
        message: chatModel.message,
        messageStatus: chatModel.messageStatus,
        messageType: chatModel.messageType,
        timestamp: chatModel.timestamp,
        isRead: chatModel.isRead,
        chatID: chatID,
        isSync: chatModel.isSync,
        senderID: chatModel.senderID);
  }

  factory ChatListModel.forOther(ChatModel chatModel, String chatID) {
    return ChatListModel(
        id: chatModel.senderID,
        myID: chatModel.receiverID,
        userName: chatModel.senderName,
        userPhoto: chatModel.senderPhoto,
        message: chatModel.message,
        messageStatus: chatModel.messageStatus,
        messageType: chatModel.messageType,
        timestamp: chatModel.timestamp,
        isRead: chatModel.isRead,
        chatID: chatID,
        isSync: chatModel.isSync,
        senderID: chatModel.senderID);
  }
}
