import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';
import 'navbar.dart';
import '../util/app_styles.dart';
import 'notificationList.dart';

class Appbar extends StatefulWidget {
  String title;
  GlobalKey<ScaffoldState> scaffoldKey;
  Appbar({super.key, required this.title, required this.scaffoldKey});

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
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
    setState(() {
      for (var item in data) {
        if (item["owner"] == sp.getString("user_name")) {
          notification.add(NotificationModel.fromMap(item));
        }
      }
    });
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
          Text(widget.title, style: Styles.title),
          Container(
            margin: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        notificationList(notification: notification)),
              ),
              child: Badge(
                badgeColor: Colors.red,
                shape: BadgeShape.circle,
                // borderRadius: BorderRadius.circular(5),
                position: BadgePosition.topEnd(top: -15, end: -5),
                padding: const EdgeInsets.all(5),
                badgeContent: Text(
                  notification.length.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                child: Icon(
                  Icons.notifications_none,
                  size: 25,
                ),
              ),
            ),
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
