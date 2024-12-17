import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';

import 'package:dltb/backend/nfcreader.dart';

import 'package:dltb/backend/printer/connectToPrinter.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/main.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/login.dart';
import 'package:dltb/pages/specialtrip.dart';
import 'package:dltb/pages/ticketingMenu/ticketingPage.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:hive/hive.dart';
import 'package:location/location.dart';

import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FirstPage extends StatefulWidget {
  FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final _myBox = Hive.box('myBox');
  DeviceInfoService deviceInfoService = DeviceInfoService();
  NFCReaderBackend backend = NFCReaderBackend();
  httprequestService httprequestServices = httprequestService();
  fetchServices fetchservice = fetchServices();
  EasyRefreshController _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  PrinterController connectToPrinter = Get.put(PrinterController());

  double progressbar = 0.5;
  String progressText = 'fetching data...';

  bool isFetch = true;

  bool isInvalid = false;
  bool isInvalidSimcard = false;
  String messagePrompt = "";
  var session;
  @override
  void initState() {
    super.initState();
    session = _myBox.get('SESSION');

    startLocationTracking();
    _checkData();
    // _fetchingdata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkData() async {
    await Future.delayed(Duration(seconds: 2));

    final filipaycardlist = _myBox.get('filipayCardList');
    print("filipaycardlist: $filipaycardlist");

    print('session: $session');

    if (filipaycardlist.isNotEmpty && filipaycardlist != null) {
      final coopData = fetchservice.fetchCoopData();
      String mobileNumber = await deviceInfoService.getMobileNumber();
      print('coopData: $coopData');

      if (coopData['coopType'] == 'Bus') {
        if (mobileNumber == "") {
          if (mounted) {
            setState(() {
              isFetch = false;
              messagePrompt = "REQUIRED SIM CARD";
              isInvalid = true;
              isInvalidSimcard = true;
            });
          }
          return;
        }
        if ("${session['mobileNumber']}" != mobileNumber) {
          if (mounted) {
            setState(() {
              isFetch = false;
              messagePrompt = "INVALID SIM CARD\nRe-fetch the data?";
              isInvalidSimcard = true;
            });
          }
          return;
        }
        if (mounted) {
          setState(() {
            isFetch = false;
            messagePrompt = "Do you want to\nre-fetch the data?";
          });
        }
        return;
      } else {
        if (mounted) {
          setState(() {
            isFetch = false;
            messagePrompt = "Do you want to\nre-fetch the data?";
          });
        }
        return;
      }
    } else {
      print('proceed to fetching');
      bool isDeviceValid = await httprequestServices.isDeviceValid();

      if (!isDeviceValid) {
        if (mounted) {
          setState(() {
            isFetch = false;
            messagePrompt = "INVALID DEVICE OR NO INTERNET CONNECTION";
            isInvalid = true;
          });
        }
      } else {
        _fetchingdata();
      }
    }
  }

  void _fetchingdata() async {
    final torTrip = _myBox.get('torTrip');
    // if (torTrip.isEmpty) {
    bool isfetchdata = await fetchservice.fetchdata();
    if (isfetchdata) {
      // startLocationTracking();
      _connectToPrinter();
    } else {
      ArtSweetAlert.show(
              context: context,
              barrierDismissible: false,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "SOMETHING WENT WRONG",
                  text: "CLICK OK TO FETCH DATA AGAIN"))
          .then((value) {
        _fetchingdata();
      });
    }
    // _connectToPrinter();
    // } else {
    //   _connectToPrinter();
    // }
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

  void _connectToPrinter() async {
    try {
      const duration = Duration(
          seconds:
              2); // Adjust the duration as needed (3 seconds in this example).
      await Future.delayed(duration);
      if (mounted)
        setState(() {
          progressText = 'Checking & Preparing Printer...';
        });
      final resultprinter = await connectToPrinter.connectToPrinter();

      if (resultprinter != null) {
        print('resultprinter: $resultprinter');
        if (resultprinter) {
          getSerialNumber();
        } else {
          ArtDialogResponse response = await ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "Can't connect to printer",
                  text: "Open Bluetooth to automatically connect"));
          print('response: $response');
          if (response.isTapConfirmButton) {
            _connectToPrinter();
          }
        }
      } else {
        ArtDialogResponse response = await ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Can't connect to printer",
                text: "Open Bluetooth to automatically connect"));
        print('else resultprinter: $resultprinter');
        print('response: $response');
        if (response.isTapConfirmButton) {
          _connectToPrinter();
        }
      }
      _refreshController.finishRefresh();
    } catch (e) {
      print(e);
    }
  }

  void getSerialNumber() async {
    _connectToPrinter();
    final torTrip = _myBox.get('torTrip');
    final SESSION = _myBox.get('SESSION');
    final coopData = fetchservice.fetchCoopData();
    const duration = Duration(
        seconds:
            2); // Adjust the duration as needed (3 seconds in this example).
    await Future.delayed(duration);
    if (mounted) {
      setState(() {
        progressText = 'Preparing NFC Reader...';
      });

      // final resultNFC = await backend.startNFCReader();

      setState(() {
        progressText = 'Checking GPS...';
      });
    }

    // try {
    //   Position position = await Geolocator.getCurrentPosition(
    //           desiredAccuracy: LocationAccuracy.high)
    //       .timeout(const Duration(seconds: 60));
    //   print('latitude: ${position.latitude}');
    //   print('longitude: ${position.longitude}');
    if (mounted) {
      setState(() {
        progressbar = 1;
      });
    }

    print('big session: $SESSION');
    String mobileNumber = await deviceInfoService.getMobileNumber();

    print('coopData: $coopData');

    if (coopData['coopType'].toString() == "Bus") {
      if (mobileNumber == "") {
        if (mounted) {
          setState(() {
            isFetch = false;
            messagePrompt = "REQUIRED SIM CARD";
            isInvalidSimcard = true;
            isInvalid = true;
          });
        }
        return;
      }
      if ("${SESSION['mobileNumber']}" != mobileNumber) {
        if (mounted) {
          setState(() {
            isFetch = false;
            messagePrompt = "INVALID SIM CARD\nRe-fetch the data?";
            isInvalidSimcard = true;
          });
        }
        return;
      }

      // if (mounted) {
      //   setState(() {
      //     isFetch = false;
      //     messagePrompt = "Do you want to\nre-fetch the data?";
      //   });
      // }
    }

    // await Future.delayed(
    //     const Duration(seconds: 1)); // Adjust the duration if needed
    if (torTrip.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } else {
      if ((SESSION['currentTripIndex'] + 1) == torTrip.length) {
        if (SESSION['tripType'] == "special") {
          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SpecialTripPage()));
          }
        } else {
          if (coopData['coopType'].toString() == "Bus") {
            if (mounted) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashboardPage()));
            }
          } else {
            if (mounted) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => TicketingPage()));
            }
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      }
    }

    // } catch (e) {
    //   print('Error getting location: $e');
    //   ArtSweetAlert.show(
    //           context: context,
    //           artDialogArgs: ArtDialogArgs(
    //               type: ArtSweetAlertType.danger,
    //               title: "ERROR",
    //               text: "Can't get GPS, restart the application..."))
    //       .then((value) {
    //     print('error gps');
    //     Navigator.pushReplacement(
    //         context, MaterialPageRoute(builder: (context) => LoginPage()));
    //     // SystemNavigator.pop();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press here, or return false to prevent it
        return false;
      },
      child: EasyRefresh(
        onRefresh: () async {
          _connectToPrinter();
        },
        controller: _refreshController,
        header: MaterialHeader(),
        child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$progressText',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    SimpleAnimationProgressBar(
                      height: 30,
                      width: 300,
                      backgroundColor: AppColors.secondaryColor,
                      foregrondColor: AppColors.primaryColor,
                      ratio: progressbar,
                      direction: Axis.horizontal,
                      curve: Curves.fastLinearToSlowEaseIn,
                      duration: const Duration(seconds: 5),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryColor,
                          offset: const Offset(
                            5.0,
                            5.0,
                          ),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              if (!isFetch)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$messagePrompt',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            if (!isInvalid)
                              Text(
                                'Note: if YES, it required an internet connection',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(
                              height: 20,
                            ),
                            if (!isInvalid)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (mounted)
                                        setState(() {
                                          progressbar = 1;
                                          isFetch = true;
                                        });
                                      getSerialNumber();
                                      // final torTrip = _myBox.get('torTrip');
                                      // final SESSION = _myBox.get('SESSION');

                                      // if (torTrip.isEmpty) {
                                      //   Navigator.pushReplacement(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //           builder: (context) => LoginPage()));
                                      // } else {
                                      //   if ((SESSION['currentTripIndex'] + 1) ==
                                      //       torTrip.length) {
                                      //     if (SESSION['tripType'] == "special") {
                                      //       Navigator.pushReplacement(
                                      //           context,
                                      //           MaterialPageRoute(
                                      //               builder: (context) =>
                                      //                   SpecialTripPage()));
                                      //     } else {
                                      //       Navigator.pushReplacement(
                                      //           context,
                                      //           MaterialPageRoute(
                                      //               builder: (context) =>
                                      //                   DashboardPage()));
                                      //     }
                                      //   } else {
                                      //     Navigator.pushReplacement(
                                      //         context,
                                      //         MaterialPageRoute(
                                      //             builder: (context) => LoginPage()));
                                      //   }
                                      // }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors
                                          .secondaryColor, // Background color of the button
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Border radius
                                      ),
                                    ),
                                    child: Text(
                                      'NO',
                                      style: TextStyle(
                                          color: AppColors.primaryColor),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (isInvalidSimcard) {
                                        await httprequestServices
                                            .isDeviceValid();
                                        if (mounted) {
                                          setState(() {
                                            isFetch = true;

                                            // _checkData();
                                            _fetchingdata();
                                          });
                                        }
                                      } else {
                                        if (mounted)
                                          setState(() {
                                            isFetch = true;
                                          });
                                        _fetchingdata();
                                      }
                                    },
                                    child: Text(
                                      'YES',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors
                                          .primaryColor, // Background color of the button
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Border radius
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            if (isInvalid)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyApp()));
                                    },
                                    child: Text(
                                      'OK',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors
                                          .primaryColor, // Background color of the button
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Border radius
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
