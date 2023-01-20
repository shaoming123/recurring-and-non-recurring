import 'package:flutter/material.dart';

class Styles {
  static Color bgColor = const Color(0xFFa0c4d4);
  static Color navbar = const Color(0xFFeeedf2);
  static Color textColor = const Color(0xFF3b3b3b);
  static Color buttonColor = const Color(0xFF60b4b4);
  static Color primaryColor = const Color(0xFF34ccb4);
  static Color secondColor = const Color(0xFFEEEEEE);
  static Color lateColor = const Color(0xFFfc9b93);
  static Color activeColor = const Color(0xFFcaf2eb);
  static Color todayColor = const Color(0xFFfff4d4);
  static Color latedotColor = const Color(0xFFf43a2c);
  static Color activedotColor = const Color.fromARGB(255, 255, 195, 74);
  static Color completeddotColor = const Color(0XFF54b058);
  static Color alldotColor = Colors.lightBlue;
  static TextStyle title =
      TextStyle(fontSize: 22, color: textColor, fontWeight: FontWeight.bold);
  static TextStyle subtitle =
      TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold);
  static TextStyle label =
      TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w700);
  static TextStyle labelData =
      TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w700);
  static TextStyle dayLeftActive = const TextStyle(
      color: Color(0xFF39948f), fontWeight: FontWeight.bold, fontSize: 12);
  static TextStyle dayLeftLate = const TextStyle(
      color: Color(0xFFf43a2c), fontWeight: FontWeight.bold, fontSize: 12);
  static TextStyle dayLeftToday = const TextStyle(
      color: Color(0xFFd08c04), fontWeight: FontWeight.bold, fontSize: 12);
}
