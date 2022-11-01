// ignore: file_names
import 'package:flutter/material.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/user.dart';
import 'package:ipsolution/src/dashboard.dart';
import 'package:ipsolution/src/dialogBox/addMember.dart';
import 'package:ipsolution/src/signup.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/fade_animation.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var dbHelper;

  late String username;
  late String password;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
  }

  void loginForm() async {
    if (_formKey.currentState!.validate()) {
      username = userController.text;
      password = passwordController.text;

      await dbHelper.getLoginUser(username, password).then((userData) {
        if (userData != null && userData.active == 'Active') {
          setSP(userData).whenComplete(() {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => Dashboard()),
                (Route<dynamic> route) => false);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login Successfully"),
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Username and Password Incorrect!"),
            ),
          );
        }
      }).catchError((error) {
        print(error);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username and Password Incorrect!"),
          ),
        );
      });
    }
  }

  Future setSP(UserModel user) async {
    final SharedPreferences sp = await _pref;

    sp.setInt("user_id", user.user_id!);
    sp.setString("user_name", user.user_name);
    sp.setString("password", user.password);
    sp.setString("email", user.email);
    sp.setString("role", user.role);
    sp.setString("position", user.position);
    sp.setString("site", user.site!);
    sp.setString("siteLead", user.siteLead!);
    sp.setString("active", user.active);
    // sp.setString("photoName", user.photoName!);
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
                              "Login",
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
                          loginForm();
                        }),
                        child: Ink(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Styles.bgColor,
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Styles.textColor,
                                  fontWeight: FontWeight.bold),
                            ),
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUp()));
                        }),
                        child: Ink(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Styles.bgColor,
                          ),
                          child: Center(
                            child: Text(
                              "Signup",
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
