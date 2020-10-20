import 'package:solo/models/base_model.dart';

class Block extends BaseModel {

  String myID;
  String blockedID;
  String timestamp;

  Block({this.myID, this.blockedID, this.timestamp});

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      myID: json["myID"],
      blockedID: json["blockedID"],
      timestamp: json["timestamp"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "myID": this.myID,
      "blockedID": this.blockedID,
      "timestamp": this.timestamp,
    };
  }

}