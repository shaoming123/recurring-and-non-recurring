import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ipsolution/provider/event_provider.dart';
import 'package:ipsolution/src/dashboard.dart';
import 'package:ipsolution/src/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // var status;
    // @override
    // void initState() async {
    //   final SharedPreferences sp = await SharedPreferences.getInstance();
    //   status = sp.getBool('isLoggedIn') ?? false;
    //   if (status != "true") {
    //     int userid = sp.getInt("user_id")!;
    //     String username = sp.getString("user_name")!;
    //     String password = sp.getString("password")!;
    //     String email = sp.getString("email")!;
    //     String userRole = sp.getString("role")!;
    //     String function = sp.getString("position")!;
    //     String site = sp.getString("site")!;
    //     String siteLead = sp.getString("siteLead")!;
    //     String active = sp.getString("active")!;
    //     String phone = sp.getString("phone")!;

    //     sp.setInt("user_id", userid);
    //     sp.setString("user_name", username);
    //     sp.setString("password", password);
    //     sp.setString("email", email);
    //     sp.setString("role", userRole);
    //     sp.setString("position", function);
    //     sp.setString("site", site);
    //     sp.setString("siteLead", siteLead);
    //     sp.setString("phone", phone);
    //     sp.setString("active", active);
    //   }
    // }

    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const Login(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
