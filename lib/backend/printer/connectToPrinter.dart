import 'package:get/get.dart';
import 'package:telpo_flutter_sdk/telpo_flutter_sdk.dart';

class PrinterController extends GetxController {
  // BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  var connected = false.obs;
  Future<bool> connectToPrinter() async {
    print('telpo connecting');
    final telpoFlutterChannel = TelpoFlutterChannel();
    final TelpoStatus status = await telpoFlutterChannel.checkStatus();
    if (status == TelpoStatus.ok) {
      connected.value = true;
    } else {
      connected.value = await telpoFlutterChannel.connect();
    }
    print('telpo connect: ${connected.value}');
    print('telpo status: $status');

    return connected.value;
  }

  void disconnectFromPrinter() {
    if (connected.value) {
      final telpoFlutterChannel = TelpoFlutterChannel();
      telpoFlutterChannel.disconnect();
      connected.value = false;
      connected.refresh();
    }
  }

  // Add a function for printing if needed
  void printReceipt() {
    // Your printing logic here
  }
}

// void main() async {
//   final printerController = PrinterController();
//   await printerController.connectToPrinter();

//   if (printerController._connected) {
//     // Use the printer for printing
//     printerController.printReceipt();
//   }

//   // Don't forget to disconnect when done
//   printerController.disconnectFromPrinter();
// }
