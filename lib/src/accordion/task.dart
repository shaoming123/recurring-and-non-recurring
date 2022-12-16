import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/src/dialogBox/nonRecurringAdd.dart';
import 'package:ipsolution/src/dialogBox/nonRecurringEdit.dart';
import 'package:ipsolution/src/non_recurring.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/checkInternet.dart';
import 'package:http/http.dart' as http;

class Task extends StatefulWidget {
  List<Map<String, dynamic>> allNonRecurring;
  List<Map<String, dynamic>> foundNonRecurring;
  List<Map<String, dynamic>> LatenonRecurring;
  List<Map<String, dynamic>> ActivenonRecurring;
  List<Map<String, dynamic>> CompletednonRecurring;

  Task({
    super.key,
    required this.allNonRecurring,
    required this.foundNonRecurring,
    required this.LatenonRecurring,
    required this.ActivenonRecurring,
    required this.CompletednonRecurring,
  });
  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  List<Map<String, dynamic>> allNonRecurring = [];
  List<Map<String, dynamic>> foundNonRecurring = [];
  List<Map<String, dynamic>> LatenonRecurring = [];
  List<Map<String, dynamic>> ActivenonRecurring = [];
  List<Map<String, dynamic>> CompletednonRecurring = [];
  List<String> type = <String>['Late', 'Active', 'Completed', 'All'];

  String _selectedUser = "";
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  TextEditingController? textcontroller;
  @override
  void initState() {
    super.initState();
    textcontroller = TextEditingController();
    foundNonRecurring = widget.foundNonRecurring;
    LatenonRecurring = widget.LatenonRecurring;
    ActivenonRecurring = widget.ActivenonRecurring;
    CompletednonRecurring = widget.CompletednonRecurring;
    getUserId();
  }

  Future<void> getUserId() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      _selectedUser = sp.getString("user_name")!;
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
  //         foundNonRecurring.add(data[x]);
  //         if (data[x]["status"] == '100') {
  //            CompletednonRecurring.add(data[x]);
  //         } else if (dayLeft.isNegative) {
  //            LatenonRecurring.add(data[x]);
  //         } else if (dayLeft > 0) {
  //           ActivenonRecurring.add(data[x]);
  //         }
  //       }
  //     }
  //   });
  // }

  void searchResult(String enteredKeyword) {
    List<Map<String, dynamic>> results_one = [];
    List<Map<String, dynamic>> results_two = [];
    List<Map<String, dynamic>> results_three = [];
    List<Map<String, dynamic>> results_four = [];

    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results_one = widget.LatenonRecurring;
      results_two = widget.ActivenonRecurring;
      results_three = widget.CompletednonRecurring;
      results_four = widget.foundNonRecurring;
    } else {
      // late
      results_one = widget.LatenonRecurring.where((data) =>
          data["category"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["subCategory"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["type"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["site"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["task"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["owner"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["due"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["startDate"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["modify"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["remark"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["status"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase())).toList();
// active
      results_two = widget.ActivenonRecurring.where((data) =>
          data["category"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["subCategory"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["type"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["site"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["task"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["owner"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["due"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["startDate"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["modify"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["remark"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["status"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase())).toList();

      //complete
      results_three = widget.CompletednonRecurring.where((data) =>
          data["category"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["subCategory"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["type"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["site"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["task"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["owner"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["due"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["startDate"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["modify"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["remark"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          data["personCheck"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) ||
          data["checked"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase())).toList();

      // all
      results_four = widget.foundNonRecurring
          .where((data) =>
              data["category"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["subCategory"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["type"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["site"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["task"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["owner"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["due"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["startDate"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["modify"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["remark"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["status"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["personCheck"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["checked"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      LatenonRecurring = results_one;
      ActivenonRecurring = results_two;
      CompletednonRecurring = results_three;
      foundNonRecurring = results_four;
    });
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  Future<void> removeNonRecurring(int id) async {
    var url =
        'https://ipsolutiontesting.000webhostapp.com/ipsolution/delete.php';
    final response = await http.post(Uri.parse(url), body: {
      "dataTable": "nonrecurring",
      "id": id.toString(),
    });
    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted!'),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NonRecurring()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Delete Unsuccessful !"),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        action: SnackBarAction(
          label: 'Dismiss',
          disabledTextColor: Colors.white,
          textColor: Colors.blue,
          onPressed: () {
            //Do whatever you want
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
                      searchResult(value);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.black),
                    // isDense: true,
                    suffixIcon: const Icon(Icons.search, color: Colors.black),
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
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //         padding: EdgeInsets.zero,
              //         backgroundColor: Styles.bgColor,
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(10))),
              //     onPressed: (() {
              //       showDialog(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return Search(context);
              //           });
              //     }),
              //     child: Padding(
              //       padding: const EdgeInsets.all(12.0),
              //       child: Ink(
              //         height: 20,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(10),
              //           color: Styles.bgColor,
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Text(
              //               "Search",
              //               style: TextStyle(
              //                   color: Styles.textColor,
              //                   fontWeight: FontWeight.bold),
              //             ),
              //             Padding(
              //               padding: const EdgeInsets.only(left: 8.0),
              //               child: Icon(Icons.search,
              //                   color: Colors.black, size: 20),
              //             )
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
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
                              userName: _selectedUser, task: true);
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
                        fontSize: 14.0, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.bold),
                    labelColor: const Color(0xFF88a4d4),
                    unselectedLabelColor: Colors.black,
                    tabs: <Widget>[
                      Tab(
                        icon: Badge(
                          badgeColor: Colors.indigo,
                          shape: BadgeShape.square,
                          borderRadius: BorderRadius.circular(5),
                          position: BadgePosition.topEnd(top: -12, end: -20),
                          padding: const EdgeInsets.all(5),
                          badgeContent: Text(
                            LatenonRecurring.length.toString(),
                            style: const TextStyle(
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
                          position: BadgePosition.topEnd(top: -12, end: -20),
                          padding: const EdgeInsets.all(5),
                          badgeContent: Text(
                            ActivenonRecurring.length.toString(),
                            style: const TextStyle(
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
                          position: BadgePosition.topEnd(top: -12, end: -20),
                          padding: const EdgeInsets.all(5),
                          badgeContent: Text(
                            CompletednonRecurring.length.toString(),
                            style: const TextStyle(
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
                          position: BadgePosition.topEnd(top: -12, end: -20),
                          padding: const EdgeInsets.all(5),
                          badgeContent: Text(
                            foundNonRecurring.length.toString(),
                            style: const TextStyle(
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
    );
  }

  Widget lateView() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(

            // columnSpacing: 12,
            // horizontalMargin: 12,
            // minWidth: 600,
            // // fixedTopRows: 1,
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
                'Cetegory',
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
            ],
            rows: List.generate(LatenonRecurring.length, (index) {
              final dayLeft = daysBetween(
                  DateTime.parse(
                      DateFormat('yyyy-MM-dd').format(DateTime.now())),
                  DateTime.parse(LatenonRecurring[index]["due"]));

              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      LatenonRecurring[index]["task"],
                      softWrap: true,
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LatenonRecurring[index]["category"].split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LatenonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LatenonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LatenonRecurring[index]["site"],
                    ),
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
                        style: const TextStyle(
                            color: Color(0xFFf43a2c),
                            fontWeight: FontWeight.bold),
                      )))),
                  DataCell(Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(LatenonRecurring[index]["due"]))
                        .toString(),
                  )),
                  DataCell(Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        LatenonRecurring[index]["remark"],
                      ),
                    ),
                  )),
                  DataCell(Text(LatenonRecurring[index]["modify"] != null &&
                          LatenonRecurring[index]["modify"].isNotEmpty
                      ? DateFormat('dd/MM/yyyy')
                          .format(
                              DateTime.parse(LatenonRecurring[index]["modify"]))
                          .toString()
                      : '')),
                  DataCell(Row(
                    children: [
                      IconButton(
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
                      ),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await Internet.isInternet()
                                .then((connection) async {
                              if (connection) {
                                await removeNonRecurring(
                                    LatenonRecurring[index]["nonRecurringId"]);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text("No Internet !"),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(20),
                                  action: SnackBarAction(
                                    label: 'Dismiss',
                                    disabledTextColor: Colors.white,
                                    textColor: Colors.blue,
                                    onPressed: () {
                                      //Do whatever you want
                                    },
                                  ),
                                ));
                              }
                            });
                          })
                    ],
                  )),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundNonRecurring[index]["user_id"].toString(),
                //             name: foundNonRecurring[index]['user_name'],
                //             password: foundNonRecurring[index]['password'],
                //             isEditing: false);
                //       });
                // }
              );
            })),
      ),
    );
  }

  Widget activeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
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
                  DateTime.parse(
                      DateFormat('yyyy-MM-dd').format(DateTime.now())),
                  DateTime.parse(ActivenonRecurring[index]["due"]));
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(ActivenonRecurring[index]["task"]))),
                  DataCell(Center(
                    child: Text(
                      ActivenonRecurring[index]["category"].split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      ActivenonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      ActivenonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      ActivenonRecurring[index]["site"],
                    ),
                  )),
                  DataCell(LinearPercentIndicator(
                      barRadius: const Radius.circular(5),
                      width: 100.0,
                      lineHeight: 20.0,
                      percent:
                          double.parse(ActivenonRecurring[index]["status"]) /
                              100,
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
                                  "${dayLeft.abs()} DAYS LATE",
                                  style: Styles.dayLeftLate,
                                )
                              : Text(
                                  "$dayLeft DAYS LEFT",
                                  style: Styles.dayLeftActive,
                                )))),
                  DataCell(Text(
                    DateFormat('dd/MM/yyyy')
                        .format(
                            DateTime.parse(ActivenonRecurring[index]["due"]))
                        .toString(),
                  )),
                  DataCell(Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        ActivenonRecurring[index]["remark"],
                      ),
                    ),
                  )),
                  DataCell(Text(ActivenonRecurring[index]["modify"] != null &&
                          ActivenonRecurring[index]["modify"].isNotEmpty
                      ? DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(
                              ActivenonRecurring[index]["modify"]))
                          .toString()
                      : '')),
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
                      onPressed: () async {
                        await Internet.isInternet().then((connection) async {
                          if (connection) {
                            await removeNonRecurring(
                                ActivenonRecurring[index]["nonRecurringId"]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text("No Internet !"),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(20),
                              action: SnackBarAction(
                                label: 'Dismiss',
                                disabledTextColor: Colors.white,
                                textColor: Colors.blue,
                                onPressed: () {
                                  //Do whatever you want
                                },
                              ),
                            ));
                          }
                        });
                      })),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundNonRecurring[index]["user_id"].toString(),
                //             name: foundNonRecurring[index]['user_name'],
                //             password: foundNonRecurring[index]['password'],
                //             isEditing: false);
                //       });
                // }
              );
            })),
      ),
    );
  }

  Widget completeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
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
                'Category',
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
                'Checked?',
                textAlign: TextAlign.center,
              ))),
              DataColumn(
                  label: Expanded(
                      child: Text(
                'Check By',
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
                  DateTime.parse(
                      DateFormat('yyyy-MM-dd').format(DateTime.now())),
                  DateTime.parse(CompletednonRecurring[index]["due"]));

              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(CompletednonRecurring[index]["task"]))),
                  DataCell(Center(
                    child: Text(
                      CompletednonRecurring[index]["category"].split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      CompletednonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      CompletednonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      CompletednonRecurring[index]["site"],
                    ),
                  )),
                  DataCell(
                    CompletednonRecurring[index]["checked"] == "-"
                        ? const Text("No Review Needed")
                        : Row(
                            children: [
                              Text(CompletednonRecurring[index]["checked"]),
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.blue,
                                value: CompletednonRecurring[index]
                                            ["checked"] ==
                                        "Checked"
                                    ? true
                                    : false,
                                shape: const CircleBorder(),
                                onChanged: (value) {
                                  setState(() {
                                    // isChecked = value!;
                                  });
                                },
                              )
                            ],
                          ),
                  ),
                  DataCell(Center(
                      child:
                          Text(CompletednonRecurring[index]["personCheck"]))),
                  DataCell(Text(
                    DateFormat('dd/MM/yyyy')
                        .format(
                            DateTime.parse(CompletednonRecurring[index]["due"]))
                        .toString(),
                  )),
                  DataCell(Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      CompletednonRecurring[index]["remark"],
                    ),
                  )),
                  DataCell(Text(
                    CompletednonRecurring[index]["modify"].isNotEmpty &&
                            CompletednonRecurring[index]["modify"] != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(
                                CompletednonRecurring[index]["modify"]))
                            .toString()
                        : '',
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
                      onPressed: () async {
                        await Internet.isInternet().then((connection) async {
                          if (connection) {
                            await removeNonRecurring(
                                CompletednonRecurring[index]["nonRecurringId"]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text("No Internet !"),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(20),
                              action: SnackBarAction(
                                label: 'Dismiss',
                                disabledTextColor: Colors.white,
                                textColor: Colors.blue,
                                onPressed: () {
                                  //Do whatever you want
                                },
                              ),
                            ));
                          }
                        });
                      })),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundNonRecurring[index]["user_id"].toString(),
                //             name: foundNonRecurring[index]['user_name'],
                //             password: foundNonRecurring[index]['password'],
                //             isEditing: false);
                //       });
                // }
              );
            })),
      ),
    );
  }

  Widget allView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
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
                'Category',
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
                'Stage / Checked',
                textAlign: TextAlign.center,
              ))),
              DataColumn(
                  label: Expanded(
                      child: Text(
                'Day Left / Check by',
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
            rows: List.generate(foundNonRecurring.length, (index) {
              final dayLeft = daysBetween(
                  DateTime.parse(
                      DateFormat('yyyy-MM-dd').format(DateTime.now())),
                  DateTime.parse(foundNonRecurring[index]["due"]));
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(foundNonRecurring[index]["task"]))),
                  DataCell(Center(
                    child: Text(
                      foundNonRecurring[index]["category"].split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      foundNonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      foundNonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      foundNonRecurring[index]["site"],
                    ),
                  )),
                  DataCell(foundNonRecurring[index]["status"] == '100'
                      ? foundNonRecurring[index]["checked"] == "-"
                          ? const Text("No Review Needed")
                          : Row(
                              children: [
                                Text(foundNonRecurring[index]["checked"]),
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.blue,
                                  value: foundNonRecurring[index]["checked"] ==
                                          "Checked"
                                      ? true
                                      : false,
                                  shape: const CircleBorder(),
                                  onChanged: (value) {
                                    setState(() {
                                      // isChecked = value!;
                                    });
                                  },
                                )
                              ],
                            )
                      : LinearPercentIndicator(
                          barRadius: const Radius.circular(5),
                          width: 100.0,
                          lineHeight: 20.0,
                          percent:
                              double.parse(foundNonRecurring[index]["status"]) /
                                  100,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                          center: Text(
                            foundNonRecurring[index]["status"],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))),
                  DataCell(foundNonRecurring[index]["status"] != '100'
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
                                      "${dayLeft.abs()} DAYS LATE",
                                      style: const TextStyle(
                                          color: Color(0xFFf43a2c),
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      "$dayLeft DAYS LEFT",
                                      style: Styles.dayLeftActive,
                                    )))
                      : Center(
                          child: Text(
                            foundNonRecurring[index]["personCheck"],
                            textAlign: TextAlign.center,
                          ),
                        )),
                  DataCell(Center(
                    child: Text(foundNonRecurring[index]["status"] != '100'
                        ? DateFormat('dd/MM/yyyy')
                            .format(
                                DateTime.parse(foundNonRecurring[index]["due"]))
                            .toString()
                        : "( ${DateFormat('dd/MM/yyyy').format(DateTime.parse(foundNonRecurring[index]["due"]))} )"),
                  )),
                  DataCell(Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      foundNonRecurring[index]["remark"],
                    ),
                  )),
                  DataCell(Text(
                    foundNonRecurring[index]["modify"].isNotEmpty &&
                            foundNonRecurring[index]["modify"] != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(
                                foundNonRecurring[index]["modify"]))
                            .toString()
                        : '',
                  )),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return editNonRecurring(
                              id: foundNonRecurring[index]["nonRecurringId"]
                                  .toString(),
                            );
                          });
                    },
                  )),
                  DataCell(IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await Internet.isInternet().then((connection) async {
                          if (connection) {
                            await removeNonRecurring(
                                foundNonRecurring[index]["nonRecurringId"]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text("No Internet !"),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(20),
                              action: SnackBarAction(
                                label: 'Dismiss',
                                disabledTextColor: Colors.white,
                                textColor: Colors.blue,
                                onPressed: () {
                                  //Do whatever you want
                                },
                              ),
                            ));
                          }
                        });
                      })),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundNonRecurring[index]["user_id"].toString(),
                //             name: foundNonRecurring[index]['user_name'],
                //             password: foundNonRecurring[index]['password'],
                //             isEditing: false);
                //       });
                // }
              );
            })),
      ),
    );
  }
}
