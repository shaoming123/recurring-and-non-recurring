//@dart=2.9
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';

import 'package:multiselect/multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/selection.dart';
import '../../util/checkInternet.dart';
import '../../util/conMysql.dart';
import '../../util/datetime.dart';
import '../../util/selection.dart';
import '../non_recurring.dart';
import 'package:http/http.dart' as http;

class addNonRecurring extends StatefulWidget {
  final String userName;
  final bool task;
  const addNonRecurring({Key key, this.userName, this.task}) : super(key: key);

  @override
  State<addNonRecurring> createState() => _addNonRecurringState();
}

Future<SharedPreferences> _pref = SharedPreferences.getInstance();

class _addNonRecurringState extends State<addNonRecurring> {
  final _formkey = GlobalKey<FormState>();
  DateTime due;
  DateTime startDate = DateTime.now();

  String _selectedUser;
  String _selectedSite = '';
  // String _selectedType = '';
  DateTime completeDate;
  final taskController = TextEditingController();
  final statusController = TextEditingController();
  final remarkController = TextEditingController();
  bool isTapped = false;
  List<String> siteList = <String>[];
  List<TypeSelect> typeList = <TypeSelect>[];
  List<dynamic> user = [];
  TypeSelect typeselect;
  List<String> checkUserList = [];
  List<String> _selectedCheckUser = [];
  var selectedCheckUser = ''.obs;

  dynamic _selectedCategory;
  String _selectedSubCategory;
  List<int> userid = [];
  List categoryData = [];
  bool check = false;
  String userPosition = '';
  String userRole = '';
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    statusController.text = '0';
    _selectedUser = widget.userName;
    Future.delayed(Duration.zero, () async {
      final SharedPreferences sp = await _pref;
      String userRole = sp.getString("role");
      List functionAccess = sp.getString("position").split(",");
      final typeOptions =
          await Selection().typeSelection(functionAccess, userRole);
      categoryData =
          await Selection().categorySelection(functionAccess, userRole);
      userPosition = sp.getString("position");
      //type selection
      List typeDate = [];
      typeDate = typeOptions;

      for (int i = 0; i < typeDate.length; i++) {
        typeList.add(TypeSelect(
            id: typeDate[i]['id'],
            value: typeDate[i]['value'],
            bold: typeDate[i]['bold']));
      }

      getData();
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    statusController.dispose();

    remarkController.dispose();

    super.dispose();
  }

  Future getData() async {
    final SharedPreferences sp = await _pref;
    final data = await dbHelper.getItems();
    final siteOptions = await Selection().siteSelection();
    String currentUserSiteLead = sp.getString("siteLead");
    String currentUsername = sp.getString("user_name");
    List functionData = sp.getString("position").split(",");
    userRole = sp.getString("role").toString();

    setState(() {
      //site selection
      for (final val in siteOptions) {
        siteList = val["options"];
      }

      // //type selection
      // List typeDate = [];
      // typeDate = typeOptions;
      // for (int i = 0; i < typeDate.length; i++) {
      //   typeList.add(TypeSelect(
      //       id: typeDate[i]['id'],
      //       value: typeDate[i]['value'],
      //       bold: typeDate[i]['bold']));
      // }
      // typeselect = typeList[0];

      // owner
      if (widget.task == false) {
        for (int i = 0; i < data.length; i++) {
          List positionList = data[i]["position"].split(",");
          List siteList = data[i]["site"].split(",");

          if (userRole == "Manager" || userRole == "Super Admin") {
            user.add({'username': data[i]["user_name"]});
          } else if (userRole == "Leader" && currentUserSiteLead != "-") {
            for (int y = 0; y < siteList.length; y++) {
              if ((data[i]["role"] == "Leader" || data[i]["role"] == "Staff") &&
                  siteList[y] == currentUserSiteLead &&
                  data[i]["user_id"] != sp.getInt("user_id")) {
                user.add({'username': data[i]["user_name"]});
              }
            }
          } else {
            for (int y = 0; y < positionList.length; y++) {
              for (int x = 0; x < functionData.length; x++) {
                if (positionList[y] == functionData[x] &&
                    (data[i]["role"] == "Leader" ||
                        data[i]["role"] == "Staff") &&
                    data[i]["user_id"] != sp.getInt("user_id")) {
                  user.add({'username': data[i]["user_name"]});
                }
              }
            }
          }
        }
      } else {
        user.add({'username': _selectedUser});
      }

      for (int i = 0; i < data.length; i++) {
        if (data[i]["role"] != "Staff" &&
            data[i]["user_name"] != currentUsername) {
          checkUserList.add(data[i]["user_name"]);
        }
      }
    });
  }

  Future pickDueDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        due = picked;
      });
    }
  }

  Future pickStartDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future pickCompleteDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        completeDate = picked;
      });
    }
  }

  Future saveNonRecurring() async {
    final SharedPreferences sp = await _pref;
    final isValid = _formkey.currentState.validate();
    if (isValid) {
      if (due == null) {
        AlertDialog alert = AlertDialog(
          title: const Text("Error"),
          content: const Text("Please select your deadline !"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      } else {
        var url =
            'https://ipsolutions4u.com/ipsolutions/recurringMobile/add.php';

        String selectedCheckUser = _selectedCheckUser.join(",");

        String currentUsername = sp.getString("user_name");

        if (_selectedCheckUser.isNotEmpty &&
            _selectedCheckUser != null &&
            statusController.text == '100') {
          for (var item in _selectedCheckUser) {
            Map<String, dynamic> notificationData = {
              "dataTable": "notification",
              'owner': item,
              'assigner': _selectedUser,
              'type': "Checking",
              'task': taskController.text,
              'deadline': DateFormat("yyyy-MM-dd").format(due).toString(),
              'noted': "No",
            };
            await http.post(Uri.parse(url), body: notificationData);
          }
        } else if (_selectedUser != currentUsername) {
          Map<String, dynamic> notificationData = {
            "dataTable": "notification",
            'owner': _selectedUser,
            'assigner': currentUsername,
            'type': "Non-recurring",
            'task': taskController.text,
            'deadline': DateFormat("yyyy-MM-dd").format(due).toString(),
            'noted': "No",
          };

          await http.post(Uri.parse(url), body: notificationData);
        }

        // final nonrecurring = nonRecurring(
        //     category: _selectedVal,
        //     subCategory: _selectedVal,
        //     type: _selectedVal,
        //     site: _selectedSite,
        //     task: taskController.text,
        //     owner: _selectedUser,
        //     startDate: startDate.toString(),
        //     due: due.toString(),
        //     modify: DateTime.now().toString(),
        //     remark: remarkController.text,
        //     completeDate: completeDate.toString(),
        //     status: statusController.text);

        // await dbHelper.addNonRecurring(nonrecurring);

        Map<String, dynamic> data = {
          "dataTable": "nonrecurring",
          "category": _selectedCategory["variables"] +
              "|" +
              _selectedCategory["department"],
          "subCategory": _selectedSubCategory,
          "type": typeselect.value,
          "site": _selectedSite,
          "task": taskController.text,
          "owner": _selectedUser,
          "startDate": DateFormat("yyyy-MM-dd").format(startDate).toString(),
          "due": DateFormat("yyyy-MM-dd").format(due).toString(),
          "modify": DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
          "remark": remarkController.text,
          "completeDate": completeDate != null
              ? DateFormat("yyyy-MM-dd").format(completeDate).toString()
              : '',
          "checked": check == false ? "-" : "Pending Review",
          "personCheck": selectedCheckUser.isEmpty ? "-" : selectedCheckUser,
          "status": statusController.text,
          "department": userPosition
        };

        final response = await http.post(Uri.parse(url), body: data);

        if (response.statusCode == 200) {
          if (!mounted) return;

          FocusScope.of(context).requestFocus(FocusNode());
          await Internet.isInternet().then((connection) async {
            if (connection) {
              EasyLoading.show(
                status: 'Adding and Loading Data ...',
                maskType: EasyLoadingMaskType.black,
              );
              // await Controller().syncdata();
              await Controller().addNonRecurringToSqlite();

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NonRecurring()),
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Adding Successful !"),
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
              EasyLoading.showSuccess('Successfully');
            }
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Adding Unsuccessful !"),
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Widget buildTextField(String labelText, String placeholder,
        TextEditingController controllerText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText,
            style: const TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: TextFormField(
                maxLines: labelText == "Task" ? 8 : null,
                cursorColor: Colors.black,
                style: const TextStyle(fontSize: 14),
                keyboardType:
                    labelText == "Status" ? TextInputType.number : null,
                decoration: InputDecoration(hintText: placeholder),
                onFieldSubmitted: (_) {},
                controller: controllerText,
                validator: labelText != "Remark"
                    ? labelText == "Status"
                        ? (data) {
                            if (double.parse(data) < 0.0 ||
                                double.parse(data) > 100.0) {
                              return 'Value must be between 0 and 100';
                            }
                            return null;
                          }
                        : (data) {
                            return data != null && data.isEmpty
                                ? 'Field cannot be empty'
                                : null;
                          }
                    : null),
          ),
        ],
      );
    }

    Widget dropdownList(String labelText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText,
            style: const TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                value: _selectedCategory != null
                    ? _selectedCategory['options']
                            .contains(_selectedSubCategory)
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
          ),
        ],
      );
    }

    Widget dropdownCategory() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Category',
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                hint: const Text("Choose item"),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))
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
          ),
        ],
      );
    }

    Widget dropdownType() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Type',
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                hint: const Text("Choose item"),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
          ),
        ],
      );
    }

    Widget dropdownSite() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Site',
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
          ),
        ],
      );
    }

    Widget dropdownOwner() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Owner",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                value: _selectedUser == '' ? null : _selectedUser,
                selectedItemHighlightColor: Colors.grey,
                validator: (value) {
                  return value == null ? 'Please select' : null;
                },
                items: List.generate(
                  user.length,
                  (index) => DropdownMenuItem(
                    value: user[index]["username"].toString(),
                    child: Text(
                      user[index]["username"].toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedUser = val;
                  });
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget checkRequest() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                "Required Checking?",
                style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
              ),
              const Gap(10),
              Container(
                padding: const EdgeInsets.all(0),
                width: 14,
                height: 14,
                color: Colors.white,
                child: Checkbox(
                  checkColor: Colors.white,
                  activeColor: Colors.blue,
                  value: check,
                  onChanged: (value) {
                    setState(() {
                      check = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: check == true ? const Color(0xFFd4dce4) : Colors.grey),
            child: DropdownButtonHideUnderline(
              child: DropDownMultiSelect(
                enabled: check == true ? true : false,
                decoration: const InputDecoration(border: InputBorder.none),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                options: checkUserList,

                // whenEmpty: 'Select position',
                onChanged: (value) {
                  setState(() {
                    _selectedCheckUser = value;
                    selectedCheckUser.value = "";

                    for (var element in _selectedCheckUser) {
                      selectedCheckUser.value =
                          "${selectedCheckUser.value}  $element";
                    }

                    // if (selectedPosition.isNotEmpty) {
                    //   checkFunctionAccess = true;
                    // }
                  });
                },
                selectedValues: _selectedCheckUser,
              ),
            ),
          ),
        ],
      );
    }

    Widget deadlineSelect() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Deadline",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: ListTile(
              title: Text(
                due == null ? 'dd/mm/yy' : Utils.toDate(due),
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                pickDueDate();
              },
            ),
          ),
        ],
      );
    }

    Widget createdOn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Created On",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Text(
            "( autofill )",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: ListTile(
              title: Text(
                Utils.toDate(startDate),
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                pickStartDate();
              },
            ),
          ),
        ],
      );
    }

    Widget completedDateSelect() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Completed Date",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Text(
            "( autofill when status = 100 )",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                pickCompleteDate();
              },
            ),
          ),
        ],
      );
    }

    return Stack(children: <Widget>[
      Container(
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
                const Text("Add Task",
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
              child: Column(children: <Widget>[
                dropdownCategory(),
                dropdownList("Sub-Category"),
                dropdownType(),
                dropdownSite(),
                buildTextField("Task", "description", taskController),
                dropdownOwner(),
                deadlineSelect(),
                buildTextField("Status", "0", statusController),
                buildTextField(
                    "Remark", "Additional Remark...", remarkController),
                Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.all(20.0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.white)),
                    child: Column(
                      children: [
                        createdOn(),
                        completedDateSelect(),
                        checkRequest(),
                      ],
                    )),
              ]),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(10),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF60b4b4)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                  ),
                  onPressed: () async {
                    await Internet.isInternet().then((connection) async {
                      if (connection) {
                        if (!isTapped) {
                          isTapped = true;
                          await saveNonRecurring();
                        }
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
                    "Save",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFd4dce4),
                        fontWeight: FontWeight.w700),
                  )),
            ),
          ]))
    ]);
  }
}
