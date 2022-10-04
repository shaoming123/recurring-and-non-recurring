import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/src/navbar.dart';

import 'package:intl/intl.dart';
import 'dart:async';
import '../util/app_styles.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> list = <String>['One', 'Two', 'Three', 'Four'];

  String _selectedVal = "";

  DateTimeRange? _selectedDateRange;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
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
    }
  }

  Widget user() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          iconSize: 30,
          isExpanded: true,
          value: "One",
          items: list
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedVal = val as String;
            });
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: Container(
            margin: EdgeInsets.symmetric(
                vertical: height * 0.08, horizontal: width * 0.02),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => scaffoldKey.currentState!.openDrawer(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 90),
                    child: Text("Report", style: Styles.title),
                  ),
                  IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.black),
                      onPressed: () => {}),
                ],
              ),
              const Gap(20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Date:",
                                  style: TextStyle(
                                      color: Styles.textColor, fontSize: 14),
                                ),
                                Text(
                                    " ${DateFormat.yMMMMd('en_US').format(startDate).toString()}  -  ${DateFormat.yMMMMd('en_US').format(endDate).toString()}"),
                              ],
                            ),
                            IconButton(
                                icon: Icon(Icons.calendar_month),
                                onPressed: () async {
                                  _show();
                                }),
                          ],
                        ),
                        const Gap(30),
                        Text(
                          "Users",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14),
                        ),
                        const Gap(10),
                        user(),
                        Text(
                          "Function",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14),
                        ),
                        const Gap(10),
                        user(),
                        Text(
                          "Site",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14),
                        ),
                        const Gap(10),
                        user(),
                        const Gap(10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(150, 50),
                                  maximumSize: const Size(150, 50),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: (() {}),
                              child: Ink(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Styles.buttonColor,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Generate",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ])));
  }
}
