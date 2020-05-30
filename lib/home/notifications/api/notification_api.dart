import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/notification_detail.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/network/firebase/firestore_manager.dart';

class FirebaseNotificationApi implements NotificationApi {
  @override
  Future<ApiResponse<bool>> createNotification(
      NotificationDetail notificationDetail) async {
    print(("Notifi"));
    print(notificationDetail.toMap());
    var insertResp = await FirestoreManager.insert(
        collection: Collection.NOTIFICATION, data: notificationDetail.toMap());

    return insertResp;
  }

  @override
  Future<ApiResponse<List<NotificationDetail>>> fetchNotification(
      User user) async {
    var apiResponse = ApiResponse<List<NotificationDetail>>();

    var ref = await FirestoreManager.getCollectionRef(Collection.NOTIFICATION);
    var snapshot = await ref
        .where("id", isEqualTo: user.id)
        .getDocuments()
        .catchError((onError) {
      apiResponse.hasError = true;
      apiResponse.error = ApiError.fromFirebaseError(onError);
    });

    var list = <NotificationDetail>[];
    snapshot.documents.forEach((doc) {
      list.add(NotificationDetail.fromMap(doc.data, documentID: doc.documentID));
    });


    list.sort((o1, o2) {
      return int.parse(o2.timestamp) - int.parse(o1.timestamp);
    });

    apiResponse.success = list;
    return apiResponse;
  }

  @override
  Future<ApiResponse<bool>> updateNotification(
      NotificationDetail notificationDetail) async {
    return await FirestoreManager.updateWithDocuments(
        collection: Collection.NOTIFICATION,
        document: notificationDetail.documentID,
        data: notificationDetail.toMap());
  }

  @override
  Stream<List<NotificationDetail>> fetchNotificationStream(User user) {
    return Firestore.instance.collection(Collection.NOTIFICATION)
        .where("id", isEqualTo: user.id)
        .snapshots().map((convert) {
          final list = <NotificationDetail>[];
          convert.documents.forEach((doc) {
            list.add(NotificationDetail.fromMap(doc.data, documentID: doc.documentID));
          });
          list.sort((o1, o2) {
            return int.parse(o2.timestamp) - int.parse(o1.timestamp);
          });
          return list;
    });
  }
}
