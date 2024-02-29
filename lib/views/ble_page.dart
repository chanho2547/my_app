import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

class BLEPage extends StatefulWidget {
  const BLEPage({super.key});

  @override
  State<BLEPage> createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  String _remoteId = '';
  String _advName = '';
  final List<String> _remoteIdList = [];
  final List<String> _advNameList = [];
  late ScanResult _r;

  @override
  void initState() {
    // TODO: implement initState

    BLESetting();
    BLEScanning();

    super.initState();
  }

  // BLE Setting
  void BLESetting() async {
    // first, check if bluetooth is supported by your hardware
// Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

// handle bluetooth on & off
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

// turn on bluetooth ourself if we can
// for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // cancel to prevent duplicate listeners
    subscription.cancel();
  }

  // BLE Scanning
  void BLEScanning() async {
    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning
    // Use: `scanResults` if you want live scan results *or* the results from a previous scan
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device

          setState(() {
            _remoteId = r.device.remoteId.toString();
            _advName = r.advertisementData.advName;
            _remoteIdList.add(_remoteId);
            _advNameList.add(_advName);
            _r = r;
          });
          print(
              '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
        }
      },
      onError: (e) => print("this is error of BLEScanning : " + e),
    );

// cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

// Wait for Bluetooth enabled & permission granted
// In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

// Start scanning w/ timeout
// Optional: you can use `stopScan()` as an alternative to using a timeout
// Note: scan filters use an *or* behavior. i.e. if you set `withServices` & `withNames`
//   we return all the advertisments that match any of the specified services *or* any
//   of the specified names.
    await FlutterBluePlus.startScan(
      // withServices: [Guid("180D")],
      // withNames: ["Bluno"],
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
    );

// wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    // Start scanning
  }

  void BLEConnect(remoteId, advName) {
    _r = ScanResult(
        device: _r.device,
        advertisementData: _r.advertisementData,
        rssi: _r.rssi,
        timeStamp: _r.timeStamp);
    _r.device.connect().then((device) {
      print('Connected to the device');
      // do something with the device
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    FlutterBluePlus.stopScan();
  }

  // build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'BLE Page',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  context.push("/network");
                },
                icon: const Icon(
                  Icons.next_plan_sharp,
                  size: 40,
                  color: Colors.black,
                ))
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: _remoteIdList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          print('remoteId: ${_remoteIdList[index]}');
                          print('advName: ${_advNameList[index]}');
                          _r = ScanResult(
                              device: _r.device,
                              advertisementData: _r.advertisementData,
                              rssi: _r.rssi,
                              timeStamp: _r.timeStamp);
                          BLEConnect(_remoteIdList[index], _advNameList[index]);
                        },
                        child: ListTile(
                          title: Text(_advNameList[index]),
                          subtitle: Text(_remoteIdList[index]),
                        ),
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
            setState(() {
              _remoteIdList.clear();
              _advNameList.clear();
            });
            BLEScanning();
          },
          child: const Icon(Icons.reset_tv),
        ));
  }
}
