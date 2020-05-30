import 'package:solo/database/dao/ConnectionDao.dart';
import 'package:solo/database/dao/UsereDao.dart';
import 'package:solo/models/connections.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/utils.dart';

import '../session_manager.dart';

class SyncService {

  final _userDao = UserDao();
  final _connectionDao = ConnectionDao();

  void syncUsersAndConnections() {
    developerLog("syncUsersAndConnections", "CALLLED");
    _userDao.deleteAll();
    _connectionDao.deleteAll();

    _startSyncing();

  }

  _startSyncing() async {

    developerLog("SYNC_START", "SYNCING....");

    final currentUser = SessionManager.currentUser;

    var following = await ApiProvider.profileApi.getFollowing(currentUser);
    var follower = await ApiProvider.profileApi.getFollower(currentUser);

    final listOfConnection = <Connection>[];
    listOfConnection.addAll(following.success);
    listOfConnection.addAll(follower.success);

    var userResp1 = await SessionManager.fetchUsrByConnection(currentUser, following.success, following: true);
    var userResp2 = await SessionManager.fetchUsrByConnection(currentUser, follower.success, following: false);

    final listOfUser = <User>[];
    listOfUser.add(currentUser);
    listOfUser.addAll(userResp1.success);

    userResp2.success.forEach((u) {
      if(!listOfUser.contains(u))
        listOfUser.add(u);
    });


    developerLog("Total Connection", listOfConnection.length);
    int count = 0;
    listOfConnection.forEach((connection) async{
      connection.isSync = 1;
      await _connectionDao.insert(connection);
      count++;
      developerLog("Connection Inserted", count);
    });

    developerLog("Total User", listOfUser.length);
    int countU = 0;
    int countUExist = 0;
    listOfUser.forEach((user) async{
      user.isSync = 1;
      final u = await _userDao.findEntityByID(user.id);
      print("User dekho $u");
      if(u == null) {
          await _userDao.insert(user);
          countU++;
          developerLog("User Inserted", countU);
        }
      else {
        print("ALREADY EXIST: " + "$u");
        countUExist++;
      }
    });
    developerLog("User Exist", countUExist);

    developerLog("SYNC_END", "COMPELETED.");
  }
}