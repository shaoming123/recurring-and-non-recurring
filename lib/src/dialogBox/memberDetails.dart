//@dart=2.9
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ipsolution/model/manageUser.dart';

import 'package:ipsolution/src/member.dart';
import 'package:multiselect/multiselect.dart';
import 'package:http/http.dart' as http;

import '../../util/checkInternet.dart';
import '../../util/constant.dart';

class DialogBox extends StatefulWidget {
  final String id;

  final bool isEditing;

  const DialogBox({Key key, this.id, this.isEditing}) : super(key: key);

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  List<String> userPosition = <String>[];
  List<String> userSite = <String>[];
  List<String> userSiteLead = <String>[];
  List<Map<String, dynamic>> userDetails = [];
  bool showPassword = true;
  String userRole = '';
  String userActive = '';
  String leadFunction = '';

  var selectedOption = ''.obs;
  var selectedSiteOption = ''.obs;
  var selectedSiteLeadOption = ''.obs;
  List<String> roleList = ["Super Admin", "Manager", "Leader", "Staff"];
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
  ];
  @override
  void initState() {
    super.initState();
    getUserData(int.parse(widget.id));
  }

  Future<void> getUserData(int id) async {
    userDetails = await dbHelper.getAUser(id);

    setState(() {
      usernameController.text = userDetails[0]['user_name'];
      passwordController.text = userDetails[0]['password'];
      emailController.text = userDetails[0]['email'];
      userRole = userDetails[0]['role'];
      userPosition = userDetails[0]['position'].split(",");

      if (userDetails[0]['site'] != '-') {
        userSite = userDetails[0]['site'].split(",");
      }
      if (userDetails[0]['siteLead'] != '-') {
        userSiteLead = userDetails[0]['siteLead'].split(",");
      }
      userActive = userDetails[0]['active'];
    });
  }

  Future<void> _updateUser(int id) async {
    if (_formkey.currentState.validate()) {
      String _selectedPos = userPosition.join(",");
      String _selectedSite = userSite.join(",");
      String _selectedSiteLead = userSiteLead.join(",");
      var url =
          'https://ipsolutions4u.com/ipsolutions/recurringMobile/edit.php';

      // await dbHelper.updateUser(UserModel(
      //     user_id: id,
      //     user_name: usernameController.text,
      //     password: passwordController.text,
      //     email: emailController.text,
      //     role: userRole,
      //     position: _selectedPos,
      //     site: _selectedSite,
      //     siteLead: _selectedSiteLead,
      //     active: userActive));
      Map<String, dynamic> data = {
        "dataTable": "user_details",
        "id": id.toString(),
        "username": usernameController.text,
        "password": passwordController.text,
        "email": emailController.text,
        "role": userRole,
        "position": _selectedPos,
        "site": _selectedSite.isEmpty ? '-' : _selectedSite,
        "siteLead": _selectedSiteLead.isEmpty ? '-' : _selectedSiteLead,
        "active": userActive
      };

      final response = await http.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        if (!mounted) return;
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
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Member()));
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
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  contentBox(context) {
    Widget buildTextField(
        String labelText,
        String placeholder,
        TextEditingController controllerText,
        bool editable,
        bool isPasswordTextField) {
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
              enabled: widget.isEditing == true ? true : false,
              cursorColor: Colors.black,
              obscureText: isPasswordTextField ? showPassword : false,
              decoration: InputDecoration(
                suffixIcon: isPasswordTextField
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),

              // decoration: InputDecoration(hintText: placeholder),
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
                value: userRole == '' ? null : userRole,
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: widget.isEditing
                    ? (val) {
                        String test = val;
                        setState(() {
                          userRole = test;
                        });
                      }
                    : null,
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Function Access',
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
            child: DropDownMultiSelect(
              decoration: const InputDecoration(border: InputBorder.none),
              enabled: widget.isEditing == true ? true : false,
              options: positiondropdownList,
              // whenEmpty: 'Select position',
              onChanged: (value) {
                setState(() {
                  userPosition = value;
                  selectedOption.value = "";

                  for (var element in userPosition) {
                    selectedOption.value = "${selectedOption.value}  $element";
                  }
                });
              },
              selectedValues: userPosition,
            ),
          ),
        ],
      );
    }

    Widget siteSelect() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Site In-Charge',
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
              child: DropDownMultiSelect(
                decoration: const InputDecoration(border: InputBorder.none),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                options: sitedropdownList,

                // whenEmpty: 'Select position',
                onChanged: (value) {
                  userSite = value;
                  selectedSiteOption.value = "";

                  for (var element in userSite) {
                    selectedSiteOption.value =
                        "${selectedSiteOption.value}  $element";
                  }
                },
                selectedValues: userSite,
              ),
            ),
          ),
        ],
      );
    }

    Widget siteLeadSelect() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Does this user hold any leadership role on the Site?',
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
              child: DropDownMultiSelect(
                decoration: const InputDecoration(border: InputBorder.none),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                options: siteLeaddropdownList,

                // whenEmpty: 'Select position',
                onChanged: (value) {
                  userSiteLead = value;
                  selectedSiteLeadOption.value = "";

                  for (var element in userSiteLead) {
                    selectedSiteLeadOption.value =
                        "${selectedSiteLeadOption.value}  $element";
                  }
                },
                selectedValues: userSiteLead,
              ),
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
                Text(widget.isEditing ? "Edit Member" : "Member Details",
                    style: const TextStyle(
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
                buildTextField(
                    "Username", "Username", usernameController, true, false),
                buildTextField(
                    "Password", "Password", passwordController, true, true),
                buildTextField("Email Address", "example@gmail.com",
                    emailController, true, false),
                roleSelect(),
                positionSelect(),
                siteSelect(),
                siteLeadSelect(),
              ]),
            ),
            widget.isEditing
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
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
                              await _updateUser(int.parse(widget.id));
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
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFd4dce4),
                              fontWeight: FontWeight.w700),
                        )),
                  )
                : Container(),
          ]))
    ]);
  }
}
