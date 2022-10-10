// ignore: file_names
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: height * 0.05, horizontal: width * 0.02),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => scaffoldKey.currentState!.openDrawer(),
                    ),
                    Text("Dashboard", style: Styles.title),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.black),
                      onPressed: () => {},
                    ),
                  ],
                ),
                const Gap(20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 100,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 60,
                              width: width * 0.15,
                              decoration: BoxDecoration(
                                color: const Color(0XFF242c28),
                                borderRadius: BorderRadius.circular(10.0),
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    // ignore: prefer_const_constructors
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.upcoming_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            alignment: Alignment.bottomRight,
                            child: Column(
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Upcoming",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      "3",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text(
                                          "Details",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onPressed: () {},
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(5),
                Card(
                  // ignore: sort_child_properties_last
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 100,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 60,
                              width: width * 0.15,
                              decoration: BoxDecoration(
                                color: const Color(0XFFe43068),
                                borderRadius: BorderRadius.circular(10.0),
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    // ignore: prefer_const_constructors
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.draw_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            alignment: Alignment.bottomRight,
                            child: Column(
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "In-Progress",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      "2",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text(
                                          "Details",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onPressed: () {},
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.all(10),
                ),
                const Gap(5),
                Card(
                  // ignore: sort_child_properties_last
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 100,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 60,
                              width: width * 0.15,
                              decoration: BoxDecoration(
                                color: const Color(0XFFf04c44),
                                borderRadius: BorderRadius.circular(10.0),
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    // ignore: prefer_const_constructors
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.warning_amber,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            alignment: Alignment.bottomRight,
                            child: Column(
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Late",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      "0",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text(
                                          "Details",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onPressed: () {},
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.all(10),
                ),
                const Gap(5),
                Card(
                  // ignore: sort_child_properties_last
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 100,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 60,
                              width: width * 0.15,
                              decoration: BoxDecoration(
                                color: const Color(0XFF54b058),
                                borderRadius: BorderRadius.circular(10.0),
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    // ignore: prefer_const_constructors
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            alignment: Alignment.bottomRight,
                            child: Column(
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Completed",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      "3",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text(
                                          "Details",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onPressed: () {},
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.all(10),
                ),
              ],
            ),
          ),
        ));
  }
}
