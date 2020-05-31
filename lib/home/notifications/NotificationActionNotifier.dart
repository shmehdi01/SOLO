import 'package:flutter/cupertino.dart';
import 'package:solo/models/notification_detail.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';
import 'package:solo/network/api_service.dart';

class NotificationActionNotifier extends ChangeNotifier {

  User _user;
  Function(ApiError apiError) _onError;
  List<NotificationDetail> _notifications = <NotificationDetail>[];
  bool loading = false;

  List<NotificationDetail> get notifications => _notifications; 

  NotificationActionNotifier(this._user,  this._onError) {
    fetchAllNotifications();
  }
  
  void fetchAllNotifications() async {
//    var response = await ApiProvider.notificationApi.fetchNotification(_user);
//
//    if(response.hasError) {
//      _onError(response.error);
//    }
//    else {
//      _notifications = response.success;
//      notifyListeners();
//    }
  loading = true;
  notifyListeners;
  ApiProvider.notificationApi.fetchNotificationStream(_user).listen((onData) {
    _notifications = onData;

    print("Data changjg");
    loading = false;
    notifyListeners();
  });
  }

  void markAsRead(NotificationDetail notificationDetail) {
    notificationDetail.isRead = true;
    ApiProvider.notificationApi.updateNotification(notificationDetail);
    notifyListeners();
  }

}