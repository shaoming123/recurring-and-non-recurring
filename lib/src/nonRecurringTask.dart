//@dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'dart:async';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/CloneHelper.dart';
import 'package:ipsolution/src/card/task.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/src/nonRecurringTeam.dart';
import 'package:ipsolution/src/popFilter.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/eventDataSource.dart';
import '../util/checkInternet.dart';
import '../util/cloneData.dart';
import 'appbar.dart';

class NonRecurring extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  const NonRecurring({Key key, this.start, this.end}) : super(key: key);

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
  // DbHelper dbHelper = DbHelper();
  CloneHelper cloneHelper = CloneHelper();
  List<Map<String, dynamic>> allNonRecurring = [];
  List<Map<String, dynamic>> foundNonRecurring = [];
  List<Map<String, dynamic>> LatenonRecurring = [];
  List<Map<String, dynamic>> ActivenonRecurring = [];
  List<Map<String, dynamic>> CompletednonRecurring = [];
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime(DateTime.now().year + 1, 1, 0);
  String userRole = 'Staff';

  // bool _isExpanded = true;
  @override
  void initState() {
    super.initState();

    _refresh();
    if (widget.start != null && widget.end != null) {
      startDate = widget.start;
      endDate = widget.end;
    }
  }

  Future<void> _refresh() async {
    List data = [];
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    await Internet.isInternet().then((connection) async {
      if (connection) {
        data = await Controller().getOnlineNonRecurring();
      } else {
        data = await cloneHelper.fetchNonrecurringData();
      }
    });

    EasyLoading.showSuccess('Done');
    // List data;
    // final data = await Controller().getNonRecurring();

    final SharedPreferences sp = await _pref;
    String userName = sp.getString("user_name");
    // allNonRecurring = [];
    // foundNonRecurring = [];
    // LatenonRecurring = [];
    // ActivenonRecurring = [];
    // CompletednonRecurring = [];

    setState(() {
      userRole = sp.getString("role");
      if (data.isNotEmpty) {
        for (int x = 0; x < data.length; x++) {
          if (data[x]["owner"] == userName) {
            DateTime dateEnd = DateTime.parse(data[x]["deadline"]);
            final dayLeft = daysBetween(
                DateTime.now(), DateTime.parse(data[x]["deadline"]));
            if ((dateEnd.isAfter(startDate) ||
                    DateFormat.yMd()
                            .format(dateEnd)
                            .compareTo(DateFormat.yMd().format(startDate)) ==
                        0) &&
                (dateEnd.isBefore(endDate) ||
                    DateFormat.yMd()
                            .format(dateEnd)
                            .compareTo(DateFormat.yMd().format(endDate)) ==
                        0)) {
              final dayLeft = daysBetween(
                  DateTime.parse(
                      DateFormat('yyyy-MM-dd').format(DateTime.now())),
                  DateTime.parse(data[x]["deadline"]));
              allNonRecurring.add(data[x]);

              foundNonRecurring.add(data[x]);

              if (data[x]["status"] == '100') {
                CompletednonRecurring.add(data[x]);
              } else if (dayLeft.isNegative) {
                data[x]["dayLeft"] = dayLeft;
                LatenonRecurring.add(data[x]);
              } else if (dayLeft >= 0) {
                data[x]["dayLeft"] = dayLeft;
                ActivenonRecurring.add(data[x]);
              }
            }
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
      } else {
        print('Error');
      }
    });
    LatenonRecurring.sort((a, b) => a['dayLeft'].compareTo(b['dayLeft']));
    ActivenonRecurring.sort((a, b) => a['dayLeft'].compareTo(b['dayLeft']));
  }

  Future<void> _show() async {
    final DateTimeRange result = await showDateRangePicker(
      context: context,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate, end: endDate)
          : null,
      firstDate: DateTime(DateTime.now().year - 50),
      lastDate: DateTime(DateTime.now().year + 50),
      saveText: 'Done',
    );

    if (result != null) {
      setState(() {
        startDate = result.start;
        endDate = result.end;
      });
      _refresh();
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  NonRecurring(start: startDate, end: endDate)));
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   allNonRecurring = [];
  //   foundNonRecurring = [];
  //   LatenonRecurring = [];
  //   ActivenonRecurring = [];
  //   CompletednonRecurring = [];
  // }

  // RefreshIndicator(
  //         onRefresh: _show,

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: Container(
          height: height - height * 0.10,
          margin: EdgeInsets.only(
              top: height * 0.08, left: width * 0.02, right: width * 0.02),
          child: Column(
            children: [
              Appbar(title: "Non-Recurring", scaffoldKey: scaffoldKey),
              // const Gap(5),
              GestureDetector(
                onTap: () {
                  _show();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.calendar_month, size: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "${DateFormat.yMMMMd('en_US').format(startDate).toString()} - ${DateFormat.yMMMMd('en_US').format(endDate).toString()}",
                              style: TextStyle(
                                  color: Styles.textColor, fontSize: 12),
                            ),
                            const Gap(15),
                            const PopFilter(task: 'ownTasks')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      Text("Total ",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
                      const Gap(5),
                      Text(totalTasks,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Completed",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
                      const Gap(5),
                      Text("$completedTasksPer%",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Overdue",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
                      const Gap(5),
                      Text(overdueTasks,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Pending",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
                      Text("Review",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 12)),
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
                child: Container(
                  color: Styles.bgColor,
                  // margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Task(
                    foundNonRecurring: foundNonRecurring,
                    latenonRecurring: LatenonRecurring,
                    activenonRecurring: ActivenonRecurring,
                    completednonRecurring: CompletednonRecurring,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
