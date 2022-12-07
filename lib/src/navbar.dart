import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/src/Login.dart';
import 'package:ipsolution/src/account.dart';
import 'package:ipsolution/src/dashboard.dart';
import 'package:ipsolution/src/member.dart';
import 'package:ipsolution/src/non_recurring.dart';
import 'package:ipsolution/src/recurrring.dart';
import 'package:ipsolution/src/report.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import '../util/checkInternet.dart';
import 'package:url_launcher/url_launcher.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  late DbHelper dbHelper;
  String username = "";
  String email = "";
  String? userRole = "";
  int? userid;
  List userData = [];

  final Uri ipsolutionUrl = Uri.parse('https://ipsolutions4u.com/ipsolutions/');

  TapGestureRecognizer? _ipsolutionTapRecognizer;
  @override
  void initState() {
    dbHelper = DbHelper();

    _ipsolutionTapRecognizer = TapGestureRecognizer()..onTap = () => _openUrl();
    getUserData();

    super.initState();
  }

  Future<void> _openUrl() async {
    Navigator.of(context).pop();
    if (!await launchUrl(ipsolutionUrl)) {
      throw 'Could not launch $ipsolutionUrl';
    }
    // var urllaunchable = await canLaunch(
    //     ipsolutionUrl.toString()); //canLaunch is from url_launcher package
    // if (urllaunchable) {
    //   await window.open(ipsolutionUrl
    //       .toString()); //launch is from url_launcher package to launch URL
    // } else {
    //   print("URL can't be launched.");
    // }
  }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;
    await Internet.isInternet().then((connection) async {
      if (connection) {
        await getImage();
      }
    });
    setState(() {
      userid = sp.getInt("user_id")!;
      username = sp.getString("user_name")!;
      userRole = sp.getString("role")!;
      email = sp.getString("email")!;
    });
  }

  Future getImage() async {
    var url = "http://192.168.1.111/testdb/getProfileImage.php";
    var response = await http.post(Uri.parse(url),
        body: {"tableName": "user_details", "user_id": userid.toString()});
    List user = json.decode(response.body);

    userData = user;
  }

  void websitelaunch() async {
    final Uri url =
        Uri(scheme: 'https', host: 'www.ipsolutions4u.com', path: '');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Styles.navbar,
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username,
                style: TextStyle(
                  color: Styles.textColor,
                )),
            accountEmail: Text(
              email,
              style: TextStyle(
                color: Styles.textColor,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Container(
                child: ClipOval(
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child:
                          //  Image.network(
                          //   'https://invenioptl.com/wp-content/uploads/2022/07/logoip.png',
                          //   fit: BoxFit.cover,
                          //   width: 90,
                          //   height: 90,
                          // ),

                          userData.length > 0
                              ? userData[0]['filepath'].isNotEmpty &&
                                      userData[0]['filepath'] != null
                                  ? Image.network(
                                      "http://192.168.1.111/testdb/uploads/${userData[0]['filepath']}",
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    )
                                  : Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    )
                              : Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                )),
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Styles.bgColor,
              // image: DecorationImage(
              //     fit: BoxFit.fill,
              //     image: AssetImage('assets/images/login/background.png')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard())),
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: const Text('Recurring'),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Recurring())),
          ),
          ListTile(
            leading: const Icon(Icons.low_priority),
            title: const Text('Non-Recurring'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => NonRecurring()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Report'),
            onTap: () {
              // Navigator.pushReplacement(
              //     context, MaterialPageRoute(builder: (context) => Report()));
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Report Function is Not Supported.'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text:
                                  'The App version does not support report function, Please go to the website to conduct this action.\n\n',
                              style: const TextStyle(color: Colors.black87),
                              children: <TextSpan>[
                                const TextSpan(text: 'Click '),
                                TextSpan(
                                    text: 'here',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => websitelaunch(),
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 16)),
                                const TextSpan(
                                    text: ' to visit the web version. '),
                              ],
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text('Maintenace (comming soon)'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Maintenace'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: 'Coming Soon',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.room_preferences),
            title: const Text('Defect (comming soon)'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Defect'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: 'Coming Soon',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.balance),
            title: const Text('Procurement (comming soon)'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Procurement'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: 'Coming Soon',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.connect_without_contact),
            title: const Text('Community (comming soon)'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Community'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: 'Coming Soon',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.construction),
            title: const Text('Operations (comming soon)'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Operations'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: 'Coming Soon',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    );
                  });
            },
          ),
          const Divider(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_box_outlined),
            title: const Text('Account'),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Account())),
          ),
          userRole == "Super Admin"
              ? ListTile(
                  leading: const Icon(Icons.supervisor_account),
                  title: const Text('Member'),
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Member())),
                )
              : Container(),
          const Divider(),
          const Gap(50),
          ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              }),
        ],
      ),
    );
  }
}
