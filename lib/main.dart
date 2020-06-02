import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:solo/languages/strings_constants.dart';
import 'package:solo/models/user.dart';
import 'package:solo/service/sync_service.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

import 'home/NotificationService.dart';
import 'home/home.dart';
import 'network/api_provider.dart';
import 'onboarding/login/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SOLO',
        supportedLocales: [Locale('en'), Locale('hi')],
        localizationsDelegates: [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: ThemeData(
            cursorColor: PRIMARY_COLOR,
            backgroundColor: Colors.white,
            primaryColor: appBarColor,
            primaryColorDark: appBarColor,
            accentColor: PRIMARY_COLOR,
            fontFamily: 'Gothom'),
        home: StartHome());
  }
}

class StartHome extends StatefulWidget {
  @override
  _StartHomeState createState() => _StartHomeState();
}

class _StartHomeState extends State<StartHome> {
  GetIt locator = GetIt.instance;

  setupServiceLocator(User user) {
    locator.registerLazySingleton<SoloService>(() => NotificationService(user));
    locator.registerLazySingleton<SyncService>(() => SyncService());
  }

  bool isLoggedIn = false;
  FirebaseUser user;
  var scaleImg = 12.0;

  @override
  void initState() {
    //Configure Api
    ApiProvider.configure(ApiFlavor.FIREBASE);

    //Check Session
    SessionManager sessionManager = SessionManager();
    sessionManager.getUser().then((user) {
      if (user != null) {
        //SessionManager.loadFriends();
        //Start Service
        setupServiceLocator(user);
        SoloService service = locator<SoloService>();
        service.init();

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HomeDashboard(
                      user: user,
                    )));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        AnimatedContainer(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("$IMAGE_ASSETS/splashbg.jpg"),
                  fit: BoxFit.fill)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset(
                  "$IMAGE_ASSETS/icon_circle.png",
                  scale: 12,
                ),
              ),
            ],
          ),
          duration: Duration(milliseconds: 300),
        ),

        Positioned(
          bottom: 180,
          left: MediaQuery.of(context).size.width/2 - 80,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Made with "),
              Icon(
                Icons.favorite,
                size: 25,
                color: Color(0xffDC3545),
              ),
              Text(" in India"),
            ],
          ),
        ),
      ],
    ));
  }
}

class Application {
  static GetIt service;
}
