import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:dltb/backend/printer/connectToPrinter.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/components/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PrinterPage extends StatelessWidget {
  PrinterController printerController = Get.put(PrinterController());

  TestPrinttt printService = TestPrinttt();

  PrinterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.secondaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Obx(() {
                  print(
                      'printerController.connected.value: ${printerController.connected.value}');
                  return Column(
                    children: [
                      const Text(
                        'PRINTER',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Status: '),
                          Text(
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: printerController.connected.value
                                      ? Colors.green
                                      : Colors.red),
                              '${printerController.connected.value ? 'Connected' : 'Disconnected'}'),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: printerController
                                        .connected.value
                                    ? MaterialStateProperty.all(Colors.green)
                                    : MaterialStateProperty.all(
                                        Colors.blueAccent)),
                            onPressed: () async {
                              await printerController.connectToPrinter();
                            },
                            child: Text(printerController.connected.value
                                ? 'Connected'
                                : 'Connect')),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                            onPressed: () async {
                              printService.sample();
                            },
                            child: Text('Test Print')),
                      ),
                    ],
                  );
                }),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors
                          .primaryColor, // Background color of the button
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Colors.black),
                        borderRadius:
                            BorderRadius.circular(10.0), // Border radius
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'BACK',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
