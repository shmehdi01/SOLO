
import 'package:path/path.dart';
import 'package:solo/database/tables.dart';
import 'package:solo/utils.dart';
import 'package:sqflite/sqflite.dart';



const String databaseName = "my_app.db";
const int databaseVersion = 1;

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider databaseProvider = DatabaseProvider._();
  factory DatabaseProvider() => databaseProvider;


  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(join(await getDatabasesPath(), databaseName),
        onCreate: _onDatabaseCreated,
        version: databaseVersion,
        onUpgrade: onDBVersionUpdated);
  }

  Future _onDatabaseCreated(Database db, int version) async {

    String tag = "CREATE_TABLE";

    tables.forEach((schema) async{
      await db.execute(schema);

      developerLog(tag, schema);
    });

  }

  Future onDBVersionUpdated(db, version, i) async {}
}
