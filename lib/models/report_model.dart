import 'package:solo/models/base_model.dart';

class Report extends BaseModel {

  String ticketId;
  String category;
  String statement;
  String reportedBy;
  String reportedId;
  String reportType;
  String timestamp;

  Report({this.ticketId, this.category, this.statement, this.reportedBy, this.reportedId,
      this.reportType, this.timestamp});

  factory Report.fromMap(Map<String, dynamic> json) {
    return Report(category: json["category"],
      statement: json["statement"],
      ticketId: json["ticketId"],
      reportedBy: json["reportedBy"],
      reportedId: json["reportedId"],
      reportType: json["reportType"],
      timestamp: json["timestamp"],);
  }

  Map<String, dynamic> toMap() {
    return {
      "category": this.category,
      "statement": this.statement,
      "reportedBy": this.reportedBy,
      "reportedId": this.reportedId,
      "reportType": this.reportType,
      "timestamp": this.timestamp,
      "ticketId": this.ticketId,
    };
  }


}

enum ReportType {
  PROFILE,
  POST
}

enum ReportCategory {
  SPAM,
  INAPPROPRIATE
}

final statements = [
  "Nudity or sexual activity",
  "Hate speechs",
  "Voilence",
  "Harassment"
  "False Information",
  "Scam or fraud",
  "I Just don't like it"
];