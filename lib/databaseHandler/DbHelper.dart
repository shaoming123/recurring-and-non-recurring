import 'package:flutter/animation.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/model/user.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import '../provider/event_provider.dart';

class DbHelper {
  static Database? _db;

  final DB_Name = 'test.db';
  final Table_User = 'user_account';
  final Table_Event = 'recurring_table';
  int Version = 1;

  // user
  String C_UserID = 'user_id';
  String C_UserName = 'user_name';
  String C_Password = 'password';
  String C_PhotoName = 'photoName';

  //event
  String recurringId = 'recurringId';
  String category = 'category';
  String subCategory = 'subCategory';
  String type = 'type';
  String site = 'site';
  String task = 'task';
  String from = 'fromD';
  String to = 'toD';
  String duration = 'duration';
  String priority = 'priority';
  String backgroundColor = 'backgroundColor';

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
        " $C_UserID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_UserName TEXT, "
        " $C_Password TEXT "
        ")");
    await db.execute(
        "CREATE TABLE $Table_Event($recurringId INTEGER PRIMARY KEY AUTOINCREMENT, $category TEXT, $subCategory TEXT, $type TEXT,$site TEXT,$task TEXT ,$from DATETIME,$to DATETIME,$duration TEXT,$priority TEXT)");
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

  Future<List<Map<String, dynamic>>> getItem(int user_id) async {
    var dbClient = await db;
    return dbClient.query(Table_User,
        where: "$C_UserID = ?", whereArgs: [user_id], limit: 1);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    var dbClient = await db;
    return dbClient.query(Table_User, orderBy: C_UserID);
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

    return res;
  }

  Future<int> deleteUser(int user_id) async {
    var dbClient = await db;
    var res = await dbClient
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }

  Future<int> addEvent(Event item) async {
    //returns number of items inserted as an integer
    print(item);
    var dbClient = await db;
    //open database

    var res = await dbClient.insert(
      Table_Event, item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );

    return res;
  }

  Future<List<Map<String, dynamic>>> fetchAllEvent() async {
    var dbClient = await db;
    return dbClient.query(Table_Event, orderBy: recurringId);
  }

  // Future<List<Event>> fetchEvent() async {
  //   //returns the memos as a list (array)

  //   final dbClient = await db; //open database
  //   final maps = await dbClient
  //       .query(Table_Event); //query all the rows in a table as an array of maps

  //   return List.generate(maps.length, (i) {
  //     //create a list of memos
  //     return Event(
  //       recurringId: maps[i]['recurringId'] as int,
  //       category: maps[i]['category'] as String,
  //       subCategory: maps[i]['subCategory'] as String,
  //       type: maps[i]['type '] as String,
  //       site: maps[i]['site'] as String,
  //       task: maps[i]['task'] as String,
  //       from: maps[i]['fromD'] as String,
  //       to: maps[i]['toD'] as String,
  //       duration: maps[i]['duration'] as String,
  //       priority: maps[i]['priority'] as String,
  //       // backgroundColor: maps[i]['backgroundColor'] as String,
  //     );
  //   });
  // }

  Future<int> deleteEvent(int recurring_Id) async {
    //returns number of items deleted
    final dbClient = await db; //open database

    var res = await dbClient.delete(Table_Event,
        where: '$recurringId = ?', whereArgs: [recurring_Id]);

    return res;
  }

  Future<int> updateEvent(Event item) async {
    // returns the number of rows updated

    final dbClient = await db; //open database

    var res = await dbClient.update(Table_Event, item.toMap(),
        where: '$recurringId = ?', whereArgs: [item.recurringId]);
    return res;
  }
}
