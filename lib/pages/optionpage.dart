import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/debugview.dart';
import 'package:dltb/pages/firstpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';
import 'package:hive/hive.dart';

// class OptionController extends GetxController {
//   var response = ''.obs;
// }

class OptionPage extends StatelessWidget {
  OptionPage({super.key});
  LoadingModal loadingModal = LoadingModal();

  // OptionController optionController = Get.put(OptionController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 60,
            child: MyButton(
                label: 'DEBUG VIEW',
                thisAction: () async {
                  loadingModal.showLoading(context);
                  Future.delayed(Duration(seconds: 2), () async {
                    String? initialization = await initializedData();
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                    if (initialization != null) {
                      print('debuggingResponse: $initialization');
                      ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.danger,
                              title: "ERROR",
                              text: initialization.toUpperCase()));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DebugViewPage()));
                    }
                  });
                },
                thisColor: Colors.redAccent),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 60,
            child: MyButton(
                label: 'TICKETING',
                thisAction: () async {
                  loadingModal.showLoading(context);
                  Future.delayed(Duration(seconds: 2), () async {
                    String? initialization = await initializedData();
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }

                    if (initialization != null) {
                      await offlineBackgroundFunction();
                      print('initialization error: $initialization');
                      ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.danger,
                              title: "ERROR",
                              text: initialization.toUpperCase()));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => FirstPage())));
                    }
                  });
                },
                thisColor: Colors.blueAccent),
          )
        ],
      )),
    );
  }

  Future<void> offlineBackgroundFunction() async {
    // DebugController debugController = Get.find();
    final _myBox = await Hive.box('myBox');
    final subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      httprequestService httprequestservice = httprequestService();
      // Got a new connectivity status!
      final offlineTicket = _myBox.get('offlineTicket');
      final offlineUpdateAdditionalFare =
          _myBox.get('offlineUpdateAdditionalFare');
      final offlineInspection = _myBox.get('offlinetorInspection');

      final offlinetorViolation = _myBox.get('offlinetorViolation');
      final offlinetorFuel = _myBox.get('offlineFuel');
      print('offlineInspection: $offlineInspection');
      print('offlinetorViolation: $offlinetorViolation');
      print('offlineUpdateAdditionalFare: $offlineUpdateAdditionalFare');
      // if (torTicket.isNotEmpty) {
      //   List<Map<String, dynamic>> offlineDataList =
      //       torTicket.where((data) => data['isOffline'] == true).toList();
      //   print('connection offlineDataList: $offlineDataList');
      // }

      print('connection result: $result');
      print('connection offlineTicket: $offlineTicket');
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        if (offlineTicket.isNotEmpty) {
          for (var item in List.from(offlineTicket)) {
            print('connection offlineTicket item: $item');
            item['isNegative'] = true;
            Map<String, dynamic> offlineTorTicket =
                await httprequestservice.torTicket(item);
            try {
              if (offlineTorTicket['messages']['code'].toString() == "0") {
                print("connection offlineTorTicket success");
                offlineTicket.remove(item);
              } else {
                print(
                    "connection offlineTicket failed ${offlineTorTicket['messages']['message']}");
              }
            } catch (e) {
              print('connection offlineTicket $e');
            }

            // if (offlineTicket.isEmpty) {
            //   return;
            // }
            // debugController.updateTickets();
          }
          _myBox.put('offlineTicket', offlineTicket);
        } else {
          // debugController.updateTickets();
        }

        if (offlineUpdateAdditionalFare.isNotEmpty) {
          for (var itemAdditionalFare
              in List.from(offlineUpdateAdditionalFare)) {
            print('connection offlineTicket item: $itemAdditionalFare');
            itemAdditionalFare['isNegative'] = true;

            Map<String, dynamic> offlineAdditionalFare =
                await httprequestservice.updateAdditionalFare(
                    itemAdditionalFare, true);
            try {
              if (offlineAdditionalFare['messages'][0]['code'].toString() ==
                  "0") {
                print("offlineUpdateAdditionalFare success");
                offlineUpdateAdditionalFare.remove(itemAdditionalFare);
              } else {
                print(
                    'offlineUpdateAdditionalFare ${offlineAdditionalFare['messages']['message']}');
                print("failed");
              }
            } catch (e) {
              print("offlineUpdateAdditionalFare error: $e");
            }

            // if (offlineUpdateAdditionalFare.isEmpty) {
            //   return;
            // }
          }
          _myBox.put(
              'offlineUpdateAdditionalFare', offlineUpdateAdditionalFare);
        }

        if (offlineInspection.isNotEmpty) {
          for (var item in List.from(offlineInspection)) {
            print('connection offlineInspection item: $item');
            Map<String, dynamic> resultofflineInspection =
                await httprequestservice.addInspection(item);
            try {
              if (resultofflineInspection['messages'][0]['code'].toString() ==
                  "0") {
                print("connection offlineInspection success");
                offlineInspection.remove(item);
              } else {
                print(
                    "connection offlineInspection failed ${resultofflineInspection['messages']['message']}");
              }
            } catch (e) {
              print('connection offlineInspection $e');
            }
            _myBox.put('offlinetorInspection', offlineInspection);
            // if (offlineInspection.isEmpty) {
            //   continue;
            // }
          }
        }

        if (offlinetorViolation.isNotEmpty) {
          for (var item in List.from(offlinetorViolation)) {
            print('connection offlinetorViolation item: $item');
            Map<String, dynamic> resultofflineViolation =
                await httprequestservice.addViolation(item);
            try {
              if (resultofflineViolation['messages'][0]['code'].toString() ==
                  "0") {
                print("connection offlinetorViolation success");
                offlinetorViolation.remove(item);
              } else {
                print(
                    "connection offlinetorViolation failed ${resultofflineViolation['messages']['message']}");
              }
            } catch (e) {
              print('connection offlinetorViolation $e');
            }

            // if (offlinetorViolation.isEmpty) {
            //   return;
            // }
          }
          _myBox.put('offlinetorViolation', offlinetorViolation);
        }
        if (offlinetorFuel.isNotEmpty) {
          for (var item in List.from(offlinetorFuel)) {
            print('connection offlinetorFuel item: $item');
            Map<String, dynamic> resultofflineFuel =
                await httprequestservice.addTorFuel(item);

            try {
              if (resultofflineFuel['messages'][0]['code'].toString() == "0") {
                print("connection offlinetorFuel success");
                print('connection offlinetorFuel: $resultofflineFuel');
                offlinetorFuel.remove(item);
              } else {
                print(
                    "connection offlinetorFuel failed ${resultofflineFuel['messages']['message']}");
              }
            } catch (e) {
              print('connection offlinetorFuel $e');
            }

            // if (offlinetorViolation.isEmpty) {
            //   return;
            // }
          }
          _myBox.put('offlineFuel', offlinetorFuel);
        } else {
          print('connection offlinetorFuel empty');
        }
      }
    });
  }

  Future<String?> initializedData() async {
    try {
      final _myBox = await Hive.box('myBox');

      // final SESSIONData = _myBox.get('SESSION');
      // print('Data in Hive box: $SESSIONData');
      // if (SESSIONData != null) {
      //   print('Data in Hive box: $SESSIONData');
      //   print('not null');
      // } else {
      String? checkAndInitializeBoxesResponse = await checkAndInitializeBoxes();
      if (checkAndInitializeBoxesResponse != null) {
        return checkAndInitializeBoxesResponse;
      }

      // BackgroundFetch.configure(
      //   BackgroundFetchConfig(
      //     minimumFetchInterval: 15, // Minimum interval in minutes
      //     stopOnTerminate: false,
      //     enableHeadless: true,
      //     startOnBoot: true,
      //     requiresBatteryNotLow: false,
      //     requiresCharging: false,
      //     requiresStorageNotLow: false,
      //   ),
      //   backgroundFetchHeadlessTask,
      // ).then((int status) {
      //   print('[BackgroundFetch] configure success: $status');
      // }).catchError((e) {
      //   print('[BackgroundFetch] configure ERROR: $e');
      // });
      // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
      // print('data length: ${_myBox.length}');
      // final storedData = _myBox.get('SESSION');
      // print('Data in Hive box: $storedData');
      // }

      // Call the function to create or replace the Hive table
    } catch (e) {
      print('initialization error $e');
      return 'initializedData error: $e';
    }
  }

  Future<String?> checkDebugging() async {
    try {
      final _myBox = await Hive.box('myBox');
      final filipaycardList = _myBox.get('filipayCardList') ?? [];

      if (filipaycardList.isEmpty || filipaycardList == null) {
        return 'NOT USE YET';
      }
    } catch (e) {
      return 'checkDebugging error: $e';
    }
  }

  Future<String?> checkAndInitializeBoxes() async {
    try {
      DeviceInfoService deviceInfoService = DeviceInfoService();

      String serialnumber = await deviceInfoService.getDeviceSerialNumber();

      final _myBox = await Hive.box('myBox');
      final torTrip = _myBox.get('torTrip') ?? [];
      final filipaycardList = _myBox.get('filipayCardList') ?? [];

      // print('torTrip: $torTrip');
      if (filipaycardList.isEmpty) {
        // if (session.isNotEmpty && !session['isAlreadyFetched']) {
        _myBox.put('torTrip', <Map<String, dynamic>>[]);
        _myBox.put('offlineTicket', <Map<String, dynamic>>[]);
        _myBox.put('offlineUpdateAdditionalFare', <Map<String, dynamic>>[]);
        _myBox.put('torTicket', <Map<String, dynamic>>[]);
        _myBox.put('prepaidTicket', <Map<String, dynamic>>[]);
        _myBox.put('prepaidBaggage', <Map<String, dynamic>>[]);
        _myBox.put('expenses', <Map<String, dynamic>>[]);
        _myBox.put('topUpList', <Map<String, dynamic>>[]);
        _myBox.put('torInspection', <Map<String, dynamic>>[]);
        _myBox.put('offlinetorInspection', <Map<String, dynamic>>[]);
        _myBox.put('offlinetorViolation', <Map<String, dynamic>>[]);
        _myBox.put('offlinetorTrouble', <Map<String, dynamic>>[]);
        _myBox.put('offlineFuel', <Map<String, dynamic>>[]);
        _myBox.put('torMain', <Map<String, dynamic>>[]);
        _myBox.put('vehicleList', <Map<String, dynamic>>[]);
        _myBox.put('vehicleListDB', <Map<String, dynamic>>[]);
        _myBox.put('fuel', <Map<String, dynamic>>[]);
        _myBox.put('filipayCardList', <Map<String, dynamic>>[]);

        _myBox.put('offlineDispatch', <Map<String, dynamic>>[]);
        _myBox.put('offlineUpdateTorTrip', <Map<String, dynamic>>[]);
        _myBox.put('offlineUpdateTorMain', <Map<String, dynamic>>[]);
        _myBox.put('offlineAddTorMain', <Map<String, dynamic>>[]);

        _myBox.put('torDispatch', {
          'driverEmpNo': "",
          'conductorEmpNo': "",
          'dispatcher1': '',
          'dispatcher2': '',
          'vehicleNo': '',
          'plate_number': '',
          'tor_no': '',
          'control_no': ''
        });
        _myBox.put('SESSION', {
          "currentStationIndex": 0,
          "selectedDestination": <String, dynamic>{},
          "tripType": "",
          "isClosed": false,
          "currentTripIndex": 0,
          "routeID": "",
          "serialNumber": serialnumber,
          "isViceVersa": false,
          "coopId": "",
          "torNo": "",
          "lastInspectorEmpNo": "",
          "isFix": false,
          'isAlreadyFetched': false,
          'reverseNum': 0,
          'inspectorKmPost': 0,
          'inspectorOnBoardPlace': "",
          'isAlreadyInsertTrip': false
        });
      } else {
        dynamic offlinetorViolationDynamic = _myBox.get('offlinetorViolation');
        dynamic offlinetorTroubleDynamic = _myBox.get('offlinetorTrouble');
        dynamic offlinetorFuelDynamic = _myBox.get('offlineFuel');
        dynamic fuelDynamic = _myBox.get('fuel');
        dynamic offlineUpdateAdditionalFareDynamic =
            _myBox.get('offlineUpdateAdditionalFare');
        dynamic torInspectionDynamic = _myBox.get('torInspection');
        dynamic offlinetorInspectionDynamic =
            _myBox.get('offlinetorInspection');
        dynamic topUpListDynamic = _myBox.get('topUpList');
        dynamic offlineTicketDynamic = _myBox.get('offlineTicket');
        dynamic prepaidBaggageDynamic = _myBox.get('prepaidBaggage');
        dynamic prepaidTicketDynamic = _myBox.get('prepaidTicket');
        dynamic stationListDynamic = _myBox.get('stationList');
        dynamic employeeListDynamic = _myBox.get('employeeList');
        dynamic cardListDynamic = _myBox.get('cardList');
        Map<dynamic, dynamic> sessionDynamic = _myBox.get('SESSION');
        dynamic torTripDynamic = _myBox.get('torTrip');
        dynamic torMainDynamic = _myBox.get('torMain');
        dynamic routeListDynamic = _myBox.get('routeList');
        dynamic filipayCardListDynamic = _myBox.get('filipayCardList');
        dynamic masterCardListDynamic = _myBox.get('masterCardList');
        dynamic coopDataDynamic = _myBox.get('coopData');
        dynamic torTicketDynamic = _myBox.get('torTicket');
        dynamic expensesDynamic = _myBox.get('expenses');
        dynamic torDispatchsDynamic = _myBox.get('torDispatch');
        dynamic vehicleListDynamic = _myBox.get('vehicleList');
        dynamic vehicleListDBDynamic = _myBox.get('vehicleListDB');

        dynamic offlineDispatchDynamic = _myBox.get('offlineDispatch');
        dynamic offlineUpdateTorTripDynamic = _myBox.get('offlineDispatch');
        dynamic offlineUpdateTorMainDynamic =
            _myBox.get('offlineUpdateTorMain');
        dynamic offlineAddTorMainDynamic = _myBox.get('offlineAddTorMain');

        List<Map<dynamic, dynamic>> offlinetorViolation =
            List<Map<dynamic, dynamic>>.from(
          offlinetorViolationDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> offlinetorTrouble =
            List<Map<dynamic, dynamic>>.from(
          offlinetorTroubleDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> offlinetorFuel =
            List<Map<dynamic, dynamic>>.from(
          offlinetorFuelDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> fuel = List<Map<dynamic, dynamic>>.from(
          fuelDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> offlineUpdateAdditionalFare =
            List<Map<dynamic, dynamic>>.from(
          offlineUpdateAdditionalFareDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> torInspection =
            List<Map<dynamic, dynamic>>.from(
          torInspectionDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> offlinetorInspection =
            List<Map<dynamic, dynamic>>.from(
          offlinetorInspectionDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> offlineTicket =
            List<Map<dynamic, dynamic>>.from(
          offlineTicketDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> topUpList =
            List<Map<dynamic, dynamic>>.from(
          topUpListDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> prepaidBaggage =
            List<Map<dynamic, dynamic>>.from(
          prepaidBaggageDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> prepaidTicket =
            List<Map<dynamic, dynamic>>.from(
          prepaidTicketDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> vehicleList =
            List<Map<dynamic, dynamic>>.from(
          vehicleListDynamic ?? [],
        );

        List<Map<dynamic, dynamic>> offlineDispatch =
            List<Map<dynamic, dynamic>>.from(
          offlineDispatchDynamic ?? [],
        );

        List<Map<dynamic, dynamic>> offlineUpdateTorMain =
            List<Map<dynamic, dynamic>>.from(
          offlineUpdateTorMainDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> offlineAddTorMain =
            List<Map<dynamic, dynamic>>.from(
          offlineAddTorMainDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> offlineUpdateTorTrip =
            List<Map<dynamic, dynamic>>.from(
          offlineUpdateTorTripDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> vehicleListDB = [];

        if (vehicleListDBDynamic != null && vehicleListDBDynamic.isNotEmpty) {
          try {
            vehicleListDB.add(Map.from(vehicleListDBDynamic));
          } catch (e) {
            print(e);
          }
        }
        List<Map<dynamic, dynamic>> expenses = List<Map<dynamic, dynamic>>.from(
          expensesDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> torTicket =
            List<Map<dynamic, dynamic>>.from(
          torTicketDynamic ?? [],
        );

        List<Map<dynamic, dynamic>> masterCardList =
            List<Map<dynamic, dynamic>>.from(
          masterCardListDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> filipayCardList =
            List<Map<dynamic, dynamic>>.from(
          filipayCardListDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> routeList =
            List<Map<dynamic, dynamic>>.from(
          routeListDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> torTrip = List<Map<dynamic, dynamic>>.from(
          torTripDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> torMain = List<Map<dynamic, dynamic>>.from(
          torMainDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> stationList =
            List<Map<dynamic, dynamic>>.from(
          stationListDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> employeeList =
            List<Map<dynamic, dynamic>>.from(
          employeeListDynamic ?? [],
        );
        List<Map<dynamic, dynamic>> cardList = List<Map<dynamic, dynamic>>.from(
          cardListDynamic ?? [],
        );
        Map<String, dynamic> coopData = convertMap(coopDataDynamic);
        Map<String, dynamic> torDispatch = convertMap(torDispatchsDynamic);
        offlinetorViolation = convertList(offlinetorViolation);
        offlinetorTrouble = convertList(offlinetorTrouble);
        offlinetorFuel = convertList(offlinetorFuel);
        fuel = convertList(fuel);
        offlineUpdateAdditionalFare = convertList(offlineUpdateAdditionalFare);
        offlinetorInspection = convertList(offlinetorInspection);
        torInspection = convertList(torInspection);
        topUpList = convertList(topUpList);
        offlineTicket = convertList(offlineTicket);
        prepaidBaggage = convertList(prepaidBaggage);
        prepaidTicket = convertList(prepaidTicket);
        vehicleList = convertList(vehicleList);
        vehicleListDB = convertList(vehicleListDB);
        torDispatch = convertMap(torDispatch);
        expenses = convertList(expenses);
        torTicket = convertList(torTicket);

        masterCardList = convertList(masterCardList);
        filipayCardList = convertList(filipayCardList);
        stationList = convertList(stationList);
        employeeList = convertList(employeeList);
        cardList = convertList(cardList);
        torTrip = convertList(torTrip);
        torMain = convertList(torMain);
        routeList = convertList(routeList);

        offlineDispatch = convertList(offlineDispatch);
        offlineUpdateTorTrip = convertList(offlineUpdateTorTrip);
        offlineUpdateTorMain = convertList(offlineUpdateTorMain);
        offlineAddTorMain = convertList(offlineAddTorMain);

        Map<String, dynamic> newession = convertMap(sessionDynamic);
        // print('cardList: $cardList');
        // print('stationList: $stationList');
        _myBox.put('offlinetorViolation', offlinetorViolation);
        _myBox.put('offlinetorTrouble', offlinetorTrouble);
        _myBox.put('offlineFuel', offlinetorFuel);
        _myBox.put('fuel', fuel);
        _myBox.put('offlineUpdateAdditionalFare', offlineUpdateAdditionalFare);
        _myBox.put('torInspection', torInspection);
        _myBox.put('offlinetorInspection', offlinetorInspection);
        _myBox.put('topUpList', topUpList);
        _myBox.put('offlineTicket', offlineTicket);
        _myBox.put('prepaidBaggage', prepaidBaggage);
        _myBox.put('prepaidTicket', prepaidTicket);
        _myBox.put('vehicleList', vehicleList);
        _myBox.put('vehicleListDB', vehicleListDB);
        _myBox.put('torDispatch', torDispatch);
        _myBox.put('expenses', expenses);
        _myBox.put('torTicket', torTicket);
        _myBox.put('coopData', coopData);
        _myBox.put('masterCardList', masterCardList);
        _myBox.put('filipayCardList', filipayCardList);
        _myBox.put('routeList', routeList);
        _myBox.put('torTrip', torTrip);
        _myBox.put('torMain', torMain);
        _myBox.put('stationList', stationList);
        _myBox.put('employeeList', employeeList);
        _myBox.put('cardList', cardList);
        _myBox.put('SESSION', newession);

        _myBox.put('offlineDispatch', offlineDispatch);
        _myBox.put('offlineUpdateTorTrip', offlineUpdateTorTrip);
        _myBox.put('offlineUpdateTorMain', offlineUpdateTorMain);
        _myBox.put('offlineAddTorMain', offlineAddTorMain);

        // print('torDispatch: $torDispatch');
        // print('torTrip is not empty');
        //
      }
    } catch (e) {
      print('checkAndInitializeBoxes error: $e');
      return 'checkAndInitializeBoxes error $e';
    }
  }

  List<Map<String, dynamic>> convertList(
      List<Map<dynamic, dynamic>> inputList) {
    return inputList.map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  Map<String, dynamic> convertMap(Map<dynamic, dynamic> inputMap) {
    Map<String, dynamic> outputMap = {};

    inputMap.forEach((key, value) {
      if (key is String) {
        outputMap[key] = value;
      } else {
        // Convert the key to a String if it's not already
        outputMap[key.toString()] = value;
      }
    });

    return outputMap;
  }
}

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key,
      required this.label,
      required this.thisAction,
      required this.thisColor});
  final String label;
  final VoidCallback thisAction;
  final Color thisColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(thisColor)),
        onPressed: thisAction,
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ));
  }
}
