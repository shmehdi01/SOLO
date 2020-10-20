import 'package:solo/database/dao/BaseDao.dart';
import 'package:solo/database/entity/search_keywords.dart';
import 'package:solo/models/Collection.dart';

class SearchKeywordDao extends BaseDao<SearchKeyword> {

  @override
  Future<SearchKeyword> findEntityByID(String id) {

  }

  @override
  Future<List<SearchKeyword>> getAll() async {
    final map = await getAllMap;
    final list = <SearchKeyword>[];
    map.forEach((element) {
      list.add(SearchKeyword.fromJson(element));
    });

    return list;
  }

  Future<List<SearchKeyword>> getAllByType(String type) async {
    var db = await provideDB;
    List<Map<String, dynamic>> map = await db.query(provideTable, where: "type = ?", whereArgs: [type], orderBy: "timestamp DESC");
    final list = <SearchKeyword>[];
    map.forEach((element) {
      list.add(SearchKeyword.fromJson(element));
    });

    return list;
  }

  @override

  String get provideTable => Collection.SEARCH_KEYWORDS;

}