//@dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:ipsolution/model/user.dart';
import 'package:ipsolution/src/dashboard.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../util/checkInternet.dart';

class Login extends StatefulWidget {
  const Login({
    Key key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  bool showPassword = true;
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // DbHelper dbHelper = DbHelper();
  String username;
  String password;

  Future loginForm() async {
    if (_formKey.currentState.validate()) {
      username = userController.text;
      password = passwordController.text;

      var url =
          'https://ipsolutions4u.com/ipsolutions/recurringMobile/login.php';
      var response = await http.post(Uri.parse(url), body: {
        "username": username,
        "password": password,
      });
      if (response.statusCode == 200) {
        // print(json.decode(response.body));
        final data = json.decode(response.body);

        if (data != null && data != "Error") {
          final dataModel = UserModel(
            user_id: int.parse(data[0]["id"]),
            user_name: data[0]["username"],
            password: data[0]["password"],
            email: data[0]["email"],
            role: data[0]["role"],
            position: data[0]["position"],
            leadFunc: data[0]["leadFunc"],
            site: data[0]["site"],
            phone: data[0]["phone"],
            active: data[0]["active"],
            siteLead: data[0]["siteLead"],
            filepath: data[0]["filepath"],
          );
          if (dataModel.active == "Active") {
            // final dataModel = UserModel.fromMap(data);

            setSP(dataModel).whenComplete(() async {
              // await Controller().addRecurringToSqlite();
              // await Controller().addNonRecurringToSqlite();

              // bool firsttimeSetup = await dbHelper.getfirst();
              EasyLoading.show(
                status: 'loading...',
                maskType: EasyLoadingMaskType.black,
              );
              await Internet.isInternet().then((connection) async {
                FocusScope.of(context).requestFocus(FocusNode());
                // if (firsttimeSetup) {
                if (!mounted) return;

                if (connection) {
                  // await dbHelper.addfirst();

                  // await Controller().addNotificationDateToSqlite();
                  // await CloneHelper().initDb();
                  // await Clone2Helper().initDb();
                  // await Controller().addRecurringToSqlite();
                  // await Controller().addNonRecurringToSqlite();

                  // sp.setString("updateTime", DateTime.now().toString());

                }
              });

              EasyLoading.showSuccess('Done');
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Dashboard()),
                  (Route<dynamic> route) => false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Login Successfully"),
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
            });
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Deactive User!"),
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
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Username and Password Incorrect!"),
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
        }
      }
    }
  }

  Future setSP(UserModel user) async {
    final SharedPreferences sp = await _pref;
    sp.setBool("isLoggedIn", true);
    sp.setInt("user_id", user.user_id);
    sp.setString("user_name", user.user_name);

    sp.setString("password", user.password);
    sp.setString("email", user.email);
    sp.setString("role", user.role);
    sp.setString("position", user.position);
    sp.setString("site", user.site);
    sp.setString("leadFunc", user.leadFunc);
    sp.setString("siteLead", user.siteLead);
    sp.setString("phone", user.phone);
    sp.setString("active", user.active);
    sp.setString("filepath", user.filepath);

    // sp.setString("photoName", user.photoName!);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: -10,
                right: -10,
                child:
                    Image.asset("assets/images/login/top1.png", width: width),
              ),
              Positioned(
                top: -10,
                right: -10,
                child:
                    Image.asset("assets/images/login/top2.png", width: width),
              ),
              Positioned(
                bottom: -10,
                right: 0,
                left: -15,
                child: Image.asset("assets/images/login/bottom1.png",
                    width: width),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: -10,
                child: Image.asset("assets/images/login/bottom2.png",
                    width: width),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                child: Column(
                  children: [
                    const Text(
                      "Powered By",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Image.asset("assets/logo.png", width: width * 0.25),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5c7494),
                            fontSize: 36),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        controller: userController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF7797AA),
                          ),
                        ),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Can\'t be empty';
                          }

                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF7797AA),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Can\'t be empty';
                          }

                          return null;
                        },
                        controller: passwordController,
                        obscureText: showPassword,
                        enableSuggestions: false,
                        autocorrect: false,
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      child: ElevatedButton(
                        onPressed: (() async {
                          await Internet.isInternet().then((connection) async {
                            if (connection) {
                              await loginForm();
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
                        }),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          elevation: 4.0,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: Offset(0, 10),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: 50.0,
                          width: width * 0.6,
                          padding: const EdgeInsets.all(0),
                          child: const Text(
                            "LOG IN",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   height: 100.0,
                    //   alignment: Alignment.bottomLeft,
                    //   margin: const EdgeInsets.symmetric(
                    //     horizontal: 20,
                    //   ),
                    //   padding: EdgeInsets.only(top: 50),
                    //   child: Column(
                    //     children: [
                    //       const Text(
                    //         "Powered By",
                    //         style: TextStyle(
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 16),
                    //       ),
                    //       Container(
                    //           width: 100.0,
                    //           child: Image.asset("assets/logo.png")),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
