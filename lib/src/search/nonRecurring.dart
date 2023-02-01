

class Search {
  List<List<Map<String, dynamic>>> searchResult(
      String enteredKeyword, found, active, late, completed) {
    List<Map<String, dynamic>> results_one = [];
    List<Map<String, dynamic>> results_two = [];
    List<Map<String, dynamic>> results_three = [];
    List<Map<String, dynamic>> results_four = [];

    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users

      results_one = late;
      results_two = active;
      results_three = completed;
      results_four = found;
    } else {
      // late
      results_one = late
          .where((data) =>
              data["category"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["subcategory"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["type"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["site"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["task"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["owner"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["deadline"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["createdDate"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["lastMod"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["remarks"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["status"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
// active
      results_two = active
          .where((data) =>
              data["category"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["subcategory"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["type"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["site"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["task"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["owner"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["deadline"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["createdDate"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["lastMod"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["remarks"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["status"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      //complete
      results_three = completed
          .where((data) =>
              data["category"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["subcategory"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["type"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["site"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["task"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["owner"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["deadline"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["createdDate"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["lastMod"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["remarks"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["personCheck"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["checked"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      // all
      results_four = found
          .where((data) =>
              data["category"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["subcategory"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["type"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["site"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["task"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["owner"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["deadline"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["createdDate"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["lastMod"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["remarks"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["status"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["personCheck"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              data["checked"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    return [results_one, results_two, results_three, results_four];
  }
}
