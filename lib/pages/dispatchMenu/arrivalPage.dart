import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/login.dart';
import 'package:dltb/pages/specialtrip.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../backend/service/services.dart';

class ArrivalPage extends StatefulWidget {
  const ArrivalPage({super.key, required this.dispatcherData});
  final dispatcherData;
  @override
  State<ArrivalPage> createState() => _ArrivalPageState();
}

class _ArrivalPageState extends State<ArrivalPage> {
  final _myBox = Hive.box('myBox');

  LoadingModal loadingModal = LoadingModal();
  HiveService hiveService = HiveService();
  timeServices basicservices = timeServices();
  TestPrinttt printService = TestPrinttt();
  fetchServices fetchService = fetchServices();

  List<Map<String, dynamic>> employeeList = [];
  Map<String, dynamic> SESSION = {};
  Map<String, dynamic> torDispatch = {};
  Map<String, dynamic> dispatcherData = {};
  List<Map<String, dynamic>> torTrip = [];
  List<Map<String, dynamic>> torTicket = [];
  Map<String, dynamic> coopData = {};
  String conductorName = '';
  String driverName = '';
  String dispatcherName = '';
  String vehicleNo = '';
  int totalBaggage = 0;
  double totalBaggageAmount = 0;
  double totalPassengerAmount = 0;
  int totalbaggageonly = 0;
  int totalbaggagewithpassenger = 0;
  int totalpassengerCount = 0;
  // int fetchAllPassengerCount() {
  //   int allPassenger = 0;
  //   try {
  //     final prepaidTicket = _myBox.get('prepaidTicket');
  //     final torTicket = _myBox.get('torTicket');
  //     final session = _myBox.get('SESSION');
  //     final torTrip = _myBox.get('torTrip');

  //     print('all torTicket: $torTicket');

  //     String control_no = torTrip[session['currentTripIndex']]['control_no'];
  //     // print('torNo: $torNo');
  //     List<Map<String, dynamic>> currentTorTicket = torTicket
  //         .where((item) => item['control_no'] == control_no && item['fare'] > 0)
  //         .toList();
  //     List<Map<String, dynamic>> currentprepaidTicket = prepaidTicket
  //         .where((item) => item['control_no'] == control_no)
  //         .toList();
  //     int sumTotalPassenger = currentprepaidTicket.fold(
  //       0,
  //       (sum, entry) => sum + (entry['totalPassenger'] ?? 0) as int,
  //     );
  //     allPassenger = currentTorTicket.length + sumTotalPassenger;

  //     return allPassenger;
  //   } catch (e) {
  //     return allPassenger;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    coopData = fetchService.fetchCoopData();
    SESSION = _myBox.get('SESSION');
    torDispatch = _myBox.get('torDispatch');
    torTrip = _myBox.get('torTrip');
    torTicket = fetchService.fetchTorTicket();
    torTicket.sort((a, b) {
      // Extract last 4 digits of ticket_number
      int last4DigitsA = int.parse(a["ticket_no"].split("-")[2]);
      int last4DigitsB = int.parse(b["ticket_no"].split("-")[2]);

      // Compare last 4 digits
      return last4DigitsA.compareTo(last4DigitsB);
    });

    totalpassengerCount = fetchService.fetchAllPassengerCount();
    print('SESSION: $SESSION');
    print('SESSION CURRENT TRIP: ${torTrip[SESSION['currentTripIndex']]}');
    totalbaggageonly = fetchService.baggageOnlyCount();
    totalbaggagewithpassenger = fetchService.baggageWithPassengerCount();

    dispatcherData = widget.dispatcherData;
    totalBaggage =
        torTicket.where((item) => (item['baggage'].round() ?? 0) > 0).length;

    // totalBaggageAmount =
    //     torTicket.fold(0.0, (double accumulator, Map<String, dynamic> item) {
    //   int baggage = item['baggage'] ?? 0;
    //   return accumulator + baggage;
    // });

    totalBaggageAmount = fetchService.totalBaggageperTrip();
    totalPassengerAmount = fetchService.totalTripCashReceived() +
        fetchService.totalTripCardSales();

    // totalPassengerAmount =
    //     torTicket.fold(0.0, (double accumulator, Map<String, dynamic> item) {
    //   int fare = item['fare'] ?? 0;
    //   return accumulator + fare;
    // });
    employeeList = fetchService.fetchEmployeeList();

    final driverData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() == torDispatch['driverEmpNo'].toString(),
    );
    print('driverData: $driverData');
    driverName = '${driverData['firstName']} ${driverData['lastName']}';

    final conductorData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() ==
          torDispatch['conductorEmpNo'].toString(),
    );
    print('conductorData: $conductorData');
    conductorName =
        '${conductorData['firstName']} ${conductorData['lastName']}';

    vehicleNo = '${torDispatch['vehicleNo']}:${torDispatch['plate_number']}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child:
                Opacity(opacity: 0.5, child: Image.asset("assets/citybg.png")),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                appbar(),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ARRIVAL MENU',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: true,
                                    label: "Opening",
                                    value:
                                        '${torTicket.isNotEmpty ? torTicket[0]['ticket_no'] : "NO TICKET"}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "Closing",
                                    value:
                                        '${torTicket.isNotEmpty ? torTicket[torTicket.length - 1]['ticket_no'] : "NO TICKET"}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "PASSENGER ISSUED",
                                    value:
                                        '${fetchService.fetchAllPassengerCount()}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "BAGGAGE ISSUED",
                                    value: '${fetchService.baggageCount()}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "TOTAL FARE",
                                    value:
                                        '${fetchService.totalTripFare().toStringAsFixed(2)}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "TOTAL BAGGAGE",
                                    value:
                                        '${fetchService.totalBaggageperTrip()}'),
                                if (coopData['coopType'] == "Bus")
                                  SizedBox(height: 5),
                                if (coopData['coopType'] == "Bus")
                                  arrivalWidget(
                                      isBottom: false,
                                      isTop: false,
                                      label: "PREPAID PASS REVENUE",
                                      value:
                                          '${fetchService.totalPrepaidPassengerRevenueperTrip()}'),
                                // SizedBox(height: 5),
                                // arrivalWidget(
                                //     isBottom: false,
                                //     isTop: false,
                                //     label: "PREPAID BAGG REVENUE",
                                //     value:
                                //         '${fetchService.totalPrepaidBaggageRevenueperTrip()}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "TOTAL EXPENSES",
                                    value:
                                        '${fetchService.totalTripExpenses().toStringAsFixed(2)}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "CASH RECEIVED",
                                    value:
                                        '${fetchService.totalTripCashReceived().toStringAsFixed(2)}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "CARD SALES",
                                    value:
                                        '${fetchService.totalTripCardSales().toStringAsFixed(2)}'),
                                if (coopData['coopType'] == "Bus")
                                  SizedBox(height: 5),
                                if (coopData['coopType'] == "Bus")
                                  arrivalWidget(
                                      isBottom: false,
                                      isTop: false,
                                      label: "TOTAL TOPUP",
                                      value:
                                          '${fetchService.getTotalTopUpperTrip().toStringAsFixed(2)}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: true,
                                    isTop: false,
                                    label: "GRAND TOTAL",
                                    value:
                                        '${fetchService.totalTripGrandTotal().toStringAsFixed(2)}'),
                                SizedBox(height: 10),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: true,
                                    label: "trip no",
                                    value: '${torTrip.length}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label:
                                        "${coopData['coopType'].toString().toUpperCase()} no",
                                    value: '$vehicleNo'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "TOR NO",
                                    value:
                                        '${torTrip[SESSION['currentTripIndex']]['tor_no']}'),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "conductor",
                                    value: conductorName),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "driver",
                                    value: driverName),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: false,
                                    isTop: false,
                                    label: "dispatcher",
                                    value:
                                        "${dispatcherData['firstName']} ${dispatcherData['middleName'] != '' ? dispatcherData['middleName'][0] : ''}. ${dispatcherData['lastName']} ${dispatcherData['nameSuffix']}"),
                                SizedBox(height: 5),
                                arrivalWidget(
                                    isBottom: true,
                                    isTop: false,
                                    label: "route",
                                    value:
                                        '${torTrip[SESSION['currentTripIndex']]['route']}'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (SESSION['tripType'] == 'regular') {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DashboardPage()));
                                  } else if (SESSION['tripType'] == 'special') {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SpecialTripPage()));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors
                                      .primaryColor, // Background color of the button

                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),

                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 1, color: Colors.black),

                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    ' BACK ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  loadingModal.showLoading(context);
                                  final torTicket =
                                      fetchService.fetchallPerTripTicket();

                                  final torTrip = _myBox.get('torTrip');
                                  final session = _myBox.get('SESSION');
                                  String control_no =
                                      torTrip[session['currentTripIndex']]
                                          ['control_no'];
                                  String route =
                                      torTrip[SESSION['currentTripIndex']]
                                              ['route']
                                          .toString();

                                  // bool isUpdateTripIndex = true;
                                  bool isUpdateTripIndex = await hiveService
                                      .updateCurrentTripIndex(dispatcherData);

                                  if (isUpdateTripIndex) {
                                    int totalBaggageCount = torTicket
                                        .where((item) =>
                                            (item['baggage'] is num &&
                                                item['baggage'] > 0) &&
                                            item['control_no'] == control_no)
                                        .length;
                                    torTicket.sort((a, b) {
                                      // Extract last 4 digits of ticket_number
                                      int last4DigitsA = int.parse(
                                          a["ticket_no"].split("-")[2]);
                                      int last4DigitsB = int.parse(
                                          b["ticket_no"].split("-")[2]);

                                      // Compare last 4 digits
                                      return last4DigitsA
                                          .compareTo(last4DigitsB);
                                    });
                                    bool isprint =
                                        await printService.printArrivalShortVer(
                                            totalpassengerCount,
                                            totalPassengerAmount,
                                            "$vehicleNo",
                                            torTrip.length);
                                    // await printService.printArrival(
                                    //     torTicket.isNotEmpty
                                    //         ? '${torTicket[0]['ticket_no']}'
                                    //         : 'NO TICKET',
                                    //     torTicket.isNotEmpty
                                    //         ? '${torTicket[torTicket.length - 1]['ticket_no']}'
                                    //         : 'NO TICKET',
                                    //     totalpassengerCount,
                                    //     totalBaggageCount,
                                    //     // +
                                    //     //     int.parse(fetchService
                                    //     //         .totalPrepaidBaggageCountperTrip()
                                    //     //         .toStringAsFixed(0)
                                    //     //         ),
                                    //     totalPassengerAmount,
                                    //     totalBaggageAmount,
                                    //     torTrip.length,
                                    //     vehicleNo,
                                    //     conductorName,
                                    //     driverName,
                                    //     '${dispatcherData['firstName']} ${dispatcherData['middleName'] != '' ? dispatcherData['middleName'][0] : ''}. ${dispatcherData['lastName']} ${dispatcherData['nameSuffix']}',
                                    //     route ?? '',
                                    //     "${SESSION['torNo']}",
                                    //     "${SESSION['tripType']}",
                                    //     fetchService.totalTripExpenses());
                                    if (isprint) {
                                      var removedcashCardInfo =
                                          SESSION.remove('cashCardInfo');
                                      var removedloginInfo =
                                          SESSION.remove('loginInfo');

                                      print(
                                          'removed Map after removing age: $SESSION');
                                      print(
                                          'Removed value: $removedcashCardInfo');
                                      print('Removed value: $removedloginInfo');

                                      _myBox.put('SESSION', SESSION);
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()));
                                    } else {
                                      Navigator.of(context).pop();
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.danger,
                                              title: "SOMETHING WENT  WRONG",
                                              text: "Please try again"));
                                    }

                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => DashboardPage()));
                                  } else {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "ERROR",
                                            text:
                                                "PLEASE CHECK YOUR INTERNET CONNECTION"));
                                  }
                                  // bool isUpdateArrived =
                                  //     await hiveService.updateArrived();

                                  // if (isUpdateArrived) {
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors
                                      .primaryColor, // Background color of the button

                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),

                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 1, color: Colors.black),

                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    ' PRINT ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class arrivalWidget extends StatelessWidget {
  const arrivalWidget({
    super.key,
    required this.isTop,
    required this.isBottom,
    required this.label,
    required this.value,
  });

  final String value;
  final String label;
  final bool isTop;
  final bool isBottom;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: isTop
              ? BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))
              : (isBottom
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))
                  : BorderRadius.circular(0))),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '${label.toUpperCase()}',
                style: TextStyle(color: Colors.white),
              ),
            )),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.35,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: isTop
                      ? BorderRadius.only(topRight: Radius.circular(20))
                      : (isBottom
                          ? BorderRadius.only(bottomRight: Radius.circular(20))
                          : BorderRadius.circular(0))),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      ' ${value} ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
