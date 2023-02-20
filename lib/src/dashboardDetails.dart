//@dart=2.9
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../model/eventDataSource.dart';
import '../util/app_styles.dart';

class DashboardDetails extends StatefulWidget {
  final List<Map<String, dynamic>> task;
  final List<Map<String, dynamic>> nonRecurring;
  final String detailName;
  const DashboardDetails(
      {Key key, this.task, this.nonRecurring, this.detailName})
      : super(key: key);

  @override
  State<DashboardDetails> createState() => _DashboardDetailsState();
}

class _DashboardDetailsState extends State<DashboardDetails> {
  List task = [];
  List nonRecurring = [];
  @override
  void initState() {
    super.initState();
    task = widget.task;
    nonRecurring = widget.nonRecurring;
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results_one = [];
    List<Map<String, dynamic>> results_two = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results_one = widget.task;
      results_two = widget.nonRecurring;
    } else {
      results_one = widget.task
          .where((data) =>
              data["task"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      results_two = widget.nonRecurring
          .where((data) =>
              data["task"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    setState(() {
      task = results_one;
      nonRecurring = results_two;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Styles.textColor, //change your color here
          ),
          centerTitle: true,
          backgroundColor: Styles.bgColor,
          title: Text("${widget.detailName} Details", style: Styles.subtitle),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: height - height * 0.1,
            margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    _runFilter(value);
                  },
                  decoration: const InputDecoration(
                      labelText: 'Search', suffixIcon: Icon(Icons.search)),
                ),
                const Gap(20),
                Expanded(
                  child: ListView(padding: const EdgeInsets.all(8), children: [
                    ...task.map((e) {
                      final dayLeft =
                          daysBetween(DateTime.now(), DateTime.parse(e["end"]));
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              leading: const Icon(Icons.event_repeat),
                              title: Text(
                                e["task"],
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              trailing: widget.detailName != 'Completed'
                                  ? Container(
                                      width: 85,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: dayLeft.isNegative
                                            ? Styles.lateColor
                                            : dayLeft == 0
                                                ? Styles.todayColor
                                                : Styles.activeColor,
                                      ),
                                      child: Center(
                                          child: dayLeft.isNegative
                                              ? Text(
                                                  "${dayLeft.abs()} DAYS LATE",
                                                  style: Styles.dayLeftLate,
                                                )
                                              : dayLeft == 0
                                                  ? Text(
                                                      "DUE TODAY",
                                                      style:
                                                          Styles.dayLeftToday,
                                                    )
                                                  : Text(
                                                      "$dayLeft DAYS LEFT",
                                                      style:
                                                          Styles.dayLeftActive,
                                                    )))
                                  : null,
                              children: <Widget>[
                                Container(
                                  width: width,
                                  margin: const EdgeInsets.all(15),
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFf8f4f4)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Start Date: ${DateFormat('dd-MM-yyyy hh:mm:ss').format(DateTime.parse(e["start"]))}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Due Date: ${DateFormat('dd-MM-yyyy hh:mm:ss').format(DateTime.parse(e["end"]))}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Duration: ${e["duration"]}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Assignee: ${e["person"]}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Site: ${e["site"]}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Recurring : ${e["recurring"]}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    // non recurring
                    ...nonRecurring.map((e) {
                      final dayLeft = daysBetween(
                          DateTime.now(), DateTime.parse(e["deadline"]));
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              leading: const Icon(Icons.low_priority),
                              title: Text(
                                e["task"].toString(),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              trailing: widget.detailName != 'Completed'
                                  ? Container(
                                      width: 85,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: dayLeft.isNegative
                                            ? Styles.lateColor
                                            : dayLeft == 0
                                                ? Styles.todayColor
                                                : Styles.activeColor,
                                      ),
                                      child: Center(
                                          child: dayLeft.isNegative
                                              ? Text(
                                                  "${dayLeft.abs()} DAYS LATE",
                                                  style: Styles.dayLeftLate,
                                                )
                                              : dayLeft == 0
                                                  ? Text(
                                                      "DUE TODAY",
                                                      style:
                                                          Styles.dayLeftToday,
                                                    )
                                                  : Text(
                                                      "$dayLeft DAYS LEFT",
                                                      style:
                                                          Styles.dayLeftActive,
                                                    )))
                                  : null,
                              children: <Widget>[
                                Container(
                                  width: width,
                                  margin: const EdgeInsets.all(15),
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFf8f4f4)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Category:  ${e["category"]}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Subcategory:  ${e["subcategory"]}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Site:  ${e["site"]}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Status:  ${e["status"]} %",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Deadline: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(e["deadline"]))}",
                                          style: Styles.labelData,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    })
                  ]),
                ),
              ],
            ),
          ),
        ));
  }
}
