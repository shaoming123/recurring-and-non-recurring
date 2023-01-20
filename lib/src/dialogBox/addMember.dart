//@dart=2.9
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:ipsolution/src/member.dart';
import 'package:multiselect/multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../util/checkInternet.dart';

class AddMember extends StatefulWidget {
  const AddMember({
    Key key,
  }) : super(key: key);

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final _formkey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  final email = TextEditingController();
  bool checkPosition = false;
  bool checkSite = false;
  bool checkSiteLead = false;
  String _selectedRole = '';
  String active = 'Active';
  var selectedOption = ''.obs;
  var selectedSiteOption = ''.obs;
  var selectedSiteLeadOption = ''.obs;
  bool checkFunctionAccess = false;
  List<String> selectedPosition = <String>[];
  List<String> selectedSite = <String>[];
  List<String> selectedSiteLead = <String>[];
  List<String> positiondropdownList = [
    'Authority & Developer',
    'Community Management',
    'Defect',
    'Engineering',
    'Financial Management',
    'Human Resources Management',
    'ICT',
    'Legal',
    'Training & Development',
    'Maintenance Management',
    'Marketing & Creative',
    'Operations',
    'Procurement',
    'Statistic'
  ];

  List<String> sitedropdownList = [
    "CRZ",
    "SKE",
    "PR8",
    "PCR",
    "SPP",
    "SKP",
    "AD2",
    "HQ",
    "ALL SITE"
  ];

  List<String> siteLeaddropdownList = [
    "CRZ",
    "SKE",
    "PR8",
    "PCR",
    "SPP",
    "SKP",
    "AD2",
    "ALL SITE"
  ];
  List<String> roleList = ["Super Admin", "Manager", "Leader", "Staff"];
  String userRole;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      userRole = sp.getString("role");
      if (userRole == 'Leader') {
        roleList.remove("Super Admin");
        roleList.remove("Manager");
      } else if (userRole == 'Manager') {
        roleList.remove("Super Admin");
      }
    });
  }

  void selectAllPosition() {
    setState(() {
      if (checkPosition == true) {
        selectedPosition = positiondropdownList;
      } else {
        selectedPosition = [];
      }
    });
  }

  void selectAllSite() {
    setState(() {
      if (checkSite == true) {
        selectedSite = sitedropdownList;
      } else {
        selectedSite = [];
      }
    });
  }

  void selectAllSiteLead() {
    setState(() {
      if (checkSiteLead == true) {
        selectedSiteLead = siteLeaddropdownList;
      } else {
        selectedSiteLead = [];
      }
    });
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

  Future<void> addUser() async {
    if (_formkey.currentState.validate()) {
      if (selectedPosition.isEmpty) {
        AlertDialog alert = AlertDialog(
          title: const Text("Error"),
          content: const Text("Function Access cannot be empty !"),
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
        String _selectedPos = selectedPosition.join(",");
        String _selectedSite = selectedSite.join(",");
        String _selectedSiteLead = selectedSiteLead.join(",");

        /* add to sqlite */
        // await dbHelper.saveData(UserModel(
        //     user_name: username.text,
        //     password: password.text,
        //     email: email.text,
        //     role: _selectedRole,
        //     leadFunc: '',
        //     position: _selectedPos,
        //     site: _selectedSite,
        //     siteLead: _selectedSiteLead,
        //     active: active
        // ));

        Map<String, dynamic> data = {
          "dataTable": "user_details",
          "username": username.text,
          "password": password.text,
          "email": email.text,
          "role": _selectedRole,
          "leadFunc": '-',
          "position": _selectedPos,
          "site": _selectedSite.isEmpty ? '-' : _selectedSite,
          "siteLead": _selectedSiteLead.isEmpty ? '-' : _selectedSiteLead,
          "active": active,
          "filepath": ""
        };

        final response = await http.post(Uri.parse(url), body: data);

        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Add User Successful!"),
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
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Member()));
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

  contentBox(context) {
    Widget buildTextField(String labelText, String placeholder,
        TextEditingController controllerText, bool editable) {
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
              cursorColor: Colors.black,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(hintText: placeholder),
              onFieldSubmitted: (_) {},
              controller: controllerText,
              validator: (duration) {
                return duration != null && duration.isEmpty
                    ? 'Field cannot be empty'
                    : null;
              },
            ),
          ),
        ],
      );
    }

    Widget roleSelect() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Role',
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
                value: _selectedRole == '' ? null : _selectedRole,
                selectedItemHighlightColor: Colors.grey,
                validator: (value) {
                  return value == null ? 'Please select' : null;
                },
                items: roleList
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
                    _selectedRole = test;

                    if (_selectedRole == "Super Admin" ||
                        _selectedRole == "Manager") {
                      checkPosition = true;
                      checkSite = true;
                    } else {
                      checkPosition = false;
                      checkSite = false;
                    }
                    selectAllPosition();
                    selectAllSite();
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

    Widget positionSelect() {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Function Access',
              style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
            ),
            const Gap(10),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                  options: positiondropdownList,

                  // whenEmpty: 'Select position',
                  onChanged: (value) {
                    setState(() {
                      selectedPosition = value;
                      selectedOption.value = "";

                      for (var element in selectedPosition) {
                        selectedOption.value =
                            "${selectedOption.value}  $element";
                      }

                      // if (selectedPosition.isNotEmpty) {
                      //   checkFunctionAccess = true;
                      // }
                    });
                  },
                  selectedValues: selectedPosition,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 14,
                    height: 14,
                    color: Colors.white,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: checkPosition,
                      onChanged: (value) {
                        setState(() {
                          checkPosition = value;
                          selectAllPosition();
                        });
                      },
                    ),
                  ),
                  const Gap(10),
                  const Text(
                    "Select All",
                    style: TextStyle(color: Color(0xFFd4dce4), fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget siteSelect() {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Site In-Charge',
              style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
            ),
            const Gap(10),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                  options: sitedropdownList,

                  // whenEmpty: 'Select position',
                  onChanged: (value) {
                    selectedSite = value;
                    selectedSiteOption.value = "";

                    for (var element in selectedSite) {
                      selectedSiteOption.value =
                          "${selectedSiteOption.value}  $element";
                    }
                  },
                  selectedValues: selectedSite,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 14,
                    height: 14,
                    color: Colors.white,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: checkSite,
                      onChanged: (value) {
                        setState(() {
                          checkSite = value;
                          selectAllSite();
                        });
                      },
                    ),
                  ),
                  const Gap(10),
                  const Text(
                    "Select All",
                    style: TextStyle(color: Color(0xFFd4dce4), fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget siteLeadSelect() {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Does this user hold any leadership role on the Site?',
              style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
            ),
            const Gap(10),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                  options: siteLeaddropdownList,

                  // whenEmpty: 'Select position',
                  onChanged: (value) {
                    selectedSiteLead = value;
                    selectedSiteLeadOption.value = "";

                    for (var element in selectedSiteLead) {
                      selectedSiteLeadOption.value =
                          "${selectedSiteLeadOption.value}  $element";
                    }
                  },
                  selectedValues: selectedSiteLead,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 14,
                    height: 14,
                    color: Colors.white,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: checkSiteLead,
                      onChanged: (value) {
                        setState(() {
                          checkSiteLead = value;
                          selectAllSiteLead();
                        });
                      },
                    ),
                  ),
                  const Gap(10),
                  const Text(
                    "Select All",
                    style: TextStyle(color: Color(0xFFd4dce4), fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                const Text("Add Member",
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
                buildTextField("Username", "Username", username, true),
                buildTextField("Password", "Password", password, true),
                buildTextField(
                    "Email Address", "example@gmail.com", email, true),
                roleSelect(),
                positionSelect(),
                siteSelect(),
                siteLeadSelect(),
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
                        await addUser();
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
