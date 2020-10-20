import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:solo/database/dao/ChatDao.dart';
import 'package:solo/helper/dialog_helper.dart';
import 'package:solo/helper/image_picker_helper.dart';
import 'package:solo/home/chat/ChatActionNotifier.dart';
import 'package:solo/home/notifications/api/push_notification.dart';
import 'package:solo/models/chat_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/firebase/firebase_storage_manager.dart';

import '../../utils.dart';

class ChatScreenPage extends StatelessWidget {
  final User sender;
  final User receiver;

  ChatBody _chatBody;

  ChatScreenPage(this.sender, this.receiver) {
    _chatBody = ChatBody(sender, receiver);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          ChatActionNotifier(sender, receiver: receiver),
      child: Scaffold(appBar: appBar(context), body: _chatBody),
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
          "${receiver.name}",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.block,
              color: Colors.black,
            ),
            onPressed: () {
              _chatBody.onBlockClicked(context);
            },
          ),
        ],
      ),
      preferredSize: Size.fromHeight(60),
    );
  }
}

class ChatBody extends StatelessWidget {
  User sender;
  User receiver;
  String groupChatId;
  String localDbChatID;
  ChatDao chatDao;
  ChatActionNotifier value;

  ChatBody(this.sender, this.receiver) {
    createID();
    createChatTable();
  }

  void onBlockClicked(context) {
    if (value.block != null && value.isBlockedByMe) {
      DialogHelper.customAlertDialog(context,
          title: "Unblock ${receiver.name}",
          content: "Are you sure to unblock",
          negativeButton: "Cancel",
          positiveButton: "Unblock", onConfrim: () async {
        await ApiProvider.chatAPi.unblock(receiver.id);
        value.clearBlock();
      });
    } else {
      DialogHelper.customAlertDialog(context,
          title: "Block ${receiver.name}",
          content: "Are you sure to block",
          negativeButton: "Cancel",
          positiveButton: "Block", onConfrim: () async {
        await ApiProvider.chatAPi.blockUser(receiver.id);
        Navigator.pop(context);
      });
    }
  }

  TextEditingController _editingController = TextEditingController();
  ScrollController listScrollController = ScrollController();

  void createID() {
    if (sender.id.hashCode <= receiver.id.hashCode) {
      groupChatId = '${sender.id}-${receiver.id}';
      localDbChatID = '${sender.id}_${receiver.id}';
    } else {
      groupChatId = '${receiver.id}-${sender.id}';
      localDbChatID = '${receiver.id}_${sender.id}';
    }
  }

  void createChatTable() {
    chatDao = ChatDao(localDbChatID);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatActionNotifier>(
      builder: (BuildContext context, ChatActionNotifier value, Widget child) {
        this.value = value;

        if (value.block != null) {
          return Container(
            child: Center(
              child: Text(value.isBlockedByMe
                  ? "${receiver.name} is Blocked by you"
                  : "${receiver.name} is blocked you"),
            ),
          );
        }

        return Container(
          child: Column(
            children: <Widget>[
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: StreamBuilder(
                        stream: ApiProvider.chatAPi.fetchChat(groupChatId),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<ChatModel>> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.data.isEmpty) {
                            return Center(
                              child: Text("Start Chat with ${receiver.name}"),
                            );
                          }

                          Timer(
                              Duration(milliseconds: 1000),
                              () => listScrollController.animateTo(
                                  listScrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut));

                          return ListView.builder(
                              controller: listScrollController,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return ChatItem(
                                    snapshot.data[index], sender, receiver);
                              });
                        },
                      ))),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        ImagePickerHelper.showImagePickerDialog(context,
                            (image) async {
                          if (image != null) {
                            progressDialog(context, "Sending Image...");
                            await sendImage(image);
                            Navigator.pop(context);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _editingController,
                        decoration: InputDecoration(
                            hintText: "Send Messsage",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: PRIMARY_COLOR,
                      ),
                      onPressed: () {
                        if (_editingController.text.isNotEmpty) {
                          sendMessage(ChatModel(
                              sender.id,
                              receiver.id,
                              sender.name,
                              receiver.name,
                              sender.photoUrl,
                              receiver.photoUrl,
                              MessageStatus.SENT,
                              MessageType.TEXT,
                              _editingController.text,
                              DateTime.now().millisecondsSinceEpoch.toString(),
                              false,
                              0));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void sendMessage(ChatModel chatModel) async {
    await ApiProvider.chatAPi.sendMessage(sender.id, chatModel, groupChatId);

    Timer(
        Duration(milliseconds: 1000),
        () => listScrollController.animateTo(
            listScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut));

    PushNotificationBuilder(
            image: chatModel.messageType == MessageType.IMAGE
                ? chatModel.message
                : null,
            message: _editingController.text,
            title: sender.name,
            token: receiver.pushToken)
        .createToken()
        .sendNotification();

    _editingController.clear();

    await chatDao.insert(chatModel);
  }

  Future<void> sendImage(File image) async {
    String imageUrl = await FirebaseStorageManager.upload(
        "ChatImages/$groupChatId-${DateTime.now().millisecondsSinceEpoch.toString()}",
        image);

    var chatModel = await ChatModel(
        sender.id,
        receiver.id,
        sender.name,
        receiver.name,
        sender.photoUrl,
        receiver.photoUrl,
        MessageStatus.SENT,
        MessageType.IMAGE,
        imageUrl,
        DateTime.now().millisecondsSinceEpoch.toString(),
        false,
        0);

    sendMessage(chatModel);
  }

  void clearChat() {
    ApiProvider.chatAPi.deleteChat(sender.id, groupChatId);
  }

  void showImageDialog() {}

  void progressDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        child: Dialog(
          child: Container(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                ),
                verticalGap(gap: 12),
                Text(message)
              ],
            ),
          ),
        ));
  }
}

class ChatItem extends StatelessWidget {
  ChatModel chatModel;
  User sender;
  User receiver;
  bool isMe;

  ChatItem(this.chatModel, this.sender, this.receiver) {
    isMe = chatModel.senderID == sender.id;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//      color: Colors.red,
      padding: const EdgeInsets.only(left: 8, right: 8),
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: isMe ? 0.0 : 8.0, right: isMe ? 8 : 0),
            child: Text(
              chatTimeFormat(chatModel.timestamp),
              style: TextStyle(color: Colors.black87, fontSize: 8),
            ),
          ),
          chatModel.messageType == MessageType.TEXT
              ? Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Text(
                        chatModel.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      )),
                )
              : Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: InkWell(
                    onTap: () {
                      showImageViewerDialog(context, chatModel.message);
                    },
                    child: Container(
                        height: 200,
                        width: 270,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: chatModel.messageType == MessageType.TEXT
                            ? Text(
                                chatModel.message,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              )
                            : CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: chatModel.message,
                              )),
                  ),
                ),
          isMe
              ? Padding(
                  padding: EdgeInsets.only(
                      left: isMe ? 0.0 : 8.0, right: isMe ? 8 : 0),
                  child: Text(
                    chatModel.messageStatus,
                    style: TextStyle(color: Colors.black87, fontSize: 10),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void showImageViewerDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      child: Scaffold(
        body: Container(
            child: Center(
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(url),
          ),
        )),
      ),
    );
  }
}
