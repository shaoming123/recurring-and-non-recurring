//@dart=2.9
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/selection.dart';
import 'package:ipsolution/util/selection.dart';
import 'package:multiselect/multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../databaseHandler/CloneHelper.dart';
import '../../util/checkInternet.dart';

import '../../util/cloneData.dart';
import '../../util/datetime.dart';
import '../nonRecurringTask.dart';

class editNonRecurring extends StatefulWidget {
  final String id;
  const editNonRecurring({Key key, this.id}) : super(key: key);

  @override
  State<editNonRecurring> createState() => _editNonRecurringState();
}

List<dynamic> user = [];
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

class _editNonRecurringState extends State<editNonRecurring> {
  final _formkey = GlobalKey<FormState>();
  DateTime due;
  DateTime startDate = DateTime.now();
  String _selectedUser = '';
  String _selectedSite = '';
  String _selectedType = '';
  DateTime completeDate;
  DateTime modify;
  List nonRecurring_edit = [];
  TextEditingController taskController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  List<String> siteList = <String>[];
  bool isTapped = false;
  List<String> checkUserList = [];
  List<String> _selectedCheckUser = [];
  var selectedCheckUser = ''.obs;
  bool check = false;
  bool internet = false;
  List<int> userid = [];
  List categoryData = [];
  List<TypeSelect> typeList = <TypeSelect>[];
  TypeSelect typeselect;
  dynamic _selectedCategory;
  String _selectedSubCategory = '';
  List _selectedData = [];
  String userPosition;
  DbHelper dbHelper = DbHelper();
  CloneHelper cloneHelper = CloneHelper();
  Future _future;
  bool isOnline;
  @override
  void initState() {
    super.initState();

    _future = Future.delayed(Duration.zero, () async {
      await getDataDetails(int.parse(widget.id));
      await Internet.isInternet().then((connection) async {
        setState(() {
          internet = connection;
        });
        if (connection) {
          final SharedPreferences sp = await _pref;
          userPosition = sp.getString("position");
          List functionAccess = sp.getString("position").split(",");
          String userRole = sp.getString("role");
          final typeOptions =
              await Selection().typeSelection(functionAccess, userRole);
          categoryData =
              await Selection().categorySelection(functionAccess, userRole);

          // user table
          var url =
              'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';
          var response = await http
              .post(Uri.parse(url), body: {"tableName": "user_details"});

          List userData = json.decode(response.body);

          // selection
          final siteOptions = await Selection().siteSelection();

          setState(() {
            user = userData;

            /////
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
                setState(() {
                  typeselect = val;
                });

                break;
              }
            }
            //////

            ///
            for (final val in siteOptions) {
              siteList = val["options"];
            }

            ///

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
  }

  @override
  void dispose() {
    _future.then((_) => null); // Cancel the future
    super.dispose();
  }

  Future<void> getDataDetails(int id) async {
    isOnline = await Internet.isInternet();
    nonRecurring_edit = isOnline
        ? await Controller().getAOnlineNonRecurring(id)
        : await cloneHelper.fetchANonRecurring(id);

    final data = await dbHelper.getItems();

    setState(() {
      for (int i = 0; i < data.length; i++) {
        if (data[i]["role"] != "Staff") {
          checkUserList.add(data[i]["user_name"]);
        }
      }

      if (nonRecurring_edit[0]['checked'] != '-' &&
          nonRecurring_edit[0]['personCheck'] != '-') {
        check = true;
      }

      _selectedData = nonRecurring_edit[0]['category'].split("|");
      _selectedSubCategory = nonRecurring_edit[0]['subcategory'];
      _selectedType = nonRecurring_edit[0]['type'];
      _selectedSite = nonRecurring_edit[0]['site'];
      _selectedUser = nonRecurring_edit[0]['owner'];
      statusController.text = nonRecurring_edit[0]['status'];
      taskController.text = nonRecurring_edit[0]['task'];
      remarkController.text = nonRecurring_edit[0]['remarks'];
      due = DateTime.parse(nonRecurring_edit[0]['deadline']);

      if (nonRecurring_edit[0]['personCheck'] != '-') {
        _selectedCheckUser = nonRecurring_edit[0]['personCheck'].split(",");
      }
      if (nonRecurring_edit[0]['completedDate'] != null &&
          nonRecurring_edit[0]['completedDate'].isNotEmpty) {
        completeDate = DateTime.parse(nonRecurring_edit[0]['completedDate']);
      }
      if (nonRecurring_edit[0]['createdDate'] != null &&
          nonRecurring_edit[0]['createdDate'].isNotEmpty) {
        startDate = DateTime.parse(nonRecurring_edit[0]['createdDate']);
      }

      if (nonRecurring_edit[0]['lastMod'] != null &&
          nonRecurring_edit[0]['lastMod'].isNotEmpty) {
        modify = DateTime.parse(nonRecurring_edit[0]['lastMod']);
      }

      // for (final val in categoryData) {
      //   print(val['value']);
      //   if (val['value']['variable'] == _selectedData[0] &&
      //       val['value'] == _selectedData[1]) {}
      // }

      // for (int i = 0; i < userData.length; i++) {
      //   if (_selectedUser != userData[i]["username"]) {
      //     user.add({
      //       'userId': userData[i]["id"],
      //       'username': userData[i]["username"]
      //     });
      //   }
      // }
    });
  }

  Future pickDueDate() async {
    final duepicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (duepicked != null) {
      setState(() {
        due = duepicked;
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

  Future<void> updateNonRecurring(int id) async {
    final SharedPreferences sp = await _pref;
    final isValid = _formkey.currentState.validate();

    if (statusController.text.toString() == '100') {
      setState(() {
        completeDate = DateTime.now();
      });
    }

    if (isValid) {
      var url =
          'https://ipsolutions4u.com/ipsolutions/recurringMobile/edit.php';
      var url_noti =
          'https://ipsolutions4u.com/ipsolutions/recurringMobile/add.php';

      String selectedCheckUser = _selectedCheckUser.join(",");

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
          await http.post(Uri.parse(url_noti), body: notificationData);
        }
      }

      // final nonrecurring = nonRecurring(
      //     nonRecurringId: id,
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

      // await dbHelper.updateNonRecurring(nonrecurring);

      Map<String, dynamic> data = {
        "dataTable": "nonrecurring",
        "nonRecurringId": id.toString(),
        "category": _selectedCategory["variables"] +
            "|" +
            _selectedCategory["department"],
        "subCategory": _selectedSubCategory,
        "type": _selectedType,
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
              status: 'Updating and Loading Data ...',
              maskType: EasyLoadingMaskType.black,
            );

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NonRecurring()),
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
          }
        });
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
                hint: Text(internet ? '' : _selectedSubCategory.toString()),
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
                hint: Text(_selectedData.isNotEmpty
                    ? _selectedData[0].toString()
                    : ""),
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
                hint: Text(internet ? "" : _selectedType),
                value: typeselect != null ? typeselect : null,
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
                hint: Text(internet ? "" : _selectedUser),
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
                  String test = val;
                  setState(() {
                    _selectedUser = test;
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
                // hint: Text(internet ? "" : nonRecurring_edit[0]['personCheck']),
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
                startDate == null ? 'dd/mm/yy' : Utils.toDate(startDate),
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
            margin: const EdgeInsets.only(bottom: 20),
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
                        checkRequest()
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
                    if (mounted) {
                      await Internet.isInternet().then((connection) async {
                        if (connection) {
                          if (!isTapped && mounted) {
                            isTapped = true;
                            await updateNonRecurring(int.parse(widget.id));
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
                    }
                  },
                  child: const Text(
                    "Update",
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
