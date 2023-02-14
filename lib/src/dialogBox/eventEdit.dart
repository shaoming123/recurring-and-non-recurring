//@dart=2.9
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/CloneHelper.dart';

import 'package:multiselect/multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../databaseHandler/Clone2Helper.dart';
import '../../model/event.dart';
import '../../model/selection.dart';
import '../../util/checkInternet.dart';

import '../../util/cloneData.dart';
import '../../util/datetime.dart';
import '../../util/selection.dart';
import '../recurrring.dart';
import 'package:http/http.dart' as http;

class EventEdit extends StatefulWidget {
  final String id;
  final List<String> user_list;
  const EventEdit({Key key, this.id, this.user_list}) : super(key: key);

  @override
  State<EventEdit> createState() => _EventEditState();
}

class _EventEditState extends State<EventEdit> {
  // DbHelper dbHelper = DbHelper();
  CloneHelper cloneHelper = CloneHelper();
  String recurringId;
  DateTime recurringDate;
  DateTime completeDate;
  String _selectedStatus = '';

  TextEditingController taskController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController recurringController = TextEditingController();
  final remarkController = TextEditingController();

  List<Map<String, dynamic>> event_edit = [];

  List<String> siteList = <String>[];
  List<String> priorityList = <String>['Low', 'Moderate', 'High'];
  List<String> statusList = <String>['Upcoming', 'In Progress', 'Done'];
  final _formkey = GlobalKey<FormState>();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  var rng = Random();

  String _selectedPriority = '';
  bool isTapped = false;
  String _selectedRecurring = '';
  String _selectedSite = '';

  List<Map<String, dynamic>> event_data = [];
  List<Event> event_recurring = [];

  List<String> selectedUsers = <String>[];

  var _selectedOption = ''.obs;
  List<String> userList = <String>[];
  bool checkUser = false;
  bool internet = false;
  String _selectedType = '';
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  List categoryData = [];
  List<TypeSelect> typeList = <TypeSelect>[];
  TypeSelect typeselect;
  dynamic _selectedCategory;
  String _selectedSubCategory = '';
  List<String> _selectedData = [];
  String currentUserSiteLead;
  Clone2Helper clone2Helper = Clone2Helper();
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getEditData(int.parse(widget.id));
      await Internet.isInternet().then((connection) async {
        setState(() {
          internet = connection;
        });
        if (connection) {
          await getData();
          final SharedPreferences sp = await _pref;
          List functionAccess = sp.getString("position").split(",");
          String userRole = sp.getString("role");
          final typeOptions = await Selection()
              .typeSelection(functionAccess, userRole, currentUserSiteLead);
          categoryData = await Selection()
              .categorySelection(functionAccess, userRole, currentUserSiteLead);

          //type selection
          setState(() {
            List typeDate = [];
            typeDate = typeOptions;
            for (int i = 0; i < typeDate.length; i++) {
              typeList.add(TypeSelect(
                  id: typeDate[i]['id'],
                  value: typeDate[i]['value'],
                  bold: typeDate[i]['bold']));
            }

            for (final val in typeList) {
              if (val.value == _selectedType) {
                typeselect = val;

                break;
              }
            }

            for (final item in categoryData) {
              // print(item['value']);
              if (item['bold'] == false &&
                  item['value']['department'] == _selectedData[1] &&
                  item['value']['variables'] == _selectedData[0]) {
                _selectedCategory = item['value'];
              }
            }
          });
        }
      });
    });
    super.initState();
  }

  Future<void> getEditData(int id) async {
    final SharedPreferences sp = await _pref;

    List event_edit = [];
    List event_data = [];

    await Internet.isInternet().then((connection) async {
      if (connection) {
        event_edit = await Controller().getAOnlineRecurring(id);
        event_data = await Controller().getOnlineRecurring();
      } else {
        event_edit = await cloneHelper.fetchARecurring(id);

        event_data = await cloneHelper.fetchRecurringData();
      }
    });

    String userRole = sp.getString("role");
    currentUserSiteLead = sp.getString("siteLead");
    isOnline = await Internet.isInternet();
    final userData = isOnline
        ? await Controller().getOnlineUser()
        : await clone2Helper.getUser();
    userList = [];

    setState(() {
      recurringId = event_edit[0]['id'].toString();

      fromDate = DateTime.parse(event_edit[0]['start']);
      toDate = DateTime.parse(event_edit[0]['end']);
      _selectedData = event_edit[0]['category'].split("|");

      _selectedSubCategory = event_edit[0]['subcategory'];
      _selectedType = event_edit[0]['type'];
      _selectedSite = event_edit[0]['site'];
      _selectedPriority = event_edit[0]['priority'];
      _selectedStatus = event_edit[0]['status'];
      selectedUsers = event_edit[0]['person'].split(',');
      taskController.text = event_edit[0]['task'];
      durationController.text = event_edit[0]['duration'];
      _selectedRecurring = event_edit[0]['recurring'];
      recurringController.text = event_edit[0]['recurringGap'];
      remarkController.text = event_edit[0]['remarks'];
      // recurringDate = DateTime.parse(event_edit[0]['recurringUntil']);

      if (event_edit[0]['completedDate'] != null &&
          (event_edit[0]['completedDate']) != '') {
        completeDate = DateTime.parse(event_edit[0]['completedDate']);
      }
      // print(selectedUsers);
      //User List
      userList.addAll(selectedUsers);

      List functionData = sp.getString("position").split(",");

      for (int i = 0; i < userData.length; i++) {
        List siteData = userData[i]["site"].split(",");
        List positionList = userData[i]["position"].split(",");
        if (userRole == "Manager" || userRole == "Super Admin") {
          userList.add(userData[i]["username"]);
        } else if (userRole == "Leader" && currentUserSiteLead != "-") {
          for (int y = 0; y < siteData.length; y++) {
            if ((userData[i]["role"] == "Leader" ||
                    userData[i]["role"] == "Staff") &&
                currentUserSiteLead.split(",").contains(siteData[y])) {
              if (!userList.contains(userData[i]["username"])) {
                userList.add(userData[i]["username"]);
              }
            }
          }
        } else {
          for (int y = 0; y < positionList.length; y++) {
            for (int x = 0; x < functionData.length; x++) {
              if (positionList[y] == functionData[x] &&
                  (userData[i]["role"] == "Leader" ||
                      userData[i]["role"] == "Staff")) {
                if (userList.contains(userData[i]['username'])) {
                } else {
                  userList.add(userData[i]["username"]);
                }
              }
            }
          }
        }
      }
      userList = userList.toSet().toList();

      // List<String> modifiedList = widget.user_list
      //   ..removeWhere((item) => item == 'All');
    });

    String uniqueNumber = event_edit[0]['unique'];
    String dependent = event_edit[0]['dependent'];

    for (var item in event_data) {
      if (item["id"].toString() != recurringId &&
          uniqueNumber == item["unique"] &&
          dependent == item["dependent"]) {
        event_recurring.add(Event.fromMap(item));
      }
    }
  }

  Future<void> getData() async {
    final siteOptions = await Selection().siteSelection();
    setState(() {
      for (final val in siteOptions) {
        siteList = val["options"];
      }
    });
  }

  Future pickCompleteDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: fromDate,
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        completeDate = picked;
      });
    }
  }

  Future pickFromDateTime({bool pickdate}) async {
    final date = await pickDateTime(fromDate, pickdate: pickdate);
    if (date == null) return;

    setState(() {
      fromDate = date;
    });
  }

  Future pickToDateTime({bool pickdate, int durationDay}) async {
    final date = await pickDateTime(toDate,
        pickdate: pickdate, durationDay: durationDay);
    if (date == null) return;

    setState(() {
      toDate = date;
    });
  }

  //Put date and time format together in one object
  Future<DateTime> pickDateTime(
    DateTime initialDate, {
    bool pickdate,
    int durationDay,
    DateTime firstDate,
  }) async {
    if (pickdate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));

      if (date == null) return null;

      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    } else {
      final timeofDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));

      if (timeofDay == null) return null;

      if (durationDay != null) {
        final date = DateTime(fromDate.year, fromDate.month, fromDate.day)
            .add(Duration(days: durationDay));
        final time = Duration(hours: timeofDay.hour, minutes: timeofDay.minute);
        return date.add(time);
      } else {
        final date =
            DateTime(initialDate.year, initialDate.month, initialDate.day);
        final time = Duration(hours: timeofDay.hour, minutes: timeofDay.minute);

        return date.add(time);
      }
    }
  }

  Future<void> updateEvent(String recurringId) async {
    final isValid = _formkey.currentState.validate();
    String selectedUser = selectedUsers.join(",");
    String color;
    if (isValid) {
      // final event = Event(
      //     recurringId: recurringId,
      //     category: _selectedVal,
      //     subCategory: _selectedVal,
      //     type: _selectedVal,
      //     site: _selectedSite,
      //     task: taskController.text,
      //     from: fromDate.toString(),
      //     to: toDate.toString(),
      //     person: selectedUser,
      //     // rule: 'FREQ=DAILY;INTERVAL=1;COUNT=20',
      //     // backgroundColor: calendarColor.toString(),
      //     duration: durationController.text,
      //     priority: _selectedPriority,
      //     recurringOpt: _selectedRecurring,
      //     recurringEvery:
      //         recurringController.text.isEmpty ? '0' : recurringController.text,
      //     recurringUntil: recurringDate.toString(),
      //     remark: remarkController.text,
      //     completeDate: completeDate.toString(),
      //     status: _selectedStatus);

      // await dbHelper.updateEvent(event);

      // get the correct toDate again ( to prevent user didnt click the end time )
      DateTime to_date =
          DateTime(fromDate.year, fromDate.month, fromDate.day).add(
        Duration(
          days: int.parse(durationController.text) - 1,
        ),
      );
      toDate = to_date.add(
        Duration(hours: toDate.hour, minutes: toDate.minute),
      );

      if (_selectedPriority == "Low") {
        color = "lightgreen";
      } else if (_selectedPriority == "Moderate") {
        color = "palegoldenrod";
      } else if (_selectedPriority == "High") {
        color = "lightcoral";
      }

      var url =
          'https://ipsolutions4u.com/ipsolutions/recurringMobile/edit.php';
      int dependent_code = rng.nextInt(900000000) + 100000000;
      // edit same recurring
      if (event_recurring.isNotEmpty) {
        for (var item in event_recurring) {
          if (item.checkRecurring == "true") {
            Map<String, dynamic> data = {
              "dataTable": "tasks",
              "recurringId": item.recurringId.toString(),
              "category": _selectedCategory["variables"] +
                  "|" +
                  _selectedCategory["department"],
              "subCategory": _selectedSubCategory,
              "type": typeselect.value,
              "site": _selectedSite,
              "task": taskController.text,
              "start": item.from.toString(),
              "end": item.to.toString(),
              "date": DateFormat("y-M-d")
                  .format(DateTime.parse(item.from))
                  .toString(),
              "deadline": DateFormat("y-M-d")
                  .format(DateTime.parse(item.to))
                  .toString(),
              "startTime":
                  DateFormat.Hm().format(DateTime.parse(item.from)).toString(),
              "dueTime":
                  DateFormat.Hm().format(DateTime.parse(item.to)).toString(),
              "duration": durationController.text,
              "person": selectedUser,
              "priority": _selectedPriority,
              "color": color,
              // "startDate": DateFormat("yyyy-MM-dd").format(startDate).toString(),
              // "deadline": DateFormat("yyyy-MM-dd").format(due!).toString(),
              "recurringOpt": _selectedRecurring,
              "recurringEvery": recurringController.text.isEmpty
                  ? '0'
                  : recurringController.text,
              "remark": remarkController.text,

              "completeDate": completeDate != null
                  ? DateFormat("yyyy-MM-dd").format(completeDate).toString()
                  : '',

              "status": _selectedStatus,
              "dependent": dependent_code.toString(),
            };
            await http.post(Uri.parse(url), body: data);
          }
        }
      }

      // current data
      Map<String, dynamic> data = {
        "dataTable": "tasks",
        "recurringId": recurringId.toString(),
        "category": _selectedCategory["variables"] +
            "|" +
            _selectedCategory["department"],
        "subCategory": _selectedSubCategory,
        "type": typeselect.value,
        "site": _selectedSite,
        "task": taskController.text,
        "start": fromDate.toString(),
        "end": toDate.toString(),
        "date": DateFormat("y-M-d").format(fromDate).toString(),
        "deadline": DateFormat("y-M-d").format(toDate).toString(),
        "startTime": DateFormat.Hm().format(fromDate).toString(),
        "dueTime": DateFormat.Hm().format(toDate).toString(),
        "person": selectedUser,
        "duration": durationController.text,
        "priority": _selectedPriority,
        "color": color,
        // "startDate": DateFormat("yyyy-MM-dd").format(startDate).toString(),
        // "deadline": DateFormat("yyyy-MM-dd").format(due!).toString(),
        "recurringOpt": _selectedRecurring,
        "recurringEvery":
            recurringController.text.isEmpty ? '0' : recurringController.text,
        "remark": remarkController.text,

        "completeDate": completeDate != null
            ? DateFormat("yyyy-MM-dd").format(completeDate).toString()
            : '',

        "status": _selectedStatus,
        "dependent": dependent_code.toString(),
      };
      final response = await http.post(Uri.parse(url), body: data);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Updated Successfully!"),
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
        ),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        FocusScope.of(context).requestFocus(FocusNode());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Recurring()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Updated Successfully!"),
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
          ),
        );
        EasyLoading.showSuccess('Successfully');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Updated Unsuccessful !"),
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
  }

  Future<void> removeEvent(String recurring_Id) async {
    var url =
        'https://ipsolutions4u.com/ipsolutions/recurringMobile/delete.php';

    var response;

    if (event_recurring.isNotEmpty) {
      for (var item in event_recurring) {
        if (item.checkRecurring == "true") {
          await http.post(Uri.parse(url), body: {
            "dataTable": "tasks",
            "id": item.recurringId.toString(),
          });
        }
      }
    }

    response = await http.post(Uri.parse(url), body: {
      "dataTable": "tasks",
      "id": recurring_Id.toString(),
    });
    if (response.statusCode == 200) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Recurring()),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Successfully deleted!'),
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

  Future<void> deleteItem(BuildContext context, String id) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Are you sure you want to delete this item?',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red[600],
                        ),
                      ),
                      onPressed: () async {
                        await removeEvent(id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  contentBox(context) {
    Widget categoryDropdown() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<dynamic>(
            iconSize: 30,
            isExpanded: true,
            hint: Text(_selectedData.isNotEmpty
                ? _selectedData[0].toString()
                : "Choose item"),
            value: _selectedCategory,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: [
              for (final item in categoryData)
                item["bold"] == true
                    ? DropdownMenuItem(
                        enabled: false,
                        child: Text(item['value'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)))
                    : DropdownMenuItem(
                        value: item['value'],
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(item['value']['variables']),
                        ))
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
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

    Widget subCategoryDropdown() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: Text(_selectedSubCategory.toString()),
            value: _selectedCategory != null
                ? _selectedCategory['options'].contains(_selectedSubCategory)
                    ? _selectedSubCategory
                    : null
                : null,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: _selectedCategory != null
                ? [
                    for (final item in _selectedCategory['options'])
                      DropdownMenuItem(value: item, child: Text(item))
                  ]
                : [],
            onChanged: (val) {
              setState(() {
                _selectedSubCategory = val;
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

    Widget typeDropdown() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<TypeSelect>(
            iconSize: 30,
            isExpanded: true,
            hint: Text(internet ? "" : _selectedType),
            value: typeselect,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: typeList.map((TypeSelect e) {
              return e.bold == "true"
                  ? DropdownMenuItem<TypeSelect>(
                      enabled: false,
                      child: Text(
                        e.value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : DropdownMenuItem<TypeSelect>(
                      value: e,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          e.value,
                        ),
                      ),
                    );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                typeselect = newValue;
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

    Widget userSite() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: Text(internet ? "" : _selectedSite),
            value: _selectedSite == '' ? null : _selectedSite,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: siteList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              String test = val;
              setState(() {
                _selectedSite = test;
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

    Widget userPrio() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: _selectedPriority == '' ? null : _selectedPriority,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: priorityList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              String test = val;
              setState(() {
                _selectedPriority = test;
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

    Widget TaskText() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: TextFormField(
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 14),
          maxLines: 8, //or null
          decoration: const InputDecoration(hintText: 'Description...'),
          onFieldSubmitted: (_) {},
          controller: taskController,
          validator: (task) {
            return task != null && task.isEmpty ? 'Task cannot be empty' : null;
          },
        ),
      );
    }

    Widget DurationField() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: TextFormField(
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter your day'),
          onFieldSubmitted: (_) {},
          controller: durationController,
          validator: (duration) {
            return duration != null && duration.isEmpty
                ? 'Duration cannot be empty'
                : null;
          },
        ),
      );
    }

    Widget FromDateSelect() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: ListTile(
          title: Text(
            Utils.toDate(fromDate),
            style: const TextStyle(fontSize: 14),
          ),
          trailing: const Icon(
            Icons.calendar_month,
            color: Colors.black,
            size: 20,
          ),
          onTap: () {
            pickFromDateTime(pickdate: true);
          },
        ),
      );
    }

    Widget TimeSelect() {
      return Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFd4dce4)),
              child: ListTile(
                title: Text(
                  Utils.toTime(fromDate),
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(
                  Icons.access_time,
                  color: Colors.black,
                  size: 20,
                ),
                onTap: () {
                  pickFromDateTime(pickdate: false);
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: const Text(
              "to",
              style: TextStyle(
                fontSize: 14,
                color: Color(0XFFd4dce4),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFd4dce4)),
              child: ListTile(
                title: Text(
                  Utils.toTime(toDate),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(
                  Icons.access_time,
                  color: Colors.black,
                  size: 20,
                ),
                onTap: () {
                  pickToDateTime(
                      pickdate: false,
                      durationDay: int.parse(durationController.text) - 1);
                },
              ),
            ),
          ),
        ],
      );
    }

    Widget userTotal() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: DropdownButtonHideUnderline(
              child: DropDownMultiSelect(
                decoration: const InputDecoration(border: InputBorder.none),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                options: userList,
                onChanged: (value) {
                  setState(() {
                    selectedUsers = value;
                    _selectedOption.value = "";

                    for (var element in selectedUsers) {
                      _selectedOption.value =
                          "${_selectedOption.value}  $element";
                    }
                  });
                },
                selectedValues: selectedUsers,
              ),
            ),
          ),
        ],
      );
    }

    Widget remarkField() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: TextFormField(
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(hintText: 'Additional Remark.....'),
          onFieldSubmitted: (_) {},
          controller: remarkController,
        ),
      );
    }

    Widget completedDate() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: ListTile(
          title: Text(
            completeDate == null ? 'dd/mm/yy' : Utils.toDate(completeDate),
            style: const TextStyle(fontSize: 14),
          ),
          trailing: const Icon(
            Icons.calendar_month,
            color: Colors.black,
            size: 20,
          ),
          onTap: () {
            pickCompleteDate();
          },
        ),
      );
    }

    Widget userStatus() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: _selectedStatus == '' ? null : _selectedStatus,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: statusList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              String test = val;
              setState(() {
                _selectedStatus = test;
              });

              if (_selectedStatus == 'Done') {
                setState(() {
                  completeDate = DateTime.now();
                });
              }
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    Widget recurringDataTable() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Center(
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.white),
                child: FittedBox(
                  child: DataTable(
                      horizontalMargin: 0,
                      dividerThickness: 2,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'No.',
                            style: TextStyle(
                                color: Color(0xFFd4dce4),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Date',
                              style: TextStyle(
                                  color: Color(0xFFd4dce4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Update/Delete',
                            style: TextStyle(
                                color: Color(0xFFd4dce4),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: event_recurring.length > 0
                          ? List.generate(
                              event_recurring.length,
                              (index) => DataRow(cells: [
                                    DataCell(
                                      Center(
                                        child: Text(
                                          (index + 1).toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    DataCell(Center(
                                      child: Text(
                                        event_recurring[index].date,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    )),
                                    DataCell(
                                      Center(
                                        child: Theme(
                                          data: ThemeData(
                                            primarySwatch: Colors.blue,
                                            unselectedWidgetColor:
                                                Colors.white, // Your color
                                          ),
                                          child: Checkbox(
                                            value: event_recurring[index]
                                                        .checkRecurring ==
                                                    "false"
                                                ? false
                                                : true,
                                            onChanged: (newValue) {
                                              setState(() {
                                                event_recurring[index]
                                                        .checkRecurring =
                                                    newValue.toString();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]))
                          : const <DataRow>[
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                ],
                              ),
                            ]
                      // List.generate(checkListItems.length, (index) {
                      //   return DataRow(cells: [
                      //     DataCell(Text(checkListItems[index]["id"].toString())),
                      //     DataCell(Text(checkListItems[index]["title"])),
                      //     DataCell(
                      //       Checkbox(
                      //         value: checkListItems[index]["value"],
                      //         onChanged: (newValue) {
                      //           setState(() {
                      //             checkListItems[index]["value"] = newValue!;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     DataCell(Text(checkListItems[index]["title"]))
                      //   ]);
                      // }
                      // ),
                      ),
                ),
              ),
            ),
            event_recurring.isEmpty
                ? Column(
                    children: const [
                      Text("The associate events have been altered.",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Divider(color: Colors.white)
                    ],
                  )
                : Container()
          ],
        ),
      );
    }

    double width = MediaQuery.of(context).size.width;

    return Stack(children: <Widget>[
      Container(
          width: width,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xFF384464),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Edit Task",
                    style: TextStyle(
                        color: Color(0xFFd4dce4),
                        fontSize: 26,
                        fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0XFFd4dce4),
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Gap(20),
            Form(
              key: _formkey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      "Category :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    categoryDropdown(),
                    const Text(
                      "Sub-Category :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    subCategoryDropdown(),
                    const Text(
                      "Type :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    typeDropdown(),
                    const Text(
                      "Site :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userSite(),
                    const Text(
                      "Task :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    TaskText(),
                    const Text(
                      "Date :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    FromDateSelect(),
                    const Text(
                      "Duration :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    DurationField(),
                    const Text(
                      "Time :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    TimeSelect(),
                    const Text(
                      "Person :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userTotal(),
                    const Text(
                      "Priority :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userPrio(),
                    const Text(
                      "Recurring :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        "*****$_selectedRecurring*****",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    recurringDataTable(),
                    const Text(
                      "Remark :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    remarkField(),
                    const Text(
                      "Completed Date : ",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Text(
                      "( autofill when status is Done )",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Gap(10),
                    completedDate(),
                    const Text(
                      "Status :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userStatus(),
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(10),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                    ),
                    onPressed: () async {
                      await Internet.isInternet().then((connection) async {
                        if (connection) {
                          await deleteItem(context, recurringId);
                        } else {
                          Navigator.of(context).pop();
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
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFd4dce4),
                          fontWeight: FontWeight.w700),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              side: const BorderSide(
                                width: 3.0,
                                color: Color(0xFF60b4b4),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF60b4b4),
                                fontWeight: FontWeight.w700),
                          )),
                    ),
                    TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(10),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF60b4b4)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                        ),
                        onPressed: () async {
                          await Internet.isInternet().then((connection) async {
                            if (connection) {
                              if (!isTapped) {
                                isTapped = true;
                                await updateEvent(recurringId);
                              }
                            } else {
                              Navigator.of(context).pop();
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
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFd4dce4),
                              fontWeight: FontWeight.w700),
                        )),
                  ],
                ),
              ],
            ),
          ]))
    ]);
  }
}
