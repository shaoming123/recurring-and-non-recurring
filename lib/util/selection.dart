import 'dart:convert';

import 'package:collection/collection.dart';

import 'package:http/http.dart' as http;

class Selection {
  Future siteSelection() async {
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "selection"});

    List selectionData = json.decode(response.body);

    List selection = [];
    for (var e in selectionData) {
      Map<String, dynamic> item = e;
      String s = e['options'].replaceAll('"', '');
      s = s.substring(1, s.length - 1);
      item['options'] = s.split(',');
      selection.add(item);
    }
    final siteoption =
        selection.where((element) => element["variables"] == "Site");

    return siteoption;
  }

  Future typeSelection(List functionAccess, String role) async {
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "selection"});

    List selectionData = json.decode(response.body);
    List selection = [];
    for (var e in selectionData) {
      Map<String, dynamic> item = e;
      String s = e['options'].replaceAll('"', '');
      int x = int.parse(e['id']);
      s = s.substring(1, s.length - 1);
      item['options'] = s.split(',');
      item['id'] = x;
      selection.add(item);
    }
    final data;
    if (role == 'Super Admin' || role == 'Manager') {
      data = selection.where((element) =>
          element["variables"] == "Types" &&
          (functionAccess.contains(element["department"]) ||
              element["department"] == "Manager"));
    } else {
      data = selection.where((element) =>
          element["variables"] == "Types" &&
          functionAccess.contains(element["department"]));
    }

    int id = 1;
    List typeSelection = [];
    for (final val in data) {
      for (final value in val.values) {
        if (value is List) {
          for (final listValue in value) {
            typeSelection.add({'id': id, 'value': listValue, 'bold': "false"});
            id = id + 1;
          }
        } else if (value is String && value != "Types") {
          typeSelection.add({'id': id, 'value': value, 'bold': "true"});
          id = id + 1;
        }
      }
    }
    return typeSelection;
  }

  Future categorySelection(List functionAccess, String role) async {
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "selection"});

    List selectionData = json.decode(response.body);

    List<Map<String, dynamic>> selection = [];
    for (var e in selectionData) {
      Map<String, dynamic> item = e;
      String s = e['options'].replaceAll('"', '');
      String x = e['variables'].toString();
      s = s.substring(1, s.length - 1);
      item['options'] = s.split(',');
      item['variables'] = x;
      selection.add(item);
    }
    final dataCategory;
    if (role == 'Super Admin' || role == 'Manager') {
      dataCategory = selection
          .where((element) =>
              (functionAccess.contains(element["department"]) ||
                  element["department"] == "Manager") &&
              element["variables"] != "Types")
          .toList();
    } else {
      dataCategory = selection
          .where((element) =>
              functionAccess.contains(element["department"]) &&
              element["variables"] != "Types")
          .toList();
    }

    final groups = groupBy(dataCategory, (Map e) => e['department']);
    List data = [];
    data = [
      for (final item in groups.entries)
        for (final value in [item.key, ...item.value])
          if (value is Map)
            {'value': value, 'bold': false}
          else
            {'value': value, 'bold': true}
    ].toList();

    return data;
  }
}
