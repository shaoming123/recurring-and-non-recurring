import 'package:ipsolution/model/user.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

class DbHelper {
  static Database? _db;

  String DB_Name = 'test.db';
  String Table_User = 'user_account';
  int Version = 1;

  String C_UserID = 'user_id';
  String C_UserName = 'user_name';
  String C_Password = 'password';

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);

    var db = await openDatabase(path, version: Version, onCreate: _onCreate);

    return db;
  }

  _onCreate(Database db, int intVersion) async {
    await db.execute("CREATE TABLE $Table_User ("
        " $C_UserID TEXT, "
        " $C_UserName TEXT, "
        " $C_Password TEXT, "
        " PRIMARY KEY ($C_UserID)"
        ")");
  }

  Future<int> getUserQuantity() async {
    var dbClient = await db;
    final res = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $Table_User'));

    if (res != null) {
      return res;
    } else {
      return 0;
    }
  }

  Future<int> saveData(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient.insert(Table_User, user.toMap());

    return res;
  }

  Future<UserModel?> getLoginUser(String username, String password) async {
    var dbClient = await db;
    var res = await dbClient.rawQuery("SELECT * FROM $Table_User WHERE "
        "$C_UserName = '$username' AND "
        "$C_Password = '$password'");
    print(res);
    // ignore: prefer_is_empty
    if (res.length > 0) {
      return UserModel.fromMap(res.first);
    } else {
      return null;
    }
  }

  Future<int> updateUser(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient.update(Table_User, user.toMap(),
        where: '$C_UserID = ?', whereArgs: [user.user_id]);
    print(res);
    return res;
  }

  Future<int> deleteUser(String user_id) async {
    var dbClient = await db;
    var res = await dbClient
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }
}
