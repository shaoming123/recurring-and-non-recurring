import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/src/dialogBox/eventAdd.dart';
import 'package:ipsolution/src/dialogBox/eventEdit.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/eventDataSource.dart';
import '../../model/manageUser.dart';
import '../dialogBox/nonRecurringAdd.dart';
import '../dialogBox/nonRecurringEdit.dart';
import '../non_recurring.dart';

class TeamTask extends StatefulWidget {
  const TeamTask({Key? key}) : super(key: key);
  @override
  State<TeamTask> createState() => _TeamTaskState();
}

final textcontroller = TextEditingController();
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

class _TeamTaskState extends State<TeamTask> {
  String _selectedPosition = "";
  String _selectedUser = "";
  bool _showContent = false;
  String currentUserPosition = '';
  String currentUserSite = '';
  List<String> combineType = <String>[];
  String userRole = '';
  String currentUserSiteLead = '';
  String currentUserLeadFunc = '';
  List<String> siteType = <String>[];
  List<Map<String, dynamic>> allTeamNonRecurring = [];
  List<Map<String, dynamic>> foundTeamNonRecurring = [];
  List<Map<String, dynamic>> LateTeamnonRecurring = [];
  List<Map<String, dynamic>> ActiveTeamnonRecurring = [];
  List<Map<String, dynamic>> CompletedTeamnonRecurring = [];
  List<dynamic> userList = [];
  double _animatedHeight = 0.0;
  bool showTable = false;
  bool check = false;
  @override
  void initState() {
    super.initState();

    //get the user position
    getUserPosition();
  }

  Future<void> getUserPosition() async {
    final SharedPreferences sp = await _pref;
    List<String> positionType = <String>[];
    siteType = <String>[];
    userRole = sp.getString("role").toString();
    currentUserPosition = sp.getString("position")!;
    currentUserSite = sp.getString("site")!;
    currentUserSiteLead = sp.getString("siteLead")!;
    currentUserLeadFunc = sp.getString("leadFunc")!;
    setState(() {
      positionType = currentUserPosition.split(",");
      siteType = currentUserSite.split(",");
      if (userRole == "Manager" || userRole == "Super Admin") {
        combineType = [...positionType, ...siteType];
      } else if (userRole == "Leader" && currentUserSiteLead != "-") {
        combineType = [
          "Community Management",
          "Maintenance Management",
          "Defect",
          "Operations",
          "Financial Management",
          "Procurement",
          "Statistic"
        ];
      } else {
        combineType = currentUserPosition.split(",");
      }
    });
  }

  Future<void> fetchUsers() async {
    foundTeamNonRecurring = [];
    CompletedTeamnonRecurring = [];
    LateTeamnonRecurring = [];
    ActiveTeamnonRecurring = [];
    final SharedPreferences sp = await _pref;
    final data = await dbHelper.getItems();
    List userSite = currentUserSite.split(',');
    // String userID = sp.getInt("user_id").toString();

    userList = [];
    setState(() {
      for (int x = 0; x < data.length; x++) {
        List positionList = data[x]["position"].split(",");
        List siteList = data[x]["site"].split(",");

        if (userRole == "Manager" || userRole == "Super Admin") {
          for (int i = 0; i < positionList.length; i++) {
            if (positionList[i] == _selectedPosition &&
                data[x]["user_id"] != sp.getInt("user_id")) {
              userList.add({
                'userId': data[x]["user_id"],
                'username': data[x]["user_name"],
                'position': data[x]["position"]
              });
            }
          }

          for (int y = 0; y < siteList.length; y++) {
            if (siteList[y] == _selectedPosition &&
                data[x]["user_id"] != sp.getInt("user_id")) {
              userList.add({
                'userId': data[x]["user_id"],
                'username': data[x]["user_name"],
                'position': data[x]["position"]
              });
            }
          }
          // }
          // else if (userRole == "Leader" && currentUserLeadFunc != '-') {
          //   for (int i = 0; i < positionList.length; i++) {
          //     if (positionList[i] == _selectedPosition &&
          //         data[x]["user_id"] != sp.getInt("user_id") &&
          //         (data[x]["role"] == "Leader" || data[x]["role"] == "Staff")) {
          //       userList.add({
          //         'userId': data[x]["user_id"],
          //         'username': data[x]["user_name"],
          //         'position': data[x]["position"]
          //       });
          //     }
          //   }
        } else if (userRole == "Leader" && currentUserSiteLead != '-') {
          for (int y = 0; y < siteList.length; y++) {
            for (int i = 0; i < positionList.length; i++) {
              if (positionList[i] == _selectedPosition &&
                  data[x]["user_id"] != sp.getInt("user_id") &&
                  (data[x]["role"] == "Leader" || data[x]["role"] == "Staff") &&
                  siteList[y] == currentUserSiteLead) {
                userList.add({
                  'userId': data[x]["user_id"],
                  'username': data[x]["user_name"],
                  'position': data[x]["position"],
                });
              }
            }
          }
        } else {
          for (int y = 0; y < siteList.length; y++) {
            for (int i = 0; i < positionList.length; i++) {
              if (positionList[i] == _selectedPosition &&
                  data[x]["user_id"] != sp.getInt("user_id") &&
                  (data[x]["role"] == "Leader" || data[x]["role"] == "Staff")) {
                userList.add({
                  'userId': data[x]["user_id"],
                  'username': data[x]["user_name"],
                  'position': data[x]["position"],
                });
              }
            }
          }
        }
      }
    });
    print(userList);
  }

  void getTeamData() async {
    final data = await dbHelper.fetchAllNonRecurring();
    foundTeamNonRecurring = [];
    CompletedTeamnonRecurring = [];
    LateTeamnonRecurring = [];
    ActiveTeamnonRecurring = [];
    setState(() {
      for (int x = 0; x < data.length; x++) {
        if (userRole == "Leader" && currentUserSiteLead != '-') {
          if (data[x]["site"] == currentUserSiteLead) {
            if (data[x]["owner"] == _selectedUser) {
              final dayLeft =
                  daysBetween(DateTime.now(), DateTime.parse(data[x]["due"]));

              foundTeamNonRecurring.add(data[x]);
              if (data[x]["status"] == '100') {
                CompletedTeamnonRecurring.add(data[x]);
              } else if (dayLeft.isNegative) {
                LateTeamnonRecurring.add(data[x]);
              } else if (dayLeft > 0) {
                ActiveTeamnonRecurring.add(data[x]);
              }
            }
          }
        } else {
          if (data[x]["owner"] == _selectedUser) {
            final dayLeft =
                daysBetween(DateTime.now(), DateTime.parse(data[x]["due"]));

            foundTeamNonRecurring.add(data[x]);
            if (data[x]["status"] == '100') {
              CompletedTeamnonRecurring.add(data[x]);
            } else if (dayLeft.isNegative) {
              LateTeamnonRecurring.add(data[x]);
            } else if (dayLeft > 0) {
              ActiveTeamnonRecurring.add(data[x]);
            }
          }
        }
      }
    });
  }

  Future<void> removeTeamNonRecurring(int id) async {
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
          title: Text(
            "Team Status Overview",
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
          tileColor: Color(0xFF88a4d4),
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
                                        userName: _selectedUser, task: false);
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
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: 30, top: 10, left: 10, right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blueGrey,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          iconSize: 30,
                          isExpanded: true,
                          hint: Text('Choose item'),
                          value: _selectedPosition == ''
                              ? null
                              : _selectedPosition,
                          items: combineType
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPosition = val!;
                              _selectedUser = '';

                              _animatedHeight = 85;
                            });
                            fetchUsers();
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      height: _animatedHeight,
                      color: Colors.transparent,
                      width: width,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 30, left: 10, right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.blueGrey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                              iconSize: 30.0,
                              isExpanded: true,
                              hint: Text('Choose item'),
                              value: _selectedUser == '' ? null : _selectedUser,
                              items: List.generate(
                                userList.length,
                                (index) => DropdownMenuItem(
                                  value: userList[index]["username"].toString(),
                                  child: Text(
                                    userList[index]["username"].toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _selectedUser = val!;
                                  showTable = true;
                                });
                                getTeamData();
                              },
                              icon: Visibility(
                                  visible:
                                      _animatedHeight != 0.0 ? true : false,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ))),
                        ),
                      ),
                    ),
                    showTable
                        ? foundTeamNonRecurring.isNotEmpty
                            ? DefaultTabController(
                                length: 4,
                                child: SizedBox(
                                  height: 500,
                                  child: Column(
                                    children: <Widget>[
                                      TabBar(
                                        indicatorColor: Styles.primaryColor,
                                        indicatorWeight: 3,
                                        padding: EdgeInsets.zero,
                                        indicatorPadding: EdgeInsets.zero,
                                        labelPadding: EdgeInsets.zero,
                                        labelStyle: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                        unselectedLabelStyle: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold),
                                        labelColor: Styles.primaryColor,
                                        unselectedLabelColor: Colors.black,
                                        tabs: <Widget>[
                                          Tab(
                                            icon: Badge(
                                              badgeColor: Colors.indigo,
                                              shape: BadgeShape.square,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              position: BadgePosition.topEnd(
                                                  top: -12, end: -20),
                                              padding: const EdgeInsets.all(5),
                                              badgeContent: Text(
                                                LateTeamnonRecurring.length
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              child: const Text("Late"),
                                            ),
                                          ),
                                          Tab(
                                            icon: Badge(
                                              badgeColor: Colors.indigo,
                                              shape: BadgeShape.square,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              position: BadgePosition.topEnd(
                                                  top: -12, end: -20),
                                              padding: const EdgeInsets.all(5),
                                              badgeContent: Text(
                                                ActiveTeamnonRecurring.length
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              child: const Text("Active"),
                                            ),
                                          ),
                                          Tab(
                                            icon: Badge(
                                              badgeColor: Colors.indigo,
                                              shape: BadgeShape.square,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              position: BadgePosition.topEnd(
                                                  top: -12, end: -20),
                                              padding: const EdgeInsets.all(5),
                                              badgeContent: Text(
                                                CompletedTeamnonRecurring.length
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              child: const Text("Completed"),
                                            ),
                                          ),
                                          Tab(
                                            icon: Badge(
                                              badgeColor: Colors.indigo,
                                              shape: BadgeShape.square,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              position: BadgePosition.topEnd(
                                                  top: -12, end: -20),
                                              padding: const EdgeInsets.all(5),
                                              badgeContent: Text(
                                                foundTeamNonRecurring.length
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              child: const Text("All"),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
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
                              )
                            : Text(
                                "No data found !",
                                style: Styles.subtitle,
                              )
                        : Container(),
                  ],
                ),
              )
            : Container()
      ]),
    );
  }

  Widget lateView() {
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
            rows: List.generate(LateTeamnonRecurring.length, (index) {
              final dayLeft = daysBetween(DateTime.now(),
                  DateTime.parse(LateTeamnonRecurring[index]["due"]));

              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      LateTeamnonRecurring[index]["task"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LateTeamnonRecurring[index]["category"].split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LateTeamnonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LateTeamnonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      LateTeamnonRecurring[index]["site"],
                    ),
                  )),
                  DataCell(LinearPercentIndicator(
                      barRadius: const Radius.circular(5),
                      width: 100.0,
                      lineHeight: 20.0,
                      percent:
                          double.parse(LateTeamnonRecurring[index]["status"]) /
                              100,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                      center: Text(
                        LateTeamnonRecurring[index]["status"],
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
                            DateTime.parse(LateTeamnonRecurring[index]["due"]))
                        .toString(),
                  )),
                  DataCell(Center(
                    child: Text(
                      LateTeamnonRecurring[index]["remark"],
                    ),
                  )),
                  DataCell(Text(LateTeamnonRecurring[index]["modify"] != null &&
                          LateTeamnonRecurring[index]["modify"].isNotEmpty
                      ? DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(
                              LateTeamnonRecurring[index]["modify"]))
                          .toString()
                      : "")),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return editNonRecurring(
                              id: LateTeamnonRecurring[index]["nonRecurringId"]
                                  .toString(),
                            );
                          });
                    },
                  )),
                  DataCell(IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        removeTeamNonRecurring(
                            LateTeamnonRecurring[index]["nonRecurringId"]);
                      })),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundTeamNonRecurring[index]["user_id"].toString(),
                //             name: foundTeamNonRecurring[index]['user_name'],
                //             password: foundTeamNonRecurring[index]['password'],
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
            rows: List.generate(ActiveTeamnonRecurring.length, (index) {
              final dayLeft = daysBetween(DateTime.now(),
                  DateTime.parse(ActiveTeamnonRecurring[index]["due"]));
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Text(ActiveTeamnonRecurring[index]["task"]))),
                  DataCell(Center(
                    child: Text(
                      ActiveTeamnonRecurring[index]["category"].split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      ActiveTeamnonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      ActiveTeamnonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      ActiveTeamnonRecurring[index]["site"],
                    ),
                  )),
                  DataCell(LinearPercentIndicator(
                      barRadius: const Radius.circular(5),
                      width: 100.0,
                      lineHeight: 20.0,
                      percent: double.parse(
                              ActiveTeamnonRecurring[index]["status"]) /
                          100,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                      center: Text(
                        ActiveTeamnonRecurring[index]["status"],
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
                        .format(DateTime.parse(
                            ActiveTeamnonRecurring[index]["due"]))
                        .toString(),
                  )),
                  DataCell(Center(
                    child: Text(
                      ActiveTeamnonRecurring[index]["remark"],
                    ),
                  )),
                  DataCell(Text(
                      ActiveTeamnonRecurring[index]["modify"] != null &&
                              ActiveTeamnonRecurring[index]["modify"].isNotEmpty
                          ? DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(
                                  ActiveTeamnonRecurring[index]["modify"]))
                              .toString()
                          : "")),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return editNonRecurring(
                              id: ActiveTeamnonRecurring[index]
                                      ["nonRecurringId"]
                                  .toString(),
                            );
                          });
                    },
                  )),
                  DataCell(IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        removeTeamNonRecurring(
                            ActiveTeamnonRecurring[index]["nonRecurringId"]);
                      })),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundTeamNonRecurring[index]["user_id"].toString(),
                //             name: foundTeamNonRecurring[index]['user_name'],
                //             password: foundTeamNonRecurring[index]['password'],
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
            rows: List.generate(CompletedTeamnonRecurring.length, (index) {
              final dayLeft = daysBetween(DateTime.now(),
                  DateTime.parse(CompletedTeamnonRecurring[index]["due"]));
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Text(CompletedTeamnonRecurring[index]["task"]))),
                  DataCell(Center(
                    child: Text(
                      CompletedTeamnonRecurring[index]["category"]
                          .split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      CompletedTeamnonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      CompletedTeamnonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      CompletedTeamnonRecurring[index]["site"],
                    ),
                  )),
                  DataCell(CompletedTeamnonRecurring[index]["checked"] != '-'
                      ? Row(
                          children: [
                            Text(CompletedTeamnonRecurring[index]["checked"]),
                            Checkbox(
                              checkColor: Colors.white,
                              activeColor: Colors.blue,
                              value: CompletedTeamnonRecurring[index]
                                          ["checked"] ==
                                      'Checked'
                                  ? true
                                  : false,
                              shape: CircleBorder(),
                              onChanged: (value) {
                                // setState(() {
                                //   check = value!;
                                // });
                              },
                            )
                          ],
                        )
                      : Text("No Review Needed")),
                  DataCell(Center(
                      child: Text(
                          CompletedTeamnonRecurring[index]["personCheck"]))),
                  DataCell(Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(
                            CompletedTeamnonRecurring[index]["due"]))
                        .toString(),
                  )),
                  DataCell(Center(
                    child: Text(
                      CompletedTeamnonRecurring[index]["remark"],
                    ),
                  )),
                  DataCell(Text(CompletedTeamnonRecurring[index]["modify"] !=
                              null &&
                          CompletedTeamnonRecurring[index]["modify"].isNotEmpty
                      ? DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(
                              CompletedTeamnonRecurring[index]["modify"]))
                          .toString()
                      : "")),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return editNonRecurring(
                              id: CompletedTeamnonRecurring[index]
                                      ["nonRecurringId"]
                                  .toString(),
                            );
                          });
                    },
                  )),
                  DataCell(IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        removeTeamNonRecurring(
                            CompletedTeamnonRecurring[index]["nonRecurringId"]);
                      })),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundTeamNonRecurring[index]["user_id"].toString(),
                //             name: foundTeamNonRecurring[index]['user_name'],
                //             password: foundTeamNonRecurring[index]['password'],
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
            rows: List.generate(foundTeamNonRecurring.length, (index) {
              final dayLeft = daysBetween(DateTime.now(),
                  DateTime.parse(foundTeamNonRecurring[index]["due"]));
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Text(foundTeamNonRecurring[index]["task"]))),
                  DataCell(Center(
                    child: Text(
                      foundTeamNonRecurring[index]["category"].split("|")[0],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      foundTeamNonRecurring[index]["subCategory"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      foundTeamNonRecurring[index]["type"],
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      foundTeamNonRecurring[index]["site"],
                    ),
                  )),
                  DataCell(foundTeamNonRecurring[index]["status"] == '100'
                      ? foundTeamNonRecurring[index]["checked"] == "-"
                          ? Text("No Review Needed")
                          : Row(
                              children: [
                                Text(foundTeamNonRecurring[index]["checked"]),
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.blue,
                                  value: foundTeamNonRecurring[index]
                                              ["checked"] ==
                                          'Checked'
                                      ? true
                                      : false,
                                  shape: CircleBorder(),
                                  onChanged: (value) {
                                    // setState(() {
                                    //   check = value!;
                                    // });
                                  },
                                )
                              ],
                            )
                      : LinearPercentIndicator(
                          barRadius: const Radius.circular(5),
                          width: 100.0,
                          lineHeight: 20.0,
                          percent: double.parse(
                                  foundTeamNonRecurring[index]["status"]) /
                              100,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                          center: Text(
                            foundTeamNonRecurring[index]["status"],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))),
                  DataCell(foundTeamNonRecurring[index]["status"] != '100'
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
                      : Center(
                          child: Text(
                            foundTeamNonRecurring[index]["personCheck"],
                            textAlign: TextAlign.center,
                          ),
                        )),
                  DataCell(Text(
                    DateFormat('dd/MM/yyyy')
                        .format(
                            DateTime.parse(foundTeamNonRecurring[index]["due"]))
                        .toString(),
                  )),
                  DataCell(Center(
                    child: Text(
                      foundTeamNonRecurring[index]["remark"],
                    ),
                  )),
                  DataCell(Text(
                      foundTeamNonRecurring[index]["modify"] != null &&
                              foundTeamNonRecurring[index]["modify"].isNotEmpty
                          ? DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(
                                  foundTeamNonRecurring[index]["modify"]))
                              .toString()
                          : "")),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return editNonRecurring(
                              id: foundTeamNonRecurring[index]["nonRecurringId"]
                                  .toString(),
                            );
                          });
                    },
                  )),
                  DataCell(IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        removeTeamNonRecurring(
                            foundTeamNonRecurring[index]["nonRecurringId"]);
                      })),
                ],
                // onSelectChanged: (e) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return DialogBox(
                //             id: foundTeamNonRecurring[index]["user_id"].toString(),
                //             name: foundTeamNonRecurring[index]['user_name'],
                //             password: foundTeamNonRecurring[index]['password'],
                //             isEditing: false);
                //       });
                // }
              );
            })),
      ),
    );
  }
}
