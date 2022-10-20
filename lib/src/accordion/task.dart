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
  const Task({Key? key}) : super(key: key);
  @override
  _TaskState createState() => _TaskState();
}

final textcontroller = TextEditingController();
List<String> type = <String>['Late', 'Active', 'Completed', 'All'];
String _selectedVal = "Late";
bool _showContent = false;
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

class _TaskState extends State<Task> {
  List<Map<String, dynamic>> allNonRecurring = [];
  List<Map<String, dynamic>> _foundNonRecurring = [];
  List<Map<String, dynamic>> LatenonRecurring = [];
  List<Map<String, dynamic>> ActivenonRecurring = [];
  List<Map<String, dynamic>> CompletednonRecurring = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    final data = await dbHelper.fetchAllNonRecurring();
    final SharedPreferences sp = await _pref;
    setState(() {
      allNonRecurring = data;
      _foundNonRecurring = data;

      for (int x = 0; x < data.length; x++) {
        final dayLeft = daysBetween(DateTime.parse(data[x]["startDate"]),
            DateTime.parse(data[x]["due"]));
        if (data[x]["status"] == '100') {
          CompletednonRecurring.add(data[x]);
        } else if (dayLeft.isNegative) {
          LatenonRecurring.add(data[x]);
        } else {
          ActivenonRecurring.add(data[x]);
        }
      }
    });
    sp.setString("totalTasks", _foundNonRecurring.length.toString());
    sp.setString("completedTasks", CompletednonRecurring.length.toString());
    sp.setString("overdueTasks", LatenonRecurring.length.toString());
  }

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
                                    return const addNonRecurring();
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
                                      LatenonRecurring.length.toString(),
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
                                      ActivenonRecurring.length.toString(),
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
                                      CompletednonRecurring.length.toString(),
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
                                      _foundNonRecurring.length.toString(),
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
          rows: List.generate(LatenonRecurring.length, (index) {
            final dayLeft = daysBetween(
                DateTime.parse(LatenonRecurring[index]["startDate"]),
                DateTime.parse(LatenonRecurring[index]["due"]));

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(LatenonRecurring[index]["task"])),
                DataCell(Text(
                  LatenonRecurring[index]["category"],
                )),
                DataCell(Text(
                  LatenonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  LatenonRecurring[index]["type"],
                )),
                DataCell(Text(
                  LatenonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent:
                        double.parse(LatenonRecurring[index]["status"]) / 100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      LatenonRecurring[index]["status"],
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
                      .format(DateTime.parse(LatenonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  LatenonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(LatenonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: LatenonRecurring[index]["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(
                          LatenonRecurring[index]["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: _foundNonRecurring[index]["user_id"].toString(),
              //             name: _foundNonRecurring[index]['user_name'],
              //             password: _foundNonRecurring[index]['password'],
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
          rows: List.generate(ActivenonRecurring.length, (index) {
            final dayLeft = daysBetween(
                DateTime.parse(ActivenonRecurring[index]["startDate"]),
                DateTime.parse(ActivenonRecurring[index]["due"]));
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(ActivenonRecurring[index]["task"])),
                DataCell(Text(
                  ActivenonRecurring[index]["category"],
                )),
                DataCell(Text(
                  ActivenonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  ActivenonRecurring[index]["type"],
                )),
                DataCell(Text(
                  ActivenonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent:
                        double.parse(ActivenonRecurring[index]["status"]) / 100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      ActivenonRecurring[index]["status"],
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
                              )))),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(ActivenonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  ActivenonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(
                          DateTime.parse(ActivenonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: ActivenonRecurring[index]["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(
                          ActivenonRecurring[index]["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: _foundNonRecurring[index]["user_id"].toString(),
              //             name: _foundNonRecurring[index]['user_name'],
              //             password: _foundNonRecurring[index]['password'],
              //             isEditing: false);
              //       });
              // }
            );
          })),
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
          rows: List.generate(CompletednonRecurring.length, (index) {
            final dayLeft = daysBetween(
                DateTime.parse(CompletednonRecurring[index]["startDate"]),
                DateTime.parse(CompletednonRecurring[index]["due"]));
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(CompletednonRecurring[index]["task"])),
                DataCell(Text(
                  CompletednonRecurring[index]["category"],
                )),
                DataCell(Text(
                  CompletednonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  CompletednonRecurring[index]["type"],
                )),
                DataCell(Text(
                  CompletednonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent:
                        double.parse(CompletednonRecurring[index]["status"]) /
                            100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      CompletednonRecurring[index]["status"],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
                DataCell(Center(child: Text("No Review Needed"))),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(
                          DateTime.parse(CompletednonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  CompletednonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(
                          CompletednonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: CompletednonRecurring[index]["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(
                          CompletednonRecurring[index]["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: _foundNonRecurring[index]["user_id"].toString(),
              //             name: _foundNonRecurring[index]['user_name'],
              //             password: _foundNonRecurring[index]['password'],
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
          rows: List.generate(_foundNonRecurring.length, (index) {
            final dayLeft = daysBetween(
                DateTime.parse(_foundNonRecurring[index]["startDate"]),
                DateTime.parse(_foundNonRecurring[index]["due"]));
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(_foundNonRecurring[index]["task"])),
                DataCell(Text(
                  _foundNonRecurring[index]["category"],
                )),
                DataCell(Text(
                  _foundNonRecurring[index]["subCategory"],
                )),
                DataCell(Text(
                  _foundNonRecurring[index]["type"],
                )),
                DataCell(Text(
                  _foundNonRecurring[index]["site"],
                )),
                DataCell(LinearPercentIndicator(
                    barRadius: const Radius.circular(5),
                    width: 100.0,
                    lineHeight: 20.0,
                    percent:
                        double.parse(_foundNonRecurring[index]["status"]) / 100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                      _foundNonRecurring[index]["status"],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
                DataCell(_foundNonRecurring[index]["status"] != '100'
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
                      .format(DateTime.parse(_foundNonRecurring[index]["due"]))
                      .toString(),
                )),
                DataCell(Text(
                  _foundNonRecurring[index]["remark"],
                )),
                DataCell(Text(
                  DateFormat('dd/MM/yyyy')
                      .format(
                          DateTime.parse(_foundNonRecurring[index]["modify"]))
                      .toString(),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return editNonRecurring(
                            id: _foundNonRecurring[index]["nonRecurringId"]
                                .toString(),
                          );
                        });
                  },
                )),
                DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeNonRecurring(
                          _foundNonRecurring[index]["nonRecurringId"]);
                    })),
              ],
              // onSelectChanged: (e) {
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return DialogBox(
              //             id: _foundNonRecurring[index]["user_id"].toString(),
              //             name: _foundNonRecurring[index]['user_name'],
              //             password: _foundNonRecurring[index]['password'],
              //             isEditing: false);
              //       });
              // }
            );
          })),
    );
  }
}
