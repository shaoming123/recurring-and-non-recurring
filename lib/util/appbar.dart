import 'package:flutter/material.dart';

import '../src/Login.dart';
import '../src/navbar.dart';
import 'app_styles.dart';

class Appbar extends StatefulWidget {
  String title;
  GlobalKey<ScaffoldState> scaffoldKey;
  Appbar({super.key, required this.title, required this.scaffoldKey});

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () => widget.scaffoldKey.currentState!.openDrawer(),
        ),
        Text(widget.title, style: Styles.title),
        IconButton(
          icon: const Icon(
            Icons.exit_to_app,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () => {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Login()))
          },
        ),
      ],
    );
  }
}
