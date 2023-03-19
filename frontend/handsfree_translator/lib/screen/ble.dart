import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothConnectScreen extends StatefulWidget {
  @override
  _BluetoothConnectScreenState createState() => _BluetoothConnectScreenState();
}

class _BluetoothConnectScreenState extends State<BluetoothConnectScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];

  void _startScan() {
    setState(() {
      devicesList.clear();
    });
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
  }

  void _stopScan() {
    flutterBlue.stopScan();
  }

  @override
  void initState() {
    super.initState();
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          setState(() {
            devicesList.add(result.device);
          });
        }
      }
    });

    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Devices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _startScan();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (BuildContext context, int index) {
          BluetoothDevice device = devicesList[index];
          return ListTile(
            title: Text(device.name == '' ? '(unknown device)' : device.name),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              child: const Text("Connect"),
              onPressed: () async {
                try {
                  await device.connect();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Connected to ${device.name}")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Failed to connect to ${device.name}")),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
