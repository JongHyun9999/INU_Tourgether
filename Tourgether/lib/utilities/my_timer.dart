import 'package:intl/intl.dart';

class MyTimer {
  String getCurrentTimeFormatted() {
    final now = DateTime.now();

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedTime = formatter.format(now);
    return formattedTime;
  }

  String formatDateString(String inputDate) {
    final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
    final outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    final date = inputFormat.parse(inputDate);
    final formattedDate = outputFormat.format(date);

    return formattedDate;
  }

  String addHoursToDateString(String inputDate, int hoursToAdd) {
    final dateTime = DateTime.parse(inputDate);
    final resultDateTime = dateTime.add(Duration(hours: hoursToAdd));
    return resultDateTime.toString();
  }
}
