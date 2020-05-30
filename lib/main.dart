import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:solo/home/HomeActionNotifier.dart';
import 'package:solo/home/home.dart';
import 'package:solo/models/user.dart';
import 'package:solo/onboarding/login/login.dart';
import 'package:solo/languages/strings_constants.dart';
import 'package:solo/service/sync_service.dart';
import 'package:solo/session_manager.dart';
import 'package:solo/utils.dart';

import 'home/NotificationService.dart';
import 'network/api_provider.dart';

void main() => runApp(ChangeNotifierProvider(child: MyApp(), create: (BuildContext context) => HomeActionNotifier(),));


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        supportedLocales: [Locale('en'), Locale('hi')],
        localizationsDelegates: [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: ThemeData(
            backgroundColor: Colors.white,
            primarySwatch: PRIMARY_COLOR,
            primaryColorDark: Colors.grey,
            fontFamily: 'Gothom'
        ),
        home: StartHome()
    );
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
      if(user != null) {

        SessionManager.loadFriends();
        //Start Service
        setupServiceLocator(user);
        SoloService service = locator<SoloService>();
        service.init();

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomePage(user: user,)));
      }else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AnimatedContainer(child: Center(child: Image.asset("$IMAGE_ASSETS/icon_circle.png", scale: 12,),), duration: Duration(milliseconds: 300),));
  }
}

class Application {
  static GetIt service;
}







