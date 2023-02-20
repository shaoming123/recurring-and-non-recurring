//@dart=2.9
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';

import 'package:ipsolution/model/notification.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../databaseHandler/Clone2Helper.dart';
import '../databaseHandler/CloneHelper.dart';
import '../util/app_styles.dart';

import '../util/checkInternet.dart';
import '../util/cloneData.dart';
import 'notificationList.dart';

class Appbar extends StatefulWidget {
  String title;
  GlobalKey<ScaffoldState> scaffoldKey;
  Appbar({Key key, this.title, this.scaffoldKey}) : super(key: key);

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  List notification = [];
  // DbHelper dbHelper = DbHelper();
  CloneHelper cloneHelper = CloneHelper();
  Clone2Helper clone2Helper = Clone2Helper();
  @override
  void initState() {
    super.initState();
    getNotification();
  }

  Future<List> getNotification() async {
    final SharedPreferences sp = await _pref;
    bool isOnline = await Internet.isInternet();

    final data = isOnline
        ? await Controller().getOnlineNotification()
        : await clone2Helper.fetchNotificationData();

    notification = [];
    if (mounted) {
      setState(() {
        for (var item in data) {
          if (item["owner"] == sp.getString("user_name")) {
            notification.add(NotificationModel.fromMap(item));
          }
        }
      });
    }

    return notification;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () => widget.scaffoldKey.currentState.openDrawer(),
          ),
          Text(widget.title, style: Styles.title),
          Row(
            children: [
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     InkWell(
              //       child:
              //           const Icon(Icons.sync, color: Colors.black, size: 20),
              //       onTap: () async {
              //         await Internet.isInternet().then((connection) async {
              //           if (connection) {
              //             EasyLoading.show(
              //               status: 'Sync data...',
              //               maskType: EasyLoadingMaskType.black,
              //             );
              //             await cloneHelper.initDb();
              //             await Controller().addDataToSqlite();
              //             await Controller().addNotificationDateToSqlite();
              //           }

              //           EasyLoading.showSuccess('Done');
              //         });
              //       },
              //     ),
              //     const Text(
              //       "Sync data",
              //       style: TextStyle(fontSize: 10),
              //     )
              //   ],
              // ),
              // const Gap(15),
              FutureBuilder<List>(
                  future: getNotification(),
                  initialData: notification,
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.hasData) {
                      List notifications = snapshot.data;

                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => notificationList(
                                    notification: notifications)),
                          ),
                          child: notifications.isNotEmpty
                              ? badge.Badge(
                                  badgeColor: Colors.red,
                                  shape: badge.BadgeShape.circle,
                                  position: badge.BadgePosition.topEnd(
                                      top: -15, end: -5),
                                  padding: const EdgeInsets.all(5),
                                  badgeContent: Text(
                                    notifications.length.toString(),
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
                                ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Icon(
                          Icons.notifications_none,
                          size: 25,
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  })
            ],
          ),
        ],
      ),
    );
  }
}
