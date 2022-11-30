import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/manageUser.dart';
import 'package:ipsolution/model/user.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../util/appbar.dart';
import '../util/checkInternet.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool showPassword = true;
  File? image;

  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  late DbHelper dbHelper;

  final username = TextEditingController();
  final password = TextEditingController();
  int? userid;
  final email = TextEditingController();
  final phone = TextEditingController();
  final userRole = TextEditingController();
  final site = TextEditingController();
  final siteLead = TextEditingController();
  String active = '';
  final function = TextEditingController();
  List userData = [];
  @override
  void initState() {
    super.initState();
    getUserData().whenComplete(() async {
      await Internet.isInternet().then((connection) async {
        if (connection) {
          await getImage();
        }
      });
    });

    dbHelper = DbHelper();
  }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      userid = sp.getInt("user_id")!;
      username.text = sp.getString("user_name")!;
      password.text = sp.getString("password")!;
      email.text = sp.getString("email")!;
      userRole.text = sp.getString("role")!;
      function.text = sp.getString("position")!;
      site.text = sp.getString("site")!;
      siteLead.text = sp.getString("siteLead")!;
      active = sp.getString("active")!;
      phone.text = sp.getString("phone")!;
    });
  }

  Future<void> getImage() async {
    var url = "http://192.168.1.111/testdb/getProfileImage.php";
    var response = await http.post(Uri.parse(url),
        body: {"tableName": "user_details", "user_id": userid.toString()});
    List user = json.decode(response.body);

    setState(() {
      userData = user;
    });
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);

      final uri = Uri.parse("http://192.168.1.111/testdb/uploadImage.php");
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = userid.toString();
      var pic = await http.MultipartFile.fromPath("image", image.path);
      request.files.add(pic);
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image Uploaded!'),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Account()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image Not Uploaded!'),
        ));
      }
      setState(() {});
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to pick image: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: SingleChildScrollView(
          child: Container(
            height: height - height * 0.16,
            margin: EdgeInsets.symmetric(
                vertical: height * 0.08, horizontal: width * 0.02),
            child: Column(children: [
              Appbar(title: "Profile", scaffoldKey: scaffoldKey),
              const Gap(20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              await Internet.isInternet()
                                  .then((connection) async {
                                if (connection) {
                                  await pickImage();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Not internet connection found'),
                                  ));
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 4,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(0, 10))
                                    ],
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: userData.length > 0
                                          ? userData[0]['filepath']
                                                      .isNotEmpty &&
                                                  userData[0]['filepath'] !=
                                                      null
                                              ? NetworkImage(
                                                      "http://192.168.1.111/testdb/uploads/${userData[0]['filepath']}")
                                                  as ImageProvider
                                              : AssetImage('assets/logo.png')
                                          : AssetImage('assets/logo.png'),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 4,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                        color: Colors.green,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const Gap(35),
                        Column(
                          children: [
                            buildTextField("Username", "Dor Alex", false, true,
                                username, 1),
                            buildTextField("E-mail", "alexd@gmail.com", false,
                                true, email, 1),
                            buildTextField("Password", "********", true, true,
                                password, 1),
                            phoneTextField("Phone No", "", false, true, phone),

                            buildTextField(
                                "Role", "-", false, false, userRole, 1),
                            buildTextField(
                                "Function", "-", false, false, function, 5),
                            buildTextField(
                                "Site In-Charge", "-", false, false, site, 1),
                            buildTextField(
                                "Site", "-", false, false, siteLead, 1),
                            // buildTextField("Site", "-", false, false, null),
                          ],
                        ),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              onPressed: () {},
                              child: const Text("CANCEL",
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                      color: Colors.black)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.buttonColor,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: (() async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  await Internet.isInternet()
                                      .then((connection) async {
                                    if (connection) {
                                      await updateAccount(
                                          UserModel(
                                              user_id: userid,
                                              user_name: username.text,
                                              password: password.text,
                                              email: email.text,
                                              role: userRole.text,
                                              position: function.text,
                                              site: site.text,
                                              siteLead: siteLead.text,
                                              phone: phone.text,
                                              active: active),
                                          context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("No Internet !")));
                                    }
                                  });
                                }
                              }),
                              child: const Text(
                                "SAVE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }

  Widget buildTextField(
      String labelText,
      String placeholder,
      bool isPasswordTextField,
      bool editable,
      TextEditingController? controllerText,
      int line) {
    return Container(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: TextFormField(
        controller: controllerText,
        enabled: editable,
        maxLines: line,
        minLines: 1,
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
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            isDense: true),
        validator: (text) {
          if (text == null || text.isEmpty) {
            return 'Can\'t be empty';
          }

          return null;
        },
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget phoneTextField(
      String labelText,
      String placeholder,
      bool isPasswordTextField,
      bool editable,
      TextEditingController? controllerText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: TextFormField(
        controller: controllerText,
        enabled: editable,
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
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
        ),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
