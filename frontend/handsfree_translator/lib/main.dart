import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  Future<void> askForPermissions() async {
    final status = await Permission.bluetooth.request();

    if (status.isGranted) {
      await Permission.location.request();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Bluetooth permission not granted'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void scanForDevices() async {
    await askForPermissions();

    await flutterBlue.startScan(timeout: const Duration(seconds: 4));

    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        print('${result.device.name} found! rssi: ${result.rssi}');
      }
    });

    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Scan Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: scanForDevices,
            child: const Text('Scan for Devices'),
          ),
        ),
      ),
    );
  }
}
