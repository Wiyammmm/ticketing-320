import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/container.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/closingMenu/editExpensesPage.dart';
import 'package:dltb/pages/closingMenu/endofDayPage.dart';
import 'package:dltb/pages/closingMenuPage.dart';
import 'package:dltb/pages/syncingMenuPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

class FinalCashPage extends StatefulWidget {
  const FinalCashPage({super.key, required this.cashierData});
  final cashierData;
  @override
  State<FinalCashPage> createState() => _FinalCashPageState();
}

class _FinalCashPageState extends State<FinalCashPage> {
  final _myBox = Hive.box('myBox');
  LoadingModal loadingmodal = LoadingModal();
  DeviceInfoService deviceInfoService = DeviceInfoService();
  GeneratorServices generatorService = GeneratorServices();
  httprequestService httpRequestServices = httprequestService();
  timeServices basicservices = timeServices();
  fetchServices fetchService = fetchServices();
  TestPrinttt printService = TestPrinttt();
  HiveService hiveService = HiveService();
  final TextEditingController textEditingController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController finalCashRemittedController = TextEditingController();
  TextEditingController shortController = TextEditingController(text: '0');
  // waybill
  List<TextEditingController> waybillTicketRevenueController = [];
  List<TextEditingController> waybillTicketCountController = [];

  // end waybill

  // puncher passenger
  // TextEditingController puncherPassengerTicketRevenueController =
  //     TextEditingController(text: '0');
  // TextEditingController puncherPassengerTicketCountController =
  //   TextEditingController(text: '0');
  List<TextEditingController> puncherPassengerTicketRevenueController = [];
  List<TextEditingController> puncherPassengerTicketCountController = [];

  // end puncher passenger

  // puncher baggage

  List<TextEditingController> puncherBaggageTicketRevenueController = [];
  List<TextEditingController> puncherBaggageTicketCountController = [];

  // TextEditingController puncherBaggageTicketRevenueController =
  //     TextEditingController(text: '0');
  // TextEditingController puncherBaggageTicketCountController =
  //     TextEditingController(text: '0');
  // end puncher baggage

  // charter

  List<TextEditingController> charterTicketRevenueController = [];
  List<TextEditingController> charterTicketCountController = [];
  // TextEditingController charterTicketRevenueController =
  //     TextEditingController(text: '0');
  // TextEditingController charterTicketCountController =
  //     TextEditingController(text: '0');
  // end charter
  List<dynamic> terminalList = [];
  List<Map<String, dynamic>> torTrip = [];
  String? selectedTerminal;
  bool isCoding = false;
  Map<String, dynamic> coopData = {};
  Map<dynamic, dynamic> sessionBox = {};
  List<Map<String, dynamic>> expenses = [];
  double cashRecieved = 0;
  double copyCashReceived = 0;
  // double netCollections = 0;
  double totalCashRemitted = 0;
  double finalCashRemittance = 0;
  double overageShortage = 0;
  double totalExpenses = 0;
  bool isDltb = false;

  double netCollection = 0;
  double copyNetCollection = 0;

  double grossRevenue = 0;
  double copyGrossRevenue = 0;
  double final_remittance = 0;

  double charterRevenue = 0;
  double copyCharterRevenue = 0;

  double waybillRevenue = 0;
  double copywaybillRevenue = 0;

  @override
  void initState() {
    super.initState();
    charterRevenue = fetchService.totalCharter();
    copyCharterRevenue = charterRevenue;
    waybillRevenue = fetchService.totalWaybill();
    copywaybillRevenue = waybillRevenue;
    grossRevenue = fetchService.getTotalGrossRevenue();
    copyGrossRevenue = grossRevenue;
    coopData = fetchService.fetchCoopData();
    terminalList = fetchService.fetchTerminalList();
    terminalList = terminalList.toSet().toList();
    print('terminalList:  $terminalList');
    cashRecieved = hiveService.getAllCashRecevied();

    remarksController.text = fetchService.getRemarks();
    torTrip = _myBox.get('torTrip');
    for (int i = 0; i < torTrip.length; i++) {
      // waybill
      waybillTicketRevenueController.add(TextEditingController(text: "0"));
      waybillTicketCountController.add(TextEditingController(text: "0"));
      // puncher passenger
      puncherPassengerTicketCountController
          .add(TextEditingController(text: "0"));
      puncherPassengerTicketRevenueController
          .add(TextEditingController(text: "0"));
      // puncher baggage
      puncherBaggageTicketRevenueController
          .add(TextEditingController(text: "0"));
      puncherBaggageTicketCountController.add(TextEditingController(text: "0"));
      // charter
      charterTicketRevenueController.add(TextEditingController(
          text: "${torTrip[i]['ticket_revenue_charter']}"));
      charterTicketCountController.add(
          TextEditingController(text: "${torTrip[i]['ticket_count_charter']}"));
    }
    sessionBox = _myBox.get('SESSION');
    expenses = _myBox.get('expenses');
    print('terminalList: $terminalList');
    totalExpenses = expenses
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();
    cashRecieved -= totalExpenses;
    copyCashReceived = cashRecieved;
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }
    netCollection = fetchService.getTotalNetCollection();
    copyNetCollection = netCollection;

    final_remittance = netCollection -
        (charterRevenue +
            waybillRevenue +
            fetchService.totalPrepaidPassengerRevenue());
  }

  @override
  void dispose() {
    // Dispose of each controller in the list when the widget is disposed
    for (var controller in waybillTicketRevenueController) {
      controller.dispose();
    }
    for (var controller in waybillTicketCountController) {
      controller.dispose();
    }
    for (var controller in puncherPassengerTicketRevenueController) {
      controller.dispose();
    }
    for (var controller in puncherPassengerTicketCountController) {
      controller.dispose();
    }
    for (var controller in puncherBaggageTicketRevenueController) {
      controller.dispose();
    }
    for (var controller in puncherBaggageTicketCountController) {
      controller.dispose();
    }
    for (var controller in charterTicketRevenueController) {
      controller.dispose();
    }
    for (var controller in charterTicketCountController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datenow = basicservices.formatDateNow();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // logic
      },
      child: Scaffold(
        body: SafeArea(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                  opacity: 0.5, child: Image.asset("assets/citybg.png")),
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
                        'END OF DAY TRIP (TOTAL)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          // height: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                              color: Color(0xfff4f7f9),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                color: AppColors.primaryColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'REMARKS',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: remarksController,
                                textAlign: TextAlign.center,
                                enabled: false,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Input Remarks',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400])),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DLTBContainer(
                            isTop: true,
                            isBottom: false,
                            label: "cash received",
                            value:
                                '${isDltb ? cashRecieved.round() : cashRecieved.toStringAsFixed(2)}'),
                        SizedBox(
                          height: 5,
                        ),
                        DLTBContainer(
                            isTop: false,
                            isBottom: false,
                            label: "Card Sales",
                            value: '${fetchService.grandTotalCardSales()}'),

                        SizedBox(
                          height: 5,
                        ),
                        DLTBContainer(
                            isTop: false,
                            isBottom: false,
                            label: "GROSS REVENUE",
                            value: '${grossRevenue.toStringAsFixed(2)}'),
                        SizedBox(
                          height: 5,
                        ),
                        DLTBContainer(
                            isTop: false,
                            isBottom: false,
                            label: "NET COLLECTION",
                            value: '${netCollection.toStringAsFixed(2)}'),
                        SizedBox(
                          height: 5,
                        ),
                        DLTBContainer(
                            isTop: false,
                            isBottom: false,
                            label: "FINAL REMITTANCE",
                            value: '${final_remittance.toStringAsFixed(2)}'),
                        if (coopData['coopType'] == "Bus")
                          SizedBox(
                            height: 5,
                          ),
                        if (coopData['coopType'] == "Bus")
                          DLTBContainer(
                              isTop: false,
                              isBottom: false,
                              label: "CHARTER REVENUE",
                              value: '${charterRevenue}'),
                        if (coopData['coopType'] == "Bus")
                          SizedBox(
                            height: 5,
                          ),
                        if (coopData['coopType'] == "Bus")
                          DLTBContainer(
                              isTop: false,
                              isBottom: false,
                              label: "PREPAID PASS REVENUE",
                              value:
                                  '${fetchService.totalPrepaidPassengerRevenue()}'),
                        if (coopData['coopType'] == "Bus")
                          SizedBox(
                            height: 5,
                          ),
                        // DLTBContainer(
                        //     isTop: false,
                        //     isBottom: false,
                        //     label: "PREPAID BAGG REVENUE",
                        //     value:
                        //         '${fetchService.totalPrepaidBaggageRevenue()}'),
                        // SizedBox(
                        //   height: 5,
                        // ),
                        if (coopData['coopType'] == "Bus")
                          DLTBContainer(
                              isTop: false,
                              isBottom: true,
                              label: "Top Up Revenue",
                              value: '${fetchService.getTotalTopUpper()}'),
                        SizedBox(
                          height: 5,
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // DLTBContainer(
                        //     isTop: true,
                        //     isBottom: false,
                        //     label: "add fare",
                        //     value: '${fetchService.grandTotalAddFare()}'),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  width: 2,
                                  color: AppColors.primaryColor), // Set border
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: ExpansionTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Remittance',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: AppColors.primaryColor,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '* ',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'FINAL CASH REMITTANCE',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  //  Text(
                                                  //   '0.00',
                                                  //   textAlign: TextAlign.center,
                                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                                  // ),
                                                  SizedBox(
                                                height: 20,
                                                child: TextFormField(
                                                  controller:
                                                      finalCashRemittedController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10),
                                                      border: InputBorder.none,
                                                      hintText: '****',
                                                      hintStyle: TextStyle(
                                                          color: Colors
                                                              .grey[600])),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      try {
                                                        shortController
                                                            .text = (double.parse(
                                                                    finalCashRemittedController
                                                                        .text) -
                                                                final_remittance)
                                                            .toString();
                                                      } catch (e) {
                                                        shortController.text =
                                                            "0";
                                                      }
                                                    });
                                                  },
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: DLTBContainer(
                                    isTop: false,
                                    isBottom: true,
                                    label: "short/over",
                                    value: "${shortController.text}"),
                              )
                              // Container(
                              //   decoration: BoxDecoration(
                              //       color: AppColors.primaryColor,
                              //       border: Border.all(
                              //           width: 2, color: Colors.white),
                              //       borderRadius: BorderRadius.circular(10)),
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(8.0),
                              //     child: Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.spaceAround,
                              //       children: [
                              //         Expanded(
                              //           child: Text(
                              //             'SHORT/OVER',
                              //             style: TextStyle(
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           ),
                              //         ),
                              //         Container(
                              //           width:
                              //               MediaQuery.of(context).size.width *
                              //                   0.3,
                              //           color: Color(0xffd9d9d9),
                              //           child: Padding(
                              //               padding: const EdgeInsets.all(8.0),
                              //               child:
                              //                   //  Text(
                              //                   //   '0.00',
                              //                   //   textAlign: TextAlign.center,
                              //                   //   style: TextStyle(fontWeight: FontWeight.bold),
                              //                   // ),
                              //                   SizedBox(
                              //                 height: 20,
                              //                 child: TextFormField(
                              //                   controller: shortController,
                              //                   keyboardType:
                              //                       TextInputType.number,
                              //                   enabled: false,
                              //                   textAlign: TextAlign.center,
                              //                   style: TextStyle(
                              //                       color: Colors.black),
                              //                   decoration: InputDecoration(
                              //                       contentPadding:
                              //                           EdgeInsets.only(
                              //                               bottom: 10),
                              //                       border: InputBorder.none,
                              //                       hintText: '****',
                              //                       hintStyle: TextStyle(
                              //                           color: Colors.black)),
                              //                 ),
                              //               )),
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  width: 2,
                                  color: AppColors.primaryColor), // Set border
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Text(
                              'EXPENSES',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: AppColors.primaryColor,
                            children: <Widget>[
                              //expenses list
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: torTrip
                                    .length, // Number of items in the list
                                itemBuilder: (BuildContext context, int index) {
                                  double totalExpenses = 0;
                                  totalExpenses = expenses
                                      .where((item) =>
                                          item['control_no'] ==
                                          "${torTrip[index]['control_no']}") // Add your condition here
                                      .map((item) =>
                                          (item['amount'] ?? 0.0) as num)
                                      .fold(
                                          0.0, (prev, amount) => prev + amount)
                                      .toDouble();
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditExpensesPage(
                                                  cashierData:
                                                      widget.cashierData,
                                                  control_no:
                                                      "${torTrip[index]['control_no']}",
                                                  torNo:
                                                      "${torTrip[index]['tor_no']}")));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          border: Border.all(
                                              width: 2, color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              'Trip ${index + 1}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'VIEW',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Total: $totalExpenses',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              //
                              // for (int i = 0; i < torTrip.length; i++)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (coopData['coopType'] == "Bus")
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                border: Border.all(
                                    width: 2,
                                    color:
                                        AppColors.primaryColor), // Set border
                                borderRadius: BorderRadius.circular(10)),
                            child: ExpansionTile(
                              title: Text(
                                'WayBill',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: AppColors.primaryColor,
                              collapsedIconColor: AppColors.primaryColor,
                              children: <Widget>[
                                for (int i = 0; i < torTrip.length; i++)
                                  ExpansionTile(
                                    title: Text('TRIP ${i + 1}'),
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(20),
                                                  topLeft:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Revenue',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              waybillTicketRevenueController[
                                                                  i],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                          onChanged: (value) {
                                                            double
                                                                puncherPassengerRev =
                                                                0;
                                                            double
                                                                puncherBaggageRev =
                                                                0;

                                                            double
                                                                waybillrevenue =
                                                                0;

                                                            for (int i = 0;
                                                                i <
                                                                    torTrip
                                                                        .length;
                                                                i++) {
                                                              try {
                                                                waybillrevenue +=
                                                                    double.parse(
                                                                        waybillTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                              try {
                                                                puncherPassengerRev +=
                                                                    double.parse(
                                                                        puncherPassengerTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }

                                                              try {
                                                                puncherBaggageRev +=
                                                                    double.parse(
                                                                        puncherBaggageTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                            }

                                                            setState(() {
                                                              cashRecieved =
                                                                  copyCashReceived +
                                                                      puncherPassengerRev +
                                                                      puncherBaggageRev;

                                                              waybillRevenue =
                                                                  copywaybillRevenue +
                                                                      waybillrevenue;

                                                              grossRevenue = copyGrossRevenue +
                                                                  puncherPassengerRev +
                                                                  puncherBaggageRev +
                                                                  waybillRevenue;

                                                              netCollection =
                                                                  grossRevenue -
                                                                      totalExpenses;

                                                              final_remittance = netCollection -
                                                                  (charterRevenue +
                                                                      waybillRevenue +
                                                                      fetchService
                                                                          .totalPrepaidPassengerRevenue());
                                                            });
                                                          },
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Count',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              waybillTicketCountController[
                                                                  i],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        if (coopData['coopType'] == "Bus")
                          SizedBox(
                            height: 10,
                          ),
                        if (coopData['coopType'] == "Bus")
                          Container(
                            decoration: BoxDecoration(
                                // Set border
                                color: AppColors.secondaryColor,
                                border: Border.all(
                                    width: 2, color: AppColors.primaryColor),
                                borderRadius: BorderRadius.circular(10)),
                            child: ExpansionTile(
                              title: Text(
                                'Puncher Passenger',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: AppColors.primaryColor,
                              collapsedIconColor: AppColors.primaryColor,
                              children: <Widget>[
                                for (int i = 0; i < torTrip.length; i++)
                                  ExpansionTile(
                                    title: Text('TRIP ${i + 1}'),
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Revenue',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              puncherPassengerTicketRevenueController[
                                                                  i],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                          onChanged: (value) {
                                                            double
                                                                puncherPassengerRev =
                                                                0;
                                                            double
                                                                puncherBaggageRev =
                                                                0;

                                                            double
                                                                waybillrevenue =
                                                                0;

                                                            for (int i = 0;
                                                                i <
                                                                    torTrip
                                                                        .length;
                                                                i++) {
                                                              try {
                                                                waybillrevenue +=
                                                                    double.parse(
                                                                        waybillTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                              try {
                                                                puncherPassengerRev +=
                                                                    double.parse(
                                                                        puncherPassengerTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }

                                                              try {
                                                                puncherBaggageRev +=
                                                                    double.parse(
                                                                        puncherBaggageTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                            }

                                                            setState(() {
                                                              cashRecieved =
                                                                  copyCashReceived +
                                                                      puncherPassengerRev +
                                                                      puncherBaggageRev;

                                                              waybillRevenue =
                                                                  copywaybillRevenue +
                                                                      waybillrevenue;

                                                              grossRevenue = copyGrossRevenue +
                                                                  puncherPassengerRev +
                                                                  puncherBaggageRev +
                                                                  waybillRevenue;

                                                              netCollection =
                                                                  grossRevenue -
                                                                      totalExpenses;

                                                              final_remittance = netCollection -
                                                                  (charterRevenue +
                                                                      waybillRevenue +
                                                                      fetchService
                                                                          .totalPrepaidPassengerRevenue());
                                                            });
                                                          },
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Count',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              puncherPassengerTicketCountController[
                                                                  i],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        if (coopData['coopType'] == "Bus")
                          SizedBox(
                            height: 10,
                          ),
                        if (coopData['coopType'] == "Bus")
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                border: Border.all(
                                    width: 2,
                                    color:
                                        AppColors.primaryColor), // Set border
                                borderRadius: BorderRadius.circular(10)),
                            child: ExpansionTile(
                              title: Text(
                                'Puncher Baggage',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: AppColors.primaryColor,
                              collapsedIconColor: AppColors.primaryColor,
                              children: <Widget>[
                                for (int i = 0; i < torTrip.length; i++)
                                  ExpansionTile(
                                    title: Text("TRIP ${i + 1}"),
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Revenue',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              puncherBaggageTicketRevenueController[
                                                                  i],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                          onChanged: (value) {
                                                            double
                                                                puncherPassengerRev =
                                                                0;
                                                            double
                                                                puncherBaggageRev =
                                                                0;

                                                            double
                                                                waybillrevenue =
                                                                0;

                                                            for (int i = 0;
                                                                i <
                                                                    torTrip
                                                                        .length;
                                                                i++) {
                                                              try {
                                                                waybillrevenue +=
                                                                    double.parse(
                                                                        waybillTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                              try {
                                                                puncherPassengerRev +=
                                                                    double.parse(
                                                                        puncherPassengerTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }

                                                              try {
                                                                puncherBaggageRev +=
                                                                    double.parse(
                                                                        puncherBaggageTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                            }

                                                            setState(() {
                                                              cashRecieved =
                                                                  copyCashReceived +
                                                                      puncherPassengerRev +
                                                                      puncherBaggageRev;

                                                              waybillRevenue =
                                                                  copywaybillRevenue +
                                                                      waybillrevenue;

                                                              grossRevenue = copyGrossRevenue +
                                                                  puncherPassengerRev +
                                                                  puncherBaggageRev +
                                                                  waybillRevenue;

                                                              netCollection =
                                                                  grossRevenue -
                                                                      totalExpenses;

                                                              final_remittance = netCollection -
                                                                  (charterRevenue +
                                                                      waybillRevenue +
                                                                      fetchService
                                                                          .totalPrepaidPassengerRevenue());
                                                            });
                                                          },
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              border: Border.all(
                                                  width: 2,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Count',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              puncherBaggageTicketCountController[
                                                                  i],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        if (coopData['coopType'] == "Bus")
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                border: Border.all(
                                    width: 2,
                                    color:
                                        AppColors.primaryColor), // Set border
                                borderRadius: BorderRadius.circular(10)),
                            child: ExpansionTile(
                              title: Text(
                                'Charter',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: AppColors.primaryColor,
                              collapsedIconColor: AppColors.primaryColor,
                              children: <Widget>[
                                for (int i = 0; i < torTrip.length; i++)
                                  ExpansionTile(
                                    title: Text("TRIP ${i + 1}"),
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Revenue',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              charterTicketRevenueController[
                                                                  i],
                                                          enabled: false,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                          onChanged: (value) {
                                                            double charterrev =
                                                                0;
                                                            for (int i = 0;
                                                                i <
                                                                    torTrip
                                                                        .length;
                                                                i++) {
                                                              try {
                                                                charterrev +=
                                                                    double.parse(
                                                                        charterTicketRevenueController[i]
                                                                            .text);
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                            }

                                                            setState(() {
                                                              charterRevenue =
                                                                  copyCharterRevenue +
                                                                      charterrev;
                                                            });
                                                          },
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Ticket Count',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          //  Text(
                                                          //   '0.00',
                                                          //   textAlign: TextAlign.center,
                                                          //   style: TextStyle(fontWeight: FontWeight.bold),
                                                          // ),
                                                          SizedBox(
                                                        height: 20,
                                                        child: TextFormField(
                                                          controller:
                                                              charterTicketCountController[
                                                                  i],
                                                          enabled: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          decoration: InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          10),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText: '****',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  color: AppColors.primaryColor, width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'CODING',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isCoding = false;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    decoration: BoxDecoration(
                                        color: isCoding
                                            ? Color(0xffd9d9d9)
                                            : AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: AppColors.primaryColor,
                                            width: 2)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'NO',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: isCoding
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isCoding = true;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    decoration: BoxDecoration(
                                        color: isCoding
                                            ? AppColors.primaryColor
                                            : Color(0xffd9d9d9),
                                        border: Border.all(
                                            width: 2,
                                            color: AppColors.primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'YES',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: isCoding
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ClosingMenuPage(
                                                cashierData: widget.cashierData,
                                              )));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors
                                      .primaryColor, // Background color of the button
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    ' CANCEL ',
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
                                onPressed: () {
                                  if (finalCashRemittedController.text.trim() !=
                                          "" &&
                                      shortController.text.trim() != "") {
                                    _showDialog();
                                  } else {
                                    ArtSweetAlert.show(
                                        context: context,
                                        barrierDismissible: false,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "INCOMPLETE",
                                            text:
                                                "PLEASE COMPLETE ALL FIELDS"));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors
                                      .primaryColor, // Background color of the button
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    ' SAVE ',
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
                ),
              ],
            )),
          ],
        )),
      ),
    );
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Save End of day FINAL CASH?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .primaryColor, // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                ' CANCEL ',
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
                              try {
                                loadingmodal.showLoading(context);
                                final torMain = _myBox.get('torMain');
                                final torTicket = _myBox.get('torTicket');
                                final prePaidPassenger =
                                    _myBox.get('prepaidTicket');
                                // final prePaidBaggage =
                                //     _myBox.get('prepaidBaggage');
                                final expenses = _myBox.get('expenses');
                                print('tortriptest.length: ${torTrip.length}');
                                bool isProceed = false;

                                int flag = 0;

                                double totalExpenses = expenses
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalDiesel = expenses
                                    .where(
                                        (item) => item['particular'] == "Fuel")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalToll = expenses
                                    .where(
                                        (item) => item['particular'] == "TOLL")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalParking = expenses
                                    .where((item) =>
                                        item['particular'] == "PARKING")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalServices = expenses
                                    .where((item) =>
                                        item['particular'] == "SERVICES")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalRepair = expenses
                                    .where((item) =>
                                        item['particular'] == "REPAIR")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalCallersFee = expenses
                                    .where((item) =>
                                        item['particular'] == "CALLER'S FEE")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalEmployeeBenefits = expenses
                                    .where((item) =>
                                        item['particular'] ==
                                        "EMPLOYEE BENEFITS")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalMaterials = expenses
                                    .where((item) =>
                                        item['particular'] == "MATERIALS")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                double totalRepresentation = expenses
                                    .where((item) =>
                                        item['particular'] == "REPRESENTATION")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();
                                double totalOthers = totalServices +
                                    totalCallersFee +
                                    totalEmployeeBenefits +
                                    totalRepair +
                                    totalMaterials +
                                    totalRepresentation;

                                String uuid = generatorService.generateUuid();
                                String deviceid = await deviceInfoService
                                    .getDeviceSerialNumber();
                                String controlNo =
                                    await generatorService.generateControlNo();

                                List<dynamic> listTorNo = torTrip
                                    .map((item) => item['tor_no']
                                        as String) // Extract tor_no values
                                    .toSet() // Convert to a set to eliminate duplicates
                                    .toList();
                                print('finalcashpage listTorNo: $listTorNo');
                                Map<String, dynamic> aggregatedData = {};
                                double waybillrevenue = 0;
                                double waybillcount = 0;

                                double puncherTicketRevenue = 0;
                                double puncherTicketCount = 0;

                                double puncherBaggageRevenue = 0;
                                double puncherBaggageCount = 0;

                                double charterTicketRevenue = 0;
                                double charterTicketCount = 0;

                                double prepaidPassengerRevenue = 0;

                                for (int index = 0;
                                    index < torTrip.length;
                                    index++) {
                                  var item = torTrip[index];

                                  prepaidPassengerRevenue += double.parse(
                                      torTrip[index]['ticket_revenue_reserved']
                                          .toString());

                                  waybillrevenue += double.parse(
                                      waybillTicketRevenueController[index]
                                          .text);
                                  waybillcount += double.parse(
                                      waybillTicketCountController[index].text);

                                  puncherTicketRevenue += double.parse(
                                      puncherPassengerTicketRevenueController[
                                              index]
                                          .text);
                                  puncherTicketCount += double.parse(
                                      puncherPassengerTicketCountController[
                                              index]
                                          .text);

                                  puncherBaggageRevenue += double.parse(
                                      puncherBaggageTicketRevenueController[
                                              index]
                                          .text);

                                  puncherBaggageCount += double.parse(
                                      puncherBaggageTicketCountController[index]
                                          .text);

                                  charterTicketRevenue += double.parse(
                                      charterTicketRevenueController[index]
                                          .text);

                                  charterTicketCount += double.parse(
                                      charterTicketCountController[index].text);

                                  item['ticket_count_waybill'] = double.parse(
                                      waybillTicketCountController[index].text);
                                  item['ticket_revenue_waybill'] = double.parse(
                                      waybillTicketRevenueController[index]
                                          .text);

                                  item['ticket_revenue_punch_passenger'] =
                                      double.parse(
                                          puncherPassengerTicketRevenueController[
                                                  index]
                                              .text);
                                  item['ticket_count_punch_passenger'] =
                                      double.parse(
                                          puncherPassengerTicketCountController[
                                                  index]
                                              .text);

                                  item['ticket_revenue_punch_baggage'] =
                                      double.parse(
                                          puncherBaggageTicketRevenueController[
                                                  index]
                                              .text);
                                  item['ticket_count_punch_baggage'] =
                                      double.parse(
                                          puncherBaggageTicketCountController[
                                                  index]
                                              .text);

                                  item['ticket_revenue_charter'] = double.parse(
                                      charterTicketRevenueController[index]
                                          .text);
                                  item['ticket_count_charter'] = double.parse(
                                      charterTicketCountController[index].text);

                                  item['ticket_revenue_punch'] = double.parse(
                                          puncherPassengerTicketRevenueController[
                                                  index]
                                              .text) +
                                      double.parse(
                                          puncherBaggageTicketRevenueController[
                                                  index]
                                              .text);
                                  item['ticket_count_punch'] = double.parse(
                                          puncherPassengerTicketCountController[
                                                  index]
                                              .text) +
                                      double.parse(
                                          puncherBaggageTicketCountController[
                                                  index]
                                              .text);

                                  item['passenger_revenue'] += double.parse(
                                      puncherPassengerTicketRevenueController[
                                              index]
                                          .text);

                                  item['baggage_revenue'] += double.parse(
                                          puncherBaggageTicketRevenueController[
                                                  index]
                                              .text) +
                                      double.parse(
                                          waybillTicketRevenueController[index]
                                              .text);

                                  item['gross_revenue'] += double.parse(
                                          puncherPassengerTicketRevenueController[
                                                  index]
                                              .text) +
                                      double.parse(
                                          puncherBaggageTicketRevenueController[
                                                  index]
                                              .text) +
                                      double.parse(
                                          waybillTicketRevenueController[index]
                                              .text);

                                  item['passenger_count'] += double.parse(
                                      puncherPassengerTicketCountController[
                                              index]
                                          .text);
                                  item['baggage_count'] += double.parse(
                                          puncherBaggageTicketCountController[
                                                  index]
                                              .text) +
                                      double.parse(
                                          waybillTicketCountController[index]
                                              .text);

                                  item['cashReceived'] += double.parse(
                                          puncherPassengerTicketRevenueController[
                                                  index]
                                              .text) +
                                      double.parse(
                                          puncherBaggageTicketRevenueController[
                                                  index]
                                              .text);

                                  Map<String, dynamic> isUpdateTortrip =
                                      await httpRequestServices
                                          .updateTorTrip(torTrip[index]);

                                  if (isUpdateTortrip['messages'][0]['code']
                                          .toString() !=
                                      "0") {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "ERROR",
                                            text:
                                                "${isUpdateTortrip['messages'][0]['message']}"));

                                    return;
                                  }

                                  print('item tortriptest: ${torTrip.length}');
                                  String torNo = item['tor_no'] as String;
                                  String control_no = "${item['control_no']}";
                                  double prePaidPassengerAmount =
                                      prePaidPassenger
                                          .where((entry) =>
                                              entry['control_no'] == control_no)
                                          .fold(
                                            0.0,
                                            (sum, entry) => sum +
                                                (entry['totalAmount'] ??
                                                    0.0) as double,
                                          );
                                  // double prePaidBaggageAmount = prePaidBaggage
                                  //     .where((entry) =>
                                  //         entry['control_no'] == control_no)
                                  //     .fold(
                                  //       0.0,
                                  //       (sum, entry) =>
                                  //           sum + (entry['totalAmount'] ?? 0.0)
                                  //               as double,
                                  //     );
                                  double ticket_revenue_reserved =
                                      prePaidPassengerAmount;
                                  // +
                                  //     prePaidBaggageAmount;

                                  int ticket_count_reserved =
                                      prePaidPassenger.length;
                                  // +
                                  //     prePaidBaggage.length;
                                  double ticket_revenue_card = torTicket
                                      .where((fare) =>
                                          fare['control_no'] == control_no &&
                                          fare['cardType'] != "mastercard" &&
                                          fare['cardType'] != "cash")
                                      .map<num>((fare) =>
                                          (fare['fare'] as num).toDouble() +
                                          (fare['baggage'] as num).toDouble() +
                                          (fare['additionalFare'] as num)
                                              .toInt())
                                      .fold(
                                          0.0, (prev, amount) => prev + amount);

                                  // int ticket_count_card = torTicket
                                  //     .where((item) =>
                                  //         item['cardType'] != 'mastercard' &&
                                  //         item['control_no'] == control_no)
                                  //     .length;
                                  // double cashReceived =
                                  //     fetchService.grandTotalCashReceived() -
                                  //         totalExpenses;
                                  // Initialize data for tor_no if not present in the map

                                  aggregatedData.putIfAbsent(torNo, () {
                                    int indexToUpdate = torMain.indexWhere(
                                        (map) => map['tor_no'] == torNo);
                                    print(
                                        'item tortriptest putIfAbsent: ${torTrip.length}');
                                    return {
                                      "coopId": "${coopData['_id']}",
                                      "UUID":
                                          "${torMain[indexToUpdate]['UUID']}",
                                      "device_id": item['device_id'],
                                      "control_no": item['control_no'],
                                      "tor_no": torNo,
                                      "date_of_trip": item['date_of_trip'],
                                      "bound":
                                          "${torMain[indexToUpdate]['bound']}",
                                      "bus_no":
                                          "${torMain[indexToUpdate]['bus_no']}",
                                      "route":
                                          "${torMain[indexToUpdate]['route']}",
                                      "route_code":
                                          "${torMain[indexToUpdate]['route_code']}",
                                      "emp_no_driver_1":
                                          "${torMain[indexToUpdate]['emp_no_driver_1']}",
                                      "emp_no_driver_2": "",
                                      "emp_no_conductor":
                                          "${torMain[indexToUpdate]['emp_no_conductor']}",
                                      "emp_name_driver_1":
                                          "${torMain[indexToUpdate]['emp_name_driver_1']}",
                                      "emp_name_driver_2": "",
                                      "emp_name_conductor":
                                          "${torMain[indexToUpdate]['emp_name_conductor']}",
                                      "eskirol_id_driver": "",
                                      "eskirol_id_conductor": "",
                                      "eskirol_name_driver": "",
                                      "eskirol_name_conductor": "",
                                      "no_of_trips": torMain[indexToUpdate]
                                          ['no_of_trips'],
                                      "toll_fees": totalToll,
                                      "parking_fee": totalParking,
                                      "diesel": totalDiesel,
                                      "diesel_no_of_liters":
                                          torMain[indexToUpdate]
                                              ['diesel_no_of_liters'],
                                      "callers_fee": totalCallersFee,
                                      "employee_benefits":
                                          totalEmployeeBenefits,
                                      "materials": totalMaterials,
                                      "representation": totalRepresentation,
                                      "others": totalOthers,
                                      "services": totalServices,
                                      "repair_maintenance": totalRepair,
                                      "total_expenses": totalExpenses,
                                      "ticket_revenue_atm":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_atm'],
                                      "ticket_count_atm": torMain[indexToUpdate]
                                          ['ticket_count_atm'],
                                      "ticket_revenue_atm_passenger":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_atm_passenger'],
                                      "ticket_revenue_atm_baggage":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_atm_baggage'],
                                      "ticket_count_atm_passenger":
                                          torMain[indexToUpdate]
                                              ['ticket_count_atm_passenger'],
                                      "ticket_count_atm_baggage":
                                          torMain[indexToUpdate]
                                              ['ticket_count_atm_baggage'],
                                      "ticket_revenue_reserved":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_reserved'],
                                      "ticket_count_reserved":
                                          torMain[indexToUpdate]
                                              ['ticket_count_reserved'],
                                      "ticket_revenue_card":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_card'],
                                      "ticket_count_card":
                                          torMain[indexToUpdate]
                                              ['ticket_count_card'],
                                      "ticket_revenue_charter":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_charter'],
                                      "ticket_count_charter":
                                          torMain[indexToUpdate]
                                              ['ticket_count_charter'],
                                      "passenger_revenue":
                                          torMain[indexToUpdate]
                                              ['passenger_revenue'],
                                      "baggage_revenue": torMain[indexToUpdate]
                                          ['baggage_revenue'],
                                      "gross_revenue": grossRevenue,
                                      "passenger_count": torMain[indexToUpdate]
                                          ['passenger_count'],
                                      "baggage_count": torMain[indexToUpdate]
                                          ['baggage_count'],
                                      "net_collections": netCollection,
                                      "temp_net_collections": netCollection,
                                      "total_cash_remitted":
                                          // fetchService.grandTotalBaggage() +
                                          charterRevenue +
                                              waybillRevenue +
                                              fetchService
                                                  .totalPrepaidPassengerRevenue(),
                                      "final_remittance": final_remittance,
                                      "final_cash_remitted": double.parse(
                                          finalCashRemittedController.text),
                                      "overage_shortage": 0,
                                      "tellers_id":
                                          "${widget.cashierData['empNo']}",
                                      "tellers_name":
                                          "${widget.cashierData['idName']}",
                                      "coding": isCoding ? "YES" : "NO",
                                      "cashReceived": torMain[indexToUpdate]
                                          ['cashReceived'],
                                      "total_top_up": torMain[indexToUpdate]
                                          ['total_top_up'],
                                      "cardSales": torMain[indexToUpdate]
                                          ['cardSales'],
                                      "remarks": "${remarksController.text}",
                                    };
                                  });
                                }
                                print(
                                    'item tortriptest after putIfAbsent: ${torTrip.length}');
                                for (int x = 0;
                                    x < aggregatedData.length;
                                    x++) {
                                  print(
                                      'aggregatedData $x: ${aggregatedData[x]}');
                                }
                                // for (var item in torTicket) {
                                //   String torNo = item['tor_no'] as String;

                                //   // Update aggregated data for the current tor_no
                                //   if (aggregatedData.containsKey(torNo)) {
                                //     aggregatedData[torNo]
                                //             ['ticket_revenue_atm'] +=
                                //         (item['subtotal'] ?? 0.0) +
                                //             (item['additionalFare'] ?? 0.0);
                                //     aggregatedData[torNo]['ticket_count_atm'] +=
                                //         1;
                                //     aggregatedData[torNo]
                                //             ['ticket_revenue_atm_passenger'] +=
                                //         (item['fare'] ?? 0.0) +
                                //             (item['additionalFare'] ?? 0.0);
                                //     aggregatedData[torNo]
                                //             ['ticket_revenue_atm_baggage'] +=
                                //         item['baggage'] ?? 0.0;
                                //     aggregatedData[torNo]
                                //             ['ticket_count_atm_passenger'] +=
                                //         (item['fare'] > 0) ? 1 : 0;
                                //     aggregatedData[torNo]
                                //             ['ticket_count_atm_baggage'] +=
                                //         (item['baggage'] > 0) ? 1 : 0;
                                //   }
                                // }

                                print(
                                    'finalcashpage aggregatedData: $aggregatedData');
                                double passengerRevenue = 0;
                                double passengerCount = 0;
                                double baggageRevenue = 0;
                                double baggageCount = 0;

                                for (int i = 0; i < listTorNo.length; i++) {
                                  print(
                                      'finalcashpage tor_no: ${listTorNo[i]}');

                                  // passenger revenue
                                  aggregatedData[listTorNo[i]]
                                          ['passenger_revenue'] +=
                                      puncherTicketRevenue;
                                  // baggage revenue
                                  passengerRevenue +=
                                      aggregatedData[listTorNo[i]]
                                          ['passenger_revenue'];

                                  aggregatedData[listTorNo[i]]
                                          ['baggage_revenue'] +=
                                      puncherBaggageRevenue + waybillrevenue;

                                  baggageRevenue += aggregatedData[listTorNo[i]]
                                      ['baggage_revenue'];

                                  // gross revenue
                                  aggregatedData[listTorNo[i]]
                                          ['ticket_revenue_waybill'] =
                                      waybillrevenue;
                                  aggregatedData[listTorNo[i]]
                                      ['ticket_count_waybill'] = waybillcount;

                                  // aggregatedData[listTorNo[i]]
                                  //         ['ticket_revenue_charter'] +=
                                  //     charterTicketRevenue;

                                  // aggregatedData[listTorNo[i]]
                                  //         ['ticket_count_charter'] +=
                                  //     charterTicketCount;

                                  // aggregatedData[listTorNo[i]]
                                  //         ['gross_revenue'] +=
                                  //     puncherTicketRevenue +
                                  //         puncherBaggageRevenue +
                                  //         waybillrevenue;

                                  // punch
                                  aggregatedData[listTorNo[i]]
                                          ['ticket_revenue_punch_passenger'] =
                                      puncherTicketRevenue;
                                  aggregatedData[listTorNo[i]]
                                          ['ticket_revenue_punch_baggage'] =
                                      puncherBaggageRevenue;

                                  aggregatedData[listTorNo[i]]
                                          ['ticket_count_punch_passenger'] =
                                      puncherTicketCount;

                                  aggregatedData[listTorNo[i]]
                                          ['ticket_count_punch_baggage'] =
                                      puncherBaggageCount;

                                  aggregatedData[listTorNo[i]]
                                          ['ticket_revenue_punch'] =
                                      puncherTicketRevenue +
                                          puncherBaggageRevenue;

                                  aggregatedData[listTorNo[i]]
                                          ['ticket_count_punch'] =
                                      puncherTicketCount + puncherBaggageCount;

                                  // net collections
                                  // aggregatedData[listTorNo[i]]
                                  //         ['net_collections'] =
                                  //     aggregatedData[listTorNo[i]]
                                  //             ['gross_revenue'] -
                                  //         totalExpenses;
                                  // netCollections = aggregatedData[listTorNo[i]]
                                  //     ['net_collections'];

                                  // cashrecevied
                                  aggregatedData[listTorNo[i]]
                                          ['cashReceived'] +=
                                      (puncherTicketRevenue +
                                              puncherBaggageRevenue) -
                                          totalExpenses;

                                  //  passenger count

                                  aggregatedData[listTorNo[i]]
                                      ['passenger_count'] += puncherTicketCount;

                                  passengerCount += aggregatedData[listTorNo[i]]
                                      ['passenger_count'];

                                  //  baggage count

                                  aggregatedData[listTorNo[i]]
                                          ['baggage_count'] +=
                                      puncherBaggageCount + waybillcount;

                                  baggageCount += aggregatedData[listTorNo[i]]
                                      ['baggage_count'];

                                  // final remittance
                                  // aggregatedData[listTorNo[i]]
                                  //         ['final_remittance'] =
                                  //     aggregatedData[listTorNo[i]]
                                  //             ['net_collections'] -
                                  //         (charterRevenue + waybillrevenue);
                                  // aggregatedData[listTorNo[i]]
                                  //     ['total_cash_remitted'] = cashRecieved;

                                  // overage shortage
                                  // aggregatedData[listTorNo[i]]
                                  //     ['overage_shortage'] = double.parse(
                                  //         finalCashRemittanceController.text) -
                                  //     aggregatedData[listTorNo[i]]
                                  //         ['final_remittance'];
                                  aggregatedData[listTorNo[i]]
                                          ['overage_shortage'] =
                                      double.parse(shortController.text);

                                  Map<String, dynamic> isUpdateTorMain =
                                      await httpRequestServices.updateTorMain(
                                          aggregatedData[listTorNo[i]]);

                                  String uuidRem =
                                      generatorService.generateUuid();
                                  String datenow =
                                      await basicservices.departedTime();

                                  if (aggregatedData[listTorNo[i]]
                                          ['ticket_revenue_charter'] >
                                      0) {
                                    String uuid =
                                        generatorService.generateUuid();
                                    bool isSend = false;
                                    while (!isSend) {
                                      Map<String, dynamic> isAddTorRemittance =
                                          await httpRequestServices
                                              .addTorRemittance({
                                        "fieldData": {
                                          "coopId": "${coopData['_id']}",
                                          "UUID": "$uuid",
                                          "device_id":
                                              "${aggregatedData[listTorNo[i]]['device_id']}",
                                          "control_no":
                                              "${aggregatedData[listTorNo[i]]['control_no']}",
                                          "tor_no": "${listTorNo[i]}",
                                          "date_of_trip":
                                              "${aggregatedData[listTorNo[i]]['date_of_trip']}",
                                          "bus_no":
                                              "${aggregatedData[listTorNo[i]]['bus_no']}",
                                          "route":
                                              "${aggregatedData[listTorNo[i]]['route']}",
                                          "route_code":
                                              "${aggregatedData[listTorNo[i]]['route_code']}",
                                          "bound":
                                              "${aggregatedData[listTorNo[i]]['bound']}",
                                          "trip_no":
                                              aggregatedData[listTorNo[i]]
                                                  ['no_of_trips'],
                                          "remittance_date": "$datenow",
                                          "remittance_time": "$datenow",
                                          "remittance_place":
                                              "${torTrip[torTrip.length - 1]['arrived_place']}",
                                          "remittance_amount": double.parse(
                                              aggregatedData[listTorNo[i]]
                                                      ['ticket_revenue_charter']
                                                  .toString()),
                                          "shortOver": 0,
                                          "remittance_type": "CHARTER",
                                          "ctr_no": "",
                                          "waybill_ticket_no": "",
                                          "cashier_emp_no":
                                              "${widget.cashierData['empNo']}",
                                          "cashier_emp_name":
                                              "${widget.cashierData['idName']}",
                                          "lat": "14.069637",
                                          "long": "120.632632",
                                          "timestamp": "$datenow",
                                        }
                                      });
                                      try {
                                        if (isAddTorRemittance['messages'][0]
                                                    ['code']
                                                .toString() ==
                                            '0') {
                                          isSend = true;
                                          break;
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  }

                                  if (baggageRevenue > 0) {
                                    bool isSend = false;
                                    String uuid =
                                        generatorService.generateUuid();
                                    while (!isSend) {
                                      Map<String, dynamic> isAddTorRemittance =
                                          await httpRequestServices
                                              .addTorRemittance({
                                        "fieldData": {
                                          "coopId": "${coopData['_id']}",
                                          "UUID": "$uuid",
                                          "device_id":
                                              "${aggregatedData[listTorNo[i]]['device_id']}",
                                          "control_no":
                                              "${aggregatedData[listTorNo[i]]['control_no']}",
                                          "tor_no": "${listTorNo[i]}",
                                          "date_of_trip":
                                              "${aggregatedData[listTorNo[i]]['date_of_trip']}",
                                          "bus_no":
                                              "${aggregatedData[listTorNo[i]]['bus_no']}",
                                          "route":
                                              "${aggregatedData[listTorNo[i]]['route']}",
                                          "route_code":
                                              "${aggregatedData[listTorNo[i]]['route_code']}",
                                          "bound":
                                              "${aggregatedData[listTorNo[i]]['bound']}",
                                          "trip_no":
                                              aggregatedData[listTorNo[i]]
                                                  ['no_of_trips'],
                                          "remittance_date": "$datenow",
                                          "remittance_time": "$datenow",
                                          "remittance_place":
                                              "${torTrip[torTrip.length - 1]['arrived_place']}",
                                          "remittance_amount":
                                              fetchService.grandTotalBaggage() +
                                                  puncherBaggageRevenue,
                                          "shortOver": 0,
                                          "remittance_type": "BAGGAGE",
                                          "ctr_no": "",
                                          "waybill_ticket_no": "",
                                          "cashier_emp_no":
                                              "${widget.cashierData['empNo']}",
                                          "cashier_emp_name":
                                              "${widget.cashierData['idName']}",
                                          "lat": "14.069637",
                                          "long": "120.632632",
                                          "timestamp": "$datenow",
                                        }
                                      });
                                      try {
                                        if (isAddTorRemittance['messages'][0]
                                                    ['code']
                                                .toString() ==
                                            '0') {
                                          isSend = true;
                                          break;
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  }

                                  if (waybillrevenue > 0) {
                                    bool isSend = false;
                                    String uuid =
                                        generatorService.generateUuid();
                                    while (!isSend) {
                                      Map<String, dynamic> isAddTorRemittance =
                                          await httpRequestServices
                                              .addTorRemittance({
                                        "fieldData": {
                                          "coopId": "${coopData['_id']}",
                                          "UUID": "$uuid",
                                          "device_id":
                                              "${aggregatedData[listTorNo[i]]['device_id']}",
                                          "control_no":
                                              "${aggregatedData[listTorNo[i]]['control_no']}",
                                          "tor_no": "${listTorNo[i]}",
                                          "date_of_trip":
                                              "${aggregatedData[listTorNo[i]]['date_of_trip']}",
                                          "bus_no":
                                              "${aggregatedData[listTorNo[i]]['bus_no']}",
                                          "route":
                                              "${aggregatedData[listTorNo[i]]['route']}",
                                          "route_code":
                                              "${aggregatedData[listTorNo[i]]['route_code']}",
                                          "bound":
                                              "${aggregatedData[listTorNo[i]]['bound']}",
                                          "trip_no":
                                              aggregatedData[listTorNo[i]]
                                                  ['no_of_trips'],
                                          "remittance_date": "$datenow",
                                          "remittance_time": "$datenow",
                                          "remittance_place":
                                              "${torTrip[torTrip.length - 1]['arrived_place']}",
                                          "remittance_amount": waybillrevenue,
                                          "shortOver": 0,
                                          "remittance_type": "CARGO",
                                          "ctr_no": "",
                                          "waybill_ticket_no": "",
                                          "cashier_emp_no":
                                              "${widget.cashierData['empNo']}",
                                          "cashier_emp_name":
                                              "${widget.cashierData['idName']}",
                                          "lat": "14.069637",
                                          "long": "120.632632",
                                          "timestamp": "$datenow",
                                        }
                                      });
                                      try {
                                        if (isAddTorRemittance['messages'][0]
                                                    ['code']
                                                .toString() ==
                                            '0') {
                                          isSend = true;
                                          break;
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  }

                                  if (prepaidPassengerRevenue > 0) {
                                    bool isSend = false;
                                    String uuid =
                                        generatorService.generateUuid();
                                    while (!isSend) {
                                      Map<String, dynamic> isAddTorRemittance =
                                          await httpRequestServices
                                              .addTorRemittance({
                                        "fieldData": {
                                          "coopId": "${coopData['_id']}",
                                          "UUID": "$uuid",
                                          "device_id":
                                              "${aggregatedData[listTorNo[i]]['device_id']}",
                                          "control_no":
                                              "${aggregatedData[listTorNo[i]]['control_no']}",
                                          "tor_no": "${listTorNo[i]}",
                                          "date_of_trip":
                                              "${aggregatedData[listTorNo[i]]['date_of_trip']}",
                                          "bus_no":
                                              "${aggregatedData[listTorNo[i]]['bus_no']}",
                                          "route":
                                              "${aggregatedData[listTorNo[i]]['route']}",
                                          "route_code":
                                              "${aggregatedData[listTorNo[i]]['route_code']}",
                                          "bound":
                                              "${aggregatedData[listTorNo[i]]['bound']}",
                                          "trip_no":
                                              aggregatedData[listTorNo[i]]
                                                  ['no_of_trips'],
                                          "remittance_date": "$datenow",
                                          "remittance_time": "$datenow",
                                          "remittance_place":
                                              "${torTrip[torTrip.length - 1]['arrived_place']}",
                                          "remittance_amount":
                                              prepaidPassengerRevenue,
                                          "shortOver": 0,
                                          "remittance_type": "PREPAID",
                                          "ctr_no": "",
                                          "waybill_ticket_no": "",
                                          "cashier_emp_no":
                                              "${widget.cashierData['empNo']}",
                                          "cashier_emp_name":
                                              "${widget.cashierData['idName']}",
                                          "lat": "14.069637",
                                          "long": "120.632632",
                                          "timestamp": "$datenow",
                                        }
                                      });
                                      try {
                                        if (isAddTorRemittance['messages'][0]
                                                    ['code']
                                                .toString() ==
                                            '0') {
                                          isSend = true;
                                          break;
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  }
                                  bool isRemittanceFinal = false;
                                  while (!isRemittanceFinal) {
                                    Map<String, dynamic> isAddTorRemittance =
                                        await httpRequestServices
                                            .addTorRemittance({
                                      "fieldData": {
                                        "coopId": "${coopData['_id']}",
                                        "UUID": "$uuidRem",
                                        "device_id":
                                            "${aggregatedData[listTorNo[i]]['device_id']}",
                                        "control_no":
                                            "${aggregatedData[listTorNo[i]]['control_no']}",
                                        "tor_no": "${listTorNo[i]}",
                                        "date_of_trip":
                                            "${aggregatedData[listTorNo[i]]['date_of_trip']}",
                                        "bus_no":
                                            "${aggregatedData[listTorNo[i]]['bus_no']}",
                                        "route":
                                            "${aggregatedData[listTorNo[i]]['route']}",
                                        "route_code":
                                            "${aggregatedData[listTorNo[i]]['route_code']}",
                                        "bound":
                                            "${aggregatedData[listTorNo[i]]['bound']}",
                                        "trip_no": aggregatedData[listTorNo[i]]
                                            ['no_of_trips'],
                                        "remittance_date": "$datenow",
                                        "remittance_time": "$datenow",
                                        "remittance_place":
                                            "${torTrip[torTrip.length - 1]['arrived_place']}",
                                        "remittance_amount": final_remittance -
                                            (fetchService.grandTotalBaggage() +
                                                puncherBaggageRevenue),
                                        "shortOver": 0,
                                        // double.parse(shortController.text),
                                        "remittance_type": "FINAL",
                                        "ctr_no": "",
                                        "waybill_ticket_no": "",
                                        "cashier_emp_no":
                                            "${widget.cashierData['empNo']}",
                                        "cashier_emp_name":
                                            "${widget.cashierData['idName']}",
                                        "lat": "14.069637",
                                        "long": "120.632632",
                                        "timestamp": "$datenow",
                                      }
                                    });
                                    try {
                                      if (isAddTorRemittance['messages'][0]
                                                  ['code']
                                              .toString() ==
                                          '0') {
                                        isRemittanceFinal = true;
                                        break;
                                      }
                                    } catch (e) {
                                      print(e);
                                    }
                                  }

                                  if (isUpdateTorMain['messages']['code']
                                          .toString() !=
                                      '0') {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        barrierDismissible: false,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "ERROR",
                                            text:
                                                "SLOW INTERNET CONNECTION, PLEASE TRY AGAIN"));
                                    return;
                                  }
                                  flag++;
                                }

                                if (flag == listTorNo.length) {
                                  bool isPrintDone = false;
                                  _showDialogPrinting(
                                      'PRINTING PLEASE WAIT...', false);

                                  if (sessionBox['coopId'].toString() ==
                                      '6597c6953bd1be740d90e7a3') {
                                    isPrintDone =
                                        await printService.printTripReportGATC(
                                            puncherTicketCount +
                                                puncherBaggageCount +
                                                passengerCount +
                                                waybillcount +
                                                baggageCount +
                                                charterTicketCount,
                                            grossRevenue,
                                            "${torMain[0]['bus_no']}");
                                  } else {
                                    isPrintDone = await printService.printTripReportFinal(
                                        "${torTrip.length}",
                                        "${torTrip[0]['tor_no']}",
                                        "$baggageRevenue",
                                        "$prepaidPassengerRevenue",
                                        // "${fetchService.totalPrepaidBaggageRevenue()}",
                                        "$puncherTicketRevenue",
                                        "$puncherTicketCount",
                                        "$puncherBaggageRevenue",
                                        "$puncherBaggageCount",
                                        "$passengerRevenue",
                                        "$passengerCount",
                                        "$waybillrevenue",
                                        "$waybillcount",
                                        "$baggageRevenue",
                                        "$baggageCount",
                                        "$charterRevenue",
                                        "$charterTicketCount",
                                        "${finalCashRemittedController.text}",
                                        "${shortController.text}",
                                        "$cashRecieved",
                                        "${fetchService.grandTotalCardSales()}",
                                        "${fetchService.grandTotalAddFare()}",
                                        "${fetchService.getTotalTopUpper()}",
                                        "${grossRevenue}",
                                        "$netCollection");
                                  }

                                  // if (isTripReport) {
                                  // isPrintDone = await printService.printTripReport(
                                  //     // '${torTrip[SESSION['currentTripIndex'] - 1]['tor_no']}',
                                  //     // '$vehicleNo',
                                  //     // '$conductorName',
                                  //     // '$driverName',
                                  //     // '$dispatcherName',
                                  //     '${widget.cashierData['firstName']} ${widget.cashierData['middleName'] != '' ? widget.cashierData['middleName'][0] : ''}. ${widget.cashierData['lastName']}',
                                  //     // regularCount,
                                  //     // totalDiscounted,
                                  //     // totalBaggage,
                                  //     // '${torTrip[SESSION['currentTripIndex'] - 1]['route']}',
                                  //     // torTicket.length,
                                  //     // totalPassengerAmount,
                                  //     torTrip,
                                  //     torTicket,
                                  //     prePaidPassenger,
                                  //     prePaidBaggage,
                                  //     double.parse(finalCashRemittanceController.text),
                                  //     double.parse(shortController.text),
                                  //     puncherTicketRevenue,
                                  //     puncherTicketCount,
                                  //     puncherBaggageRevenue,
                                  //     puncherBaggageCount,
                                  //     passengerRevenue,
                                  //     passengerCount,
                                  //     baggageRevenue,
                                  //     baggageCount,
                                  //     charterTicketRevenue,
                                  //     charterTicketCount);
                                  // } else {
                                  //   isPrintDone = printService.printTripSummary();
                                  // }
                                  const duration = Duration(
                                      seconds:
                                          3); // Adjust the duration as needed (3 seconds in this example).
                                  await Future.delayed(duration);
                                  if (isPrintDone) {
                                    // bool isUpdateClosing = true;
                                    String? isUpdateClosing =
                                        await hiveService.updateClosing(true);
                                    if (isUpdateClosing == null) {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SyncingMenuPage()));
                                    } else {
                                      Navigator.of(context).pop();
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.danger,
                                              title: "SOMETHING WENT WRONG",
                                              text: "$isUpdateClosing"));
                                      return;
                                    }
                                    // _showDialogPrinting(
                                    //     'Are you sure you would like to close\nthe transaction?',
                                    //     true);
                                  }
                                  // Navigator.pushReplacement(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => EndofDayPage(
                                  //               cashierData: widget.cashierData,
                                  //               finalRemitt: double.parse(
                                  //                   finalRemittanceController
                                  //                       .text),
                                  //               shortOver: double.parse(
                                  //                   shortController.text),
                                  //               puncherTR: double.parse(
                                  //                   puncherPassengerTicketRevenueController
                                  //                       .text),
                                  //               puncherTC: double.parse(
                                  //                   puncherPassengerTicketCountController
                                  //                       .text),
                                  //               puncherBR: double.parse(
                                  //                   puncherBaggageTicketRevenueController
                                  //                       .text),
                                  //               puncherBC: double.parse(
                                  //                   puncherBaggageTicketCountController
                                  //                       .text),
                                  //             )));
                                } else {
                                  print(
                                      'something went wrong in final cashpage');
                                }
                              } catch (e) {
                                print("final remit error: $e");
                                Navigator.of(context).pop();
                                ArtSweetAlert.show(
                                    context: context,
                                    barrierDismissible: false,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.danger,
                                        title: "ERROR",
                                        text: "INVALID INPUT"));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .primaryColor, // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                ' SAVE ',
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
            ),
          );
        });
  }

  void _showDialogPrinting(String title, bool isDismissible) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              // logic
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.22,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDismissible)
                        Image.asset(
                          'assets/warning.png',
                          width: 40,
                        ),
                      Text(
                        '$title',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isDismissible)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(
                                      0xFF00adee), // Background color of the button
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
                                    'NO',
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
                                  String? isUpdateClosing =
                                      await hiveService.updateClosing(true);
                                  if (isUpdateClosing == null) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SyncingMenuPage()));
                                  } else {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "SOMETHING WENT WRONG",
                                            text: "$isUpdateClosing"));
                                    return;
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(
                                      0xFF00adee), // Background color of the button
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
                                    ' YES ',
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
              ),
            ),
          );
        });
  }
}
