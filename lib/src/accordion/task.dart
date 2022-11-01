import 'package:badges/badges.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/src/dialogBox/eventAdd.dart';
import 'package:ipsolution/src/dialogBox/eventEdit.dart';
import 'package:ipsolution/src/dialogBox/nonRecurringAdd.dart';
import 'package:ipsolution/src/dialogBox/nonRecurringEdit.dart';
import 'package:ipsolution/src/non_recurring.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/manageUser.dart';

class Task extends StatefulWidget {
  final List<Map<String, dynamic>> allNonRecurring;
  final List<Map<String, dynamic>> foundNonRecurring;
  final List<Map<String, dynamic>> LatenonRecurring;
  final List<Map<String, dynamic>> ActivenonRecurring;
  final List<Map<String, dynamic>> CompletednonRecurring;
  const Task({
    Key? key,
    required this.allNonRecurring,
    required this.foundNonRecurring,
    required this.LatenonRecurring,
    required this.ActivenonRecurring,
    required this.CompletednonRecurring,
  }) : super(key: key);
  @override
  _TaskState createState() => _TaskState();
}

final textcontroller = TextEditingController();
List<String> type = <String>['Late', 'Active', 'Completed', 'All'];
String _selectedVal = "Late";
String _selectedUser = "";
bool _showContent = false;
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

class _TaskState extends State<Task> {
  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      _selectedUser = sp.getInt("user_id")!.toString();
    });
  }

  @override
  void dispose() {
    super.dispose();

    // widget.allNonRecurring = [];
    // foundNonRecurring = [];
    // LatenonRecurring = [];
    // ActivenonRecurring = [];
    // CompletednonRecurring = [];
  }

  // void _refresh() async {
  //   final data = await dbHelper.fetchAllNonRecurring();

  //   final SharedPreferences sp = await _pref;
  //   String userID = sp.getInt("user_id").toString();
  //   setState(() {
  //     for (int x = 0; x < data.length; x++) {
  //       if (data[x]["owner"] == userID) {
  //         final dayLeft = daysBetween(DateTime.parse(data[x]["startDate"]),
  //             DateTime.parse(data[x]["due"]));
  //         allNonRecurring.add(data[x]);
  //         widget.foundNonRecurring.add(data[x]);
  //         if (data[x]["status"] == '100') {
  //            widget.CompletednonRecurring.add(data[x]);
  //         } else if (dayLeft.isNegative) {
  //            widget.LatenonRecurring.add(data[x]);
  //         } else if (dayLeft > 0) {
  //           widget.ActivenonRecurring.add(data[x]);
  //         }
  //       }
  //     }
  //   });
  // }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  Future<void> removeNonRecurring(int id) async {
    await dbHelper.deleteNonRecurring(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted!'),
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NonRecurring()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
          title: Text(
            "Task Overview",
            style:
                TextStyle(color: Styles.textColor, fontWeight: FontWeight.w700),
          ),
          trailing: IconButton(
            icon: Icon(
                _showContent ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: () {
              setState(() {
                _showContent = !_showContent;
              });
            },
          ),
          tileColor: const Color(0xFF88a4d4),
        ),
        _showContent
            ? Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Styles.bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 180,
                          height: 40,
                          child: TextFormField(
                            controller: textcontroller,
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            onChanged: (value) {
                              setState(() {
                                // _searchResult = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                              isDense: true,
                              suffixIcon:
                                  const Icon(Icons.search, color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  style: BorderStyle.none,
                                ),
                              ),
                              // filled: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
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
                                        userId: _selectedUser);
                                  });
                            }),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Ink(
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Styles.bgColor,
                                ),
                                child: Center(
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
                        ),
                      ],
                    ),
                    const Gap(20),
                    // dropdown
                    // Container(
                    //   margin: const EdgeInsets.only(bottom: 30, top: 10),
                    //   padding: const EdgeInsets.symmetric(horizontal: 15),
                    //   decoration: BoxDecoration(
                    //       border: Border.all(
                    //           color: Colors.blueGrey,
                    //           width: 1,
                    //           style: BorderStyle.solid),
                    //       borderRadius: BorderRadius.circular(8)),
                    //   child: DropdownButtonHideUnderline(
                    //     child: DropdownButton2(
                    //       iconSize: 30,
                    //       isExpanded: true,
                    //       value: _selectedVal,
                    //       items: type
                    //           .map(
                    //             (e) => DropdownMenuItem(
                    //               value: e,
                    //               child: Text(e),
                    //             ),
                    //           )
                    //           .toList(),
                    //       onChanged: (val) {
                    //         setState(() {});
                    //       },
                    //       icon: const Icon(
                    //         Icons.arrow_drop_down,
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    DefaultTabController(
                      length: 4,
                      child: SizedBox(
                        height: 500,
                        child: Column(
                          children: <Widget>[
                            TabBar(
                              indicatorColor: const Color(0xFF88a4d4),
                              indicatorWeight: 3,
                              padding: EdgeInsets.zero,
                              indicatorPadding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              labelStyle: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                              unselectedLabelStyle: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                              labelColor: const Color(0xFF88a4d4),
                              unselectedLabelColor: Colors.black,
                              tabs: <Widget>[
                                Tab(
                                  icon: Badge(
                                    badgeColor: Colors.indigo,
                                    shape: BadgeShape.square,
                                    borderRadius: BorderRadius.circular(5),
                                    position: BadgePosition.topEnd(
                                        top: -12, end: -20),
                                    padding: const EdgeInsets.all(5),
                                    badgeContent: Text(
                                      widget.LatenonRecurring.length.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text("Late"),
                                  ),
                                ),
                                Tab(
                                  icon: Badge(
                                    badgeColor: Colors.indigo,
                                    shape: BadgeShape.square,
                                    borderRadius: BorderRadius.circular(5),
                                    position: BadgePosition.topEnd(
                                        top: -12, end: -20),
                                    padding: const EdgeInsets.all(5),
                                    badgeContent: Text(
                                      widget.ActivenonRecurring.length
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text("Active"),
                                  ),
                                ),
                                Tab(
                                  icon: Badge(
                                    badgeColor: Colors.indigo,
                                    shape: BadgeShape.square,
                                    borderRadius: BorderRadius.circular(5),
                                    position: BadgePosition.topEnd(
                                        top: -12, end: -20),
                                    padding: const EdgeInsets.all(5),
                                    badgeContent: Text(
                                      widget.CompletednonRecurring.length
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text("Completed"),
                                  ),
                                ),
                                Tab(
                                  icon: Badge(
                                    badgeColor: Colors.indigo,
                                    shape: BadgeShape.square,
                                    borderRadius: BorderRadius.circular(5),
                                    position: BadgePosition.topEnd(
                                        top: -12, end: -20),
                                    padding: const EdgeInsets.all(5),
                                    badgeContent: Text(
                                      widget.foundNonRecurring.length
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text("All"),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  lateView(),
                                  activeView(),
                                  completeView(),
                                  allView(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container()
      ]),
    );
  }

  Widget lateView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF88a4d4)),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Task',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Catehory',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Sub-Category',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Type',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Site',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Stage',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Day Left',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Due',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Remark',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Last Mod.',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Action',
              textAlign: TextAlign.center,
            ))),
            DataColumn(label: Text('')),
          ],
          rows: List.generate(widget.LatenonRecurring.length, (index) {
            final dayLeft = daysBetween(DateTime.now(),
                DateTime.parse(widget.LatenonRecurring[index]["due"]));

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(widget.LatenonRecurring[index]["task"])),
                DataCell(Text(
                  widget.LatenonRecurring[index]["category"],
                )),
                DataCell(Text(
                  widget.LatenonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  widget.LatenonRecurring[index]["type"],
                )),
                DataCell(Text(
                  widget.LatenonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent:
                        double.parse(widget.LatenonRecurring[index]["status"]) /
                            100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      widget.LatenonRecurring[index]["status"],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
                DataCell(Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Styles.lateColor,
                    ),
                    child: Center(
                        child: Text(
                      "${dayLeft.abs()} DAYS LATE",
                      style: TextStyle(
                          color: Color(0xFFf43a2c),
                          fontWeight: FontWeight.bold),
                    )))),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(
                          DateTime.parse(widget.LatenonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  widget.LatenonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          widget.LatenonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: widget.LatenonRecurring[index]["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(
                          widget.LatenonRecurring[index]["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: widget.foundNonRecurring[index]["user_id"].toString(),
              //             name: widget.foundNonRecurring[index]['user_name'],
              //             password: widget.foundNonRecurring[index]['password'],
              //             isEditing: false);
              //       });
              // }
            );
          })),
    );
  }

  Widget activeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF88a4d4)),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Task',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Catehory',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Sub-Category',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Type',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Site',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Stage',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Day Left',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Due',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Remark',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Last Mod.',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Action',
              textAlign: TextAlign.center,
            ))),
            DataColumn(label: Text('')),
          ],
          rows: List.generate(widget.ActivenonRecurring.length, (index) {
            final dayLeft = daysBetween(DateTime.now(),
                DateTime.parse(widget.ActivenonRecurring[index]["due"]));
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(widget.ActivenonRecurring[index]["task"])),
                DataCell(Text(
                  widget.ActivenonRecurring[index]["category"],
                )),
                DataCell(Text(
                  widget.ActivenonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  widget.ActivenonRecurring[index]["type"],
                )),
                DataCell(Text(
                  widget.ActivenonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent: double.parse(
                            widget.ActivenonRecurring[index]["status"]) /
                        100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      widget.ActivenonRecurring[index]["status"],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
                DataCell(Container(
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
                                dayLeft.abs().toString() + " DAYS LATE",
                                style: Styles.dayLeftLate,
                              )
                            : Text(
                                "$dayLeft DAYS LEFT",
                                style: Styles.dayLeftActive,
                              )
                              
                              ))),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          widget.ActivenonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  widget.ActivenonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          widget.ActivenonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: widget.ActivenonRecurring[index]
                                    ["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(
                          widget.ActivenonRecurring[index]["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: widget.foundNonRecurring[index]["user_id"].toString(),
              //             name: widget.foundNonRecurring[index]['user_name'],
              //             password: widget.foundNonRecurring[index]['password'],
              //             isEditing: false);
              //       });
              // }
            );
          })
          ),
    );
  }

  Widget completeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF88a4d4)),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Task',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Catehory',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Sub-Category',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Type',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Site',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Stage',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Day Left/Checked?',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Due',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Remark',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Last Mod.',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Action',
              textAlign: TextAlign.center,
            ))),
            DataColumn(label: Text('')),
          ],
          rows: List.generate(widget.CompletednonRecurring.length, (index) {
            final dayLeft = daysBetween(DateTime.now(),
                DateTime.parse(widget.CompletednonRecurring[index]["due"]));
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(widget.CompletednonRecurring[index]["task"])),
                DataCell(Text(
                  widget.CompletednonRecurring[index]["category"],
                )),
                DataCell(Text(
                  widget.CompletednonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  widget.CompletednonRecurring[index]["type"],
                )),
                DataCell(Text(
                  widget.CompletednonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent: double.parse(
                            widget.CompletednonRecurring[index]["status"]) /
                        100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      widget.CompletednonRecurring[index]["status"],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
                DataCell(Center(child: Text("No Review Needed"))),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          widget.CompletednonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  widget.CompletednonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          widget.CompletednonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: widget.CompletednonRecurring[index]
                                    ["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(widget.CompletednonRecurring[index]
                          ["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: widget.foundNonRecurring[index]["user_id"].toString(),
              //             name: widget.foundNonRecurring[index]['user_name'],
              //             password: widget.foundNonRecurring[index]['password'],
              //             isEditing: false);
              //       });
              // }
            );
          })),
    );
  }

  Widget allView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF88a4d4)),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Task',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Catehory',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Sub-Category',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Type',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Site',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Stage',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Day Left/Check by',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Due',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Remark',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Last Mod.',
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              'Action',
              textAlign: TextAlign.center,
            ))),
            DataColumn(label: Text('')),
          ],
          rows: List.generate(widget.foundNonRecurring.length, (index) {
            final dayLeft = daysBetween(DateTime.now(),
                DateTime.parse(widget.foundNonRecurring[index]["due"]));
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(widget.foundNonRecurring[index]["task"])),
                DataCell(Text(
                  widget.foundNonRecurring[index]["category"],
                )),
                DataCell(Text(
                  widget.foundNonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  widget.foundNonRecurring[index]["type"],
                )),
                DataCell(Text(
                  widget.foundNonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent: double.parse(
                            widget.foundNonRecurring[index]["status"]) /
                        100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      widget.foundNonRecurring[index]["status"],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
                DataCell(widget.foundNonRecurring[index]["status"] != '100'
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
                                    dayLeft.abs().toString() + " DAYS LATE",
                                    style: TextStyle(
                                        color: Color(0xFFf43a2c),
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    "$dayLeft DAYS LEFT",
                                    style: Styles.dayLeftActive,
                                  )))
                    : Text("No Review Needed")),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          widget.foundNonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  widget.foundNonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          widget.foundNonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: widget.foundNonRecurring[index]
                                    ["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(
                          widget.foundNonRecurring[index]["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: widget.foundNonRecurring[index]["user_id"].toString(),
              //             name: widget.foundNonRecurring[index]['user_name'],
              //             password: widget.foundNonRecurring[index]['password'],
              //             isEditing: false);
              //       });
              // }
            );
          })),
    );
  }
}
