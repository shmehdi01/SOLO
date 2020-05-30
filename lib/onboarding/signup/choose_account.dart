import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/onboarding/signup/notifiers/SignUpActionNotifier.dart';

import '../../utils.dart';

class ChooseAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: Scaffold(
        body: AccountTypeBody(),
      ),
      create: (BuildContext context) => SignUpActionNotifier(),
    );
  }
}

class AccountTypeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var _radius = Radius.circular(25);

    return Stack(
      children: <Widget>[
        Opacity(
          child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          PRIMARY_COLOR.withOpacity(1.0), BlendMode.softLight),
                      image: AssetImage("assets/images/login_bg.jpeg"),
                      fit: BoxFit.cover))),
          opacity: 0.8,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 140,
              ),
              Container(
                padding: const EdgeInsets.only(
                    left: 12, right: 40, top: 15, bottom: 15),
                decoration: BoxDecoration(
                    color: PRIMARY_COLOR,
                    borderRadius: BorderRadius.only(
                        topRight: _radius, bottomRight: _radius)),
                child: Text(
                  "  Choose Account Type",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Stack(
                children: <Widget>[
                  Opacity(
                    child: Container(
                      margin: EdgeInsets.only(right: 150),
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topRight: _radius, bottomRight: _radius),
                      ),
                    ), opacity: 0.8,
                  ),
                  Container(
                    //color: Colors.red,
                    padding: EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Public", style: TextStyle(color: PRIMARY_COLOR,fontSize: 25),),
                            SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("For brands,\ncelebrities and\nfamous people",style: TextStyle(fontSize: 16),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 48,
                    right: 100,
                    child: SizedBox(
                      child: blueRoundedButton(Icons.public, "Public"),
                      width: 130,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Stack(
                children: <Widget>[
                  Opacity(
                    child: Container(
                      margin: EdgeInsets.only(right: 150),
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topRight: _radius, bottomRight: _radius),
                      ),
                    ), opacity: 0.8,
                  ),
                  Container(
                    //color: Colors.red,
                    padding: EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Private", style: TextStyle(color: PRIMARY_COLOR,fontSize: 25),),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("For People,\nwho want a\npersonal space\nwith close people",style: TextStyle(fontSize: 16),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 48,
                    right: 100,
                    child: SizedBox(
                      child: blueRoundedButton(Icons.person_pin, "Private"),
                      width: 130,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget blueRoundedButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.only(
          left: 12, right: 20, top: 15, bottom: 15),
      decoration: BoxDecoration(
          color: PRIMARY_COLOR,
          borderRadius: BorderRadius.all( Radius.circular(25))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Colors.white,),
          SizedBox(width: 8,),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
