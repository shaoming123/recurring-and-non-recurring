//@dart=2.9
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/src/accordion/task.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../databaseHandler/DbHelper.dart';
import '../model/eventDataSource.dart';
import 'appbar.dart';
import 'accordion/teamTask.dart';
import 'footer.dart';

class NonRecurring extends StatefulWidget {
  const NonRecurring({Key key}) : super(key: key);

  @override
  State<NonRecurring> createState() => _NonRecurringState();
}

class _NonRecurringState extends State<NonRecurring> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  String completedTask = '0';
  String totalTasks = '0';
  String overdueTasks = '0';
  String completedTasksPer = '0';
  String requestReviewNumber = '0';
  String pendingReviewNumber = '0';
  int requestReview = 0;
  int pendingReview = 0;
  bool arrowChange = false;
  DbHelper dbHelper = DbHelper();
  List<Map<String, dynamic>> allNonRecurring = [];
  List<Map<String, dynamic>> foundNonRecurring = [];
  List<Map<String, dynamic>> LatenonRecurring = [];
  List<Map<String, dynamic>> ActivenonRecurring = [];
  List<Map<String, dynamic>> CompletednonRecurring = [];
  String userRole = 'Staff';
  // DateTime dateNow = DateTime.now();
  // DateTime startDate;
  // DateTime endDate;
  // bool _isExpanded = true;
  @override
  void initState() {
    super.initState();
    // startDate = DateTime(dateNow.year, 1, 1);
    // endDate = DateTime(dateNow.year + 1, 1, 0);
    _refresh();
  }

  Future<void> _refresh() async {
    final data = await dbHelper.fetchAllNonRecurring();

    final SharedPreferences sp = await _pref;
    String userName = sp.getString("user_name");
    // allNonRecurring = [];
    // foundNonRecurring = [];
    // LatenonRecurring = [];
    // ActivenonRecurring = [];
    // CompletednonRecurring = [];
    setState(() {
      userRole = sp.getString("role");

      for (int x = 0; x < data.length; x++) {
        if (data[x]["owner"] == userName) {
          // DateTime dateEnd = DateTime.parse(data[x]["due"]);

          // if ((dateEnd.isAfter(startDate) ||
          //         DateFormat.yMd()
          //                 .format(dateEnd)
          //                 .compareTo(DateFormat.yMd().format(startDate)) ==
          //             0) &&
          //     (dateEnd.isBefore(endDate) ||
          //         DateFormat.yMd()
          //                 .format(dateEnd)
          //                 .compareTo(DateFormat.yMd().format(endDate)) ==
          //             0)) {
          final dayLeft = daysBetween(
              DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())),
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
          // }
        }

        if (data[x]["checked"] == "Pending Review" &&
            data[x]["status"] == '100') {
          List personList = data[x]['personCheck'].split(",");

          for (int i = 0; i < personList.length; i++) {
            if (personList[i] == userName) {
              requestReview = requestReview + 1;
            }
          }
          if (data[x]["owner"] == userName) {
            pendingReview = pendingReview + 1;
          }
        }
      }

      completedTask = CompletednonRecurring.length.toString();
      overdueTasks = LatenonRecurring.length.toString();
      totalTasks = allNonRecurring.length.toString();
      requestReviewNumber = requestReview.toString();
      pendingReviewNumber = pendingReview.toString();
      if (completedTask != '0') {
        completedTasksPer =
            ((int.parse(completedTask) / int.parse(totalTasks)) * 100)
                .toStringAsFixed(0)
                .toString();
      }
    });
  }

  // void _show() async {
  //   final DateTimeRange result = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(DateTime.now().year - 50),
  //     lastDate: DateTime(DateTime.now().year + 50),
  //     currentDate: DateTime.now(),
  //     saveText: 'Done',
  //   );

  //   if (result != null) {
  //     setState(() {
  //       startDate = result.start;
  //       endDate = result.end;
  //     });
  //     await _refresh();
  //   }
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   allNonRecurring = [];
  //   foundNonRecurring = [];
  //   LatenonRecurring = [];
  //   ActivenonRecurring = [];
  //   CompletednonRecurring = [];
  // }

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
            height: height - height * 0.10,
            margin: EdgeInsets.only(
                top: height * 0.08,
                bottom: height * 0.02,
                left: width * 0.02,
                right: width * 0.02),
            child: Column(
              children: [
                Appbar(title: "Non-Recurring", scaffoldKey: scaffoldKey),
                const Gap(5),
                // GestureDetector(
                //   onTap: () {
                //     _show();
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 10),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         const Icon(Icons.calendar_month, size: 15),
                //         Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //           child: Text(
                //             "${DateFormat.yMMMMd('en_US').format(startDate).toString()} - ${DateFormat.yMMMMd('en_US').format(endDate).toString()}",
                //             style: TextStyle(
                //                 color: Styles.textColor, fontSize: 12),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const Gap(15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        Text("Total ",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        Text("Tasks",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        const Gap(5),
                        Text(totalTasks,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                      ]),
                      Column(children: [
                        Text("Completed",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        Text("Tasks",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        const Gap(5),
                        Text("$completedTasksPer%",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                      ]),
                      Column(children: [
                        Text("Overdue",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        Text("Tasks",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        const Gap(5),
                        Text(overdueTasks,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                      ]),
                      Column(children: [
                        Text("Pending",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        Text("Review",
                            style: TextStyle(
                                color: Styles.textColor, fontSize: 12)),
                        const Gap(5),
                        Text(pendingReviewNumber,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                      ]),
                      userRole == 'Staff'
                          ? Container()
                          : Column(children: [
                              Text("Request",
                                  style: TextStyle(
                                      color: Styles.textColor, fontSize: 12)),
                              Text("Review",
                                  style: TextStyle(
                                      color: Styles.textColor, fontSize: 12)),
                              const Gap(5),
                              Text(requestReviewNumber,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700)),
                            ])
                    ],
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF88a4d4),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                // ignore: prefer_const_constructors
                                offset: const Offset(
                                    0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: const Text("Task Overview",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                // key: PageStorageKey<Task>(Task),
                                maintainState: true,

                                children: <Widget>[
                                  Task(
                                    allNonRecurring: allNonRecurring,
                                    foundNonRecurring: foundNonRecurring,
                                    LatenonRecurring: LatenonRecurring,
                                    ActivenonRecurring: ActivenonRecurring,
                                    CompletednonRecurring:
                                        CompletednonRecurring,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(20),
                        userRole != 'Staff'
                            ? Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF88a4d4),
                                  borderRadius: BorderRadius.circular(10),
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
                                child: Column(
                                  children: const [
                                    ExpansionTile(
                                      maintainState: true,
                                      title: Text(
                                        "Team Status Overview",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      children: [TeamTask()],
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        const Footer()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
