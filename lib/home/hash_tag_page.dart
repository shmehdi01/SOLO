import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solo/utils.dart';

class HashTagPage extends StatelessWidget {

  final String hashTag;

  HashTagPage(this.hashTag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.android, size: 60, color: Colors.lightGreen,),
              verticalGap(gap: 8),
              Text("$hashTag", style: TextStyle(fontSize: FONT_LARGE, fontWeight: FontWeight.bold, color: Colors.purpleAccent),),
              Text("UNDER DEVELOPMENT ! Come back later", style: TextStyle(fontSize: FONT_NORMAL),),
            ],
          ),
        ),
      ),
    );
  }
}
