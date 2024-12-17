import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/pages/firstpage.dart';
import 'package:dltb/pages/optionpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart';

class DebugController extends GetxController {
  OptionPage optionPage = OptionPage();
  FirstPage firstPage = FirstPage();

  var isAllTransaction = true.obs;
  var totalAmount = 0.0.obs;
  var allticketList = [].obs; // Initialize an empty list as observable
  var offlineticketList = [].obs;

  // Lifecycle method where async initialization happens
  @override
  void onInit() async {
    super.onInit();

    // Open the Hive box
    final _myBox = await Hive.openBox('myBox');

    // Retrieve the 'offlineTicket' from Hive and assign it to ticketList
    var offlineTickets = _myBox.get('offlineTicket');
    var tickets = _myBox.get('torTicket');

    print('tickets: $tickets');

    offlineticketList.value = offlineTickets; // Make it observable
    allticketList.value = tickets;
    await startLocationTracking();
  }

  Future<void> startLocationTracking() async {
    final _myBox = await Hive.openBox('myBox');

    final coopData = _myBox.get('coopData');
    final session = _myBox.get('SESSION');

    bool isTicketProceed = false;
    bool isupdateAdditionalFare = false;
    bool isInspectionProceed = false;

    bool isofflineDispatchProceed = false;
    bool isofflineUpdateTorTripProceed = false;
    bool isofflineUpdateTorMainProceed = false;
    bool isofflineAddTorMainProceed = false;

    bool isChangedMobileNumber = false;
    httprequestService httpRequestServices = httprequestService();
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Enable background mode
    try {
      await location.enableBackgroundMode(enable: true);
      location.onLocationChanged.listen((LocationData newLocation) async {
        httprequestService httprequestservice = httprequestService();

        // Got a new connectivity status!
        final offlineTicket = _myBox.get('offlineTicket');
        final offlineUpdateAdditionalFare =
            _myBox.get('offlineUpdateAdditionalFare');
        final offlineInspection = _myBox.get('offlinetorInspection');
        final offlinetorViolation = _myBox.get('offlinetorViolation');
        final offlinetorFuel = _myBox.get('offlineFuel');

        // new offline
        final offlineDispatch = _myBox.get('offlineDispatch');
        final offlineUpdateTorTrip = _myBox.get('offlineUpdateTorTrip');
        final offlineUpdateTorMain = _myBox.get('offlineUpdateTorMain');
        final offlineAddTorMain = _myBox.get('offlineAddTorMain');

        print('offlineInspection: $offlineInspection');
        print('offlinetorViolation: $offlinetorViolation');
        print('offlineUpdateAdditionalFare: $offlineUpdateAdditionalFare');
        // if (torTicket.isNotEmpty) {
        //   List<Map<String, dynamic>> offlineDataList =
        //       torTicket.where((data) => data['isOffline'] == true).toList();
        //   print('connection offlineDataList: $offlineDataList');
        // }

// offline dispatching
        if (offlineDispatch.isNotEmpty) {
          print('not empty offlineDispatch: $offlineDispatch');
          if (!isofflineDispatchProceed) {
            for (var item in List.from(offlineDispatch)) {
              print('connection offlineDispatch item: $item');
              isofflineDispatchProceed = true;
              Map<String, dynamic> resultofflineDispatch =
                  await httprequestservice.torTrip(item);
              try {
                if (resultofflineDispatch['messages'][0]['code'].toString() ==
                    "0") {
                  isofflineDispatchProceed = false;
                  print("connection offlineDispatch success");
                  offlineDispatch.remove(item);
                } else {
                  isofflineDispatchProceed = false;
                  print(
                      "connection offlineDispatch failed ${resultofflineDispatch['messages']['message']}");
                }
              } catch (e) {
                isofflineDispatchProceed = false;
                print('connection offlineDispatch $e');
              }
              _myBox.put('offlineDispatch', offlineDispatch);
            }
          }
        } else {
          print('empty offlineDispatch: $offlineDispatch');
        }

        // offline update tortrip
        if (offlineUpdateTorTrip.isNotEmpty) {
          print('not empty offlineUpdateTorTrip: $offlineUpdateTorTrip');
          if (!isofflineUpdateTorTripProceed) {
            for (var item in List.from(offlineUpdateTorTrip)) {
              print('connection offlineUpdateTorTrip item: $item');
              isofflineUpdateTorTripProceed = true;
              Map<String, dynamic> resultofflineUpdateTorTrip =
                  await httprequestservice.torTrip(item);
              try {
                if (resultofflineUpdateTorTrip['messages'][0]['code']
                        .toString() ==
                    "0") {
                  isofflineUpdateTorTripProceed = false;
                  print("connection offlineUpdateTorTrip success");
                  offlineUpdateTorTrip.remove(item);
                } else {
                  isofflineUpdateTorTripProceed = false;
                  print(
                      "connection offlineUpdateTorTrip failed ${resultofflineUpdateTorTrip['messages']['message']}");
                }
              } catch (e) {
                isofflineUpdateTorTripProceed = false;
                print('connection offlineUpdateTorTrip $e');
              }
              _myBox.put('offlineUpdateTorTrip', offlineUpdateTorTrip);
            }
          }
        } else {
          print('empty offlineUpdateTorTrip: $offlineUpdateTorTrip');
        }
// offline update tormain
        if (offlineUpdateTorMain.isNotEmpty) {
          if (!isofflineUpdateTorMainProceed) {
            for (var item in List.from(offlineUpdateTorMain)) {
              print('connection offlineUpdateTorMain item: $item');
              isofflineUpdateTorMainProceed = true;
              Map<String, dynamic> resultofflineUpdateTorMain =
                  await httprequestservice.updateTorMain(item);
              try {
                if (resultofflineUpdateTorMain['messages']['code'].toString() ==
                    "0") {
                  isofflineUpdateTorMainProceed = false;
                  print("connection offlineUpdateTorMain success");
                  offlineUpdateTorMain.remove(item);
                } else {
                  isofflineUpdateTorMainProceed = false;
                  print(
                      "connection offlineUpdateTorMain failed ${resultofflineUpdateTorMain['messages']['message']}");
                }
              } catch (e) {
                isofflineUpdateTorMainProceed = false;
                print('connection offlineUpdateTorMain $e');
              }
              _myBox.put('offlineUpdateTorMain', offlineUpdateTorMain);
            }
          }
        }

// offline add tormain
        if (offlineAddTorMain.isNotEmpty) {
          if (!isofflineAddTorMainProceed) {
            for (var item in List.from(offlineAddTorMain)) {
              print('connection offlineUpdateTorMain item: $item');
              isofflineAddTorMainProceed = true;
              Map<String, dynamic> resultofflineAddTorMain =
                  await httprequestservice.addTorMain(item);
              try {
                if (resultofflineAddTorMain['messages'][0]['code'].toString() ==
                    "0") {
                  isofflineAddTorMainProceed = false;
                  print("connection offlineUpdateTorMain success");
                  offlineAddTorMain.remove(item);
                } else {
                  isofflineAddTorMainProceed = false;
                  print(
                      "connection offlineUpdateTorMain failed ${resultofflineAddTorMain['messages']['message']}");
                }
              } catch (e) {
                isofflineAddTorMainProceed = false;
                print('connection offlineUpdateTorMain $e');
              }
              _myBox.put('offlineAddTorMain', offlineAddTorMain);
            }
          }
        }
        if (offlineTicket.isNotEmpty) {
          if (!isTicketProceed) {
            for (var item in List.from(offlineTicket)) {
              print('connection offlineTicket item: $item');
              item['isNegative'] = true;
              isTicketProceed = true;
              Map<String, dynamic> offlineTorTicket =
                  await httprequestservice.torTicket(item);

              try {
                if (offlineTorTicket['messages']['code'].toString() == "0") {
                  print("connection offlineTorTicket success");
                  isTicketProceed = false;
                  offlineTicket.remove(item);
                } else {
                  isTicketProceed = false;
                  print(
                      "connection failed ${offlineTorTicket['messages']['message']}");
                }
              } catch (e) {
                isTicketProceed = false;
                print('connection $e');
              }
              updateTickets();
            }
            _myBox.put('offlineTicket', offlineTicket);
          }
        }

        if (offlineUpdateAdditionalFare.isNotEmpty) {
          if (!isupdateAdditionalFare) {
            for (var itemAdditionalFare
                in List.from(offlineUpdateAdditionalFare)) {
              print('connection offlineTicket item: $itemAdditionalFare');
              itemAdditionalFare['isNegative'] = true;
              isupdateAdditionalFare = true;
              Map<String, dynamic> offlineAdditionalFare =
                  await httprequestservice.updateAdditionalFare(
                      itemAdditionalFare, true);
              try {
                if (offlineAdditionalFare['messages'][0]['code'].toString() ==
                    "0") {
                  isupdateAdditionalFare = false;
                  print("offlineUpdateAdditionalFare success");
                  offlineUpdateAdditionalFare.remove(itemAdditionalFare);
                } else {
                  isupdateAdditionalFare = false;
                  print(
                      'offlineUpdateAdditionalFare ${offlineAdditionalFare['messages']['message']}');
                  print("failed");
                }
              } catch (e) {
                isupdateAdditionalFare = false;
                print("offlineUpdateAdditionalFare error: $e");
              }
            }
            _myBox.put(
                'offlineUpdateAdditionalFare', offlineUpdateAdditionalFare);
          }
        }

        if (offlineInspection.isNotEmpty) {
          if (!isInspectionProceed) {
            for (var item in List.from(offlineInspection)) {
              print('connection offlineInspection item: $item');
              isInspectionProceed = true;
              Map<String, dynamic> resultofflineInspection =
                  await httprequestservice.addInspection(item);
              try {
                if (resultofflineInspection['messages'][0]['code'].toString() ==
                    "0") {
                  isInspectionProceed = false;
                  print("connection offlineInspection success");
                  offlineInspection.remove(item);
                } else {
                  isInspectionProceed = false;
                  print(
                      "connection offlineInspection failed ${resultofflineInspection['messages']['message']}");
                }
              } catch (e) {
                isInspectionProceed = false;
                print('connection offlineInspection $e');
              }
              _myBox.put('offlinetorInspection', offlineInspection);
            }
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

        _myBox.put('myLocation', {
          "latitude": "${newLocation.latitude}",
          "longitude": "${newLocation.longitude}"
        });
        print(
            "Latitude: ${newLocation.latitude}, Longitude: ${newLocation.longitude}");
        // Perform actions based on location change.
        if (coopData != null) {
          Map<String, dynamic> updateLocation =
              await httpRequestServices.updateLocation({
            "coopId": "${coopData['_id']}",
            "latitude": newLocation.latitude,
            "longitude": newLocation.longitude,
            "deviceId": "${session['serialNumber']}"
          });
        }
      });
    } catch (e) {
      print('getting location error: $e');
      startLocationTracking();
    }
  }

  void updateTickets() async {
    print('updateTickets()');
    final _myBox = await Hive.openBox('myBox');

    // Retrieve the 'offlineTicket' from Hive and assign it to ticketList
    var offlineTickets = _myBox.get('offlineTicket');
    var tickets = _myBox.get('torTicket');

    print('tickets: $tickets');

    offlineticketList.value = offlineTickets; // Make it observable
    allticketList.value = tickets;
    offlineticketList.refresh();
    allticketList.refresh();
  }
}

class DebugViewPage extends StatelessWidget {
  DebugViewPage({super.key});

  DebugController debugController = Get.put(DebugController());
  timeServices timeservices = timeServices();
  TestPrinttt printService = TestPrinttt();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DEBUG VIEW'),
          centerTitle: true,
        ),
        floatingActionButton: Obx(() {
          return debugController.isAllTransaction.value
              ? FloatingActionButton(
                  child: const Text('Print'),
                  onPressed: () async {
                    if (debugController.allticketList.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No ticket'),
                            duration: Duration(seconds: 2)),
                      );
                      return;
                    }
                    var torMain;
                    try {
                      print(
                          'debugController.totalAmount.value: ${debugController.totalAmount.value}');
                      final _myBox = Hive.box('myBox');
                      torMain = _myBox.get('torMain');
                      bool isPrintDone = await printService.printTripReportGATC(
                          debugController.allticketList.length.toDouble(),
                          debugController.totalAmount.value,
                          "${torMain[0]['bus_no']}");
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('error: $e'),
                            duration: Duration(seconds: 2)),
                      );

                      return;
                    }
                  })
              : const SizedBox();
        }),
        body: Obx(() {
          bool isAllTransaction = debugController.isAllTransaction.value;
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      debugController.isAllTransaction.value = true;
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: isAllTransaction
                              ? Colors.blueAccent
                              : Color.fromARGB(255, 179, 201, 238)),
                      child: const Center(
                        child: Text(
                          'ALL TRANSACTION',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      debugController.isAllTransaction.value = false;
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: isAllTransaction
                              ? Color.fromARGB(255, 179, 201, 238)
                              : Colors.blueAccent),
                      child: const Center(
                        child: Text(
                          'UNSYNC DATA',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              Expanded(
                child: Obx(() {
                  final allTickets = debugController.allticketList;
                  final offlineTickets = debugController.offlineticketList;

                  // print('allTickets: $allTickets');
                  // print('offlineTickets: $offlineTickets');

                  return ListView.builder(
                      itemCount: debugController.isAllTransaction.value
                          ? allTickets.length
                          : offlineTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = debugController.isAllTransaction.value
                            ? allTickets[index]
                            : offlineTickets[index]['items'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              ListRow(
                                label: "Ticket No:",
                                value: '${ticket['ticket_no']}',
                              ),
                              ListRow(
                                label: "Date:",
                                value:
                                    '${timeservices.converterDate(ticket['created_on'].toString())}',
                              ),
                              ListRow(
                                label: "Origin:",
                                value: '${ticket['from_place']}',
                              ),
                              ListRow(
                                label: "Destination:",
                                value: '${ticket['to_place']}',
                              ),
                              ListRow(
                                label: "Amount:",
                                value: '${ticket['subtotal']}',
                              ),
                              Divider()
                            ],
                          ),
                        );
                      });
                }),
              ),
              Obx(() {
                double totalAmount = 0;
                if (debugController.isAllTransaction.value) {
                  debugController.allticketList.forEach((ticket) {
                    totalAmount +=
                        ticket['subtotal']; // Add each ticket's amount
                  });
                } else {
                  debugController.offlineticketList.forEach((ticket) {
                    totalAmount +=
                        ticket['items']['subtotal']; // Add each ticket's amount
                  });
                }
                debugController.totalAmount.value = totalAmount;

                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                  ),
                  child: Center(
                      child: Text(
                    'TOTAL AMOUNT: ₱$totalAmount',
                    style: TextStyle(color: Colors.white),
                  )),
                );
              })
            ],
          );
        }));
  }
}

class ListRow extends StatelessWidget {
  const ListRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    );
  }
}
