//@dart=2.9
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Clone2Helper {
  Clone2Helper.internal();
  static final Clone2Helper instance = Clone2Helper.internal();
  factory Clone2Helper() => instance;

  final userTable = 'user_details';
  final notiTable = 'notification';

  // final _version = 1;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    String downloadUrl =
        "https://ipsolutions4u.com/ipsolutions/recurringMobile/syncData/sqlite_db_2.db";
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    String dbFile = "$path/sqlite_db_2.db";
    File f = File(dbFile);

    Dio dio = Dio();
    Response response = await dio.get(downloadUrl,
        options: Options(responseType: ResponseType.bytes));

    if (response.statusCode == 200) {
      // Get the md5 hash of the downloaded file
      String downloadedMd5 = md5.convert(response.data).toString();

      if (f.existsSync()) {
        // Get the md5 hash of the existing file
        String existingMd5 = md5.convert(await f.readAsBytes()).toString();
        // Compare the md5 hash of the downloaded file with the existing file
        if (existingMd5 != downloadedMd5) {
          // If they are different, update the existing file with the downloaded file
          await f.writeAsBytes(response.data);
        }
      } else {
        // If the file doesn't exist, create it and write the downloaded file to it
        await f.create();
        await f.writeAsBytes(response.data);
      }
    }

    var openDb = await openDatabase(dbFile);
    return openDb;
  }

  Future<List<Map<String, dynamic>>> getUser() async {
    final dbclient = await db;

    return dbclient.query(userTable, orderBy: 'id');
  }

  Future<List<Map<String, dynamic>>> getAUser(int id) async {
    var dbClient = await db;
    return dbClient.query(userTable,
        where: "id = ?", whereArgs: [id], limit: 1);
  }

  Future<List<Map<String, dynamic>>> fetchNotificationData() async {
    var dbclient = await db;
    final data = await dbclient.query(notiTable, orderBy: 'id');

    return data;
  }
}
