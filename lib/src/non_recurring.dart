import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/src/accordion/task.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/manageUser.dart';
import 'accordion/teamTask.dart';

class NonRecurring extends StatefulWidget {
  const NonRecurring({super.key});

  @override
  State<NonRecurring> createState() => _NonRecurringState();
}

String completedTask = '';
String totalTasks = '';
String overdueTasks = '';
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

class _NonRecurringState extends State<NonRecurring> {
  @override
  void initState() {
    getTasksData();
    super.initState();
  }

  Future<void> getTasksData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      totalTasks = sp.getString("totalTasks")!;
      completedTask = sp.getString("completedTasks")!;
      overdueTasks = sp.getString("overdueTasks")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: Container(
          margin: EdgeInsets.only(
              top: height * 0.08, left: width * 0.02, right: width * 0.02),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => scaffoldKey.currentState!.openDrawer(),
                  ),
                  Text("Non-Recurring", style: Styles.title),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.black),
                    onPressed: () => {},
                  ),
                ],
              ),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      Text("Total ",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      Text(totalTasks,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Completed",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      Text(completedTask,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Overdue",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      Text(overdueTasks,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Pending",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Review",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      const Text("0",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ],
                ),
              ),
              const Gap(20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Task(),
                      const Gap(20),
                      const TeamTask(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
