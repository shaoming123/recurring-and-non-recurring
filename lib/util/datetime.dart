import 'package:intl/intl.dart';

class Utils {
  static String toDateTime(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    final time = DateFormat.Hm().format(dateTime);

    return '$date $time';
  }

  static String toDate(DateTime datetime) {
    final date = DateFormat('dd/MM/yyyy').format(datetime);

    return date;
  }

  static String toTime(DateTime datetime) {
    final time = DateFormat.Hm().format(datetime);

    return time;
  }
}
