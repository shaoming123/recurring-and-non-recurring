import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/src/dialogBox/eventAdd.dart';
import 'package:ipsolution/src/dialogBox/eventEdit.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../model/eventDataSource.dart';
import '../../model/manageUser.dart';
import '../../util/checkInternet.dart';
import '../../util/conMysql.dart';
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
  TextEditingController? textcontroller;
  String _selectedPosition = "";
  String _selectedUser = "";
  bool _showContent = false;
  String currentUserPosition = '';
  String currentUserSite = '';
  List<String> combineType = <String>[];
  String userRole = '';
  String? currentUsername;
  String currentUserSiteLead = '';
  String currentUserLeadFunc = '';
  List<String> siteType = <String>[];
  List<Map<String, dynamic>> allTeamNonRecurring = [];
  List<Map<String, dynamic>> foundTeamNonRecurring = [];
  List<Map<String, dynamic>> LateTeamnonRecurring = [];
  List<Map<String, dynamic>> ActiveTeamnonRecurring = [];
  List<Map<String, dynamic>> CompletedTeamnonRecurring = [];

  List<Map<String, dynamic>> full_foundTeamNonRecurring = [];
  List<Map<String, dynamic>> full_LateTeamnonRecurring = [];
  List<Map<String, dynamic>> full_ActiveTeamnonRecurring = [];
  List<Map<String, dynamic>> full_CompletedTeamnonRecurring = [];
  List<String> positionType = <String>[];
  List<dynamic> userList = [];
  double _animatedHeight = 0.0;
  bool showTable = false;
  bool check = false;
  int requestcheck = 0;
  DbHelper dbHelper = DbHelper();

  int checkNum = 0;
  @override
  void initState() {
    super.initState();
    textcontroller = TextEditingController();
    //get the user position
    getUserPosition();
  }

  Future<void> getUserPosition() async {
    final SharedPreferences sp = await _pref;
    positionType = <String>[];
    siteType = <String>[];
    currentUsername = sp.getString("user_name").toString();
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
    });
  }

  void getTeamData() async {
    final data = await dbHelper.fetchAllNonRecurring();
    foundTeamNonRecurring = [];
    CompletedTeamnonRecurring = [];
    LateTeamnonRecurring = [];
    ActiveTeamnonRecurring = [];
    textcontroller!.clear();
    setState(() {
      for (int x = 0; x < data.length; x++) {
        if (userRole == "Super Admin" || userRole == 'Manager') {
          final dayLeft =
              daysBetween(DateTime.now(), DateTime.parse(data[x]["due"]));
          if (data[x]["owner"] == _selectedUser) {
            if (data[x]["site"] == _selectedPosition) {
              foundTeamNonRecurring.add(data[x]);
              if (data[x]["status"] == '100') {
                CompletedTeamnonRecurring.add(data[x]);
              } else if (dayLeft.isNegative) {
                LateTeamnonRecurring.add(data[x]);
              } else if (dayLeft > 0) {
                ActiveTeamnonRecurring.add(data[x]);
              }
            } else if (positionType.contains(_selectedPosition)) {
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
        } else if (userRole == "Leader" && currentUserSiteLead != '-') {
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

      full_LateTeamnonRecurring = LateTeamnonRecurring;
      full_ActiveTeamnonRecurring = ActiveTeamnonRecurring;
      full_CompletedTeamnonRecurring = CompletedTeamnonRecurring;
      full_foundTeamNonRecurring = foundTeamNonRecurring;

      checkNum = 0;
      for (var item in foundTeamNonRecurring)
        if (item["checked"] == "Pending Review" &&
            item["personCheck"] == currentUsername) checkNum = checkNum + 1;
    });
  }

  Future<void> toggleSwitch(value, int id) async {
    String checked = '';
    String tableName = "nonrecurring";
    setState(() {
      if (value == true) {
        checked = 'Checked';
      } else {
        checked = 'Pending Review';
      }
    });

    final response = await Controller()
        .switchToggle(checked, id.toString(), tableName, "checked");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Updated Successfully!"),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.blue,
            onPressed: () {
              //Do whatever you want
            },
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NonRecurring()),
      );
    }
  }

  Future<void> removeTeamNonRecurring(int id) async {
    var url = 'http://192.168.1.111/testdb/delete.php';
    final response = await http.post(Uri.parse(url), body: {
      "dataTable": "nonrecurring",
      "id": id.toString(),
    });
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully deleted!'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        action: SnackBarAction(
          label: 'Dismiss',
          disabledTextColor: Colors.white,
          textColor: Colors.blue,
          onPressed: () {
            //Do whatever you want
          },
        ),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NonRecurring()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Delete Unsuccessful !"),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
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

  void searchResult(String enteredKeyword) {
    List<Map<String, dynamic>> results_one = [];
    List<Map<String, dynamic>> results_two = [];
    List<Map<String, dynamic>> results_three = [];
    List<Map<String, dynamic>> results_four = [];

    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results_one = full_LateTeamnonRecurring;
      results_two = full_ActiveTeamnonRecurring;
      results_three = full_CompletedTeamnonRecurring;
      results_four = full_foundTeamNonRecurring;
    } else {
      results_one = full_LateTeamnonRecurring
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
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      // active
      results_two = full_ActiveTeamnonRecurring
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
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      //complete
      results_three = full_CompletedTeamnonRecurring
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
              data["personCheck"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["checked"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      // all
      results_four = full_foundTeamNonRecurring
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
      LateTeamnonRecurring = results_one;
      ActiveTeamnonRecurring = results_two;
      CompletedTeamnonRecurring = results_three;
      foundTeamNonRecurring = results_four;
    });
  }

  // Widget Search(context) {
  //   return SingleChildScrollView(
  //     child: Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       backgroundColor: Colors.transparent,
  //       child: Container(
  //           padding: const EdgeInsets.all(20),
  //           margin: const EdgeInsets.only(top: 45),
  //           decoration: BoxDecoration(
  //               shape: BoxShape.rectangle,
  //               color: const Color(0xFF384464),
  //               borderRadius: BorderRadius.circular(20),
  //               boxShadow: [
  //                 const BoxShadow(
  //                     color: Colors.black,
  //                     offset: Offset(0, 10),
  //                     blurRadius: 10),
  //               ]),
  //           child: Column(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text("Search",
  //                         style: TextStyle(
  //                             color: Color(0xFFd4dce4),
  //                             fontSize: 26,
  //                             fontWeight: FontWeight.w700)),
  //                     IconButton(
  //                       icon: const Icon(
  //                         Icons.cancel_outlined,
  //                         color: Color(0XFFd4dce4),
  //                         size: 30,
  //                       ),
  //                       onPressed: () => Navigator.of(context).pop(),
  //                     ),
  //                   ],
  //                 ),
  //                 const Gap(20),
  //                 Container(
  //                   margin: const EdgeInsets.only(bottom: 30),
  //                   padding: const EdgeInsets.symmetric(horizontal: 5),
  //                   decoration: BoxDecoration(
  //                       border: Border.all(color: Colors.white, width: 1),
  //                       borderRadius: BorderRadius.circular(12),
  //                       color: const Color(0xFFd4dce4)),
  //                   child: TextFormField(
  //                     cursorColor: Colors.black,
  //                     style: const TextStyle(fontSize: 14),

  //                     decoration: InputDecoration(hintText: "Search...."),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         searchResult(value);
  //                       });
  //                     },
  //                     // controller: controllerText,
  //                   ),
  //                 ),
  //                 Align(
  //                   alignment: Alignment.bottomRight,
  //                   child: TextButton(
  //                       style: ButtonStyle(
  //                         padding: MaterialStateProperty.all<EdgeInsets>(
  //                           const EdgeInsets.all(10),
  //                         ),
  //                         backgroundColor: MaterialStateProperty.all<Color>(
  //                             const Color(0xFF60b4b4)),
  //                         shape: MaterialStateProperty.all(
  //                             RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(10.0))),
  //                       ),
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: const Text(
  //                         "search",
  //                         style: TextStyle(
  //                             fontSize: 18,
  //                             color: Color(0xFFd4dce4),
  //                             fontWeight: FontWeight.w700),
  //                       )),
  //                 ),
  //               ])),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                    isDense: true,
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
            margin:
                const EdgeInsets.only(bottom: 30, top: 10, left: 10, right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.blueGrey, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                iconSize: 30,
                isExpanded: true,
                hint: Text('Choose item'),
                value: _selectedPosition == '' ? null : _selectedPosition,
                selectedItemHighlightColor: Colors.grey,
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
              margin: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
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
                    selectedItemHighlightColor: Colors.grey,
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
                        visible: _animatedHeight != 0.0 ? true : false,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ))),
              ),
            ),
          ),
          showTable
              ? foundTeamNonRecurring.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        checkNum > 0
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 20, top: 0),
                                child: Text(
                                  "***Request Checking*** ",
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(),
                        DefaultTabController(
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
                                        borderRadius: BorderRadius.circular(5),
                                        position: BadgePosition.topEnd(
                                            top: -12, end: -20),
                                        padding: const EdgeInsets.all(5),
                                        badgeContent: Text(
                                          LateTeamnonRecurring.length
                                              .toString(),
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
                                          ActiveTeamnonRecurring.length
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
                                          CompletedTeamnonRecurring.length
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
                                          foundTeamNonRecurring.length
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
                        ),
                      ],
                    )
                  : Text(
                      "No data found !",
                      style: Styles.subtitle,
                    )
              : Container(),
        ],
      ),
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
                      onPressed: () async {
                        await Internet.isInternet().then((connection) async {
                          if (connection) {
                            await removeTeamNonRecurring(
                                LateTeamnonRecurring[index]["nonRecurringId"]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("No Internet !"),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(20),
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
                      onPressed: () async {
                        await Internet.isInternet().then((connection) async {
                          if (connection) {
                            await removeTeamNonRecurring(
                                ActiveTeamnonRecurring[index]
                                    ["nonRecurringId"]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("No Internet !"),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(20),
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
                      ? Center(
                          child: Row(
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
                                onChanged: (value) async {
                                  await Internet.isInternet()
                                      .then((connection) async {
                                    if (connection) {
                                      if (CompletedTeamnonRecurring[index]
                                              ["personCheck"] ==
                                          currentUsername) {
                                        await toggleSwitch(
                                            value,
                                            CompletedTeamnonRecurring[index]
                                                ["nonRecurringId"]);
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("No Internet !"),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(20),
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
                                },
                              )
                            ],
                          ),
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
                      onPressed: () async {
                        await Internet.isInternet().then((connection) async {
                          if (connection) {
                            await removeTeamNonRecurring(
                                CompletedTeamnonRecurring[index]
                                    ["nonRecurringId"]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("No Internet !"),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(20),
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
                                  onChanged: (value) async {
                                    await Internet.isInternet()
                                        .then((connection) async {
                                      if (connection) {
                                        if (foundTeamNonRecurring[index]
                                                ["personCheck"] ==
                                            currentUsername) {
                                          await toggleSwitch(
                                              value,
                                              foundTeamNonRecurring[index]
                                                  ["nonRecurringId"]);
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("No Internet !"),
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(20),
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
                      onPressed: () async {
                        await Internet.isInternet().then((connection) async {
                          if (connection) {
                            await removeTeamNonRecurring(
                                foundTeamNonRecurring[index]["nonRecurringId"]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("No Internet !"),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(20),
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
