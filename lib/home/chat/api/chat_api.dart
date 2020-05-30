import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:solo/home/chat/chat_page.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/chat_model.dart';
import 'package:solo/network/api_service.dart';

import '../../../session_manager.dart';

class FirebaseChatApi extends ChatApi {
  @override
  Stream<List<ChatModel>> fetchChat(String chatID) {
    print("Snapshot 1");
    var querySnapshot = Firestore.instance
        .collection(Collection.CHAT)
        .document(chatID)
        .collection(chatID)
        .orderBy('timestamp', descending: false)
        .snapshots();


    var x = querySnapshot.map<List<ChatModel>>((convert) {
      var list = <ChatModel>[];
      if(convert.documents.isEmpty) {
        return list;
      }

      convert.documents.forEach((doc) {
        print("Snapshot 2");
        list.add(ChatModel.fromMap(doc.data));
      });

      debugPrint("Current User ${SessionManager.currentUser.id}");

      var model = list.last;
      if (SessionManager.currentUser.id != model.senderID) {
        model.messageStatus = MessageStatus.SEEN;
        model.isRead = true;
        sendMessage("", model, chatID);
      }
      return list;
    });

    return x;
  }

  @override
  Future<void> sendMessage(
      String userID, ChatModel chatModel, String chatID) async {
    var documentReference = Firestore.instance
        .collection(Collection.CHAT)
        .document(chatID)
        .collection(chatID)
        .document(chatModel.timestamp);

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        chatModel.toMap(),
      );
    });

    setChatList(
        ChatListModel.forMe(chatModel, chatID), chatID, chatModel.senderID);

    setChatList(ChatListModel.forOther(chatModel, chatID), chatID,
        chatModel.receiverID);
  }

  @override
  Future<void> clearChat(String userID, String chatID) async {
    var documentReference = await Firestore.instance
        .collection(Collection.CHAT)
        .document(chatID)
        .collection(chatID)
        .getDocuments();

    documentReference.documents.forEach((doc) {
      clearChatByID(userID, chatID, doc.documentID);
    });
  }

  @override
  Future<void> clearChatByID(String userID, String chatID, String msgID) async {
    Firestore.instance
        .collection(Collection.CHAT)
        .document(chatID)
        .collection(chatID)
        .document(msgID)
        .delete();
  }

  @override
  Future<void> deleteChat(String userID, String chatID) async {
    //DELETE FROM CHAT LIST
    Firestore.instance
        .collection(Collection.CHAT_LIST)
        .document(chatID)
        .delete();

    //CLEAR CHAT ALSO
    clearChat(userID, chatID);
  }

  @override
  Stream<List<ChatListModel>> fetchAllChat(String userID) {
    print("my id $userID");
    var querySnapshot = Firestore.instance
        .collection(Collection.CHAT_LIST)
        .document(userID)
        .collection(userID)
        .snapshots();

    var x = querySnapshot.map<List<ChatListModel>>((convert) {
      var list = <ChatListModel>[];
      convert.documents.forEach((doc) {
        print(doc.documentID);

        var model = ChatListModel.fromMap(doc.data);
        list.add(model);

        //UPDATE STATUS
        if (userID != model.senderID) {
          if (model.messageStatus != MessageStatus.DELIVERED &&
              model.messageStatus != MessageStatus.SEEN) {

            Map<String, dynamic> map = Map();
            map['messageStatus'] = MessageStatus.DELIVERED;

            model.messageStatus = MessageStatus.DELIVERED;
            //update to chat list
            updateChatList(map, model.chatID, model.senderID);

            //Update last chat also

            Firestore.instance
                .collection(Collection.CHAT)
                .document(model.chatID)
                .collection(model.chatID)
                .document(model.timestamp)
                .updateData(map);
          }
        }
      });

      return list;
    });

    return x;
  }

  Future<void> updateChatList(
      Map<String, dynamic> map, chatID, String userID) async {
    Firestore.instance
        .collection(Collection.CHAT_LIST)
        .document(userID)
        .collection(userID)
        .document(chatID)
        .updateData(map);
  }

  @override
  Future<void> setChatList(ChatListModel chatListModel, chatID, String userID) async {
    Firestore.instance
        .collection(Collection.CHAT_LIST)
        .document(userID)
        .collection(userID)
        .document(chatID)
        .setData(chatListModel.toMap());
  }
}
