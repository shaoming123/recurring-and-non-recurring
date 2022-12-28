import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/notification.dart';
import 'package:ipsolution/src/dashboard.dart';
import 'package:ipsolution/src/recurrring.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/app_styles.dart';
import '../util/checkInternet.dart';
import '../util/conMysql.dart';
import 'non_recurring.dart';
import 'notificationList.dart';

class Appbar extends StatefulWidget {
  String title;
  GlobalKey<ScaffoldState> scaffoldKey;
  Appbar({super.key, required this.title, required this.scaffoldKey});

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  List<NotificationModel> notification = [];
  DbHelper dbHelper = DbHelper();
  @override
  void initState() {
    super.initState();
    getNotification();
  }

  Future<void> getNotification() async {
    final SharedPreferences sp = await _pref;
    final data = await dbHelper.fetchAllNotification();
    if (mounted) {
      setState(() {
        for (var item in data) {
          if (item["owner"] == sp.getString("user_name")) {
            notification.add(NotificationModel.fromMap(item));
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    notification = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () => widget.scaffoldKey.currentState!.openDrawer(),
          ),
          const Gap(20),
          Text(widget.title, style: Styles.title),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.sync,
                  color: Colors.black,
                  size: 25,
                ),
                onPressed: () async {
                  await Internet.isInternet().then((connection) async {
                    if (connection) {
                      EasyLoading.show(
                        status: 'Sync data...',
                        maskType: EasyLoadingMaskType.black,
                      );
                      await Controller().addNotificationDateToSqlite();

                      if (widget.title == "Recurring") {
                        await Controller().addRecurringToSqlite();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Recurring()),
                        );
                      } else if (widget.title == "Non-Recurring") {
                        await Controller().addNonRecurringToSqlite();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NonRecurring()),
                        );
                      } else if (widget.title == "Dashboard") {
                        await Controller().addRecurringToSqlite();
                        await Controller().addNonRecurringToSqlite();

                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Dashboard()),
                        );
                      }

                      EasyLoading.showSuccess('Done');
                    }
                  });
                },
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  notificationList(notification: notification)),
                        ),
                    child: notification.isNotEmpty
                        ? Badge(
                            badgeColor: Colors.red,
                            shape: BadgeShape.circle,
                            // borderRadius: BorderRadius.circular(5),
                            position: BadgePosition.topEnd(top: -15, end: -5),
                            padding: const EdgeInsets.all(5),
                            badgeContent: Text(
                              notification.length.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            child: const Icon(
                              Icons.notifications_none,
                              size: 25,
                            ),
                          )
                        : const Icon(
                            Icons.notifications_none,
                            size: 25,
                          )),
              ),
            ],
          ),
          // IconButton(
          //   icon: const Icon(
          //     Icons.exit_to_app,
          //     color: Colors.black,
          //     size: 25,
          //   ),
          //   onPressed: () => {
          //     Navigator.pushReplacement(context,
          //         MaterialPageRoute(builder: (context) => const Login()))
          //   },
          // ),
        ],
      ),
    );
  }
}
