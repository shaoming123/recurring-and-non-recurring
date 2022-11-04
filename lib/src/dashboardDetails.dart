import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/eventDataSource.dart';
import '../util/app_styles.dart';

class DashboardDetails extends StatefulWidget {
  final List<Map<String, dynamic>> task;
  final List<Map<String, dynamic>> nonRecurring;
  final String detailName;
  const DashboardDetails(
      {super.key,
      required this.task,
      required this.nonRecurring,
      required this.detailName});

  @override
  State<DashboardDetails> createState() => _DashboardDetailsState();
}

class _DashboardDetailsState extends State<DashboardDetails> {
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
        body: Container(
            margin: EdgeInsets.symmetric(
                vertical: height * 0.05, horizontal: width * 0.05),
            child: ListView(padding: const EdgeInsets.all(8), children: [
              ...widget.task.map((e) {
                final dayLeft =
                    daysBetween(DateTime.now(), DateTime.parse(e["toD"]));
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
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
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ExpansionTile(
                        leading: Icon(Icons.event_repeat),
                        title: Text(
                          e["task"],
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        trailing: widget.detailName != 'Completed'
                            ? Container(
                                width: 100,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: dayLeft.isNegative
                                      ? Styles.lateColor
                                      : Styles.activeColor,
                                ),
                                child: Center(
                                    child: dayLeft.isNegative
                                        ? Text(
                                            dayLeft.abs().toString() +
                                                " DAYS LATE",
                                            style: Styles.dayLeftLate,
                                          )
                                        : Text(
                                            "$dayLeft DAYS LEFT",
                                            style: Styles.dayLeftActive,
                                          )))
                            : null,
                        children: <Widget>[
                          Container(
                            width: width,
                            margin: EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(color: Color(0xFFf8f4f4)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Start Date: ${DateFormat('dd-MM-yyyy hh:mm:ss').format(DateTime.parse(e["fromD"]))}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Due Date: ${DateFormat('dd-MM-yyyy hh:mm:ss').format(DateTime.parse(e["toD"]))}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Duration: ${e["duration"]}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Assignee: ${e["person"]}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Site: ${e["site"]}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Recurring : ${e["recurringOpt"]}",
                                    style: TextStyle(color: Styles.textColor),
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
              ...widget.nonRecurring.map((e) {
                final dayLeft =
                    daysBetween(DateTime.now(), DateTime.parse(e["due"]));
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
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
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ExpansionTile(
                        leading: Icon(Icons.low_priority),
                        title: Text(
                          e["task"].toString(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        trailing: widget.detailName != 'Completed'
                            ? Container(
                                width: 100,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: dayLeft.isNegative
                                      ? Styles.lateColor
                                      : Styles.activeColor,
                                ),
                                child: Center(
                                    child: dayLeft.isNegative
                                        ? Text(
                                            dayLeft.abs().toString() +
                                                " DAYS LATE",
                                            style: Styles.dayLeftLate,
                                          )
                                        : Text(
                                            "$dayLeft DAYS LEFT",
                                            style: Styles.dayLeftActive,
                                          )))
                            : null,
                        children: <Widget>[
                          Container(
                            width: width,
                            margin: EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(color: Color(0xFFf8f4f4)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Category:  ${e["category"]}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Subcategory:  ${e["subCategory"]}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Site:  ${e["site"]}",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Status:  ${e["status"]} %",
                                    style: TextStyle(color: Styles.textColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Deadline: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(e["due"]))}",
                                    style: TextStyle(color: Styles.textColor),
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
            ])));
  }
}
