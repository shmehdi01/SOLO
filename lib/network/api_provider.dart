import 'package:solo/hashtag/api/firebase_hashtag_api.dart';
import 'package:solo/home/api/firebase_home_api.dart';
import 'package:solo/home/chat/api/chat_api.dart';
import 'package:solo/home/explore/api/explore_api.dart';
import 'package:solo/home/notifications/api/notification_api.dart';
import 'package:solo/home/profile/api/profile_api.dart';
import 'package:solo/home/report/api/firebase_report_api.dart';
import 'package:solo/network/api_service.dart';
import 'package:solo/onboarding/login/api/login_api.dart';
import 'package:solo/onboarding/signup/api/sign_up_api.dart';

import 'api_service.dart';

enum ApiFlavor {
  FIREBASE,
  NETWORK,
}

///PROVIDE APIS : When ever you register new api in [api_service.dart]
///provide api in this class respectively all flavors.
class ApiProvider {
  static final _apiProvider = ApiProvider._();
  static ApiFlavor _flavor;

  factory ApiProvider() => _apiProvider;
  ApiProvider._();

  static get apiFlavour => _flavor;

  ///Configure Once when App open for the first time.
  ///[ApiFlavor] use your implementation flavour
  ///e.g [ApiFlavor.FIREBASE], [ApiFlavor.NETWORK]
  static void configure(ApiFlavor apiFlavor) => _flavor = apiFlavor;


  //PROVIDING LOGIN API
  static LoginApi get loginApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseLogin();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }

  //PROVIDING SIGN UP API
  static SignUpApi get signUpApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseSignUp();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }

  //PROVIDING PROFILE API
  static ProfileApi get profileApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseProfileApi();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }

  //PROVIDING EXPLORE API
  static ExploreApi get exploreApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseExploreApi();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }

  //PROVIDING NOTIFICATION API
  static NotificationApi get notificationApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseNotificationApi();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }

  //PROVIDING CHAT API
  static ChatApi get chatAPi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseChatApi();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }

  //PROVIDING HOME API
  static HomeApi get homeApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseHomeApi();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }

  //PROVIDING REPORT API
  static ReportApi get reportApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseReportApi();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }


  //PROVIDING HASH TAG API
  static HashTagApi get hashTagApi {
    switch (_flavor) {
      case ApiFlavor.FIREBASE:
        return FirebaseHashTagApi();
      case ApiFlavor.NETWORK:
        return null;
    }
    return null;
  }
}
