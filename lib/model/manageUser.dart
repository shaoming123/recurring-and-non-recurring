import 'package:flutter/material.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/user.dart';
import 'package:ipsolution/src/account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../src/member.dart';

DbHelper dbHelper = DbHelper();
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

Future updateSP(UserModel user) async {
  final SharedPreferences sp = await _pref;

  sp.setInt("user_id", user.user_id!);
  sp.setString("phone", user.phone!);
  sp.setString("user_name", user.user_name);
  sp.setString("password", user.password);
  sp.setString("email", user.email);
  sp.setString("role", user.role);
  sp.setString("position", user.position);
  sp.setString("leadFunc", user.leadFunc!);
  sp.setString("site", user.site!);
  sp.setString("siteLead", user.siteLead!);
  sp.setString("active", user.active);
}

Future updateAccount(UserModel user, context) async {
  var url = 'https://ipsolutiontesting.000webhostapp.com/ipsolution/edit.php';

  Map<String, dynamic> data = {
    "dataTable": "user_details",
    "id": user.user_id.toString(),
    "username": user.user_name,
    "password": user.password,
    "email": user.email,
    "role": user.role,
    "position": user.position,
    "site": user.site,
    "siteLead": user.siteLead,
    "phone": user.phone,
    "active": user.active,
  };
  final response = await http.post(Uri.parse(url), body: data);

  if (response.statusCode == 200) {
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
    updateSP(user).whenComplete(() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Account()));
    });
  } else {
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
  // await dbHelper.updateUser(user).then((value) {
  //   if (value == 1) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Updated Successfully!"),
  //       ),
  //     );

  //     updateSP(user, true).whenComplete(() {
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => Account()));
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Error Update!"),
  //       ),
  //     );
  //   }
  // }).catchError((error) {
  //   print(error);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text("Error"),
  //     ),
  //   );
  // });
}

// Delete an item
Future removeUser(int id, context) async {
  var url = 'https://ipsolutiontesting.000webhostapp.com/ipsolution/delete.php';
  final response = await http.post(Uri.parse(url), body: {
    "dataTable": "user_details",
    "id": id.toString(),
  });
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Successfully deleted!'),
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Member()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Delete Unsuccessful !"),
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
