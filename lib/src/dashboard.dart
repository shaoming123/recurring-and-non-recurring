//@dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/CloneHelper.dart';

import 'package:ipsolution/src/dashboardDetails.dart';
import 'package:ipsolution/src/footer.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/checkInternet.dart';
import '../util/cloneData.dart';
import 'appbar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key key,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  List<Map<String, dynamic>> completed = [];
  List<Map<String, dynamic>> late = [];
  List<Map<String, dynamic>> progress = [];
  List<Map<String, dynamic>> upcoming = [];

  List<Map<String, dynamic>> completedNon = [];
  List<Map<String, dynamic>> lateNon = [];
  List<Map<String, dynamic>> progressNon = [];
  List<Map<String, dynamic>> upcomingNon = [];
  DateTime dateNow = DateTime.now();
  DateTime startDate;
  DateTime endDate;
  bool isOnline;
  CloneHelper cloneHelper = CloneHelper();
  @override
  void initState() {
    super.initState();

    startDate = DateTime(dateNow.year, dateNow.month, 1);
    endDate = DateTime(dateNow.year, dateNow.month + 1, 0);

    refresh();
  }

  Future<void> refresh() async {
    isOnline = await Internet.isInternet();
    // final data = await CloneHelper().fetchNonrecurringData();
    // print(data.length);

    final SharedPreferences sp = await _pref;
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    // if (isOnline) {
    //   await cloneHelper.initDb();
    // }
    final taskData = isOnline
        ? await Controller().getOnlineRecurring()
        : await cloneHelper.fetchRecurringData();
    final nonRecurringData = isOnline
        ? await Controller().getOnlineNonRecurring()
        : await cloneHelper.fetchNonrecurringData();
    EasyLoading.showSuccess('Done');
    completed = [];
    late = [];
    progress = [];
    upcoming = [];

    completedNon = [];
    lateNon = [];
    progressNon = [];
    upcomingNon = [];

    String userName = sp.getString("user_name");
    String username = sp.getString("user_name");
    List<String> personList = [];

    setState(() {
      for (int x = 0; x < taskData.length; x++) {
        personList = taskData[x]["person"].split(',');

        for (int i = 0; i < personList.length; i++) {
          if (personList[i] == username) {
            DateTime dateStart = DateTime.now(); //YOUR DATE GOES HERE
            DateTime dateEnd = DateTime.parse(taskData[x]["end"]);
            bool isValidDate = dateStart.isBefore(dateEnd) ||
                DateFormat.yMd().format(dateStart) ==
                    DateFormat.yMd().format(dateEnd);

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
              if (taskData[x]["status"] == "Done") {
                completed.add(taskData[x]);
              } else if (isValidDate == false) {
                late.add(taskData[x]);
              } else if (taskData[x]["status"] == "In Progress") {
                progress.add(taskData[x]);
              } else {
                upcoming.add(taskData[x]);
              }
            }
          }
        }
      }

      for (int x = 0; x < nonRecurringData.length; x++) {
        if (nonRecurringData[x]["owner"] == userName) {
          DateTime dateStart = DateTime.now(); //YOUR DATE GOES HERE
          DateTime dateEnd = DateTime.parse(nonRecurringData[x]["deadline"]);
          bool isValidDate = dateStart.isBefore(dateEnd) ||
              DateFormat.yMd().format(dateStart) ==
                  DateFormat.yMd().format(dateEnd); // YOUR DATE GOES HERE
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
            if (nonRecurringData[x]["status"] == "100") {
              completedNon.add(nonRecurringData[x]);
            } else if (isValidDate == false) {
              lateNon.add(nonRecurringData[x]);
            } else if (int.parse(nonRecurringData[x]["status"]) > 0) {
              progressNon.add(nonRecurringData[x]);
            } else {
              upcomingNon.add(nonRecurringData[x]);
            }
          }
        }
      }
    });
  }

  void _show() async {
    final DateTimeRange result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 50),
      lastDate: DateTime(DateTime.now().year + 50),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      setState(() {
        startDate = result.start;
        endDate = result.end;
      });

      refresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
    completed = [];
    late = [];
    progress = [];
    upcoming = [];

    completedNon = [];
    lateNon = [];
    progressNon = [];
    upcomingNon = [];
  }

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
                vertical: height * 0.08, horizontal: width * 0.02),
            child: Column(
              children: [
                Appbar(title: "Dashboard", scaffoldKey: scaffoldKey),
                GestureDetector(
                  onTap: () {
                    _show();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.calendar_month),
                        Text(
                          "${DateFormat.yMMMMd('en_US').format(startDate).toString()} - ${DateFormat.yMMMMd('en_US').format(endDate).toString()}",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
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
                                Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Upcoming",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      (upcoming.length + upcomingNon.length)
                                          .toString(),
                                      style: const TextStyle(
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DashboardDetails(
                                                      task: upcoming,
                                                      nonRecurring: upcomingNon,
                                                      detailName: 'Upcoming',
                                                    )),
                                          );
                                        },
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
                                Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "In Progress",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      (progress.length + progressNon.length)
                                          .toString(),
                                      style: const TextStyle(
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DashboardDetails(
                                                      task: progress,
                                                      nonRecurring: progressNon,
                                                      detailName: 'In Progress',
                                                    )),
                                          );
                                        },
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
                                Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Late",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      (late.length + lateNon.length).toString(),
                                      style: const TextStyle(
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DashboardDetails(
                                                      task: late,
                                                      nonRecurring: lateNon,
                                                      detailName: 'Late',
                                                    )),
                                          );
                                        },
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
                                Expanded(
                                  flex: 5,
                                  child: ListTile(
                                    title: const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Completed",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    subtitle: Text(
                                      (completed.length + completedNon.length)
                                          .toString(),
                                      style: const TextStyle(
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DashboardDetails(
                                                      task: completed,
                                                      nonRecurring:
                                                          completedNon,
                                                      detailName: 'Completed',
                                                    )),
                                          );
                                        },
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
                const Footer()
              ],
            ),
          ),
        ));
  }
}
