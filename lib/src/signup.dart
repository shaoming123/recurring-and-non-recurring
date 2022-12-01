// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/user.dart';
import 'package:ipsolution/src/Login.dart';
import 'package:ipsolution/src/dashboard.dart';
import 'package:ipsolution/src/dialogBox/addMember.dart';
import 'package:ipsolution/util/app_styles.dart';

import '../util/fade_animation.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String username;
  late String password;
  late int userQuantity = 0;

  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
  }

  void signupForm() async {
    if (_formKey.currentState!.validate()) {
      username = userController.text;
      password = passwordController.text;

      _formKey.currentState!.save();

      UserModel user_model = UserModel(
          user_name: username,
          password: password,
          role: 'Super Admin',
          email: username,
          position: "position_one",
          leadFunc: '',
          site: '',
          siteLead: '',
          active: 'Active');
      await dbHelper.saveData(user_model).then((userData) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Register account Successfully!"),
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
      }).catchError((error) {
        print(error);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: Data Save Fail"),
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 350,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/login/background.png'),
                      fit: BoxFit.fitWidth)),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 30,
                    width: 80,
                    height: 200,
                    child: FadeAnimation(
                        1,
                        Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/login/light-1.png'))),
                        )),
                  ),
                  Positioned(
                    left: 140,
                    width: 80,
                    height: 150,
                    child: FadeAnimation(
                        1.3,
                        Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/login/light-2.png'))),
                        )),
                  ),
                  Positioned(
                    right: 40,
                    top: 40,
                    width: 80,
                    height: 150,
                    child: FadeAnimation(
                        1.5,
                        Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/login/clock.png'))),
                        )),
                  ),
                  Positioned(
                    child: FadeAnimation(
                        1.6,
                        Container(
                          margin: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Signup",
                              style: TextStyle(
                                  color: Styles.textColor,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  FadeAnimation(
                      1.8,
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10))
                            ]),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]!))),
                                child: TextFormField(
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Can\'t be empty';
                                    }

                                    return null;
                                  },
                                  controller: userController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Username",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Can\'t be empty';
                                    }

                                    return null;
                                  },
                                  controller: passwordController,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  FadeAnimation(
                      2,
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Styles.bgColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: (() {
                          signupForm();
                        }),
                        child: Ink(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Styles.bgColor,
                          ),
                          child: Center(
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  color: Styles.textColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
