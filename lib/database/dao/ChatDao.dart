import 'package:solo/database/dao/BaseDao.dart';
import 'package:solo/database/tables.dart';
import 'package:solo/models/chat_model.dart';
import 'package:sqflite/sqflite.dart';

class ChatDao extends BaseDao<ChatModel> {

  String _chatId;
  Database _db;

  ChatDao(this._chatId)  {
    _initDb();
  }

  _initDb() async {
    _db = await provideDB;
    _db.execute(ChatTableHelper.createChatTableQuery(provideTable));
  }

  @override
  Future<ChatModel> findEntityByID(String id) {
    // TODO: implement findEntityByID
    throw UnimplementedError();
  }

  @override
  Future<List<ChatModel>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  Future<bool> isChatExist() async {
    final db = await provideDB;
    getAllMap;
    return false;
  }

  Stream<List<ChatModel>> fetchChats() {

    print("fetchChats");

    final stream = Stream.fromFuture(getAllMap).map<List<ChatModel>>((convert) {
      print("Convert $convert");
      var list = <ChatModel>[];
      convert.forEach((doc) {
        list.add(ChatModel.fromMap(doc));
      });
      print("List of local chat ${list.length}");
      return list;
    });

    return stream;
  }

  Future<void> createChatTable() async {
    print("DB DEkho2 $_db");

  }

  @override
  // TODO: implement provideTable
  String get provideTable => _chatId;

}