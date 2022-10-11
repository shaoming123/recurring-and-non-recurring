import 'package:flutter/animation.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/model/user.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

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
        " $C_UserID TEXT, "
        " $C_UserName TEXT, "
        " $C_Password TEXT, "
        " PRIMARY KEY ($C_UserID)"
        ")");
    await db.execute(
        "CREATE TABLE $Table_Event($recurringId INTEGER PRIMARY KEY AUTOINCREMENT, $category TEXT, $subCategory TEXT, $type TEXT,$site TEXT,$task TEXT ,$from TEXT,$to TEXT,$duration TEXT,$priority TEXT,$backgroundColor TEXT)");
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

  Future<int> deleteUser(String user_id) async {
    var dbClient = await db;
    var res = await dbClient
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }

  Future<int> addEvent(Event item) async {
    //returns number of items inserted as an integer

    var dbClient = await db;
    //open database

    var res = await dbClient.insert(
      Table_Event, item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );

    return res;
  }

  Future<List<Event>> fetchEvent() async {
    //returns the memos as a list (array)

    final dbClient = await db; //open database
    final maps = await dbClient
        .query(Table_Event); //query all the rows in a table as an array of maps

    return List.generate(maps.length, (i) {
      //create a list of memos
      return Event(
        recurringId: maps[i]['recurringId'] as int,
        category: maps[i]['category'] as String,
        subCategory: maps[i]['subCategory'] as String,
        type: maps[i]['type '] as String,
        site: maps[i]['site'] as String,
        task: maps[i]['task'] as String,
        from: maps[i]['fromD'] as String,
        to: maps[i]['toD'] as String,
        duration: maps[i]['duration'] as String,
        priority: maps[i]['priority'] as String,
        backgroundColor: maps[i]['backgroundColor'] as String,
      );
    });
  }

  Future<int> deleteEvent(int recurringId) async {
    //returns number of items deleted
    final dbClient = await db; //open database

    int result = await dbClient.delete(Table_Event, //table name
        where: "$recurringId = ?",
        whereArgs: [recurringId] // use whereArgs to avoid SQL injection
        );

    return result;
  }

  Future<int> updateEvent(int id, Event item) async {
    // returns the number of rows updated

    final dbClient = await db; //open database

    int result = await dbClient.update(Table_Event, item.toMap(),
        where: "$recurringId = ?", whereArgs: [recurringId]);
    return result;
  }
}
