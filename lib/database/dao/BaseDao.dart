
import 'package:flutter/cupertino.dart';
import 'package:solo/database/entity/base.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils.dart';
import '../database_provider.dart';

abstract class BaseDao<E extends Entity> {
  String get provideTable;

  Future<Database> get provideDB {
    DatabaseProvider databaseProvider = DatabaseProvider.databaseProvider;
    return databaseProvider.database;
  }

  Future<List<E>> getAll();

  Future<E> findEntityByID(String id);

  Future<int> insert(E entity) async {
    var db = await provideDB;
    print("Insert: ${entity.toMap()}");
    return await db.insert(provideTable, entity.toMap());
  }

  Future<int> delete(
      {@required String where, @required List<dynamic> whereArgs}) async {
    var db = await provideDB;
    return await db.delete(provideTable, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteAll() async {
    var db = await provideDB;
    return await db.delete(provideTable);
  }

  Future<int> deleteByID(String id, {String columnName = "id"}) {
    developerLog("Delete By ID", "Deleted By Id = $id where columns = $columnName");
    return delete(where: "$columnName =  ?", whereArgs: [id]);
  }

  Future<int> update(E entity, {String where, List whereArgs}) async {
    var db = await provideDB;
    return await db.update(provideTable, entity.toMap(), where: where,whereArgs: whereArgs);
  }

  Future<int> updateByID(E entity, String id,  {String col = "id"}) async {
    var db = await provideDB;
    return await db.update(provideTable, entity.toMap(), where: "$col = ?", whereArgs: [id]);
  }


  Future<Map<String, dynamic>> findMapById(String id, {String columnName = "id"}) async {
    developerLog("FindMapByID", "Find By Id = $id where columns = $columnName");

    var db = await provideDB;
    List<Map<String, dynamic>> map =
        await db.query(provideTable, where: "$columnName = ?", whereArgs: [id]);

    developerLog("FindMapByID", "Map : $map");

    if(map.length == 0) {
      return null;
    }
    return map[0];
  }

  Future<List<Map<String, dynamic>>> get getAllMap async {
    var db = await provideDB;
    List<Map<String, dynamic>> map = await db.query(provideTable);
    developerLog("Get All Map", "Maps $map");
    return map;
  }
}
