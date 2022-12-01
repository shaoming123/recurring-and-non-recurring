import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

class Rule {
  String? rule;
  String recurringRule(_selectedRecurring, recurringDate, recurringController,
      fromDate, toDate, durationController) {
    String freq = _selectedRecurring.toUpperCase();
    String recurring_date = DateFormat('yyyyMMdd').format(recurringDate!);
    String recurringEvery =
        recurringController.isEmpty ? '0' : recurringController;

    // Once
    if (_selectedRecurring == 'Once') {
      String difference = daysBetween(toDate, recurringDate!).toString();

      rule = 'FREQ=DAILY;INTERVAL=$difference;UNTIL=$recurring_date';

      //Daily
    } else if (_selectedRecurring == 'Daily') {
      int dailyInterval =
          int.parse(durationController) + int.parse(recurringEvery);

      rule = 'FREQ=DAILY;INTERVAL=$dailyInterval;UNTIL=$recurring_date';

      //Weekly
    } else if (_selectedRecurring == 'Weekly') {
      String weekday = DateFormat('EEEE').format(fromDate).toUpperCase();

      rule =
          'FREQ=WEEKLY;INTERVAL=$recurringEvery;BYDAY=$weekday;UNTIL=$recurring_date';

      // Monthly
    } else if (_selectedRecurring == 'Monthly') {
      String dateNumber = DateFormat('dd').format(fromDate);

      rule =
          'FREQ=MONTHLY;BYMONTHDAY=$dateNumber;INTERVAL=$recurringEvery;UNTIL=$recurring_date';

      // Yearly
    } else if (_selectedRecurring == 'Yearly') {
      //  rule = 'FREQ=YEARLY;BYMONTHDAY=17;BYMONTH=10;INTERVAL=1;UNTIL=20231229';
    }

    return rule!;
  }
}
