import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/model/user.dart';

import '../databaseHandler/DbHelper.dart';
import '../model/nonRecurring.dart';
import '../model/notification.dart';

DbHelper dbHelper = DbHelper();

class Controller {
  Future addDataToSqlite() async {
    await dbHelper.deleteAllUser();
    var url = 'http://192.168.1.111/testdb/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "user_details"});
    List userData = json.decode(response.body);

    for (int i = 0; i < userData.length; i++) {
      final data = UserModel(
        user_id: int.parse(userData[i]["id"]),
        user_name: userData[i]["username"],
        password: userData[i]["password"],
        email: userData[i]["email"],
        role: userData[i]["role"],
        position: userData[i]["position"],
        leadFunc: userData[i]["leadFunc"],
        site: userData[i]["site"],
        active: userData[i]["active"],
        siteLead: userData[i]["siteLead"],
      );

      await dbHelper.saveData(data);
    }
  }

  Future addRecurringToSqlite() async {
    await dbHelper.deleteAllEvent();
    var url = 'http://192.168.1.111/testdb/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "tasks"});
    List recurringData = json.decode(response.body);

    for (int i = 0; i < recurringData.length; i++) {
      final data = Event(
          recurringId: int.parse(recurringData[i]["id"]),
          category: recurringData[i]["category"],
          subCategory: recurringData[i]["subcategory"],
          type: recurringData[i]["type"],
          site: recurringData[i]["site"],
          task: recurringData[i]["task"],
          duration: recurringData[i]["duration"],
          priority: recurringData[i]["priority"],
          from: recurringData[i]["start"],
          to: recurringData[i]["end"],
          person: recurringData[i]["person"],
          remark: recurringData[i]["remarks"],
          recurringOpt: recurringData[i]["recurring"],
          recurringEvery: recurringData[i]["recurringGap"],
          color: recurringData[i]["color"],
          status: recurringData[i]["status"]);

      await dbHelper.addEvent(data);
    }
  }

  Future addNonRecurringToSqlite() async {
    await dbHelper.deleteAllNonRecurring();
    var url = 'http://192.168.1.111/testdb/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "nonrecurring"});
    List nonrecurringData = json.decode(response.body);

    for (int i = 0; i < nonrecurringData.length; i++) {
      final datanonRecurring = nonRecurring(
          nonRecurringId: int.parse(nonrecurringData[i]["id"]),
          category: nonrecurringData[i]["category"],
          subCategory: nonrecurringData[i]["subcategory"],
          type: nonrecurringData[i]["type"],
          site: nonrecurringData[i]["site"],
          task: nonrecurringData[i]["task"],
          owner: nonrecurringData[i]["owner"],
          startDate: nonrecurringData[i]["createdDate"].toString(),
          due: nonrecurringData[i]["deadline"].toString(),
          status: nonrecurringData[i]["status"],
          remark: nonrecurringData[i]["remarks"],
          modify: nonrecurringData[i]["lastMod"].toString(),
          completeDate: nonrecurringData[i]["completedDate"].toString(),
          checked: nonrecurringData[i]["checked"],
          personCheck: nonrecurringData[i]["personCheck"]);

      await dbHelper.addNonRecurring(datanonRecurring);
    }
  }

  Future switchToggle(toggle, id, tableName, columnName) async {
    var url = 'http://192.168.1.111/testdb/toggleSwitch.php';
    var response = await http.post(Uri.parse(url), body: {
      "dataTable": tableName,
      "id": id,
      "switch": toggle,
      "columnName": columnName
    });

    return response;
  }

// anotherways to sync
  Future addNotificationDateToSqlite() async {
    await dbHelper.deleteAllNotification();
    var url = 'http://192.168.1.111/testdb/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "notification"});
    List notificationData = json.decode(response.body);

    // for (int i = 0; i < notificationData.length; i++) {
    //   final data = NotificationModel(
    //     id: int.parse(notificationData[i]["id"]),
    //     owner: notificationData[i]["owner"],
    //     assigner: notificationData[i]["assigner"],
    //     task: notificationData[i]["task"],
    //     deadline: notificationData[i]["deadline"],
    //     type: notificationData[i]["type"],
    //     noted: notificationData[i]["noted"],
    //   );

    await dbHelper.addNotification(notificationData);
    // }
  }
}
