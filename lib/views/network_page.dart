import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wifi_scan/wifi_scan.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  List<WiFiAccessPoint> _accessPoints = [];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  String alertTitle = "";

  @override
  void initState() {
    super.initState();
    // _startScan();
    // _startListeningToScannedResults();
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _startScan() async {
    // check platform support and necessary requirements
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch (can) {
      case CanStartScan.yes:
        // start full scan async-ly
        final isScanning = await WiFiScan.instance.startScan();
        print("isScanning: $isScanning");
        //...
        break;
      case CanStartScan.failed:
        print("failed to start full scan");
        // failed to start full scan
        //...

        break;
      case CanStartScan.notSupported:
        print("wifi scanning not supported");
        // wifi scanning not supported

        _showDialog(
            "NOT SUPPORTED", "Wi-Fi scanning not supported in this device.");

        //...

        //_showDialog("Alert", "wifi scanning not supported in this device.");

        break;
      case CanStartScan.noLocationPermissionRequired:
        print("wifi scanning supported, but location permission required");
        // wifi scanning supported, but location permission required
        //...
        break;
      case CanStartScan.noLocationPermissionDenied:
        print("wifi scanning supported, but location permission denied");
        // wifi scanning supported, but location permission denied
        //...
        break;
      case CanStartScan.noLocationPermissionUpgradeAccuracy:
        print("wifi scanning supported, but location permission denied");
        // wifi scanning supported, but location permission denied
        //...
        break;
      case CanStartScan.noLocationServiceDisabled:
        print("wifi scanning supported, but location service disabled");
        // wifi scanning supported, but location service disabled
        //...
        break;
    }
  }

  void _getScannedResults() async {
    // check platform support and necessary requirements
    final can =
        await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    switch (can) {
      case CanGetScannedResults.yes:
        // get scanned results
        final accessPoints = await WiFiScan.instance.getScannedResults();
        print(accessPoints);
        // ...
        break;
      case CanGetScannedResults.notSupported:
        print("wifi scanning not supported");
        // wifi scanning not supported
        //...
        break;
      case CanGetScannedResults.noLocationPermissionRequired:
        print("wifi scanning supported, but location permission required");
        // wifi scanning supported, but location permission required
        //...
        break;
      case CanGetScannedResults.noLocationPermissionDenied:
        print("wifi scanning supported, but location permission denied");
        // wifi scanning supported, but location permission denied
        //...
        break;
      case CanGetScannedResults.noLocationPermissionUpgradeAccuracy:
        print("wifi scanning supported, but location permission denied");
        // wifi scanning supported, but location permission denied
        //...
        break;
      case CanGetScannedResults.noLocationServiceDisabled:
        print("wifi scanning supported, but location service disabled");
        // wifi scanning supported, but location service disabled
        //...
        break;
    }
  }

  void _startListeningToScannedResults() async {
    // check platform support and necessary requirements
    final can =
        await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    switch (can) {
      case CanGetScannedResults.yes:
        // listen to onScannedResultsAvailable stream
        subscription =
            WiFiScan.instance.onScannedResultsAvailable.listen((results) {
          // update accessPoints
          setState(() => _accessPoints = results);
        });
      case CanGetScannedResults.notSupported:
        print("wifi scanning not supported");
      // wifi scanning not supported
      case CanGetScannedResults.noLocationPermissionRequired:
        print("wifi scanning supported, but location permission required");
      case CanGetScannedResults.noLocationPermissionDenied:
        print("wifi scanning supported, but location permission denied");
      case CanGetScannedResults.noLocationPermissionUpgradeAccuracy:
        print("wifi scanning supported, but location permission denied");
      case CanGetScannedResults.noLocationServiceDisabled:
        // ...
        break;
      // ... handle other cases of CanGetScannedResults values
    }
  }

// make sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Network Page',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push("/sound");
            },
            icon: const Icon(
              Icons.next_plan_sharp,
              size: 40,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _accessPoints.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_accessPoints[index].ssid),
                      subtitle: Text(_accessPoints[index].bssid),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _startScan();
        },
        child: const Icon(Icons.reset_tv),
      ),
    );
  }
}
