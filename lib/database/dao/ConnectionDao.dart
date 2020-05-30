import 'package:solo/database/dao/BaseDao.dart';
import 'package:solo/database/dao/UsereDao.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/connections.dart';
import 'package:solo/models/user.dart';
import 'package:solo/utils.dart';

class ConnectionDao extends BaseDao<Connection> {
  @override
  Future<Connection> findEntityByID(String id) {
    // TODO: implement findEntityByID
    throw UnimplementedError();
  }

  Future<Connection> findConnection(Connection connection) async {
    final db = await provideDB;
    final maps = await db.query(provideTable,
        where: "follower = ? and following = ?",
        whereArgs: [connection.follower, connection.following]);

    developerLog("findConnection", maps.length );

    if(maps != null && maps.length > 0) {
      return Connection.fromMap(maps[0]);
    }
    else return null;
  }

  @override
  Future<List<Connection>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  Future<List<User>> getFollowers(String myID, {int isSync = 1}) async {
    final db = await provideDB;
    final maps = await db.query(provideTable,
        where: "following = ? and isSync = ?", whereArgs: [myID, isSync]);
    final list = <User>[];

    print(maps);
    await Future.forEach(maps, (map) async {
      String followerID = map['follower'];
      var user = await UserDao().findEntityByID(followerID);
      list.add(user);
    });

    return list;
  }

  Future<List<User>> getFollowing(String myID, {int isSync = 1}) async {
    final db = await provideDB;
    final maps = await db.query(provideTable,
        where: "follower = ? and isSync = ?", whereArgs: [myID, isSync]);
    final list = <User>[];

    await Future.forEach(maps, (map) async {
      String followerID = map['following'];
      var user = await UserDao().findEntityByID(followerID);
      list.add(user);
    });

    return list;
  }

  Future<Connection> isFollowing(String follower, String following,
      {int isSync = 1}) async {
    final db = await provideDB;
    final map = await db.query(provideTable,
        where: "follower = ? and following = ? and isSync = ?",
        whereArgs: [follower, following, isSync]);

    print("hahahah $map}");
    if (map == null || map.isEmpty) return null;

    return Connection.fromMap(map[0]);
  }

  Future<void> deleteConnection(Connection connection) async {
    await delete(
        where: "follower = ? and following = ?",
        whereArgs: [connection.follower, connection.following]);
  }

  @override
  // TODO: implement provideTable
  String get provideTable => Collection.CONNECTION;
}
