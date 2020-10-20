import 'package:solo/database/entity/base.dart';

class SearchKeyword extends Entity {

  int id;
  String keyword;
  String type;
  int isRead;
  int isSync;
  String timestamp;

  SearchKeyword(
      {this.id, this.keyword, this.type, this.isRead, this.isSync, this.timestamp});

  Map<String, dynamic> toMap() {
    return {
    "id": this.id,
    "keyword": this.keyword,
    "type": this.type,
    "isRead": this.isRead,
    "isSync": this.isSync,
    "timestamp": this.timestamp
  };}

  factory SearchKeyword.fromJson(Map<String, dynamic> json) {
    return SearchKeyword(
      id: json["id"],
      keyword: json["keyword"],
      type: json["type"],
      timestamp: json["timestamp"],
    );
  }

}