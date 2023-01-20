//@dart=2.9
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../model/eventDataSource.dart';
import '../../util/app_styles.dart';
import '../dialogBox/nonRecurringAdd.dart';
import '../dialogBox/nonRecurringEdit.dart';
import '../search/nonRecurring.dart';

class Teamtask extends StatefulWidget {
  List<Map<String, dynamic>> foundTeamNonRecurring;
  List<Map<String, dynamic>> lateTeamNonRecurring;
  List<Map<String, dynamic>> activeTeamNonRecurring;
  List<Map<String, dynamic>> completedTeamNonRecurring;
  String selectedUser;
  Teamtask(
      {Key key,
      this.foundTeamNonRecurring,
      this.lateTeamNonRecurring,
      this.activeTeamNonRecurring,
      this.completedTeamNonRecurring,
      this.selectedUser})
      : super(key: key);

  @override
  State<Teamtask> createState() => _TeamtaskState();
}

class _TeamtaskState extends State<Teamtask>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> foundTeamNonRecurring;
  List<Map<String, dynamic>> lateTeamNonRecurring;
  List<Map<String, dynamic>> activeTeamNonRecurring;
  List<Map<String, dynamic>> completedTeamNonRecurring;

  bool _isExpanded = false;
  AnimationController _animationController;
  double currentPageValue = 0;
  PageController controller = PageController();
  int _curr = 0;
  double screenHeight;
  @override
  void initState() {
    super.initState();
    foundTeamNonRecurring = widget.foundTeamNonRecurring;
    lateTeamNonRecurring = widget.lateTeamNonRecurring;
    activeTeamNonRecurring = widget.activeTeamNonRecurring;
    completedTeamNonRecurring = widget.completedTeamNonRecurring;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageViewItem = <Widget>[
      page('Late', screenHeight, lateTeamNonRecurring),
      page('Active', screenHeight, activeTeamNonRecurring),
      page('Completed', screenHeight, completedTeamNonRecurring),
      page('All', screenHeight, foundTeamNonRecurring),
    ];
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      if (_isExpanded) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isExpanded ? width / 1.5 : 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Styles.secondColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                List<List<Map<String, dynamic>>> results =
                                    Search().searchResult(
                                        value,
                                        widget.foundTeamNonRecurring,
                                        widget.activeTeamNonRecurring,
                                        widget.lateTeamNonRecurring,
                                        widget.completedTeamNonRecurring);

                                setState(() {
                                  lateTeamNonRecurring = results[0];
                                  activeTeamNonRecurring = results[1];
                                  completedTeamNonRecurring = results[2];
                                  foundTeamNonRecurring = results[3];
                                });
                              },
                            ))
                        : const Center(
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                  ),
                ),
                const Gap(10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Styles.bgColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: (() {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return addNonRecurring(
                              userName: widget.selectedUser, task: true);
                        });
                  }),
                  child: Ink(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Styles.secondColor,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Add Task",
                          style: TextStyle(
                              color: Styles.textColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              onPageChanged: (num) {
                setState(() {
                  _curr = num;
                });
              },
              children: pageViewItem,
            ),
          ),
        ],
      ),
    );
  }
}

Widget page(label, screenHeight, nonRecurring) {
  return Container(
    color: Styles.bgColor,
    child: Container(
      decoration: BoxDecoration(
        color: Styles.secondColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      width: double.infinity,
      height: screenHeight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Container(
                    width: 20,
                    height: 20,
                    color: label == 'Late'
                        ? Styles.latedotColor
                        : label == 'Active'
                            ? Styles.activedotColor
                            : label == 'Completed'
                                ? Styles.completeddotColor
                                : Styles.alldotColor,
                  ),
                ),
                const Gap(10),
                Text(
                  "$label (${nonRecurring.length})",
                  style: Styles.subtitle,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Container(
              height: screenHeight / 1.8,
              margin: const EdgeInsets.only(left: 20, right: 20),
              padding: const EdgeInsets.only(bottom: 20),
              child: ListView.builder(
                itemCount: nonRecurring.length,
                itemBuilder: (BuildContext context, int index) {
                  final dayLeft = daysBetween(DateTime.now(),
                      DateTime.parse(nonRecurring[index]["due"]));
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
                          offset:
                              const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: nonRecurring.isNotEmpty
                        ? Column(
                            children: [
                              ExpansionTile(
                                leading: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                title: Text(
                                  nonRecurring[index]['task'],
                                  // overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),

                                // TextField(
                                //   enabled: false,
                                //   maxLines: 1,
                                //   decoration: InputDecoration(
                                //     hintText:
                                //         'New Form - Need To Assign Someone To Add New Form - Notices - Someone Create And Richie Review - Done In Weekly Basi',
                                //     border: InputBorder.none,
                                //     hintStyle: TextStyle(
                                //         fontSize: 14,
                                //         fontWeight: FontWeight.w500,
                                //         color: Colors.black),
                                //   ),
                                // ),
                                trailing: Container(
                                    width: 90,
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
                                                    style: Styles.dayLeftToday,
                                                  )
                                                : Text(
                                                    "$dayLeft DAYS LEFT",
                                                    style: Styles.dayLeftActive,
                                                  ))),
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 20),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return editNonRecurring(
                                                        id: nonRecurring[index][
                                                                "nonRecurringId"]
                                                            .toString(),
                                                      );
                                                    });
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return editNonRecurring(
                                                        id: nonRecurring[index][
                                                                "nonRecurringId"]
                                                            .toString(),
                                                      );
                                                    });
                                              },
                                            ),
                                          ],
                                        ),
                                        const Gap(10),
                                        buildField(
                                            'Category',
                                            nonRecurring[index]['category']
                                                .split("|")[0]),
                                        const Gap(20),
                                        buildField('Sub-Category	',
                                            nonRecurring[index]['subCategory']),
                                        const Gap(20),
                                        buildField('Type',
                                            nonRecurring[index]['type']),
                                        const Gap(20),
                                        buildField('Site',
                                            nonRecurring[index]['site']),
                                        const Gap(20),
                                        buildField(
                                            'Due', nonRecurring[index]['due']),
                                        const Gap(20),
                                        buildField('Stages',
                                            nonRecurring[index]['status']),
                                        const Gap(20),
                                        buildField('Remark',
                                            nonRecurring[index]['remark']),
                                        const Gap(20),
                                        buildField('Last Mod',
                                            nonRecurring[index]['modify']),
                                        const Gap(10),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        : const Text('No data found!'),
                  );
                },
              ),
            )),
          ),
        ],
      ),
    ),
  );
}

Widget buildField(String labelText, String content) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
            width: 80, child: Text('$labelText:', style: Styles.label)),
      ),
      const Gap(10),
      Flexible(
        child: Container(
          width: 150,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
          ),
          child: Center(
              child: labelText != 'Stages'
                  ? Text(content, style: Styles.labelData)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: LinearPercentIndicator(
                          barRadius: const Radius.circular(5),
                          // width: 100.0,
                          lineHeight: 50.0,
                          percent: double.parse(content) / 100,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                          center: Text(
                            content,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    )),
        ),
      )
    ],
  );
}
