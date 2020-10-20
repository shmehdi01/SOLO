import 'package:solo/models/Collection.dart';

const tables = <String>[
  '''
  CREATE TABLE ${Collection.USER} ( 
      id VARCHAR(256) PRIMARY KEY, 
      name VARCHAR(256),
      email VARCHAR(256),
      phone VARCHAR(256),
      photoUrl VARCHAR(256),
      bannerUrl VARCHAR(256),
      bio VARCHAR(256),
      isEmailVerified tinyint(1) DEFAULT 0,
      accountType int(11),
      pushToken VARCHAR(256),
      isSync tinyint(1) DEFAULT 0 
     )  
''',
  '''
  CREATE TABLE ${Collection.CONNECTION} ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      follower VARCHAR(256),
      following VARCHAR(256),
      time VARCHAR(256),
      message VARCHAR(256),
      isSync tinyint(1) DEFAULT 0 
     )  
''',
  '''
  CREATE TABLE ${Collection.NOTIFICATION} ( 
      id VARCHAR(256) PRIMARY KEY, 
      documentID VARCHAR(256),
      message VARCHAR(256),
      type int(11),
      isRead tinyint(1)  DEFAULT 0,
      intentId VARCHAR(256),
      addtionalMsg VARCHAR(256),
      isSync tinyint(1) DEFAULT 0 
     )  
''',

  '''
  CREATE TABLE ${Collection.CHAT_LIST} ( 
      sn INTEGER PRIMARY KEY AUTOINCREMENT, 
      id VARCHAR(256), 
      myID VARCHAR(256),
      userName VARCHAR(256),
      userPhoto VARCHAR(256),
      message VARCHAR(256),
      messageType VARCHAR(256),
      messageStatus VARCHAR(256),
      timestamp VARCHAR(256),
      chatID VARCHAR(256),
      senderID VARCHAR(256),
      isRead tinyint(1)  DEFAULT 0,
      isSync tinyint(1) DEFAULT 0 
     )  
''',

  '''
  CREATE TABLE ${Collection.SEARCH_KEYWORDS} ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      keyword VARCHAR(256), 
      type VARCHAR(256),
      timestamp VARCHAR(256),
      isRead tinyint(1)  DEFAULT 0,
      isSync tinyint(1) DEFAULT 0 
     )  
''',
];

class ChatTableHelper {
  static String createChatTableQuery(String chatId) {
    return '''
  CREATE TABLE IF NOT EXISTS $chatId ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      senderID TEXT,
      receiverID TEXT,
      senderName VARCHAR(256),
      receiverName VARCHAR(256),
      senderPhoto VARCHAR(256),
      receiverPhoto VARCHAR(256),
      messageStatus VARCHAR(256),
      messageType VARCHAR(256),
      message VARCHAR(256),
      timestamp VARCHAR(256),
      isRead tinyint(1)  DEFAULT 0,
      isSync tinyint(1) DEFAULT 0 
     )  
''';
  }
}
