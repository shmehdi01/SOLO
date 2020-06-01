import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solo/models/Collection.dart';
import 'package:solo/models/report_model.dart';
import 'package:solo/network/api_service.dart';

class FirebaseReportApi extends ReportApi {

  @override
  Future<ApiResponse<void>> report(Report report) async {

     await Firestore.instance.collection(Collection.REPORT).add(report.toMap());

     return ApiResponse();
  }

}