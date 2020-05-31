import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo/home/home.dart';
import 'package:solo/models/user.dart';
import 'package:solo/onboarding/signup/notifiers/ImagePickerNotifier.dart';
import 'package:solo/onboarding/signup/notifiers/SignUpActionNotifier.dart';

import '../../languages/strings_constants.dart';
import '../../utils.dart';

class AddProfilePage extends StatelessWidget {
  final User user;
  final bool changeDp;

  AddProfilePage(this.user, {this.changeDp = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: Scaffold(
        backgroundColor: Color(0xffefefef),
        appBar: AppBar(
          shape: appBarRounded,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "${user.name}",
            style: TextStyle(
                color: Colors.black,
                fontSize: FONT_LARGE,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            if(!changeDp) Container(
              margin: const EdgeInsets.all(8),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                textColor: Colors.white,
                color: PRIMARY_COLOR,
                child: Text(
                  getString(context, STR_SKIP),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage(
                                user: user,
                              )));
                },
              ),
            ),
          ],
          backgroundColor: Colors.white,
        ),
        body: AddProfileBody(),
      ),
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => SignUpActionNotifier(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => ImagePickerNotifier(user, changeDp),
        ),
      ],
    );
  }
}

class AddProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageNotifier = Provider.of<ImagePickerNotifier>(context);

    return SafeArea(
      child: Container(
        width: double.infinity,
        //color: Colors.red,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 60,
            ),
            Text(
              getString(context, STR_ADD_PROFILE_PICTURE),
              style:
                  TextStyle(fontSize: FONT_LARGE, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(getString(context, STR_ADD_PHOTO_FRIEND_FIND)),
            SizedBox(
              height: 15,
            ),
            Consumer<ImagePickerNotifier>(
              builder: (BuildContext context, ImagePickerNotifier value,
                  Widget child) {
                return Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: imageNotifier.user.photoUrl != null  ? CachedNetworkImageProvider(imageNotifier.user.photoUrl) :value.imageFile == null
                          ? AssetImage("$IMAGE_ASSETS/default_dp.png")
                          : FileImage(value.imageFile),
                      backgroundColor: Color(0xffefefef),
                    ),
                    value.loader ? Container(
                        child: CircularProgressIndicator(),
                    height: 200,
                    width: 200,) : Container(
                      height: 200,
                      width: 200,
                    )
                  ],
                );
              },
            ),
            Expanded(child: Container()),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                textColor: Colors.white,
                color: PRIMARY_COLOR,
                child: Text(getString(context, STR_CHOOSE_PHOTO)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                hoverElevation: 2,
                height: 50,
                minWidth: double.infinity,
                elevation: 0,
                onPressed: () {
                  imageNotifier.pickImageFromGallery(context);
                },
              ),
//materialButton(getString(context, STR_CHOOSE_PHOTO), PRIMARY_COLOR, Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                textColor: Colors.black87,
                color: Colors.white,
                child: Text(getString(context, STR_TAKE_PHOTO)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                //hoverColor: Color(0xfffcfcfc),
                hoverElevation: 2,
                height: 50,
                minWidth: double.infinity,
                elevation: 0,
                onPressed: () {
                  imageNotifier.pickImageFromCamera(context);
                },
              ),
            ),
            //materialButton(getString(context, STR_TAKE_PHOTO),  Colors.white, Colors.black87),),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget blueRoundedButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 20, top: 15, bottom: 15),
      decoration: BoxDecoration(
          color: PRIMARY_COLOR,
          borderRadius: BorderRadius.all(Radius.circular(25))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

Widget roundedButton(String text, Color color, Color txtColor,
    {Function onTap}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Expanded(
        child: Container(
          padding:
              const EdgeInsets.only(left: 12, right: 20, top: 15, bottom: 15),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: txtColor, fontSize: FONT_NORMAL),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget myAppBar(
    {@required Widget leading,
    @required Widget center,
    @required Widget trailing}) {
  return PreferredSize(
    preferredSize: Size(double.infinity, 70),
    child: Container(
      //color: Colors.red,
      child: Column(
        children: <Widget>[
          Container(
            height: 28,
          ),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            )),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  leading,
                  Expanded(
                    child: Center(
                      child: center,
                    ),
                  ),
                  trailing
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
