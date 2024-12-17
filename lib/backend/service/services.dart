import 'package:intl/intl.dart';

class timeServices {
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  String converterDate(String date) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS');
    final parsedDate = dateFormat.parse(date);

    final outputFormat =
        DateFormat('MMM-dd-yyyy HH:mm:ss'); // Desired output format
    return outputFormat.format(parsedDate);
  }

  Future<String> dateofTrip() async {
    DateTime datenow = DateTime.now();

    final dateofTrip = DateFormat('MM/dd/yyyy');
    return dateofTrip.format(datenow);
  }

  Future<String> departedTime() async {
    DateTime datenow = DateTime.now();
    final departedTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS');

    return departedTime.format(datenow);
  }

  Future<String> departureTimestamp() async {
    DateTime datenow = DateTime.now();
    final departueTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss');
    return departueTimestamp.format(datenow);
  }

  // fast return
  String dateofTrip2() {
    DateTime datenow = DateTime.now();

    final dateofTrip = DateFormat('MM/dd/yyyy');
    return dateofTrip.format(datenow);
  }

  String departedTime2() {
    DateTime datenow = DateTime.now();
    final departedTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS');

    return departedTime.format(datenow);
  }

  String departureTimestamp2() {
    DateTime datenow = DateTime.now();
    final departueTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss');
    return departueTimestamp.format(datenow);
  }
}
