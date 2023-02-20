//@dart=2.9
import 'package:flutter/material.dart';

import 'nonRecurringTask.dart';
import 'nonRecurringTeam.dart';

class PopFilter extends StatefulWidget {
  final String task;
  final String selectedUser;
  final String selectedPosition;
  const PopFilter(
      {Key key, this.task, this.selectedUser, this.selectedPosition})
      : super(key: key);

  @override
  State<PopFilter> createState() => _PopFilterState();
}

class _PopFilterState extends State<PopFilter> {
  @override
  DateTime startDate;
  DateTime endDate;

  void _setDates(FilterOption option) {
    setState(() {
      switch (option) {
        case FilterOption.thisYear:
          startDate = DateTime(DateTime.now().year, 1, 1);
          endDate = DateTime(DateTime.now().year, 12, 31);
          break;
        case FilterOption.lastMonth:
          var now = DateTime.now();
          startDate = DateTime(now.year, now.month - 1, 1);
          endDate = startDate.add(const Duration(days: 31));
          break;
        case FilterOption.lastYear:
          startDate = DateTime(DateTime.now().year - 1, 1, 1);
          endDate = DateTime(DateTime.now().year - 1, 12, 31);
          break;
        case FilterOption.thisMonth:
          var now = DateTime.now();
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
          break;
      }
    });

    if (widget.task == 'ownTasks') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  NonRecurring(start: startDate, end: endDate)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterOption>(
      offset: const Offset(0, 25),
      padding: EdgeInsets.zero,
      onSelected: _setDates,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: FilterOption.thisYear,
          child: Text(
            'This Year',
            style: TextStyle(fontSize: 14),
          ),
        ),
        const PopupMenuItem(
          value: FilterOption.lastMonth,
          child: Text(
            'Last Month',
            style: TextStyle(fontSize: 14),
          ),
        ),
        const PopupMenuItem(
          value: FilterOption.lastYear,
          child: Text(
            'Last Year',
            style: TextStyle(fontSize: 14),
          ),
        ),
        const PopupMenuItem(
          value: FilterOption.thisMonth,
          child: Text(
            'This Month',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
      child: const SizedBox(
        height: 20,
        width: 25,
        child: Icon(
          Icons.filter_alt,
          size: 20,
        ),
      ),
    );
  }
}

enum FilterOption {
  thisYear,
  lastMonth,
  lastYear,
  thisMonth,
}
