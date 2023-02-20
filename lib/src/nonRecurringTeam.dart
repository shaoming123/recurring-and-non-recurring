//@dart=2.9
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/src/popFilter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../databaseHandler/Clone2Helper.dart';
import '../databaseHandler/CloneHelper.dart';
import '../model/eventDataSource.dart';
import '../util/app_styles.dart';
import '../util/checkInternet.dart';
import '../util/cloneData.dart';
import 'appbar.dart';
import 'card/teamTask.dart';
import 'navbar.dart';

class NonRecurringTeam extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final String selectedUser;
  final String selectedPosition;
  const NonRecurringTeam(
      {Key key, this.start, this.end, this.selectedUser, this.selectedPosition})
      : super(key: key);

  @override
  State<NonRecurringTeam> createState() => _NonRecurringTeamState();
}

List<Map<String, dynamic>> allTeamNonRecurring = [];

List<Map<String, dynamic>> lateTeamNonRecurring = [];
List<Map<String, dynamic>> activeTeamNonRecurring = [];
List<Map<String, dynamic>> completedTeamNonRecurring = [];

class _NonRecurringTeamState extends State<NonRecurringTeam> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  // DbHelper dbHelper = DbHelper();
  CloneHelper cloneHelper = CloneHelper();
  Clone2Helper clone2Helper = Clone2Helper();
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime(DateTime.now().year + 1, 1, 0);
  String userRole = 'Staff';

  List<String> positionType = <String>[];
  List<dynamic> userList = [];
  List<String> siteType = <String>[];
  List<String> combineType = <String>[];

  String currentUsername;
  String currentUserSiteLead;
  String currentUserLeadFunc;
  String currentUserPosition;
  String currentUserSite;
  String _selectedPosition;
  String _selectedUser;
  int checkNum = 0;

  bool isOnline;
  @override
  void initState() {
    super.initState();

    if (widget.start != null && widget.end != null) {
      startDate = widget.start;
      endDate = widget.end;
    }
    if (widget.selectedUser != null && widget.selectedPosition != null) {
      _selectedPosition = widget.selectedPosition;
      _selectedUser = widget.selectedUser;
    } else {
      allTeamNonRecurring = [];
      completedTeamNonRecurring = [];
      lateTeamNonRecurring = [];
      activeTeamNonRecurring = [];
    }

    getUserPosition();
    fetchUsers();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   allTeamNonRecurring = [];
  //   completedTeamNonRecurring = [];
  //   lateTeamNonRecurring = [];
  //   activeTeamNonRecurring = [];
  // }

  Future<void> getUserPosition() async {
    final SharedPreferences sp = await _pref;
    positionType = <String>[];
    siteType = <String>[];
    currentUsername = sp.getString("user_name").toString();
    userRole = sp.getString("role").toString();
    currentUserPosition = sp.getString("position");
    currentUserSite = sp.getString("site");
    currentUserSiteLead = sp.getString("siteLead");
    currentUserLeadFunc = sp.getString("leadFunc");
    setState(() {
      positionType = currentUserPosition.split(",");
      siteType = currentUserSite.split(",");
      if (userRole == "Manager" || userRole == "Super Admin") {
        combineType = [...positionType, ...siteType];
        combineType.insert(0, "Manager");
        combineType.remove("-");
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
    final SharedPreferences sp = await _pref;
    isOnline = await Internet.isInternet();
    final data = isOnline
        ? await Controller().getOnlineUser()
        : await clone2Helper.getUser();
    // List userSite = currentUserSite.split(',');
    // String userID = sp.getString("id").toString();

    userList = [];
    setState(() {
      for (int x = 0; x < data.length; x++) {
        List positionList = data[x]["position"].split(",");
        List siteList = data[x]["site"].split(",");

        if (userRole == "Manager" || userRole == "Super Admin") {
          if (_selectedPosition == "Manager" && data[x]["role"] == "Manager") {
            userList.add({
              'userId': data[x]["id"],
              'username': data[x]["username"],
              'position': data[x]["position"]
            });
          } else {
            for (int i = 0; i < positionList.length; i++) {
              if (positionList[i] == _selectedPosition &&
                  data[x]["id"] != sp.getInt("user_id").toString() &&
                  data[x]["role"] != "Manager") {
                userList.add({
                  'userId': data[x]["id"],
                  'username': data[x]["username"],
                  'position': data[x]["position"]
                });
              }
            }

            for (int y = 0; y < siteList.length; y++) {
              if (siteList[y] == _selectedPosition &&
                  data[x]["id"] != sp.getInt("user_id").toString() &&
                  data[x]["role"] != "Manager") {
                userList.add({
                  'userId': data[x]["id"],
                  'username': data[x]["username"],
                  'position': data[x]["position"]
                });
              }
            }
          }

          // }
          // else if (userRole == "Leader" && currentUserLeadFunc != '-') {
          //   for (int i = 0; i < positionList.length; i++) {
          //     if (positionList[i] == _selectedPosition &&
          //         data[x]["id"] != sp.getString("id") &&
          //         (data[x]["role"] == "Leader" || data[x]["role"] == "Staff")) {
          //       userList.add({
          //         'userId': data[x]["id"],
          //         'username': data[x]["user_name"],
          //         'position': data[x]["position"]
          //       });
          //     }
          //   }
        } else if (userRole == "Leader" && currentUserSiteLead != '-') {
          for (int y = 0; y < siteList.length; y++) {
            for (int i = 0; i < positionList.length; i++) {
              if (positionList[i] == _selectedPosition &&
                  data[x]["id"] != sp.getInt("user_id").toString() &&
                  (data[x]["role"] == "Leader" || data[x]["role"] == "Staff") &&
                  currentUserSiteLead.split(",").contains(siteList[y])) {
                if (!userList.any((user) => user['userId']
                    .toString()
                    .contains(data[x]["id"].toString()))) {
                  userList.add({
                    'userId': data[x]["id"],
                    'username': data[x]["username"],
                    'position': data[x]["position"],
                  });
                }
              }
            }
          }
        } else {
          for (int i = 0; i < positionList.length; i++) {
            if (positionList[i] == _selectedPosition &&
                data[x]["id"] != sp.getInt("user_id").toString() &&
                (data[x]["role"] == "Leader" || data[x]["role"] == "Staff")) {
              userList.add({
                'userId': data[x]["id"],
                'username': data[x]["username"],
                'position': data[x]["position"],
              });
            }
          }
        }
      }
    });
  }

  Future<void> getTeamData() async {
    List data = [];
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    await Internet.isInternet().then((connection) async {
      if (connection) {
        data = await Controller().getOnlineNonRecurring();
      } else {
        data = await cloneHelper.fetchNonrecurringData();
      }
    });
    EasyLoading.showSuccess('Done');
    allTeamNonRecurring = [];
    completedTeamNonRecurring = [];
    lateTeamNonRecurring = [];
    activeTeamNonRecurring = [];

    setState(() {
      for (int x = 0; x < data.length; x++) {
        DateTime dateEnd = DateTime.parse(data[x]["deadline"]);
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
          if (userRole == "Super Admin" || userRole == 'Manager') {
            final dayLeft = daysBetween(
                DateTime.now(), DateTime.parse(data[x]["deadline"]));

            if (data[x]["owner"] == _selectedUser) {
              if (data[x]["site"] == _selectedPosition) {
                allTeamNonRecurring.add(data[x]);
                if (data[x]["status"] == '100') {
                  completedTeamNonRecurring.add(data[x]);
                } else if (dayLeft.isNegative) {
                  lateTeamNonRecurring.add(data[x]);
                } else if (dayLeft >= 0) {
                  activeTeamNonRecurring.add(data[x]);
                }
              } else if (positionType.contains(_selectedPosition) ||
                  _selectedPosition == "Manager") {
                allTeamNonRecurring.add(data[x]);
                if (data[x]["status"] == '100') {
                  completedTeamNonRecurring.add(data[x]);
                } else if (dayLeft.isNegative) {
                  lateTeamNonRecurring.add(data[x]);
                } else if (dayLeft >= 0) {
                  activeTeamNonRecurring.add(data[x]);
                }
              }
            }
          } else if (userRole == "Leader" && currentUserSiteLead != '-') {
            // if (data[x]["site"] == currentUserSiteLead) {
            if (data[x]["owner"] == _selectedUser) {
              final dayLeft = daysBetween(
                  DateTime.now(), DateTime.parse(data[x]["deadline"]));

              allTeamNonRecurring.add(data[x]);
              if (data[x]["status"] == '100') {
                completedTeamNonRecurring.add(data[x]);
              } else if (dayLeft.isNegative) {
                lateTeamNonRecurring.add(data[x]);
              } else if (dayLeft >= 0) {
                activeTeamNonRecurring.add(data[x]);
              }
              // }
            }
          } else {
            if (data[x]["owner"] == _selectedUser) {
              final dayLeft = daysBetween(
                  DateTime.now(), DateTime.parse(data[x]["deadline"]));

              allTeamNonRecurring.add(data[x]);
              if (data[x]["status"] == '100') {
                completedTeamNonRecurring.add(data[x]);
              } else if (dayLeft.isNegative) {
                lateTeamNonRecurring.add(data[x]);
              } else if (dayLeft >= 0) {
                activeTeamNonRecurring.add(data[x]);
              }
            }
          }
        }
      }

      checkNum = 0;
      for (var item in allTeamNonRecurring) {
        if (item["checked"] == "Pending Review") {
          List person = item["personCheck"].split(',');
          for (var check in person) {
            if (check == currentUsername) {
              checkNum = checkNum + 1;
            }
          }
        }
      }
    });
  }

  Future<void> _show() async {
    final DateTimeRange result = await showDateRangePicker(
      context: context,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate, end: endDate)
          : null,
      // initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(DateTime.now().year - 50),
      lastDate: DateTime(DateTime.now().year + 50),
      saveText: 'Done',
    );

    if (result != null) {
      setState(() {
        startDate = result.start;
        endDate = result.end;
      });
      await getTeamData();
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NonRecurringTeam(
                  start: startDate,
                  end: endDate,
                  selectedUser: _selectedUser,
                  selectedPosition: _selectedPosition)));
    }
  }

  void _setDates(FilterOption option) async {
    setState(() {
      switch (option) {
        case FilterOption.thisYear:
          startDate = DateTime(DateTime.now().year, 1, 1);
          endDate = DateTime(DateTime.now().year, 12, 31);
          break;
        case FilterOption.lastMonth:
          var now = DateTime.now();
          startDate = DateTime(now.year, now.month - 1, 1);
          endDate = startDate.add(const Duration(days: 31));
          break;
        case FilterOption.lastYear:
          startDate = DateTime(DateTime.now().year - 1, 1, 1);
          endDate = DateTime(DateTime.now().year - 1, 12, 31);
          break;
        case FilterOption.thisMonth:
          var now = DateTime.now();
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
          break;
      }
    });
    await getTeamData();
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => NonRecurringTeam(
                  start: startDate,
                  end: endDate,
                  selectedUser: _selectedUser,
                  selectedPosition: _selectedPosition,
                )));
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
            height: height - height * 0.10,
            margin: EdgeInsets.only(
                top: height * 0.08, left: width * 0.02, right: width * 0.02),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Appbar(title: "Non-Recurring", scaffoldKey: scaffoldKey),
                  const Gap(5),
                  GestureDetector(
                    onTap: () {
                      _show();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.calendar_month, size: 15),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  "${DateFormat.yMMMMd('en_US').format(startDate).toString()} - ${DateFormat.yMMMMd('en_US').format(endDate).toString()}",
                                  style: TextStyle(
                                      color: Styles.textColor, fontSize: 12),
                                ),
                                const Gap(15),
                                // filter
                                PopupMenuButton<FilterOption>(
                                  offset: const Offset(0, 25),
                                  padding: EdgeInsets.zero,
                                  onSelected: _setDates,
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: FilterOption.thisYear,
                                      child: Text(
                                        'This Year',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: FilterOption.lastMonth,
                                      child: Text(
                                        'Last Month',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: FilterOption.lastYear,
                                      child: Text(
                                        'Last Year',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: FilterOption.thisMonth,
                                      child: Text(
                                        'This Month',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                  child: const SizedBox(
                                    height: 20,
                                    width: 25,
                                    child: Icon(
                                      Icons.filter_alt,
                                      size: 20,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child: Text("Team Overview Status", style: Styles.subtitle),
                  // ),
                  const Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  dropdownMaxHeight: 300,
                                  iconSize: 25,
                                  isExpanded: true,
                                  value: _selectedPosition == ''
                                      ? null
                                      : _selectedPosition,
                                  selectedItemHighlightColor: Colors.grey,
                                  hint: const Text(
                                    'Function/Site',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  // value: ,
                                  items: combineType
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) async {
                                    if (mounted) {
                                      setState(() {
                                        _selectedPosition = val;
                                        _selectedUser = '';
                                      });
                                      await fetchUsers();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              margin: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  dropdownMaxHeight: 300,
                                  iconSize: 25,
                                  isExpanded: true,
                                  hint: const Text(
                                    'User',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: _selectedUser == ''
                                      ? null
                                      : _selectedUser,
                                  selectedItemHighlightColor: Colors.grey,
                                  items: userList
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e['username'],
                                          child: Text(
                                            e["username"],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) async {
                                    if (mounted) {
                                      setState(() {
                                        _selectedUser = val;
                                      });
                                    }
                                    await getTeamData();
                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NonRecurringTeam(
                                                    start: startDate,
                                                    end: endDate,
                                                    selectedUser: _selectedUser,
                                                    selectedPosition:
                                                        _selectedPosition)));
                                  },
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  const Gap(5),
                  const Gap(10),
                  Expanded(
                    child: Container(
                      color: Styles.bgColor,
                      // margin: const EdgeInsets.symmetric(horizontal: 20),

                      child: Teamtask(
                          foundTeamNonRecurring: allTeamNonRecurring,
                          lateTeamNonRecurring: lateTeamNonRecurring,
                          activeTeamNonRecurring: activeTeamNonRecurring,
                          completedTeamNonRecurring: completedTeamNonRecurring,
                          selectedUser: _selectedUser),
                    ),
                  ),
                ])));
  }
}
