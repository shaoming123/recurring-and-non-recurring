import 'package:flutter/material.dart';
import 'package:ipsolution/model/manageUser.dart';

import '../model/notification.dart';
import '../util/app_styles.dart';
import '../util/checkInternet.dart';
import 'package:http/http.dart' as http;

class notificationList extends StatefulWidget {
  List<NotificationModel> notification;
  notificationList({super.key, required this.notification});

  @override
  State<notificationList> createState() => _notificationListState();
}

class _notificationListState extends State<notificationList> {
  List<NotificationModel> notification = [];
  @override
  void initState() {
    super.initState();
    notification = widget.notification;
  }

  Future<void> removeNotification(int id) async {
    var url = 'http://192.168.1.111/testdb/delete.php';
    await dbHelper.deleteNotification(id);
    final response = await http.post(Uri.parse(url), body: {
      "dataTable": "notification",
      "id": id.toString(),
    });
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully deleted!'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        action: SnackBarAction(
          label: 'Dismiss',
          disabledTextColor: Colors.white,
          textColor: Colors.blue,
          onPressed: () {
            //Do whatever you want
          },
        ),
      ));

      notification = notification..removeWhere((item) => item.id == id);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => notificationList(notification: notification)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Delete Unsuccessful !"),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        action: SnackBarAction(
          label: 'Dismiss',
          disabledTextColor: Colors.white,
          textColor: Colors.blue,
          onPressed: () {
            //Do whatever you want
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Styles.textColor, //change your color here
        ),
        centerTitle: true,
        backgroundColor: Styles.bgColor,
        title: Text("Notifications", style: Styles.subtitle),
      ),
      body: ListView.separated(
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: notification.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListTile(
                  leading: Icon(notification[index].type == "Recurring"
                      ? Icons.event_repeat
                      : notification[index].type == "Non-recurring"
                          ? Icons.low_priority
                          : Icons.check_circle_outline),
                  title: Text(
                      notification[index].type == "Checking"
                          ? notification[index].assigner +
                              " request for checking"
                          : notification[index].type,
                      style: TextStyle(
                          color: Styles.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Task : ",
                                style: TextStyle(
                                    color: Styles.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(notification[index].task,
                            style: TextStyle(
                              color: Styles.textColor,
                              fontSize: 16,
                            )),
                        Row(
                          children: [
                            Text(
                                notification[index].type == "Recurring"
                                    ? "Repeat : "
                                    : notification[index].type ==
                                            "Non-recurring"
                                        ? "Deadline : "
                                        : "Date : ",
                                style: TextStyle(
                                    color: Styles.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text(notification[index].deadline,
                                style: TextStyle(
                                    color: Styles.textColor, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {},
                  // enabled: enable,
                  trailing: IconButton(
                    onPressed: () async {
                      await Internet.isInternet().then((connection) async {
                        if (connection) {
                          await removeNotification(notification[index].id);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("No Internet !"),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(20),
                            action: SnackBarAction(
                              label: 'Dismiss',
                              disabledTextColor: Colors.white,
                              textColor: Colors.blue,
                              onPressed: () {
                                //Do whatever you want
                              },
                            ),
                          ));
                        }
                      });
                    },
                    icon: Icon(Icons.cancel_rounded),
                    iconSize: 30,
                  )),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              thickness: 5,
            );
          }),
    );
  }
}
