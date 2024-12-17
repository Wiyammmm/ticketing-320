// ignore_for_file: unused_import

// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue;
import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:telpo_flutter_sdk/telpo_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:intl/intl.dart';

///Test printing
class TestPrinttt {
  fetchServices fetchservice = fetchServices();
  HiveService hiveService = HiveService();
  final telpoFlutterChannel = TelpoFlutterChannel();
  // void customPrint3Column(
  //     String column1, String column2, String column3, int fontSize,
  //     [String separator = "   "]) {
  //   String output = "$column1$column2$column3";
  //   blue.BlueThermalPrinter bluetooth = blue.BlueThermalPrinter.instance;
  //   bluetooth.printCustom(output, fontSize, 1);
  // }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<bool> isPrintProceed() async {
    // final bool? isConnected = await telpoFlutterChannel.isConnected();
    final TelpoStatus status = await telpoFlutterChannel.checkStatus();
    if (status == TelpoStatus.ok) {
      return true;
    } else {
      final bool? isConnected = await telpoFlutterChannel.isConnected();
      if (isConnected != null) {
        if (status == TelpoStatus.ok) {
          return true;
        }
      }
    }
    return false;
  }

  PrintData printdata(String text, int align, [int size = 1]) {
    return PrintData.text(text,
        alignment: align == 0
            ? PrintAlignment.left
            : align == 1
                ? PrintAlignment.center
                : PrintAlignment.right,
        fontSize: size == 1
            ? PrintedFontSize.size18
            : size == 2
                ? PrintedFontSize.size24
                : size == 3
                    ? PrintedFontSize.size34
                    : PrintedFontSize.size44);
  }

  Future<void> sample() async {
    bool isPrintProceedResult = await isPrintProceed();
    print('telpo isPrintProceedResult: $isPrintProceedResult');
    final coopData = fetchservice.fetchCoopData();
    if (isPrintProceedResult) {
      final sheet = TelpoPrintSheet();

      sheet.addElements([
        printdata(breakString("${coopData['cooperativeName']}", 24), 1),
        if (coopData['telephoneNumber'] != null)
          printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
        printdata("POWERED BY: FILIPAY", 1),
        PrintData.space(line: 12)
      ]);
      final PrintResult result = await telpoFlutterChannel.print(sheet);
    }
  }

  printDispatch(
      String torNo,
      String driverName,
      String conductorName,
      String dispatcherName,
      String trip,
      int tripNo,
      String vehicleNo,
      String route,
      String bound) async {
    bool isPrintProceedResult = await isPrintProceed();
    if (isPrintProceedResult) {
      final sheet = TelpoPrintSheet();

      final coopData = fetchservice.fetchCoopData();
      String formatDateNow() {
        final now = DateTime.now();
        final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
        return formattedDate;
      }

      final formattedDate = formatDateNow();

      if (driverName.length > 14) {
        driverName = driverName.substring(0, 14) + "..";
      }
      if (conductorName.length > 14) {
        conductorName = conductorName.substring(0, 14) + "..";
      }
      if (dispatcherName.length > 14) {
        dispatcherName = dispatcherName.substring(0, 14) + "..";
      }

      sheet.addElements([
        printdata(breakString("${coopData['cooperativeName']}", 24), 1, 2),
        printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
        printdata("POWERED BY: FILIPAY", 1),
        printdata("DISPATCH REPORT", 1),
        printdata("TOR#:   $torNo", 1),
        printdata("DATE: $formattedDate", 1),
        printdata("TRIP NO.:    $tripNo", 1),
        printdata(
            "${coopData['coopType'].toString().toUpperCase()} NO.:     $vehicleNo",
            1),
        printdata("---ROUTE NAME--", 1),
        printdata(route, 1),
        printdata("PASS. COUNT.:", 1),
        printdata("DRIV. NAME.:   $driverName", 1),
        printdata("COND. NAME.:   $conductorName", 1),
        printdata("DISP. NAME.:   $dispatcherName", 1),
        printdata("TYPE:   ${trip.toUpperCase()} TRIP", 1),
        printdata("- - - - - - - - - - - - - - -", 1),
        printdata("NOT AN OFFICIAL RECEIPT", 1),
        PrintData.space(line: 12)
      ]);

      final PrintResult result = await telpoFlutterChannel.print(sheet);
    }
  }

  String breakString(String input, int maxLength) {
    List<String> words = input.split(' ');

    String firstLine = '';
    String secondLine = '';

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if ((firstLine.length + 1 + word.length) <= maxLength) {
        // Add the word to the first line
        firstLine += (firstLine == "" ? '' : ' ') + word;
      } else if (secondLine == "") {
        // If the second line is empty, add the word to it
        secondLine += word;
      } else {
        // Truncate the word if it exceeds the maxLength
        int remainingSpace = maxLength - secondLine.length - 1;
        secondLine += ' ' +
            (word.length > remainingSpace
                ? word.substring(0, remainingSpace) + '..'
                : word);
        break;
      }
    }
    // Return the concatenated lines
    if (secondLine.trim() == "") {
      return "$firstLine";
    } else {
      return '$firstLine\n$secondLine';
    }
  }

  printTicket(
      String ticketNo,
      String cardType,
      double amount,
      double subtotal,
      double kmrun,
      String origin,
      String destination,
      String passengerType,
      bool isDiscounted,
      String vehicleNo,
      String from,
      String to,
      String route,
      double discountPercent,
      int pax,
      double newBalance,
      String sNo,
      String idNo,
      String mop,
      [int totalRides = 0]) async {
    bool isPrintProceedResult = await isPrintProceed();
    if (isPrintProceedResult) {
      final sheet = TelpoPrintSheet();

      bool isDltb = false;
      bool isJeepney = false;
      final coopData = fetchservice.fetchCoopData();
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }

      if (coopData['coopType'] != "Bus") {
        isJeepney = true;
      }

      double discount = 0.0;
      if (cardType == 'mastercard' || cardType == 'cash') {
        cardType = 'CASH';
      } else {
        cardType = 'FILIPAY CARD';
      }
      if (isDiscounted) {
        discount = amount * discountPercent;
        // subtotal = subtotal - discount;
      }

      String formatDateNow() {
        final now = DateTime.now();
        final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
        return formattedDate;
      }

      // try {
      final formattedDate = formatDateNow();

      if (origin.length > 16) {
        origin = origin.substring(0, 13) + "..";
      }
      if (destination.length > 16) {
        destination = destination.substring(0, 13) + "..";
      }

      sheet.addElements([
        printdata(breakString("${coopData['cooperativeName']}", 24), 1, 2),
        printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
        printdata("POWERED BY: FILIPAY", 1),
        printdata("PASSENGER RECEIPT", 1),
        printdata("TICKET#: ${newText(ticketNo, 35)}", 0),
        printdata("MOP:     ${newText(mop, 53)}", 0),
        printdata("PASS TYPE:${newText(passengerType.toUpperCase(), 43)}", 0),
        printdata(
            "${coopData['coopType'].toString().toUpperCase()} NO:${newText(vehicleNo, 43)}",
            0),
        printdata(
            "Discount:${newText("   ${coopData['coopType'] == "Bus" ? discount.round() : discount.toStringAsFixed(2)}", 48)}",
            0),
        printdata(
            "Amount: ${newText("${coopData['coopType'] == "Bus" ? amount.round() : amount.toStringAsFixed(2)}", 50)}",
            0),
        printdata("Pax:     ${newText("$pax", 55)}", 0),
        if (cardType == 'FILIPAY CARD' && coopData['isPromoActive'])
          printdata("Total Rides: ${newText(totalRides.toString(), 45)}", 1),

        if (cardType == 'FILIPAY CARD')
          printdata("SN:      ${newText(sNo, 55)}", 1),
        if (cardType == 'FILIPAY CARD')
          printdata(
              "REM BAL: ${newText(newBalance.toStringAsFixed(2), 45)}", 1),

        printdata(
            "TOTAL AMOUNT: ${coopData['coopType'] == "Bus" ? subtotal.round() : subtotal.toStringAsFixed(2)}",
            1,
            2),

        // printdata("- - - - - - - - - - - - - - -", 1),
        printdata("FROM $origin TO $destination", 1),
        // printdata("DESTINATION:   $destination", 1),
        printdata("KM RUN:  ${newText("${kmrun.toInt()}", 55)}", 0),
        printdata("DATE:    ${newText(formattedDate, 36)}", 0),
        if (cardType == 'FILIPAY CARD' &&
            coopData['isPromoActive'] &&
            (totalRides > 12 && totalRides <= 15))
          printdata("This Transaction is FREE", 1),
        // printdata("PASSENGER'S COPY", 1),
        // printdata("- - - - - - - - - - - - - - -", 1),
        printdata("NOT AN OFFICIAL RECEIPT", 1),
        PrintData.space(line: 12)
      ]);

      final PrintResult result = await telpoFlutterChannel.print(sheet);
    }
    // } catch (e) {
    //   print(e);
    // }
  }

  Future<bool> printListticket(List<Map<String, dynamic>> tickets) async {
    try {
      bool isDltb = false;
      final coopData = fetchservice.fetchCoopData();
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }
      for (int i = 0; i < tickets.length; i++) {
        print('ticket-$i: ${tickets[i]}');
        String origin = tickets[i]['from_place'];
        String destination = tickets[i]['to_place'];
        String ticketNo = tickets[i]['ticket_no'];
        String cardType = tickets[i]['cardType'];
        String passengerType = tickets[i]['passengerType'];
        String kmrun = tickets[i]['km_run'].toString();
        String dateString = tickets[i]['created_on'].toString();
        DateTime dateTime = DateTime.parse(dateString);
        String formattedDate = DateFormat('MMM dd, yyyy EEE').format(dateTime);
        double discount = double.parse(tickets[i]['discount'].toString());

        double amount = double.parse(tickets[i]['fare'].toString()) +
            double.parse(tickets[i]['discount'].toString()) -
            double.parse(tickets[i]['baggage'].toString());
        double subtotal = double.parse(tickets[i]['fare'].toString()) -
            double.parse(tickets[i]['baggage'].toString());

        double baggageAmount = double.parse(tickets[i]['baggage'].toString());

        if (origin.length > 16) {
          origin = origin.substring(0, 13) + "..";
        }
        if (destination.length > 16) {
          destination = destination.substring(0, 13) + "..";
        }

        bluetooth.isConnected.then((isConnected) {
          if (isConnected == true) {
            // bluetooth.printNewLine();

            bluetooth.printCustom("DEL MONTE LAND", 1, 1);
            bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

            bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
            bluetooth.printCustom("RECEIPT", 1, 1);
            bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);
            // bluetooth.printLeftRight("Ticket#:", "$ticketNo", 1);
            bluetooth.printLeftRight("MOP:", "$cardType", 1);
            bluetooth.printLeftRight(
                "PASS TYPE:", "${passengerType.toUpperCase()}", 1);
            // if (isrouteLong) {
            //   bluetooth.printCustom('Route: $route', 1, 0);
            // } else {
            //   bluetooth.printLeftRight("Route:", "$route", 1);
            // }
            bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
            bluetooth.printLeftRight("DESTINATION:", "$destination", 1);
            bluetooth.printLeftRight("KM Run:", "$kmrun", 1);

            bluetooth.printCustom("DATE: $formattedDate", 1, 1);

            bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
            // bluetooth.printLeftRight("Baggage:", "$baggageAmount", 1);
            bluetooth.printLeftRight(
                "Discount:",
                "${coopData['coopType'] == "Bus" ? discount.round() : discount}",
                1);
            bluetooth.printLeftRight(
                "Amount:",
                "${coopData['coopType'] == "Bus" ? amount.round() : amount}",
                1);
            bluetooth.printCustom("TOTAL AMOUNT", 2, 1);
            bluetooth.printCustom("${subtotal.toStringAsFixed(2)}", 2, 1);

            bluetooth.printNewLine();
            bluetooth.printNewLine();
            bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
            bluetooth.printNewLine();
            bluetooth.printNewLine();

            if (baggageAmount > 0) {
              bluetooth.printCustom(
                  breakString("${coopData['cooperativeName']}", 24), 1, 1);
              if (coopData['telephoneNumber'] != null) {
                bluetooth.printCustom(
                    "Contact Us: ${coopData['telephoneNumber']}", 1, 1);
              }
              // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
              // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);
              bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
              bluetooth.printCustom("BAGGAGE RECEIPT", 1, 1);
              bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);
              // bluetooth.printLeftRight("Ticket#:", "$ticketNo", 1);

              // if (isrouteLong) {
              //   bluetooth.printCustom('Route: $route', 1, 0);
              // } else {
              //   bluetooth.printLeftRight("Route:", "$route", 1);
              // }
              bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
              bluetooth.printLeftRight("DESTINATION:", "$destination", 1);
              bluetooth.printLeftRight("KM Run:", "$kmrun", 1);

              bluetooth.printCustom("DATE: $formattedDate", 1, 1);

              bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
              bluetooth.printLeftRight(
                  "Baggage:",
                  "${coopData['coopType'] == "Bus" ? baggageAmount.round() : baggageAmount}",
                  1);

              bluetooth.printNewLine();
              bluetooth.printNewLine();
              bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
              bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
              bluetooth.printNewLine();
              // bluetooth.printNewLine();

              bluetooth.paperCut();
            }
          }
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  printBaggage(
      String ticketNo,
      String cardType,
      double baggageAmount,
      double kmrun,
      String origin,
      String destination,
      String vehicleNo,
      String from,
      String to,
      String route) async {
    bool isPrintProceedResult = await isPrintProceed();
    if (isPrintProceedResult) {
      final sheet = TelpoPrintSheet();

      bool isDltb = false;
      final coopData = fetchservice.fetchCoopData();
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }
      if (cardType == 'mastercard' || cardType == 'cash') {
        cardType = 'CASH';
      } else {
        cardType = 'FILIPAY CARD';
      }
      String formatDateNow() {
        final now = DateTime.now();
        final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
        return formattedDate;
      }

      final formattedDate = formatDateNow();
      if (origin.length > 16) {
        origin = origin.substring(0, 13) + "..";
      }
      if (destination.length > 16) {
        destination = destination.substring(0, 13) + "..";
      }

      sheet.addElements([
        printdata(breakString("${coopData['cooperativeName']}", 24), 1, 2),
        printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
        printdata("POWERED BY: FILIPAY", 1),
        printdata("BAGGAGE RECEIPT", 1),
        printdata("Ticket#:   $ticketNo", 1),
        printdata("MOP:   $cardType", 1),
        if (!fetchservice.getIsNumeric()) printdata("ORIGIN::   $origin", 1),
        if (!fetchservice.getIsNumeric())
          printdata("DESTINATION::   $destination", 1),
        printdata("KM Run:   $kmrun", 1),
        printdata("DATE:  $formattedDate ", 1),
        printdata("- - - - - - - - - - - - - - -", 1),
        printdata(
            "Baggage:   ${coopData['coopType'] == "Bus" ? baggageAmount.round() : baggageAmount}",
            1),
        printdata("PASSENGER'S COPY", 1),
        printdata("- - - - - - - - - - - - - - -", 1),
        printdata("NOT AN OFFICIAL RECEIPT", 1),
        PrintData.space(line: 12)
      ]);

      // sheet.addElement(PrintData.text("$vehicleNo",
      //     alignment: PrintAlignment.values[PrintData.text()], fontSize: PrintedFontSize.size24));

      final PrintResult result = await telpoFlutterChannel.print(sheet);
    }
  }

  printExpenses(
      List<Map<String, dynamic>> expensesList, String vehicleNo) async {
    bool isPrintProceedResult = await isPrintProceed();
    if (isPrintProceedResult) {
      final sheet = TelpoPrintSheet();

      final coopData = fetchservice.fetchCoopData();
      bool isDltb = false;
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }
      String formatDateNow() {
        final now = DateTime.now();
        final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
        return formattedDate;
      }

      final formattedDate = formatDateNow();
      sheet.addElements([
        printdata(breakString("${coopData['cooperativeName']}", 24), 1, 2),
        printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
        printdata("POWERED BY: FILIPAY", 1),
        printdata("EXPENSES", 1),
        printdata("DATE: $formattedDate", 1),
        if (vehicleNo != "")
          printdata(
              "${coopData['coopType'].toString().toUpperCase()} NO: $vehicleNo",
              1),
        printdata("- - - - - - - - - - - - - - -", 1),
        printdata("PARTICULAR:   AMOUNT", 1),
      ]);
      List<Map<String, dynamic>> othersExpenses = [];
      double totalExpenses = 0;
      for (var expense in expensesList) {
        totalExpenses += expense['amount'];
        String expenseDescription = expense['particular'];
        double expenseAmount = double.parse(expense['amount'].toString());
        // bluetooth.printLeftRight(
        //     "PARTICULAR:", "${expenseDescription.toUpperCase()}", 1);
        if (expense['particular'] == "SERVICES" ||
            expense['particular'] == "CALLER'S FEE" ||
            expense['particular'] == "EMPLOYEE BENEFITS" ||
            expense['particular'] == "MATERIALS" ||
            expense['particular'] == "REPRESENTATION" ||
            expense['particular'] == "REPAIR") {
          othersExpenses.add(expense);
        } else {
          sheet.addElement(printdata(
              "$expenseDescription:   ${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
              1));
        }
      }

      if (othersExpenses.isNotEmpty) {
        sheet.addElement(printdata("OTHERS   ", 1));

        for (var expense in othersExpenses) {
          String expenseDescription = expense['particular'];
          if (expenseDescription == "EMPLOYEE BENEFITS") {
            expenseDescription = "EMP BENEFITS";
          }
          double expenseAmount = double.parse(expense['amount'].toString());

          sheet.addElement(printdata(
              "${expenseDescription}   ${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
              1));
        }
      }

      sheet.addElements([
        printdata("TOTAL EXPENSES:   ${totalExpenses.toStringAsFixed(2)}", 1),
        printdata("- - - - - - - - - - - - - - -", 1),
        printdata("NOT AN OFFICIAL RECEIPT", 1),
        PrintData.space(line: 12)
      ]);

      final PrintResult result = await telpoFlutterChannel.print(sheet);
    }
  }

  Future<bool> printArrival(
      String opening,
      String closing,
      int totalPassenger,
      int totalBaggage,
      double totalPassengerAmount,
      double totalBaggageAmount,
      int tripNo,
      String vehicleNo,
      String conductorName,
      String driverName,
      String dispatcherName,
      String route,
      String torNo,
      String tripType,
      double totalExpenses) async {
    bool isPrintProceedResult = await isPrintProceed();
    final _myBox = Hive.box('myBox');
    // final SESSION = _myBox.get('SESSION');
    final coopData = fetchservice.fetchCoopData();
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');
    final torTicket = _myBox.get('torTicket');
    String control_no = "";
    try {
      control_no = torTrip[session['currentTripIndex'] - 1]['control_no'];
    } catch (e) {
      control_no = torTrip[session['currentTripIndex']]['control_no'];
    }
    double getTotalTopUpperTrip() {
      double total = 0;
      final topUpList = _myBox.get('topUpList');

      if (topUpList.isNotEmpty) {
        for (var element in topUpList) {
          if (element['response']['control_no'].toString() == "$control_no") {
            total += double.parse((element['response']['mastercard']
                        ['previousBalance'] -
                    element['response']['mastercard']['newBalance'])
                .toString());
          }
        }
      }
      return total;
    }

    // int baggageWithPassengerCount = fetchservice.baggageWithPassengerCount();
    int baggageWithPassengerCount() {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['baggage'] is num && item['baggage'] > 0) &&
              item['control_no'] == control_no &&
              (item['fare'] is num && item['fare'] > 0))
          .length;
      return totalBaggageCount;
    }

    int baggageOnlyCount() {
      final torTicket = _myBox.get('torTicket');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['baggage'] is num && item['baggage'] > 0) &&
              item['control_no'] == control_no &&
              (item['fare'] is num && item['fare'] == 0))
          .length;
      return totalBaggageCount;
    }

    double totalTripBaggageOnly() {
      final fareList = _myBox.get('torTicket');

      // String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              // fare['cardType'] == cardTypeToFilter &&
              fare['baggage'] > 0 &&
              fare['fare'] == 0)
          .map<num>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    double totalTripBaggagewithPassenger() {
      final fareList = _myBox.get('torTicket');

      // String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              // fare['cardType'] == cardTypeToFilter &&
              fare['baggage'] > 0 &&
              fare['fare'] > 0)
          .map<num>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    int cardSalesCount() {
      final torTicket = _myBox.get('torTicket');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['cardType'] != 'mastercard' &&
                  item['cardType'] != 'cash') &&
              item['control_no'] == control_no)
          .length;
      return totalBaggageCount;
    }

    double totalBaggageperTrip() {
      final torTicket = _myBox.get('torTicket');

      double sumOfBaggage = torTicket
          .where((fare) => fare['control_no'] == control_no)
          .map<double>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, baggage) => prev + baggage);

      return sumOfBaggage;
    }

    double totalPrepaidPassengerRevenueperTrip() {
      double total = 0;

      final prePaidList = _myBox.get('prepaidTicket');
      for (var element in prePaidList) {
        if (element['control_no'] == control_no) {
          total += element['totalAmount'];
        }
      }

      return total;
    }

    double totalPrepaidBaggageRevenueperTrip() {
      double total = 0;

      final prePaidList = _myBox.get('prepaidBaggage');
      for (var element in prePaidList) {
        if (element['control_no'] == control_no) {
          total += element['totalAmount'];
        }
      }

      return total;
    }

    double totalTripCardSales() {
      final fareList = _myBox.get('torTicket');

      // String controlNumberToFilter = fetchservice.getCurrentControlNumber();

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['cardType'] != "mastercard" && fare['cardType'] != "cash"))
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      double totaladdFareAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['additionalFareCardType'] != "mastercard" &&
                  fare['additionalFareCardType'] != "cash"))
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      return totalAmount + totaladdFareAmount;
    }

    double totalTripCashReceived() {
      final fareList = _myBox.get('torTicket');

      String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['cardType'] == cardTypeToFilter ||
                  fare['cardType'] == "cash"))
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      double totaladdFareAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['additionalFareCardType'] == cardTypeToFilter ||
                  fare['additionalFareCardType'] == "cash"))
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      return totalAmount + totaladdFareAmount + getTotalTopUpperTrip();
    }

    double totalTripGrandTotal() {
      final fareList = _myBox.get('torTicket');

      double totalAmount = fareList
          .where((fare) => fare['control_no'] == control_no)
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble() +
              (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount +
          getTotalTopUpperTrip() +
          totalPrepaidPassengerRevenueperTrip() +
          totalPrepaidBaggageRevenueperTrip() -
          totalExpenses;
    }

    double totalAddFare() {
      final fareList = _myBox.get('torTicket');

      double totalAmount = fareList
          .where((fare) => fare['control_no'] == control_no)
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd,yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    if (conductorName.length > 16) {
      conductorName = conductorName.substring(0, 13) + "..";
    }
    if (driverName.length > 16) {
      driverName = driverName.substring(0, 13) + "..";
    }
    if (dispatcherName.length > 16) {
      dispatcherName = dispatcherName.substring(0, 13) + "..";
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }
      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();
        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1, 2),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("ARRIVAL", 1),
          printdata("DATE: $formattedDate", 1),
          printdata("TOR#: $torNo", 1),
          printdata("TRIP TYPE: ${tripType.toUpperCase()}", 1),
        ]);
        if (tripType == "special") {
          sheet.addElements([
            printdata("- - - - - - - - - - - - - - -", 1),
            printdata("PASSENGER COUNT: $totalPassenger", 1),
            printdata("PASS REVENUE: ${tripType.toUpperCase()}", 1),
            printdata("TRIP NO: $tripNo", 1),
            printdata(
                "${coopData['coopType'].toString().toUpperCase()} NO:   $vehicleNo",
                1),
            printdata("DRIVER:   $driverName", 1),
            printdata("CONDUCTOR:   $conductorName", 1),
            printdata("DISPATCHER:   $dispatcherName", 1),
            printdata("ROUTE:   $route", 1),
            printdata("SN: ${session['serialNumber']}", 1),
            printdata("- - - - - - - - - - - - - - -", 1),
            printdata("NOT AN OFFICIAL RECEIPT", 1),
            PrintData.space(line: 12)
          ]);
          final PrintResult result = await telpoFlutterChannel.print(sheet);
          return true;
        }

        sheet.addElements([
          printdata("OPENING:   $opening", 1),
          printdata("CLOSING:   $closing", 1),
          printdata("TOTAL PASS:   $totalPassenger", 1),
          printdata("TOTAL BAGGAGE:   $totalBaggage", 1),
          printdata("CS ISSUED:   ${cardSalesCount()}", 1),
          printdata("BAGGAGE AMOUNT:   ${totalBaggageperTrip()}", 1),
          if (coopData['coopType'] == "Bus")
            printdata(
                "PREPAID PASS:   ${totalPrepaidPassengerRevenueperTrip()}", 1),
          printdata(
              "TOTAL FARE:   ${fetchservice.totalTripFare().toStringAsFixed(2)}",
              1),
          printdata("ADD FARE:  ${totalAddFare().toStringAsFixed(2)}", 1),
          printdata(
              "CASH RECEIVED:   ${totalTripCashReceived().toStringAsFixed(2)}",
              1),
          printdata("CARD SALES:   ${totalTripCardSales()}", 1),
          printdata("TOTAL EXPENSES:   ${totalExpenses.toStringAsFixed(2)}", 1),
          if (coopData['coopType'] == "Bus")
            printdata(
                "TOPUP TOTAL:   ${getTotalTopUpperTrip().toStringAsFixed(2)}",
                1),
          printdata(
              "GRAND TOTAL:   ${totalTripGrandTotal().toStringAsFixed(2)}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("TRIP NO:   $tripNo", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()} NO:   $vehicleNo",
              1),
          printdata("CONDUCTOR:   $conductorName", 1),
          printdata("DRIVER:   $driverName", 1),
          printdata("DISPATCHER:   $dispatcherName", 1),
          printdata("ROUTE:   $route", 1),
          printdata("SN:   ${session['serialNumber']}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printArrivalShortVer(int totalTransaction, double totalAmount,
      String vehicleNo, int tripNo) async {
    bool isPrintProceedResult = await isPrintProceed();

    if (isPrintProceedResult) {
      final sheet = TelpoPrintSheet();

      final coopData = fetchservice.fetchCoopData();
      String formatDateNow() {
        final now = DateTime.now();
        final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
        return formattedDate;
      }

      String dateConverter(String dateString) {
        DateTime dateTime = DateTime.parse(dateString);
        String formattedDateTime =
            DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
        return formattedDateTime;
      }

      final formattedDate = formatDateNow();

      sheet.addElements([
        printdata(breakString("${coopData['cooperativeName']}", 24), 1, 2),
        if (coopData['telephoneNumber'] != null)
          printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
        printdata("POWERED BY: FILIPAY", 1),
        printdata("ARRIVAL", 1),
        printdata("DATE: $formattedDate", 1),
        printdata("TRIP #: $tripNo", 1),
        printdata("- - - - - - - - - - - - - - -", 1),
        printdata("Number of Transaction", 1, 2),
        printdata("${totalTransaction.toInt()}", 1, 3),
        printdata("Total Amount of Collections", 1, 2),
        printdata("${NumberFormat('#,##0.00').format(totalAmount)}", 1, 3),
        printdata(
            "${coopData['coopType'].toString().toUpperCase()} #$vehicleNo",
            1,
            2),
        printdata("- - - - - - - - - - - - - - -", 1),
        PrintData.space(line: 12)
      ]);
      final PrintResult result = await telpoFlutterChannel.print(sheet);
      if (result != PrintResult.success) {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> printTripReportGATC(
      double totalTransaction, double totalAmount, String vehicleNo) async {
    bool isPrintProceedResult = await isPrintProceed();

    if (isPrintProceedResult) {
      final sheet = TelpoPrintSheet();

      final coopData = fetchservice.fetchCoopData();
      String formatDateNow() {
        final now = DateTime.now();
        final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
        return formattedDate;
      }

      String dateConverter(String dateString) {
        DateTime dateTime = DateTime.parse(dateString);
        String formattedDateTime =
            DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
        return formattedDateTime;
      }

      final formattedDate = formatDateNow();

      sheet.addElements([
        printdata(breakString("${coopData['cooperativeName']}", 24), 1, 2),
        if (coopData['telephoneNumber'] != null)
          printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
        printdata("POWERED BY: FILIPAY", 1),
        printdata("TRIP SUMMARY", 1),
        printdata("DATE: $formattedDate", 1),
        printdata("- - - - - - - - - - - - - - -", 1),
        printdata("Number of Transaction", 1, 2),
        printdata("${totalTransaction.toInt()}", 1, 3),
        printdata("Total Amount of Collections", 1, 2),
        printdata("${NumberFormat('#,##0.00').format(totalAmount)}", 1, 3),
        printdata(
            "${coopData['coopType'].toString().toUpperCase()} #$vehicleNo",
            1,
            2),
        printdata("- - - - - - - - - - - - - - -", 1),
        PrintData.space(line: 12)
      ]);
      final PrintResult result = await telpoFlutterChannel.print(sheet);
      if (result != PrintResult.success) {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> printTripReportFinal(
      String totalTrip,
      String torNo,
      String totalBaggage,
      String prepaidPass,
      // String prepaidBagg,
      String puncherTR,
      String puncherTC,
      String puncherBR,
      String puncherBC,
      String passengerTR,
      String passengerTC,
      String waybillrevenue,
      String waybillcount,
      String baggageTR,
      String baggageTC,
      String charterPR,
      String charterPC,
      String finalRemitt,
      String shortOver,
      String cashReceived,
      String cardSales,
      String addFare,
      String topupTotal,
      String grandTotal,
      String netCollection) async {
    try {
      bool isPrintProceedResult = await isPrintProceed();
      final expensesList = fetchservice.fetchExpensesList();
      final coopData = fetchservice.fetchCoopData();
      bool isDltb = false;
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }
      List<Map<String, dynamic>> othersExpenses = [];

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();
        String formatDateNow() {
          final now = DateTime.now();
          final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
          return formattedDate;
        }

        String dateConverter(String dateString) {
          DateTime dateTime = DateTime.parse(dateString);
          String formattedDateTime =
              DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
          return formattedDateTime;
        }

        final formattedDate = formatDateNow();
        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("TRIP SUMMARY", 1),
          printdata("DATE: $formattedDate", 1),
          printdata("TOTAL TRIPS:    $totalTrip", 1),
          printdata("TOR#:   $torNo", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
        ]);
        if (expensesList.isNotEmpty) {
          sheet.addElements([
            printdata("EXPENSES", 1),
            printdata("PARTICULAR:   AMOUNT", 1),
          ]);
          double totalExpenses = 0;
          for (var expense in expensesList) {
            totalExpenses += expense['amount'];
            String expenseDescription = expense['particular'];
            double expenseAmount = double.parse(expense['amount'].toString());
            // bluetooth.printLeftRight(
            //     "PARTICULAR:", "${expenseDescription.toUpperCase()}", 1);
            if (expense['particular'] == "SERVICES" ||
                expense['particular'] == "CALLER'S FEE" ||
                expense['particular'] == "EMPLOYEE BENEFITS" ||
                expense['particular'] == "MATERIALS" ||
                expense['particular'] == "REPRESENTATION" ||
                expense['particular'] == "REPAIR") {
              othersExpenses.add(expense);
            } else {
              sheet.addElement(printdata(
                  "$expenseDescription   ${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
                  1));
            }
          }
          if (othersExpenses.isNotEmpty) {
            sheet.addElement(printdata("OTHERS   ", 1));

            for (var expense in othersExpenses) {
              String expenseDescription = expense['particular'];
              if (expenseDescription == "EMPLOYEE BENEFITS") {
                expenseDescription = "EMP BENEFITS";
              }
              double expenseAmount = double.parse(expense['amount'].toString());
              sheet.addElement(printdata(
                  "${expenseDescription}   ${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
                  1));
            }
          }

          sheet.addElements([
            printdata(
                "TOTAL EXPENSES   ${totalExpenses.toStringAsFixed(2)}", 1),
            printdata("- - - - - - - - - - - - - - -", 1)
          ]);
        }
        sheet.addElement(printdata("TOTAL BAGGAGE:   $totalBaggage", 1));
        if (coopData['coopType'] == "Bus") {
          sheet.addElements([
            printdata("PREPAID PASS:   $prepaidPass", 1),
            printdata("PUNCHER TR:   $puncherTR", 1),
            printdata("PUNCHER TC:   $puncherTC", 1),
            printdata("PUNCHER BR:   $puncherBR", 1),
            printdata("PUNCHER BC:   $puncherBC", 1),
          ]);
        }
        sheet.addElements([
          printdata("PASSENGER TR:   $passengerTR", 1),
          printdata("PASSENGER TC:   $passengerTC", 1),
        ]);
        if (coopData['coopType'] == "Bus") {
          sheet.addElements([
            printdata("WAYBILL TR:   $waybillrevenue", 1),
            printdata("WAYBILL TC:   $waybillcount", 1),
          ]);
        }

        sheet.addElements([
          printdata("BAGGAGE TR:   $baggageTR", 1),
          printdata("BAGGAGE TC:   $baggageTC", 1),
        ]);
        if (coopData['coopType'] == "Bus") {
          sheet.addElements([
            printdata("CHARTER PR:   $charterPR", 1),
            printdata("CHARTER PC:   $charterPC", 1),
          ]);
        }

        sheet.addElements([
          printdata("FINAL REMITT:   $finalRemitt", 1),
          printdata("SHORT/OVER:   $shortOver", 1),
          printdata("CASH RECEIVED:   $cashReceived", 1),
          printdata("CARD SALES:   $cardSales", 1),
          printdata("ADD FARE:   $addFare", 1),
          if (coopData['coopType'] == "Bus")
            printdata("TOPUP TOTAL:   $topupTotal", 1),
          printdata("GROSS REVENUE:   $grandTotal", 1),
          printdata("NET COLLECTION:   $netCollection", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }
      return true;
    } catch (e) {
      print("printTripReportFinal error: $e");
      return false;
    }
  }

  Future<bool> printTripReport(
      // String torNo,
      // String vehicleNo,
      // String conductorName,
      // String driverName,
      // String dispatcherName,
      String cashierName,
      // int regularCount,
      // int discountedCount,
      // int baggageCount,
      // String route,
      // int totalTickets,
      // double totalAmount,
      List<Map<String, dynamic>> torTrip,
      List<Map<String, dynamic>> torTicket,
      List<Map<String, dynamic>> prePaidPassenger,
      List<Map<String, dynamic>> prePaidBaggage,
      double finalRemitt,
      double shortOver,
      double puncherTR,
      double puncherTC,
      double puncherBR,
      double puncherBC,
      double passengerRevenue,
      double passengerCount,
      double baggageRevenue,
      double baggageCount,
      double charterTicketRevenue,
      double charterTicketCount) async {
    try {
      bool isPrintProceedResult = await isPrintProceed();
      final expensesList = fetchservice.fetchExpensesList();

      final coopData = fetchservice.fetchCoopData();
      // bluetooth.isConnected.then((isConnected) {
      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();
        // final myBox = Hive.box('myBox');
        // final ticketList = myBox.get('torTicket');

        bool isPrinterReady = false;

        isPrinterReady = true;

        double grandTotal = 0;
        double grandBaggage = 0;
        double grandPrepaidPassengerTotal = 0;
        double grandPrepaidBaggageTotal = 0;
        double grandTotalCashRecived = 0;
        double additionalFare = 0;

        String formatDateNow() {
          final now = DateTime.now();
          final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
          return formattedDate;
        }

        String dateConverter(String dateString) {
          DateTime dateTime = DateTime.parse(dateString);
          String formattedDateTime =
              DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
          return formattedDateTime;
        }

        final formattedDate = formatDateNow();

        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("TRIP SUMMARY", 1),
          printdata("DATE: $formattedDate", 1),
        ]);

        for (int i = 0; i < torTrip.length; i++) {
          print('tortrip[$i]: ${torTrip[i]}');
          String conductorName = torTrip[i]['conductor'].toString();
          String dispatcherName1 = torTrip[i]['departed_dispatcher'].toString();
          String dispatcherName2 = torTrip[i]['arrived_dispatcher'].toString();
          String driverName = torTrip[i]['driver'].toString();
          String control_no = torTrip[i]['control_no'].toString();
          String torNo = torTrip[i]['tor_no'].toString();
          String departed_date =
              dateConverter(torTrip[i]['departure_timestamp'].toString());
          String arrived_date =
              dateConverter(torTrip[i]['arrival_timestamp'].toString());
          String vehicleNo = torTrip[i]['bus_no'].toString();

          int regularCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['discount'] == 0)
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          print('ticketList: $torTicket');
          print('regularCount: $regularCount');
          int discountedCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['discount'] > 0)
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);
          int pwdCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['passengerType'] == "pwd")
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          int studentCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['passengerType'] == "student")
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          int seniorCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['passengerType'] == "senior")
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          int baggageCounter = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no && ticket['baggage'] > 0)
              .length;

          int prePaidPassengerCount = prePaidPassenger
              .where((entry) => entry['control_no'] == control_no)
              .fold(
                0,
                (sum, entry) => sum + (entry['totalPassenger'] ?? 0) as int,
              );
          int prePaidBaggageCount = prePaidBaggage
              .where((ticket) => ticket['control_no'] == control_no)
              .length;

          double prePaidPassengerAmount = prePaidPassenger
              .where((entry) => entry['control_no'] == control_no)
              .fold(
                0.0,
                (sum, entry) => sum + (entry['totalAmount'] ?? 0.0) as double,
              );
          double cardSales = torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['cardType'] != "mastercard" &&
                      entry['cardType'] != "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      (double.parse(entry['fare'].toString() ?? "0.0") *
                          entry['pax']) +
                      double.parse(entry['baggage'].toString() ?? "0.0"));

          cardSales += torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['additionalFareCardType'] != "mastercard" &&
                      entry['additionalFareCardType'] != "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      double.parse(
                          entry['additionalFare'].toString() ?? "0.0"));
          double cashR = torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['cardType'] == "mastercard" ||
                      entry['cardType'] == "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      (double.parse(
                          entry['fare'].toString() ?? "0.0" * entry['pax'])) +
                      double.parse(entry['baggage'].toString() ?? "0.0"));

          cashR += torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['additionalFareCardType'] == "mastercard" ||
                      entry['additionalFareCardType'] == "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      double.parse(
                          entry['additionalFare'].toString() ?? "0.0"));
          double prePaidBaggageAmount = prePaidBaggage
              .where((entry) => entry['control_no'] == control_no)
              .fold(
                0.0,
                (sum, entry) => sum + (entry['totalAmount'] ?? 0.0) as double,
              );
          grandPrepaidPassengerTotal += prePaidPassengerAmount;
          grandPrepaidBaggageTotal += prePaidBaggageAmount;

          double tripTotalbaggage = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .fold(0.0,
                  (sum, ticket) => sum + (ticket['baggage'] as num).toDouble());

          int totalTickets = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .length;
          double totalAmount = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .fold(
                  0.0,
                  (sum, ticket) =>
                      sum +
                      ((ticket['fare'] as num).toDouble() * ticket['pax']) +
                      (ticket['baggage'] as num).toDouble() +
                      (ticket['additionalFare'] as num).toDouble());

          additionalFare = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .fold(
                  0.0,
                  (sum, ticket) =>
                      sum + (ticket['additionalFare'] as num).toDouble());

          grandTotal +=
              totalAmount += prePaidBaggageAmount + prePaidPassengerAmount;

          grandBaggage += tripTotalbaggage;
          grandTotalCashRecived += totalAmount;
          String route = '${torTrip[i]['route']}';
          String tripType = '${torTrip[i]['tripType']}';

          if (conductorName.length > 16) {
            conductorName = conductorName.substring(0, 13) + "..";
          }
          if (dispatcherName1.length > 16) {
            dispatcherName1 = dispatcherName1.substring(0, 13) + "..";
          }
          if (dispatcherName2.length > 16) {
            dispatcherName2 = dispatcherName2.substring(0, 13) + "..";
          }
          if (driverName.length > 16) {
            driverName = driverName.substring(0, 13) + "..";
          }
          if (cashierName.length > 16) {
            cashierName = cashierName.substring(0, 13) + "..";
          }

          if (isPrinterReady) {
            List<Map<String, dynamic>> othersExpenses = [];
            try {
              if (torTrip[i]['control_no'] == expensesList[i]['control_no']) {
                double totalExpenses = 0;
                List<Map<String, dynamic>> filteredExpenses = expensesList
                    .where((expenses) =>
                        expenses['control_no'] == torTrip[i]['control_no'])
                    .toList();
                if (coopData['coopType'] == 'Bus') {
                  sheet.addElement(printdata("TRIP No ${i + 1}", 1));
                }
                sheet.addElements([
                  printdata("TOR#: $torNo", 1),
                  printdata("TRIP TYPE: ${tripType.toUpperCase()}", 1),
                  printdata("EXPENSES", 1),
                  printdata("PARTICULAR:   AMOUNT", 1),
                ]);

                for (var element in filteredExpenses) {
                  totalExpenses += double.parse(element['amount'].toString());
                  if (element['particular'] == "SERVICES" ||
                      element['particular'] == "CALLER'S FEE" ||
                      element['particular'] == "EMPLOYEE BENEFITS" ||
                      element['particular'] == "MATERIALS" ||
                      element['particular'] == "REPRESENTATION" ||
                      element['particular'] == "REPAIR") {
                    othersExpenses.add(element);
                  } else {
                    sheet.addElement(printdata(
                        "${element['particular']}   ${element['amount']}", 1));
                  }
                }
                if (othersExpenses.isNotEmpty) {
                  sheet.addElement(printdata("OTHERS   ", 1));

                  for (var element in othersExpenses) {
                    if (element['particular'] == "EMPLOYEE BENEFITS") {
                      element['particular'] = "EMP BENEFITS";
                    }
                    sheet.addElement(printdata(
                        "${element['particular']}   ${element['amount']}", 1));
                  }
                }
                sheet.addElement(
                    printdata("TOTAL EXPENSES:   $totalExpenses", 1));
              }
            } catch (e) {
              print(e);
            }
          }
        }
        grandTotalCashRecived += puncherTR + puncherBR;
        sheet.addElements([
          printdata("- - - - - - - - - - - - - - ", 1),
          printdata(
              "TOTAL BAGGAGE:    ${fetchservice.grandTotalBaggage().toStringAsFixed(2)}",
              1),
        ]);

        if (coopData['coopType'] == "Bus") {
          sheet.addElement(printdata(
              "PREPAID PASS:   ${grandPrepaidPassengerTotal.toStringAsFixed(2)}",
              1));
        }
        if (coopData['coopType'] == "Bus") {
          sheet.addElements([
            printdata("PUNCHER TR:   ${puncherTR}", 1),
            printdata("PUNCHER TC:   ${puncherTC}", 1),
            printdata("PUNCHER BR:   ${puncherBR}", 1),
            printdata("PUNCHER BC:   ${puncherBC}", 1),
          ]);
        }

        // NEW
        sheet.addElements([
          printdata("PASSENGER TR:   ${passengerRevenue}", 1),
          printdata("PASSENGER TC:   ${passengerCount}", 1),
          printdata("BAGAGGE TR:   ${baggageRevenue}", 1),
          printdata("BAGGAGE TC:   ${baggageCount}", 1),
        ]);

        if (coopData['coopType'] == "Bus") {
          sheet.addElements([
            printdata("CHARTER PR:   ${charterTicketRevenue}", 1),
            printdata("CHARTER PC:   ${charterTicketCount}", 1),
          ]);
        }
        sheet.addElements([
          printdata("FINAL REMITT:   ${finalRemitt}", 1),
          printdata("SHORT/OVER:   ${shortOver}", 1),
          printdata(
              "CASH RECEIVED:   ${fetchservice.getAllCashRecevied().toStringAsFixed(2)}",
              1),
          printdata(
              "CARD SALES:   ${fetchservice.grandTotalCardSales().toStringAsFixed(2)}",
              1),
          printdata("ADD FARE:   ${fetchservice.grandTotalAddFare()}", 1),
        ]);

        if (coopData['coopType'] == "Bus") {
          sheet.addElement(printdata(
              "TOPUP TOTAL:   ${fetchservice.getTotalTopUpper().toStringAsFixed(2)}",
              1));
        }
        sheet.addElements([
          printdata(
              "GRAND TOTAL:   ${(fetchservice.getAllCashRecevied() + fetchservice.grandTotalCardSales() + fetchservice.totalPrepaidPassengerRevenue() + fetchservice.totalPrepaidBaggageRevenue()).toStringAsFixed(2)}",
              1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }
      // });

      return true;
    } catch (e) {
      print('print report error: $e');
      return false;
    }
  }

  bool printTripSummary() {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: ${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("TRIP SUMMARY", 1, 1);
          bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);
          bluetooth.printLeftRight("DISPATCHED:", "$formattedDate", 1);
          bluetooth.printLeftRight(
              "${coopData['coopType'].toString().toUpperCase()} NO:", "103", 1);
          bluetooth.printLeftRight("CONDUCTOR:", "Juan Dela Cruz", 1);
          bluetooth.printLeftRight("DRIVER:", "Juan Dela Cruz", 1);
          bluetooth.printLeftRight("DISPATCHER:", "Juan Dela Cruz", 1);
          bluetooth.printCustom("ROUTE:     DISTRICT - STAR MALL", 1, 1);
          // bluetooth.printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  num convertNumToIntegerOrDecimal(num number) {
    // Convert the number to a string
    String numberString = number.toString();
    int decimalIndex = numberString.indexOf('.');
    // Check if the number contains a decimal point or is greater than 0 as a double
    if (decimalIndex != -1 && decimalIndex < numberString.length - 1) {
      // If it contains a decimal or is greater than 0, return it as a double
      String decimalPart = numberString.substring(decimalIndex + 1);
      if (double.parse(decimalPart) > 0) {
        return double.parse(numberString);
      } else {
        return number.toInt();
      }
    } else {
      // If it doesn't contain a decimal and is not greater than 0, return it as an integer
      return number.toInt();
    }
  }

  Future<bool> printInspectionSummary(
      String type,
      String torNo,
      String passenger,
      String baggage,
      String headCount,
      String kmPost,
      String driverName,
      String conductorName,
      String vehicleNo,
      String route,
      String inspectorName,
      List<Map<String, dynamic>> tickets,
      bool isTicket,
      int discrepancy,
      int passengerTransfer,
      int PassengerWithPass,
      int PassengerPrepaid,
      int baggageCount) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();

        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("INSPECTION SUMMARY", 1),
          printdata("${type.toUpperCase()}", 1),
          printdata("TOR#: $torNo", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("DATE: $formattedDate", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()} NO:   $vehicleNo",
              1),
          printdata("INSPECTOR:   $inspectorName", 1),
          printdata("CONDUCTOR:   $conductorName", 1),
          printdata("DRIVER:   $driverName", 1),
          printdata("ROUTE:   $route", 1),
          printdata("OPENING:   ${tickets[0]['ticket_no']}", 1),
          printdata(
              "CLOSING:   ${tickets[tickets.length - 1]['ticket_no']}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("PASSENGER:   $passenger", 1),
          printdata("BAGGAGE:   $baggage", 1),
        ]);
        if (!fetchservice.getIsNumeric()) {
          sheet.addElements([
            printdata("HEAD COUNT:   $headCount", 1),
            printdata("BAGGAGE COUNT:   $baggageCount", 1),
            printdata("DISCREPANCY:   $discrepancy", 1),
            printdata("TRANSFER:   $passengerTransfer", 1),
            printdata("PASSED:   $PassengerWithPass", 1),
            printdata("PREPAID:   $PassengerPrepaid", 1),
            printdata("KM POST:   $kmPost", 1),
          ]);
        }
        sheet.addElements([
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("INSPECTION TICKET REPORT", 1),
        ]);

        if (!fetchservice.getIsNumeric()) {
          if (coopData['coopType'] != "Bus") {
            sheet.addElement(printdata("TN   TIME   FR TO   FARE   PAX", 1));
          } else {
            sheet.addElement(printdata("TN   TIME   FR  TO   FARE", 1));
          }
        } else {
          if (coopData['coopType'] != "Bus") {
            sheet.addElement(printdata("TN   TIME   FARE   PAX", 1));
          } else {
            sheet.addElement(printdata("TN   TIME   FARE", 1));
          }
        }
        double grandtotal = 0;
        double grandbaggage = 0;
        double grandcardsales = 0;
        double grandcashreceived = 0;

        double grandbaggageonly = 0;
        double grandbaggagewithpassenger = 0;

        int pwdcount = 0;
        int studentcount = 0;
        int seniorcount = 0;
        int cardsalescount = 0;
        int regularcount = 0;
        int baggagecount = 0;
        int discountedcount = 0;
        int totalticketcount = 0;
        double addfare = 0;

        bool havebaggage = false;
        bool havepwd = false;
        bool havestudent = false;
        bool havesenior = false;
        bool havecardsales = false;
        bool havebaggageonly = false;
        bool havebaggagewithpassenger = false;
        bool haveAddFare = false;
        bool haveCsAddfare = false;
        bool havecardsalesbaggage = false;
        for (int i = 0; i < tickets.length; i++) {
          num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
          // print('inspection tickets $i: ${tickets}');
          grandtotal +=
              (double.parse(tickets[i]['fare'].toString()) * tickets[i]['pax']);

          grandtotal += double.parse(tickets[i]['baggage'].toString());
          addfare += double.parse(tickets[i]['additionalFare'].toString());

          totalticketcount += 1;
          if (tickets[i]['cardType'] == "mastercard" ||
              tickets[i]['cardType'] == "cash") {
            grandcashreceived += (double.parse(tickets[i]['fare'].toString()) *
                    tickets[i]['pax']) +
                double.parse(tickets[i]['baggage'].toString());
          }
          if (tickets[i]['additionalFareCardType'] == "mastercard" ||
              tickets[i]['additionalFareCardType'] == "cash") {
            grandcashreceived +=
                double.parse(tickets[i]['additionalFare'].toString());
          }
          if (tickets[i]['cardType'] != "mastercard" &&
              tickets[i]['cardType'] != "cash") {
            grandcardsales += (double.parse(tickets[i]['fare'].toString()) *
                    tickets[i]['pax']) +
                double.parse(tickets[i]['baggage'].toString());
          }
          if (tickets[i]['additionalFareCardType'] != "mastercard" &&
              tickets[i]['additionalFareCardType'] != "cash") {
            grandcardsales +=
                double.parse(tickets[i]['additionalFare'].toString());
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              (tickets[i]['passengerType'] == 'regular' ||
                  tickets[i]['passengerType'] == 'FULL FARE')) {
            regularcount += tickets[i]['pax'] as int;

            DateTime dateTime =
                DateTime.parse(tickets[i]['created_on'].toString());
            String timeOnly = "${dateTime.hour}:${dateTime.minute}";
            if (!fetchservice.getIsNumeric()) {
              if (coopData['coopType'] != "Bus") {
                sheet.addElement(printdata(
                    "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-${toKm} ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                    1));
              } else {
                sheet.addElement(printdata(
                    "te${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${toKm}\t${tickets[i]['fare']}\t",
                    1));
              }
            } else {
              if (coopData['coopType'] != "Bus") {
                sheet.addElement(printdata(
                    "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}   ${tickets[i]['pax']}",
                    1));
              } else {
                sheet.addElement(printdata(
                    "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}",
                    1));
              }
            }
          }
          // if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] == 0) {
          //   havebaggageonly = true;
          // }
          if (tickets[i]['baggage'] > 0) {
            havebaggage = true;
          }
          if (tickets[i]['additionalFare'] > 0 &&
              (tickets[i]['additionalFareCardType'] == 'mastercard' ||
                  tickets[i]['additionalFareCardType'] == 'cash')) {
            haveAddFare = true;
          }
          if (tickets[i]['additionalFare'] > 0 &&
              tickets[i]['additionalFareCardType'] != 'mastercard' &&
              tickets[i]['additionalFareCardType'] != 'cash') {
            haveCsAddfare = true;
          }

          if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] > 0) {
            havebaggagewithpassenger = true;
          }

          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              tickets[i]['passengerType'] == 'student') {
            havestudent = true;
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              tickets[i]['passengerType'] == 'pwd') {
            havepwd = true;
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              tickets[i]['passengerType'] == 'senior') {
            havesenior = true;
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] != 'mastercard' &&
                  tickets[i]['cardType'] != 'cash')) {
            havecardsales = true;
          }
          if (tickets[i]['fare'] == 0 &&
              tickets[i]['cardType'] != 'mastercard' &&
              tickets[i]['cardType'] != 'cash') {
            havecardsalesbaggage = true;
          }
        }

        grandtotal += addfare;
        if (havebaggage) {
          sheet.addElement(printdata("BAGGAGE   ", 1));

          // bluetooth.printCustom("BAGGAGE", 1, 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['baggage'] > 0) {
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              grandbaggageonly +=
                  double.parse(tickets[i]['baggage'].toString());
              baggagecount += 1;
              grandbaggage += double.parse(tickets[i]['baggage'].toString());

              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}\t\t\t",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['baggage']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['baggage']}   ",
                      1));
                }
              }
            }
          }
        }
        // if (havebaggageonly) {
        //   bluetooth.printLeftRight("BAGGAGE ONLY", "", 1);
        //   // bluetooth.printCustom("BAGGAGE", 1, 1);

        //   for (int i = 0; i < tickets.length; i++) {
        //     if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] <= 0) {
        //       DateTime dateTime =
        //           DateTime.parse(tickets[i]['created_on'].toString());
        //       String timeOnly = "${dateTime.hour}:${dateTime.minute}";
        //       grandbaggageonly +=
        //           double.parse(tickets[i]['baggage'].toString());
        //       baggagecount += 1;
        //       grandbaggage += double.parse(tickets[i]['baggage'].toString());
        //       // grandcashreceived +=
        //       //     double.parse(tickets[i]['baggage'].toString()) +
        //       //         double.parse(tickets[i]['additionalFare'].toString());
        //       // bluetooth.print4Column(
        //       //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
        //       //     "${tickets[i]['from_km']}",
        //       //     "${tickets[i]['to_km']}",
        //       //     "${tickets[i]['baggage']}",
        //       //     1);
        //       if (!fetchservice.getIsNumeric()) {
        //         if (coopData['coopType'] != "Bus") {
        //           bluetooth.printCustom(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}",
        //               1,
        //               1);
        //         } else {
        //           bluetooth.printCustom(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}\t\t\t",
        //               1,
        //               1);
        //         }
        //       } else {
        //         if (coopData['coopType'] != "Bus") {
        //           bluetooth.print3Column(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
        //               "$timeOnly",
        //               "${tickets[i]['baggage']}",
        //               1);
        //         } else {
        //           bluetooth.print4Column(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
        //               "$timeOnly",
        //               "${tickets[i]['baggage']}",
        //               "",
        //               1);
        //         }
        //       }
        //     }
        //   }
        // }
        // if (havebaggagewithpassenger) {
        //   bluetooth.printLeftRight("BAGGAGE W/ PASS", "", 1);
        //   // bluetooth.printCustom("BAGGAGE", 1, 1);

        //   for (int i = 0; i < tickets.length; i++) {
        //     if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] > 0) {
        //       DateTime dateTime =
        //           DateTime.parse(tickets[i]['created_on'].toString());
        //       String timeOnly = "${dateTime.hour}:${dateTime.minute}";
        //       grandbaggagewithpassenger +=
        //           double.parse(tickets[i]['baggage'].toString());
        //       baggagecount += 1;
        //       grandbaggage += double.parse(tickets[i]['baggage'].toString());
        //       // grandcashreceived +=
        //       //     double.parse(tickets[i]['baggage'].toString()) +
        //       //         double.parse(tickets[i]['additionalFare'].toString());
        //       // bluetooth.print4Column(
        //       //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
        //       //     "${tickets[i]['from_km']}",
        //       //     "${tickets[i]['to_km']}",
        //       //     "${tickets[i]['baggage']}",
        //       //     1);
        //       if (!fetchservice.getIsNumeric()) {
        //         if (coopData['coopType'] != "Bus") {
        //           bluetooth.printCustom(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}",
        //               1,
        //               1);
        //         } else {
        //           bluetooth.printCustom(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}\t\t\t",
        //               1,
        //               1);
        //         }
        //       } else {
        //         if (coopData['coopType'] != "Bus") {
        //           bluetooth.print3Column(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
        //               "$timeOnly",
        //               "${tickets[i]['baggage']}",
        //               1);
        //         } else {
        //           bluetooth.print4Column(
        //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
        //               "$timeOnly",
        //               "${tickets[i]['baggage']}",
        //               "",
        //               1);
        //         }
        //       }
        //     }
        //   }
        // }
        //
        if (havestudent) {
          sheet.addElement(printdata("STUDENT   ", 1));

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'student') {
              studentcount += tickets[i]['pax'] as int;
              discountedcount += tickets[i]['pax'] as int;

              // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
              // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);
              // grandcashreceived +=
              //     double.parse(tickets[i]['fare'].toString()) +
              //         double.parse(tickets[i]['additionalFare'].toString());
              // bluetooth.print4Column(
              //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
              //     "${tickets[i]['from_km']}",
              //     "${tickets[i]['to_km']}",
              //     "${tickets[i]['fare']}",
              //     1);
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";

              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}   ${tickets[i]['pax']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}",
                      1));
                }
              }
            }
          }
        }

        if (havesenior) {
          sheet.addElement(printdata("SENIOR   ", 1));

          // bluetooth.printCustom("SENIOR", 1, 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'senior') {
              seniorcount += tickets[i]['pax'] as int;
              discountedcount += tickets[i]['pax'] as int;

              // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
              // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);
              // grandcashreceived +=
              //     double.parse(tickets[i]['fare'].toString()) +
              //         double.parse(tickets[i]['additionalFare'].toString());
              // bluetooth.print4Column(
              //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
              //     "${tickets[i]['from_km']}",
              //     "${tickets[i]['to_km']}",
              //     "${tickets[i]['fare']}",
              //     1);
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}   ${tickets[i]['pax']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}",
                      1));
                }
              }
            }
          }
        }
        if (havepwd) {
          sheet.addElement(printdata("PWD   ", 1));

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'pwd') {
              pwdcount += tickets[i]['pax'] as int;
              discountedcount += tickets[i]['pax'] as int;

              // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
              // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);
              // grandcashreceived +=
              //     double.parse(tickets[i]['fare'].toString()) +
              //         double.parse(tickets[i]['additionalFare'].toString());
              // bluetooth.print4Column(
              //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
              //     "${tickets[i]['from_km']}",
              //     "${tickets[i]['to_km']}",
              //     "${tickets[i]['fare']}",
              //     1);
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}   ${tickets[i]['pax']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}",
                      1));
                }
              }
            }
          }
        }
        if (havecardsales) {
          sheet.addElement(printdata("CS TICKET", 1));

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if ((tickets[i]['cardType'] != 'mastercard' &&
                    tickets[i]['cardType'] != 'cash') &&
                tickets[i]['fare'] > 0) {
              cardsalescount += tickets[i]['pax'] as int;
              if (tickets[i]['passengerType'] == "regular" ||
                  tickets[i]['passengerType'] == "FULL FARE") {
                regularcount += tickets[i]['pax'] as int;
              }
              if (tickets[i]['passengerType'] == "student") {
                studentcount += tickets[i]['pax'] as int;
              }
              if (tickets[i]['passengerType'] == "senior") {
                seniorcount += tickets[i]['pax'] as int;
              }
              if (tickets[i]['passengerType'] == "pwd") {
                pwdcount += tickets[i]['pax'] as int;
              }

              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}   ${tickets[i]['pax']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['fare']}",
                      1));
                }
              }
            }
          }
        }
        if (havecardsalesbaggage) {
          sheet.addElement(printdata("CS BAGGAGE", 1));

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if ((tickets[i]['cardType'] != 'mastercard' &&
                    tickets[i]['cardType'] != 'cash') &&
                tickets[i]['fare'] == 0) {
              cardsalescount += tickets[i]['pax'] as int;

              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}\t\t\t",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['baggage']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['baggage']}   ",
                      1));
                }
              }
            }
          }
        }
        if (haveAddFare) {
          sheet.addElement(printdata("ADD FARE   ", 1));

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['additionalFare'] > 0 &&
                (tickets[i]['additionalFareCardType'] == 'mastercard' ||
                    tickets[i]['additionalFareCardType'] == 'cash')) {
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}\t\t\t",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['additionalFare']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['additionalFare']}    ",
                      1));
                }
              }
            }
          }
        }
        if (haveCsAddfare) {
          sheet.addElement(printdata("CS ADD FARE   ", 1));

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['additionalFare'] > 0 &&
                tickets[i]['additionalFareCardType'] != 'mastercard' &&
                tickets[i]['additionalFareCardType'] != 'cash') {
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}\t\t\t",
                      1));
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['additionalFare']}",
                      1));
                } else {
                  sheet.addElement(printdata(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}   $timeOnly   ${tickets[i]['additionalFare']}   ",
                      1));
                }
              }
            }
          }
        }
        sheet.addElements([
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("TICKET ISSUED:   $totalticketcount", 1),
          printdata("BAGGAGE ISSUED:   $baggage", 1),
          printdata("REGULAR ISSUED:   $regularcount", 1),
          printdata("STUDENT ISSUED:   $studentcount", 1),
          printdata("PWD ISSUED:   $pwdcount", 1),
          printdata("SENIOR ISSUED:   $seniorcount", 1),
          printdata("DISC ISSUED:   $discountedcount", 1),
          printdata("CS ISSUED:   $cardsalescount", 1),
          printdata("CARD SALES:   $grandcardsales", 1),
          printdata("CASH RECEIVED:   $grandcashreceived", 1),
          printdata("BAGGAGE TOTAL:   $grandbaggage", 1),
          printdata("ADD FARE:   $addfare", 1),
          printdata("GRAND TOTAL:   $grandtotal", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTopUpPassengerReceipt(
      String sNo,
      String MCsNo,
      String vehicleNo,
      double amount,
      double previousBalance,
      double newBalance,
      double conductorpreviousBalance,
      double conductornewBalance,
      String referenceNumber) async {
    bool isPrintProceedResult = await isPrintProceed();

    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();
        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("TOP-UP CONDUCTOR'S COPY RECEIPT", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("REF NO: $referenceNumber", 1),
          printdata("SN: $MCsNo", 1),
          printdata("DATE: $formattedDate", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()} NO:   $vehicleNo",
              1),
          printdata("AMOUNT:   ${amount.toStringAsFixed(2)}", 1),
          printdata(
              "PREV BALANCE:   ${conductorpreviousBalance.toStringAsFixed(2)}",
              1),
          printdata(
              "NEW BALANCE:   ${conductornewBalance.toStringAsFixed(2)}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("TOP-UP PASSENGER'S COPY RECEIPT", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("REF NO: $referenceNumber", 1),
          printdata("SN: $MCsNo", 1),
          printdata("DATE: $formattedDate", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()} NO:   $vehicleNo",
              1),
          printdata("AMOUNT:   ${amount.toStringAsFixed(2)}", 1),
          printdata(
              "PREV BALANCE:   ${conductorpreviousBalance.toStringAsFixed(2)}",
              1),
          printdata(
              "NEW BALANCE:   ${conductornewBalance.toStringAsFixed(2)}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTopUpMasterCard(
      String sNo,
      String cardOwner,
      double amount,
      double previousBalance,
      double newBalance,
      String referenceNumber,
      String cashierName) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    if (cardOwner.length > 16) {
      cardOwner = cardOwner.substring(0, 15);
    }
    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();

        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("TOP-UP CASHIER'S COPY RECEIPT", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("REF NO:   $referenceNumber", 1),
          printdata("DATE:   $formattedDate", 1),
          printdata("SN:   $sNo", 1),
          printdata("CARD OWNER:   $cardOwner", 1),
          printdata("CASHIER:   $cashierName", 1),
          printdata("AMOUNT:   ${amount.toStringAsFixed(2)}", 1),
          printdata("PREV BALANCE:   ${previousBalance.toStringAsFixed(2)}", 1),
          printdata("NEW BALANCE:   ${newBalance.toStringAsFixed(2)}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("TOP-UP CASHIER'S COPY RECEIPT", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("REF NO:   $referenceNumber", 1),
          printdata("DATE:   $formattedDate", 1),
          printdata("SN:   $sNo", 1),
          printdata("CARD OWNER:   $cardOwner", 1),
          printdata("CASHIER:   $cashierName", 1),
          printdata("AMOUNT:   ${amount.toStringAsFixed(2)}", 1),
          printdata("PREV BALANCE:   ${previousBalance.toStringAsFixed(2)}", 1),
          printdata("NEW BALANCE:   ${newBalance.toStringAsFixed(2)}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print('printTopUpMasterCard error: $e');
      return false;
    }
  }

  Future<bool> printCheckingBalance(
    String cardId,
    double amount,
  ) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      String formattedNumber = NumberFormat("#,##0", "en_US")
          .format(double.parse(amount.toStringAsFixed(2)));
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();
        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("CHECKING BALANCE RECEIPT", 1),
          printdata("DATE:   $formattedDate", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("SN:   $cardId", 1),
          printdata("BALANCE:   ${amount.toStringAsFixed(2)}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTrouble(
      String torNo,
      String route,
      String dateoftrip,
      String vehicleNo,
      String bound,
      String inspectorName,
      String trouble,
      String kmPost,
      String onboardPlace) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();

        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("TROUBLE REPORT", 1),
          printdata("DATE:   $formattedDate", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("TOR NO:   $torNo", 1),
          printdata("ROUTE:   $route", 1),
          printdata("DATE OF TRIP:   $dateoftrip", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()} No:   $vehicleNo",
              1),
          printdata("Bound:   $bound", 1),
          printdata("INSP NAME:   $inspectorName", 1),
        ]);

        if (!fetchservice.getIsNumeric()) {
          sheet.addElements([
            printdata("KM POST:   $kmPost", 1),
            printdata("ONBOARD PLACE:   $onboardPlace", 1),
          ]);
        }
        sheet.addElements([
          printdata("TROUBLE DESC:   $trouble", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);
        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printViolation(
      String torNo,
      String route,
      String dateoftrip,
      String vehicleNo,
      String bound,
      String inspectorName,
      String employeeName,
      String violation,
      String kmpost,
      String onboardplace) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();
        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("VIOLATION REPORT", 1),
          printdata("DATE: $formattedDate", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("TOR NO: $torNo", 1),
          printdata("ROUTE: $route", 1),
          printdata("DATE OF TRIP: $dateoftrip", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()} No: $vehicleNo",
              1),
          printdata("BOUND: $bound", 1),
        ]);

        if (!fetchservice.getIsNumeric()) {
          sheet.addElements([
            printdata("KM POST:   $kmpost", 1),
            printdata("ONBOARD PLACE:   $onboardplace", 1),
          ]);
        }

        sheet.addElements([
          printdata("INSP NAME:   $inspectorName", 1),
          printdata("EMP NAME:   $employeeName", 1),
          printdata("VIOLATION:   $violation", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);
        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printAdditionalFare(
      Map<String, dynamic> item, double amount) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();

        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("ADDITIONAL FARE", 1),
          printdata("DATE: $formattedDate", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("Ticket No: ${item['ticket_no']}", 1),
          printdata("ROUTE: ${item['route']}", 1),
        ]);

        if (!fetchservice.getIsNumeric()) {
          sheet.addElements([
            printdata("FROM:   ${item['from_place']}", 1),
            printdata("TO:   ${item['to_place']}", 1),
          ]);
        }

        sheet.addElements([
          printdata("ADDITIONAL FARE:   $amount", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);
        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printFuel(Map<String, dynamic> item) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();

        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("FUEL RECEIPT", 1),
          printdata("DATE: $formattedDate", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()}#: ${item['bus_no']}",
              1),
          printdata("ROUTE: ${item['route']}", 1),
          printdata("ATTENDANT: ${item['fuel_attendant']}", 1),
          printdata("STATION:   ${item['fuel_station']}", 1),
          printdata("FULL TANK:   ${item['full_tank']}", 1),
          printdata("LITERS:   ${item['fuel_liters']}", 1),
          printdata("PRICE PER LITER: ${item['fuel_price_per_liter']}", 1),
          printdata("AMOUNT: ${item['fuel_amount']}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);

        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print("$e");
      return false;
    }
  }

  Future<bool> printPrepaid(Map<String, dynamic> item) async {
    bool isPrintProceedResult = await isPrintProceed();
    final coopData = fetchservice.fetchCoopData();

    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (isPrintProceedResult) {
        final sheet = TelpoPrintSheet();

        sheet.addElements([
          printdata(breakString("${coopData['cooperativeName']}", 24), 1),
          if (coopData['telephoneNumber'] != null)
            printdata("Contact Us: ${coopData['telephoneNumber']}", 1),
          printdata("POWERED BY: FILIPAY", 1),
          printdata("PREPAID RECEIPT", 1),
          printdata("DATE: $formattedDate", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata(
              "${coopData['coopType'].toString().toUpperCase()}#: ${item['bus_no']}",
              1),
          printdata("ROUTE: ${item['route']}", 1),
          printdata("FROM: ${item['from']}", 1),
          printdata("TO: ${item['to']}", 1),
          printdata("PAX: ${item['pax']}", 1),
          printdata("DATE: $formattedDate", 1),
          printdata("   PASSENGERS   ", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
        ]);

        for (var element in item['passengers']) {
          sheet.addElements([
            printdata("  NAME: ${element['fieldData']['nameOfPassenger']}", 1),
            printdata("  SEAT#: ${element['fieldData']['seatNo']}", 1),
            printdata("  FARE#: ${element['fieldData']['amount']}", 1),
            printdata("- - - - - - - - - - - - - - -", 1),
          ]);
        }
        sheet.addElements([
          printdata("TOTAL FARE:   ${item['fare']}", 1),
          printdata("BAGGAGE:   ${item['baggage']}", 1),
          printdata("TOTAL AMOUNT:   ${item['total']}", 1),
          printdata("- - - - - - - - - - - - - - -", 1),
          printdata("NOT AN OFFICIAL RECEIPT", 1),
          PrintData.space(line: 12)
        ]);
        final PrintResult result = await telpoFlutterChannel.print(sheet);
      }

      return true;
    } catch (e) {
      print("prepaid error: $e");
      return false;
    }
  }

  String newText(String text, [int maxright = 22]) {
    if (text.length > maxright) {
      // Trim the text to 20 characters and add '..'
      return text.substring(0, maxright - 2) + '..';
    } else if (text.length < maxright) {
      // Add spaces at the start to make the text length 22
      return text.padLeft(maxright);
    }
    return text;
  }
}
