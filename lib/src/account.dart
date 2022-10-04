import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool showPassword = false;

  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
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
        body: Container(
          margin: EdgeInsets.symmetric(
              vertical: height * 0.08, horizontal: width * 0.02),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => scaffoldKey.currentState!.openDrawer(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: Text("Profile", style: Styles.title),
              ),
              IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.black),
                  onPressed: () => {}),
            ]),
            const Gap(20),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: ListView(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () => pickImage(),
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
                                      image: image == null
                                          ? const NetworkImage(
                                              'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png')
                                          : FileImage(image!)
                                              as ImageProvider)),
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
                    buildTextField("Username", "Dor Alex", false, true),
                    buildTextField("E-mail", "alexd@gmail.com", false, true),
                    buildTextField("Password", "********", true, true),
                    buildTextField("Phone No", "0123342234", false, true),
                    buildTextField("Role", "-", false, false),
                    buildTextField("Function", "-", false, false),
                    buildTextField("Site", "-", false, false),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
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
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {},
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
          ]),
        ));
  }

  Widget buildTextField(String labelText, String placeholder,
      bool isPasswordTextField, bool editable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
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
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }
}