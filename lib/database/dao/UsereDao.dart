import 'package:solo/database/dao/BaseDao.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/user.dart';

class UserDao extends BaseDao<User> {

  @override
  Future<User> findEntityByID(String id,) async {
    var map =  await findMapById(id);
    if(map == null) {
      return null;
    }
    return User.fromMap(map);
  }

  @override
  Future<List<User>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  // TODO: implement provideTable
  String get provideTable => Collection.USER;

  
}