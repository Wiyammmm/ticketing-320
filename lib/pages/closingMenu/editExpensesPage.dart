import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';

import 'package:dltb/pages/closingMenu/finalCashPage.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class EditExpensesPage extends StatefulWidget {
  const EditExpensesPage(
      {super.key,
      required this.control_no,
      required this.cashierData,
      required this.torNo});
  final String control_no;
  final cashierData;
  final String torNo;
  @override
  State<EditExpensesPage> createState() => _EditExpensesPageState();
}

class _EditExpensesPageState extends State<EditExpensesPage> {
  final _myBox = Hive.box('myBox');
  httprequestService httpRequestServices = httprequestService();
  GeneratorServices generatorServices = GeneratorServices();
  timeServices timeService = timeServices();
  TestPrinttt printService = TestPrinttt();
  HiveService hiveService = HiveService();

  fetchServices fetchService = fetchServices();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> expensesList = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> torTrip = [];
  Map<String, dynamic> session = {};
  TextEditingController expensesAmountController = TextEditingController();
  bool isFullTank = false;
  List<String> particularList = [
    'TOLL',
    'PARKING',
    // 'FUEL',
    'SERVICES',
    "CALLER'S FEE",
    "EMPLOYEE BENEFITS",
    "MATERIALS",
    "REPRESENTATION",
    'REPAIR',
    'FOOD'
  ];
  // fuel controller
  TextEditingController fuelStationController = TextEditingController();
  TextEditingController fuelLitersController = TextEditingController();
  TextEditingController fuelPricePerLiterController = TextEditingController();
  TextEditingController fuelAmountController = TextEditingController();

  // end fuel controller
  String selectedParticular = '';
  String control_no = '';
  String torNo = "";
  List<Map<String, dynamic>> vehicleNos = [];
  bool isOffline = false;
  void updateSelectedParticular(String newValue) {
    setState(() {
      selectedParticular = newValue;
    });
  }

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    expenses = _myBox.get('expenses');
    session = _myBox.get('SESSION');
    torTrip = _myBox.get('torTrip');
    control_no = widget.control_no;
    torNo = widget.torNo;
    expensesList =
        expenses.where((item) => item['control_no'] == control_no).toList();
    print('expenses list: $expensesList');
    vehicleNos =
        torTrip.where((map) => map['control_no'] == control_no).toList();
    print('vehicleNos: ${vehicleNos[0]['bus_no']}');
    print('vehicleNos plate number: ${vehicleNos[0]['plate_number']}');
  }

  @override
  void dispose() {
    fuelStationController.dispose();
    fuelLitersController.dispose();
    fuelPricePerLiterController.dispose();
    fuelAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child:
                Opacity(opacity: 0.5, child: Image.asset("assets/citybg.png")),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height + 20,
            decoration: BoxDecoration(color: Colors.transparent),
            child: SingleChildScrollView(
                child: Column(
              children: [
                appbar(),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Text(
                      "EXPENSES",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(20))),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text('PARTICULAR',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Text(
                                        'AMOUNT',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.41,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  itemCount: expensesList.length,
                                  itemBuilder: (context, index) {
                                    final expense = expensesList[index];
                                    bool lightbg = false;
                                    if (index % 2 == 1) {
                                      lightbg = true;
                                    }
                                    return GestureDetector(
                                      onLongPress: () {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type:
                                                    ArtSweetAlertType.question,
                                                title: "OPTION",
                                                text:
                                                    "CHOOSE IF EDIT OR DELETE",
                                                denyButtonText: "DELETE",
                                                confirmButtonText: 'EDIT',
                                                onConfirm: () {
                                                  Navigator.of(context).pop();
                                                  int indexToEdit =
                                                      expenses.indexOf(
                                                          expensesList[index]);
                                                  setState(() {
                                                    selectedParticular =
                                                        expensesList[index]
                                                            ['particular'];
                                                    expensesAmountController
                                                            .text =
                                                        "${expensesList[index]['amount']}";
                                                  });
                                                  _showAddModal(context, true,
                                                      indexToEdit);
                                                },
                                                onDeny: () {
                                                  Navigator.of(context).pop();
                                                  ArtSweetAlert.show(
                                                      context: context,
                                                      artDialogArgs:
                                                          ArtDialogArgs(
                                                              type:
                                                                  ArtSweetAlertType
                                                                      .warning,
                                                              title: "WARNING",
                                                              text:
                                                                  "ARE YOU SURE YOU WANT TO DELETE THIS?",
                                                              denyButtonText:
                                                                  "YES",
                                                              confirmButtonText:
                                                                  'NO',
                                                              onConfirm: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              onDeny: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                int indexToRemove =
                                                                    expenses.indexOf(
                                                                        expensesList[
                                                                            index]);
                                                                print(
                                                                    'indexToRemove: $indexToRemove');

                                                                expenses.removeAt(
                                                                    indexToRemove);
                                                                _myBox.put(
                                                                    'expenses',
                                                                    expenses);
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => EditExpensesPage(
                                                                              cashierData: widget.cashierData,
                                                                              control_no: widget.control_no,
                                                                              torNo: widget.torNo,
                                                                            )));
                                                              }));
                                                }));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: lightbg
                                              ? AppColors.primaryColor
                                              : Colors.white,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                        '${expense['particular'].toString().toUpperCase()}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: lightbg
                                                                ? Colors.white
                                                                : Color(
                                                                    0xff58595b),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  )),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '₱${double.parse(expense['amount'].toString()).toStringAsFixed(2)}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: lightbg
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff58595b),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed: () {
                              _showAddModal(context, false, 0);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .primaryColor, // Background color of the button

                              padding: EdgeInsets.symmetric(horizontal: 24.0),

                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 2, color: Colors.white),

                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: Text(
                              'ADD',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FinalCashPage(
                                              cashierData: widget.cashierData,
                                            )));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .primaryColor, // Background color of the button

                                padding: EdgeInsets.symmetric(horizontal: 24.0),

                                shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(width: 1, color: Colors.black),

                                  borderRadius: BorderRadius.circular(
                                      10.0), // Border radius
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'BACK',
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
                                if (expensesList.isNotEmpty) {
                                  printService.printExpenses(expensesList,
                                      "${vehicleNos[0]['bus_no']}:${vehicleNos[0]['plate_number']}");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .primaryColor, // Background color of the button

                                padding: EdgeInsets.symmetric(horizontal: 24.0),

                                shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(width: 1, color: Colors.black),

                                  borderRadius: BorderRadius.circular(
                                      10.0), // Border radius
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'PRINT',
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
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            )),
          ),
        ],
      )),
    );
  }

  void _showAddModal(BuildContext context, bool isEdit, int indexToEdit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Container(
                  height: selectedParticular == "FUEL"
                      ? MediaQuery.of(context).size.height * 0.7
                      : MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'EDIT EXPENSES' : 'ADD EXPENSES',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'SELECT',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: particularList.map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Center(
                                        child: Text(
                                          value.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  value: particularList
                                          .contains(selectedParticular)
                                      ? selectedParticular
                                      : null, // Use the selectedParticular value here
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        selectedParticular = value!;
                                        print(
                                            'selectedParticular: $selectedParticular');
                                      });
                                    }
                                  },
                                  // Rest of your dropdown styling properties...
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            selectedParticular == "FUEL"
                                ? SizedBox(
                                    height: isKeyboardOpen
                                        ? MediaQuery.of(context).size.height *
                                            0.2
                                        : MediaQuery.of(context).size.height *
                                            0.4,
                                    child: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    fuelStationController,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor),
                                                decoration: InputDecoration(
                                                    hintText: 'FUEL STATION',
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color: AppColors
                                                                .primaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    fuelLitersController,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor),
                                                decoration: InputDecoration(
                                                    hintText: 'FUEL LITERS',
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color: AppColors
                                                                .primaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    fuelPricePerLiterController,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor),
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'FUEL PRICE PER LITER',
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color: AppColors
                                                                .primaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    fuelAmountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor),
                                                decoration: InputDecoration(
                                                    hintText: 'Enter Amount',
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color: AppColors
                                                                .primaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Full Tank',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Checkbox(
                                                      activeColor:
                                                          Color.fromARGB(
                                                              255, 0, 80, 109),
                                                      value: isFullTank,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          isFullTank =
                                                              !isFullTank;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            // Container(
                                            //   decoration: BoxDecoration(
                                            //       border: Border.all(
                                            //           width: 1,
                                            //           color: AppColors.primaryColor),
                                            //       borderRadius:
                                            //           BorderRadius.circular(10)),
                                            //   child: DropdownButton<String>(
                                            //     isExpanded: true,
                                            //     hint: const Row(
                                            //       children: [
                                            //         SizedBox(width: 4),
                                            //         Expanded(
                                            //           child: Text(
                                            //             'FULL TANK',
                                            //             textAlign: TextAlign.center,
                                            //             style: TextStyle(
                                            //               fontSize: 14,
                                            //               fontWeight:
                                            //                   FontWeight.bold,
                                            //               color: AppColors.primaryColor,
                                            //             ),
                                            //             overflow:
                                            //                 TextOverflow.ellipsis,
                                            //           ),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //     value: selectedValue,
                                            //     onChanged: (newValue) {
                                            //       setState(() {
                                            //         selectedValue = newValue!;
                                            //       });
                                            //     },
                                            //     items: <String>['Yes', 'No']
                                            //         .map<DropdownMenuItem<String>>(
                                            //             (String value) {
                                            //       return DropdownMenuItem<String>(
                                            //         value: value,
                                            //         child: Center(
                                            //           child: Text(
                                            //             value.toUpperCase(),
                                            //             textAlign: TextAlign.center,
                                            //             style: const TextStyle(
                                            //               fontSize: 14,
                                            //               fontWeight:
                                            //                   FontWeight.bold,
                                            //               color: AppColors.primaryColor,
                                            //             ),
                                            //             overflow:
                                            //                 TextOverflow.ellipsis,
                                            //           ),
                                            //         ),
                                            //       );
                                            //     }).toList(),

                                            //   ),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: expensesAmountController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.primaryColor),
                                      decoration: InputDecoration(
                                          hintText: 'Enter Amount',
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color:
                                                      AppColors.primaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      onTap: () {
                                        expensesAmountController.text = "";
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              double particularAmount = 0.0;

                              if (isEdit) {
                                print("edit to");
                                expenses[indexToEdit]['particular'] =
                                    "$selectedParticular";
                                try {
                                  particularAmount = double.parse(
                                      expensesAmountController.text);
                                } catch (e) {
                                  print(e);
                                }
                                expenses[indexToEdit]['amount'] =
                                    particularAmount;
                                _myBox.put('expenses', expenses);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditExpensesPage(
                                              cashierData: widget.cashierData,
                                              control_no: widget.control_no,
                                              torNo: widget.torNo,
                                            )));

                                return;
                              }
                              if (selectedParticular == "FUEL") {
                                if (!_formKey.currentState!.validate()) {
                                  ArtSweetAlert.show(
                                      context: context,
                                      barrierDismissible: false,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.info,
                                          title: "INCOMPLETE",
                                          text: "PLEASE COMPLETE THE FORM"));
                                  return;
                                }
                                final coopData = fetchService.fetchCoopData();
                                final session = _myBox.get('SESSION');
                                String uuid = generatorServices.generateUuid();
                                // String controlNo =
                                //     torTrip[session['currentTripIndex']]
                                //         ['control_no'];
                                final currentTorTrip =
                                    torTrip[session['currentTripIndex']];
                                particularAmount =
                                    double.parse(fuelAmountController.text);
                                String dateOfTrip = timeService.dateofTrip2();
                                String dateTimeNow =
                                    timeService.departedTime2();

                                final myLocation = _myBox.get('myLocation');

                                Map<String, dynamic> requestBodyItemTorFuel = {
                                  "coopId": "${coopData['_id']}",
                                  "UUID": "$uuid",
                                  "device_id": "${session['serialNumber']}",
                                  "control_no":
                                      "${currentTorTrip['control_no']}",
                                  "tor_no": "${session['torNo']}",
                                  "date_of_trip": "$dateOfTrip",
                                  "bus_no": "${currentTorTrip['bus_no']}",
                                  "route": "${currentTorTrip['route']}",
                                  "route_code":
                                      "${currentTorTrip['route_code']}",
                                  "bound": "${currentTorTrip['bound']}",
                                  "trip_no": currentTorTrip['trip_no'],
                                  "refuel_date": "$dateTimeNow",
                                  "refuel_time": "$dateTimeNow",
                                  "fuel_station":
                                      "${fuelStationController.text}",
                                  "fuel_liters":
                                      double.parse(fuelLitersController.text),
                                  "fuel_amount":
                                      double.parse(fuelAmountController.text),
                                  "fuel_price_per_liter": double.parse(
                                      fuelPricePerLiterController.text),
                                  "fuel_attendant": "DESTREZA, ALAN C.",
                                  "full_tank": isFullTank ? "YES" : "NO",
                                  "timestamp": "$dateTimeNow",
                                  "lat": '${myLocation?['latitude'] ?? 0.00}',
                                  "long": '${myLocation?['longitude'] ?? 0.00}',
                                  "remarks": ""
                                };
                                Map<String, dynamic> addTorFuel =
                                    await httpRequestServices
                                        .addTorFuel(requestBodyItemTorFuel);
                                if (addTorFuel['messages'][0]['code']
                                        .toString() ==
                                    "0") {
                                  bool isAddedExpenses =
                                      await hiveService.addExpenses({
                                    'particular': selectedParticular,
                                    'amount': particularAmount,
                                    'tor_no': torNo,
                                    "control_no": control_no
                                  });
                                  hiveService.updatetorMainExpenses(
                                      selectedParticular,
                                      torNo,
                                      particularAmount);
                                } else if (addTorFuel['messages'][0]['code']
                                        .toString() ==
                                    "500") {
                                  await ArtSweetAlert.show(
                                      context: context,
                                      barrierDismissible: false,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.danger,
                                          showCancelBtn: true,
                                          cancelButtonText: 'NO',
                                          confirmButtonText: 'YES',
                                          title: "OFFLINE",
                                          onConfirm: () {
                                            Navigator.of(context).pop();
                                            isOffline = true;

                                            print('addOfflineFuel: $isOffline');
                                          },
                                          onDeny: () {
                                            print('deny');
                                            final offlineFuel =
                                                _myBox.get('offlineFuel');
                                            for (int i = 0;
                                                i < offlineFuel.length;
                                                i++) {
                                              print(
                                                  'offline fuel $i: ${offlineFuel[i]}');
                                            }
                                            Navigator.of(context).pop();
                                            return;
                                          },
                                          onCancel: () {
                                            final offlineFuel =
                                                _myBox.get('offlineFuel');
                                            for (int i = 0;
                                                i < offlineFuel.length;
                                                i++) {
                                              print(
                                                  'offline fuel $i: ${offlineFuel[i]}');
                                            }
                                          },
                                          text:
                                              "Are you sure you would like to use Offline mode?"));
                                } else {
                                  ArtSweetAlert.show(
                                      context: context,
                                      barrierDismissible: false,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.warning,
                                          title: "ERROR",
                                          text:
                                              "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));
                                }

                                if (isOffline) {
                                  bool isAddOfflineFuel = await hiveService
                                      .addOfflineFuel({
                                    "fieldData": requestBodyItemTorFuel
                                  });
                                  if (isAddOfflineFuel) {
                                  } else {
                                    hiveService.updatetorMainExpenses(
                                        selectedParticular,
                                        torNo,
                                        particularAmount);
                                    ArtSweetAlert.show(
                                        context: context,
                                        barrierDismissible: false,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.success,
                                            title: "SUCCESS",
                                            text:
                                                "Added Offline Successfully!"));
                                  }
                                }
                              } else {
                                if (expensesAmountController.text != '') {
                                  try {
                                    particularAmount = double.parse(
                                        expensesAmountController.text);
                                    bool isAddedExpenses =
                                        await hiveService.addExpenses({
                                      'particular': selectedParticular,
                                      'amount': particularAmount,
                                      'tor_no': torNo,
                                      "control_no": control_no
                                    });

                                    if (isAddedExpenses) {
                                      hiveService.updatetorMainExpenses(
                                          selectedParticular,
                                          torNo,
                                          particularAmount);
                                      Navigator.of(context).pop();
                                      ArtSweetAlert.show(
                                          context: context,
                                          barrierDismissible: false,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.success,
                                              title: "SUCCESS",
                                              text: "Added Successfully!"));
                                      _updatepage();
                                      // setState(() {
                                      //   expenses = _myBox.get('expenses');

                                      //   expensesList = expenses
                                      //       .where((item) =>
                                      //           item['control_no'] ==
                                      //           control_no)
                                      //       .toList();
                                      // });
                                      return;
                                    } else {
                                      Navigator.of(context).pop();
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.danger,
                                              title: "SOMETHING WENT  WRONG",
                                              text: "Please try again"));
                                    }
                                  } catch (e) {
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "INVALID",
                                            text: "PLEASE INPUT VALID AMOUNT"));
                                  }
                                } else {
                                  ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.danger,
                                          title: "MISSING",
                                          text: "Fill all the data first"));
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .primaryColor, // Background color of the button

                              padding: EdgeInsets.symmetric(horizontal: 24.0),

                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.black),

                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'SAVE',
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
                    ),
                  ),
                ));
          });
        });
      },
    );
  }

  void _updatepage() {
    setState(() {
      expensesList = _myBox.get('expenses');
      expensesList = expensesList
          .where((item) => item['control_no'] == control_no)
          .toList();
    });
  }
}
