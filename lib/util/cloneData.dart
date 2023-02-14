//@dart=2.9
import 'dart:convert';

import 'package:http/http.dart' as http;

// final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
// int i = 0;

class Controller {
  // Future addDataToSqlite() async {
  //   await dbHelper.deleteAllUser();
  //   var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

  //   var response =
  //       await http.post(Uri.parse(url), body: {"tableName": "user_details"});
  //   List userData = json.decode(response.body);

  //   for (int i = 0; i < userData.length; i++) {
  //     final data = UserModel(
  //         user_id: int.parse(userData[i]["id"]),
  //         user_name: userData[i]["username"],
  //         password: userData[i]["password"],
  //         email: userData[i]["email"],
  //         role: userData[i]["role"],
  //         position: userData[i]["position"],
  //         leadFunc: userData[i]["leadFunc"],
  //         site: userData[i]["site"],
  //         active: userData[i]["active"],
  //         siteLead: userData[i]["siteLead"],
  //         filepath: userData[i]["filepath"]);

  //     await dbHelper.saveData(data);
  //   }
  // }

  // Future addRecurringToSqlite() async {
  //   await dbHelper.deleteAllEvent();
  //   var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

  //   var response =
  //       await http.post(Uri.parse(url), body: {"tableName": "tasks"});
  //   List recurringData = json.decode(response.body);

  //   for (int i = 0; i < recurringData.length; i++) {
  //     final data = Event(
  //         // recurringId: int.parse(recurringData[i]["id"]),
  //         category: recurringData[i]["category"],
  //         subCategory: recurringData[i]["subcategory"],
  //         type: recurringData[i]["type"],
  //         site: recurringData[i]["site"],
  //         task: recurringData[i]["task"],
  //         duration: recurringData[i]["duration"],
  //         priority: recurringData[i]["priority"],
  //         date: recurringData[i]["date"],
  //         deadline: recurringData[i]["deadline"],
  //         startTime: recurringData[i]["startTime"],
  //         dueTime: recurringData[i]["dueTime"],
  //         from: recurringData[i]["start"],
  //         to: recurringData[i]["end"],
  //         person: recurringData[i]["person"],
  //         remark: recurringData[i]["remarks"],
  //         recurringOpt: recurringData[i]["recurring"],
  //         recurringEvery: recurringData[i]["recurringGap"],
  //         color: recurringData[i]["color"],
  //         status: recurringData[i]["status"],
  //         uniqueNumber: recurringData[i]["unique"],
  //         dependent: recurringData[i]["dependent"],
  //         completeDate: recurringData[i]["completedDate"],
  //         checkRecurring: "false");

  //     await dbHelper.addEvent(data);
  //   }
  // }

  // Future addNonRecurringToSqlite() async {
  //   await dbHelper.deleteAllNonRecurring();
  //   var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

  //   var response =
  //       await http.post(Uri.parse(url), body: {"tableName": "nonrecurring"});
  //   List nonrecurringData = json.decode(response.body);

  //   for (int i = 0; i < nonrecurringData.length; i++) {
  //     final datanonRecurring = nonRecurring(
  //         nonRecurringId: int.parse(nonrecurringData[i]["id"]),
  //         category: nonrecurringData[i]["category"],
  //         subCategory: nonrecurringData[i]["subcategory"],
  //         type: nonrecurringData[i]["type"],
  //         site: nonrecurringData[i]["site"],
  //         task: nonrecurringData[i]["task"],
  //         owner: nonrecurringData[i]["owner"],
  //         startDate: nonrecurringData[i]["createdDate"].toString(),
  //         due: nonrecurringData[i]["deadline"].toString(),
  //         status: nonrecurringData[i]["status"],
  //         remark: nonrecurringData[i]["remarks"],
  //         modify: nonrecurringData[i]["lastMod"].toString(),
  //         completeDate: nonrecurringData[i]["completedDate"].toString(),
  //         checked: nonrecurringData[i]["checked"],
  //         personCheck: nonrecurringData[i]["personCheck"]);

  //     await dbHelper.addNonRecurring(datanonRecurring);
  //   }
  // }

  Future switchToggle(toggle, id, tableName, columnName) async {
    var url =
        'https://ipsolutions4u.com/ipsolutions/recurringMobile/toggleSwitch.php';
    var response = await http.post(Uri.parse(url), body: {
      "dataTable": tableName,
      "id": id,
      "switch": toggle,
      "columnName": columnName
    });

    return response;
  }

// anotherways to sync
  // Future addNotificationDateToSqlite() async {
  //   await dbHelper.deleteAllNotification();
  //   var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

  //   var response =
  //       await http.post(Uri.parse(url), body: {"tableName": "notification"});
  //   List notificationData = json.decode(response.body);

  //   // for (int i = 0; i < notificationData.length; i++) {
  //   //   final data = NotificationModel(
  //   //     id: int.parse(notificationData[i]["id"]),
  //   //     owner: notificationData[i]["owner"],
  //   //     assigner: notificationData[i]["assigner"],
  //   //     task: notificationData[i]["task"],
  //   //     deadline: notificationData[i]["deadline"],
  //   //     type: notificationData[i]["type"],
  //   //     noted: notificationData[i]["noted"],
  //   //   );

  //   await dbHelper.addNotification(notificationData);
  //   // }
  // }

  // Get online data

  Future getOnlineUser() async {
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

    var response =
        await http.post(Uri.parse(url), body: {"tableName": "user_details"});
    List userData = json.decode(response.body);

    return userData;
  }

  Future<List> getOnlineNonRecurring() async {
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

    var response =
        await http.post(Uri.parse(url), body: {"tableName": "nonrecurring"});
    List nonrecurringData = json.decode(response.body);

    return nonrecurringData;
  }

  Future<List> getOnlineRecurring() async {
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

    var response =
        await http.post(Uri.parse(url), body: {"tableName": "tasks"});

    List recurringData = json.decode(response.body);

    return recurringData;
  }

  Future<List> getOnlineNotification() async {
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';

    var response =
        await http.post(Uri.parse(url), body: {"tableName": "notification"});
    List notificationData = json.decode(response.body);

    return notificationData;
  }

// Single Online
  Future getAOnlineUser(int id) async {
    var url =
        'https://ipsolutions4u.com/ipsolutions/recurringMobile/readSingle.php';
    var response = await http.post(Uri.parse(url),
        body: {"tableName": "user_details", "id": id.toString()});
    var userData = [];
    if (response.body.isNotEmpty) {
      var data = json.decode(response.body);
      if (data is Map) {
        userData.add(data);
      }
    } else {
      userData = [];
    }

    return userData;
  }

  Future getAOnlineRecurring(int id) async {
    var url =
        'https://ipsolutions4u.com/ipsolutions/recurringMobile/readSingle.php';

    var response = await http.post(Uri.parse(url),
        body: {"tableName": "tasks", "id": id.toString()});

    var recurringData = [];
    if (response.body.isNotEmpty) {
      var data = json.decode(response.body);
      if (data is Map) {
        recurringData.add(data);
      }
    } else {
      recurringData = [];
    }

    return recurringData;
  }

  Future getAOnlineNonRecurring(int id) async {
    var url =
        'https://ipsolutions4u.com/ipsolutions/recurringMobile/readSingle.php';

    var response = await http.post(Uri.parse(url),
        body: {"tableName": "nonrecurring", "id": id.toString()});

    var nonrecurringData = [];
    if (response.body.isNotEmpty) {
      var data = json.decode(response.body);
      if (data is Map) {
        nonrecurringData.add(data);
      }
    } else {
      nonrecurringData = [];
    }

    return nonrecurringData;
  }
}
