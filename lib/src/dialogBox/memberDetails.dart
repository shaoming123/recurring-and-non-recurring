import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/model/manageUser.dart';
import 'package:ipsolution/src/member.dart';

import '../../model/user.dart';
import '../../util/app_styles.dart';
import '../../util/constant.dart';

class DialogBox extends StatefulWidget {
  final String id;
  final String name;
  final String password;
  final bool isEditing;

  const DialogBox(
      {Key? key,
      required this.id,
      required this.name,
      required this.password,
      required this.isEditing})
      : super(key: key);

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    usernameController.text = widget.name;
    passwordController.text = widget.password;
  }

  Future<void> _updateUser(int id) async {
    await dbHelper.updateUser(
        UserModel(id, usernameController.text, passwordController.text));

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Member()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
                left: Constants.padding,
                top: Constants.padding,
                right: Constants.padding,
                bottom: Constants.padding),
            margin: const EdgeInsets.only(top: Constants.avatarRadius),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(Constants.padding),
                boxShadow: [
                  const BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 10),
                      blurRadius: 10),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Member Details", style: Styles.subtitle),
                const Gap(15),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 3),
                        labelText: "ID",
                        labelStyle: const TextStyle(fontSize: 18),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: widget.id.toString(),
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: TextFormField(
                    controller: usernameController,
                    enabled: widget.isEditing ? true : false,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: "Username",
                      labelStyle: TextStyle(fontSize: 18),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: passwordController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    enabled: widget.isEditing ? true : false,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: "Password",
                      labelStyle: TextStyle(fontSize: 18),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 18),
                        )),
                    TextButton(
                        onPressed: () {
                          _updateUser(int.parse(widget.id));
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                ),
              ],
            ),
          ),
          // Positioned(
          //   left: Constants.padding,
          //   right: Constants.padding,
          //   child: CircleAvatar(
          //     backgroundColor: Colors.transparent,
          //     radius: Constants.avatarRadius,
          //     child: ClipRRect(
          //         borderRadius:
          //             BorderRadius.all(Radius.circular(Constants.avatarRadius)),
          //         child: Image.asset("assets/model.jpeg")),
          //   ),
          // ),
        ],
      ),
    );
  }
}
