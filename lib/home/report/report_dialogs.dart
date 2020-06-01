import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/location/locationPage.dart';
import 'package:solo/models/report_model.dart';
import 'package:solo/models/user.dart';
import 'package:solo/network/api_provider.dart';

import '../../utils.dart';

class BottomSheetReport extends StatelessWidget {
  final ReportType reportType;
  final User user;
  final String reportingID;

  BottomSheetReport(this.reportType, this.user, this.reportingID);

  static show(BuildContext context,
      {@required ReportType reportType,
      @required User user,
      @required reportingID}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (context) => BottomSheetReport(reportType, user, reportingID));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 35,
              height: 3.5,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Colors.blueGrey),
            ),
          ),
          verticalGap(gap: 12),
          Center(
            child: Text(
              "Report",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: FONT_LARGE),
            ),
          ),
          verticalGap(gap: 8),
          Divider(),
          verticalGap(gap: 8),
          Text(
            "Why are you reporting this post",
            style: TextStyle(
              color: Colors.black,
              fontSize: FONT_NORMAL,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalGap(gap: 8),
          InkWell(
            onTap: () async {
              await ApiProvider.reportApi.report(_createReport(
                  reportType, ReportCategory.SPAM, user, reportingID, "It is spam"));

            Navigator.pop(context);
              _confirmDialog(context);
            },
            child: Container(
              width: MATCH_PARENT,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Text(
                "It's spam",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: FONT_NORMAL,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          verticalGap(gap: 8),
          InkWell(
            onTap: () async {
              await ApiProvider.reportApi.report(_createReport(
                  reportType, ReportCategory.INAPPROPRIATE, user, reportingID, "Inappropriate"));

              Navigator.pop(context);
              _confirmDialog(context);
            },
            child: Container(
              width: MATCH_PARENT,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Text(
                "It's inappropriate",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: FONT_NORMAL,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Report _createReport(
    ReportType reportType, ReportCategory category, User user, String id, String statement) {
  return Report(
      timestamp: Utils.timestamp(),
      category: category.toString(),
      reportType: reportType.toString(),
      reportedBy: user.id,
      reportedId: id,
      statement: statement,
      ticketId: Uuid().generateV4());
}

void _confirmDialog(context) {
  showDialog(context: context,
      child: Dialog(
    child: Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.check_circle_outline, color: Colors.green, size: 40,),
          verticalGap(gap: 12),
          Text(
            "Thanks for letting us know",
            style: TextStyle(
              color: Colors.black,
              fontSize: FONT_LARGE,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalGap(gap: 5),
          Text(
            "Your feedback is important in helping us to keep the Solo community safe",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: FONT_NORMAL,
              fontWeight: FontWeight.normal,
            ),
          )
        ],

    ),
    ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  ));
}

class _BottomSheetReportCategory extends StatelessWidget {
  static show(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (context) => _BottomSheetReportCategory());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 35,
              height: 3.5,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Colors.blueGrey),
            ),
          ),
          verticalGap(gap: 12),
          Center(
            child: Text(
              "Report",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: FONT_LARGE),
            ),
          ),
          verticalGap(gap: 8),
          Divider(),
          verticalGap(gap: 8),
          Text(
            "Why are you reporting this post",
            style: TextStyle(
              color: Colors.black,
              fontSize: FONT_NORMAL,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalGap(gap: 8),
          Expanded(
            child: ListView(
              children: statements
                  .map(
                    (e) => InkWell(
                      onTap: () {},
                      child: Container(
                        width: MATCH_PARENT,
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Text(
                          "$e",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: FONT_NORMAL,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
