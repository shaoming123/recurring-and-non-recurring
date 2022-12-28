
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/model/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import '../model/nonRecurring.dart';
import '../model/notification.dart';

class DbHelper {
  static Database? _db;

  final DB_Name = 'sqlite.db';
  final Table_User = 'user_account';
  final Table_Event = 'recurring_table';
  final Table_NonRecurring = 'non_recurring';
  final Table_Notification = 'notification';
  int Version = 1;

  // user
  String C_UserID = 'user_id';
  String C_UserName = 'user_name';
  String C_Password = 'password';
  String C_PhotoName = 'photoName';
  String C_Role = 'role';
  String C_Email = 'email';
  String C_Position = 'position';
  String C_LeadFunc = 'leadFunc';
  String C_Site = 'site';
  String C_SiteLead = 'siteLead';
  String C_Phone = 'phone';
  String C_Active = 'active';
  String C_File = 'filepath';

  //event
  String recurringId = 'recurringId';
  String category = 'category';
  String subCategory = 'subCategory';
  String type = 'type';
  String site = 'site';
  String task = 'task';
  String from = 'fromD';
  String to = 'toD';
  String person = 'person';
  String duration = 'duration';
  String priority = 'priority';
  String recurringOpt = 'recurringOpt';
  String recurringEvery = 'recurringEvery';
  String recurringUntil = 'recurringUntil';
  String remark = 'remark';
  String completeDate = 'completeDate';
  String status = 'status';
  String color = 'color';
  String date = 'date';
  String deadline = 'deadline';
  String start = 'startTime';
  String end = 'dueTime';
  String uniqueNumber = 'uniqueNumber';
  String dependent = 'dependent';
  String checkRecurring = 'checkRecurring';

  //non-recurring
  String nonRecurringId = 'nonRecurringId';
  String noncategory = 'category';
  String nonsubCategory = 'subCategory';
  String nontype = 'type';
  String nonsite = 'site';
  String nontask = 'task';
  String owner = 'owner';
  String startDate = 'startDate';
  String due = 'due';
  String modify = 'modify';
  String nonremark = 'remark';
  String noncompleteDate = 'completeDate';
  String checked = 'checked';
  String personCheck = 'personCheck';
  String nonstatus = 'status';

  //notification
  String notificationId = 'id';
  String notificationOwner = 'owner';
  String assigner = 'assigner';
  String notificationTask = 'task';
  String notificationDeadline = 'deadline';
  String notificationType = 'type';
  String noted = 'noted';

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
        " $C_UserID INTEGER PRIMARY KEY, "
        " $C_UserName TEXT, "
        " $C_Password TEXT, "
        " $C_Email TEXT, "
        " $C_Role TEXT, "
        " $C_Position TEXT, "
        " $C_LeadFunc TEXT, "
        " $C_Site TEXT, "
        " $C_SiteLead TEXT, "
        " $C_Phone TEXT, "
        " $C_File TEXT, "
        " $C_Active TEXT "
        ")");
    await db.execute("CREATE TABLE $Table_Event ("
        " $recurringId INTEGER PRIMARY KEY, "
        " $category TEXT, "
        " $subCategory TEXT, "
        " $type TEXT, "
        " $site TEXT, "
        " $task TEXT, "
        " $date TEXT, "
        " $deadline TEXT, "
        " $start TEXT, "
        " $end TEXT, "
        " $from TEXT, "
        " $to TEXT, "
        " $duration TEXT, "
        " $priority TEXT, "
        " $color TEXT, "
        " $recurringOpt TEXT, "
        " $recurringEvery TEXT, "
        " $remark TEXT, "
        " $completeDate TEXT, "
        " $dependent TEXT, "
        " $uniqueNumber TEXT, "
        " $checkRecurring TEXT, "
        " $status TEXT, "
        " $person TEXT "
        ")");
    await db.execute(
        "CREATE TABLE $Table_NonRecurring($nonRecurringId INTEGER PRIMARY KEY, $noncategory TEXT, $nonsubCategory TEXT, $nontype TEXT,$nonsite TEXT,$nontask TEXT ,$owner TEXT ,$startDate TEXT,$due TEXT,$modify TEXT, $nonremark TEXT, $noncompleteDate TEXT, $checked TEXT, $personCheck TEXT, $nonstatus TEXT)");
    await db.execute(
        "CREATE TABLE $Table_Notification($notificationId INTEGER PRIMARY KEY, $notificationOwner TEXT, $assigner TEXT, $notificationTask TEXT,$notificationDeadline TEXT,$notificationType TEXT ,$noted TEXT)");
    await db.execute(
        "CREATE TABLE checkfirst(id INTEGER PRIMARY KEY, firsttime TEXT)");
  }

  Future<bool> getfirst() async {
    var dbClient = await db;
    final res = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM checkfirst'));
    print(res);
    if (res == 0) {
      // Table is empty, return true
      return true;
    } else {
      // Table is not empty, return false
      return false;
    }
  }

  Future<int> addfirst() async {
    var dbClient = await db;
    var res = await dbClient.insert(
      'checkfirst', {'firsttime': 'true'}, //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );

    return res;
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

  Future<List<Map<String, dynamic>>> getAUser(int id) async {
    var dbClient = await db;
    return dbClient.query(Table_User,
        where: "$C_UserID = ?", whereArgs: [id], limit: 1);
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

  Future<int> updateUserActive(String active, int id) async {
    var dbClient = await db;
    var res = await dbClient.rawUpdate(
        'UPDATE $Table_User SET $C_Active = ? WHERE $C_UserID = ?',
        [active, id]);

    return res;
  }

  Future<int> deleteUser(int user_id) async {
    var dbClient = await db;
    var res = await dbClient
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }

  Future<int> deleteAllUser() async {
    var dbClient = await db;
    var res = await dbClient.delete(Table_User);
    return res;
  }

  // Recurring
  Future<int> addEvent(Event item) async {
    var dbClient = await db;
    //open database

    var res = await dbClient.insert(
      Table_Event, item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );

    return res;
  }

  Future<List<Map<String, dynamic>>> fetchAEvent(int id) async {
    var dbClient = await db;
    return dbClient.query(Table_Event,
        where: "$recurringId = ?", whereArgs: [id], limit: 1);
  }

  Future<List<Map<String, dynamic>>> fetchAllEvent() async {
    var dbClient = await db;
    return dbClient.query(Table_Event, orderBy: recurringId);
  }

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

  Future<int> deleteAllEvent() async {
    var dbClient = await db;
    var res = await dbClient.delete(Table_Event);
    return res;
  }

  /*end recurring*/

  // Non-Recurring
  Future<int> addNonRecurring(nonRecurring item) async {
    var dbClient = await db;
    var res = await dbClient.insert(
      Table_NonRecurring, item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );

    return res;
  }

  Future<List<Map<String, dynamic>>> fetchANonRecurring(int id) async {
    var dbClient = await db;
    return dbClient.query(Table_NonRecurring,
        where: "$nonRecurringId = ?", whereArgs: [id], limit: 1);
  }

  Future<List<Map<String, dynamic>>> fetchAllNonRecurring() async {
    var dbClient = await db;
    return dbClient.query(Table_NonRecurring, orderBy: nonRecurringId);
  }

  Future<int> deleteNonRecurring(int id) async {
    //returns number of items deleted
    final dbClient = await db; //open database

    var res = await dbClient.delete(Table_NonRecurring,
        where: '$nonRecurringId = ?', whereArgs: [id]);

    return res;
  }

  Future<int> deleteAllNonRecurring() async {
    var dbClient = await db;
    var res = await dbClient.delete(Table_NonRecurring);
    return res;
  }

  Future<int> updateNonRecurring(nonRecurring item) async {
    // returns the number of rows updated

    final dbClient = await db; //open database

    var res = await dbClient.update(Table_NonRecurring, item.toMap(),
        where: '$nonRecurringId = ?', whereArgs: [item.nonRecurringId]);
    return res;
  }
  /*end non-recurring*/

  /*start notification*/

  Future addNotification(List item) async {
    var dbClient = await db;
    for (var element in item) {
      await dbClient.insert(
        Table_Notification,
        element, //toMap() function from MemoModel
        conflictAlgorithm: ConflictAlgorithm.ignore,
      ); //ignores conflicts due to duplicate entries
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllNotification() async {
    var dbClient = await db;
    return dbClient.query(Table_Notification, orderBy: notificationId);
  }

  Future<int> deleteAllNotification() async {
    var dbClient = await db;
    var res = await dbClient.delete(Table_Notification);
    return res;
  }

  Future<int> deleteNotification(int id) async {
    //returns number of items deleted
    final dbClient = await db; //open database

    var res = await dbClient.delete(Table_Notification,
        where: '$notificationId = ?', whereArgs: [id]);

    return res;
  }
  /*end notification*/

// sync data

  Future syncMember(UserModel data) async {
    var dbClient = await db;

    // Loop through the rows

    // Check if the row exists in the SQLite database
    final list = await dbClient
        .query(Table_User, where: '$C_UserID=?', whereArgs: [data.user_id]);

    // If the row exists in the SQLite database, update it
    if (list.isNotEmpty) {
      await dbClient.update(Table_User, data.toMap(),
          where: '$C_UserID = ?', whereArgs: [data.user_id]);
    }
    // If the row does not exist in the SQLite database, insert it
    else {
      await dbClient.insert(Table_User, data.toMap());
    }
  }

  Future syncEvent(Event data) async {
    var dbClient = await db;

    // Loop through the rows

    // Check if the row exists in the SQLite database
    final list = await dbClient.query(Table_Event,
        where: '$recurringId=?', whereArgs: [data.recurringId]);

    // If the row exists in the SQLite database, update it
    if (list.isNotEmpty) {
      await dbClient.update(Table_Event, data.toMap(),
          where: '$recurringId = ?', whereArgs: [data.recurringId]);
    }
    // If the row does not exist in the SQLite database, insert it
    else {
      await dbClient.insert(Table_Event, data.toMap());
    }
  }

  Future syncNonRecurring(nonRecurring data) async {
    var dbClient = await db;

    // Loop through the rows

    // Check if the row exists in the SQLite database
    final list = await dbClient.query(Table_NonRecurring,
        where: '$nonRecurringId=?', whereArgs: [data.nonRecurringId]);

    // If the row exists in the SQLite database, update it
    if (list.isNotEmpty) {
      await dbClient.update(Table_NonRecurring, data.toMap(),
          where: '$nonRecurringId = ?', whereArgs: [data.nonRecurringId]);
    }
    // If the row does not exist in the SQLite database, insert it
    else {
      await dbClient.insert(Table_NonRecurring, data.toMap());
    }
  }

  Future syncNotification(NotificationModel data) async {
    var dbClient = await db;

    // Loop through the rows

    // Check if the row exists in the SQLite database
    final list = await dbClient.query(Table_Notification,
        where: '$notificationId=?', whereArgs: [data.id]);

    // If the row exists in the SQLite database, update it
    if (list.isNotEmpty) {
      await dbClient.update(Table_Notification, data.toMap(),
          where: '$notificationId = ?', whereArgs: [data.id]);
    }
    // If the row does not exist in the SQLite database, insert it
    else {
      await dbClient.insert(Table_Notification, data.toMap());
    }
  }
}
