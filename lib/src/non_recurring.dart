import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/src/accordion/task.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/eventDataSource.dart';
import '../model/manageUser.dart';
import 'accordion/teamTask.dart';

class NonRecurring extends StatefulWidget {
  const NonRecurring({super.key});

  @override
  State<NonRecurring> createState() => _NonRecurringState();
}

class _NonRecurringState extends State<NonRecurring> {
  List<Map<String, dynamic>> allNonRecurring = [];
  List<Map<String, dynamic>> foundNonRecurring = [];
  List<Map<String, dynamic>> LatenonRecurring = [];
  List<Map<String, dynamic>> ActivenonRecurring = [];
  List<Map<String, dynamic>> CompletednonRecurring = [];
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  String completedTask = '0';
  String totalTasks = '0';
  String overdueTasks = '0';
  String completedTasksPer = '0';
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    final data = await dbHelper.fetchAllNonRecurring();

    final SharedPreferences sp = await _pref;
    String userID = sp.getInt("user_id").toString();
    setState(() {
      for (int x = 0; x < data.length; x++) {
        if (data[x]["owner"] == userID) {
          final dayLeft = daysBetween(DateTime.parse(data[x]["startDate"]),
              DateTime.parse(data[x]["due"]));
          allNonRecurring.add(data[x]);
          foundNonRecurring.add(data[x]);
          if (data[x]["status"] == '100') {
            CompletednonRecurring.add(data[x]);
          } else if (dayLeft.isNegative) {
            LatenonRecurring.add(data[x]);
          } else if (dayLeft > 0) {
            ActivenonRecurring.add(data[x]);
          }
        }
      }
      completedTask = CompletednonRecurring.length.toString();
      overdueTasks = LatenonRecurring.length.toString();
      totalTasks = allNonRecurring.length.toString();

      if (completedTask != '0') {
        completedTasksPer =
            ((int.parse(completedTask) / int.parse(totalTasks)) * 100)
                .toStringAsFixed(0)
                .toString();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    allNonRecurring = [];
    foundNonRecurring = [];
    LatenonRecurring = [];
    ActivenonRecurring = [];
    CompletednonRecurring = [];
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
                      Text(completedTasksPer + "%",
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
                      Task(
                          allNonRecurring: allNonRecurring,
                          foundNonRecurring: foundNonRecurring,
                          LatenonRecurring: LatenonRecurring,
                          ActivenonRecurring: ActivenonRecurring,
                          CompletednonRecurring: CompletednonRecurring),
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
