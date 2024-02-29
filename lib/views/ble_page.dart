import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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
  final flutterReactiveBle = FlutterReactiveBle();

  @override
  void initState() {
    // TODO: implement initState
    DiscoverBLE();
    super.initState();
  }

  // BLE 스캔
  void DiscoverBLE() {
    // 스캔 구독을 위한 변수 선언
    StreamSubscription? scanSubscription;

    // 디바이스 스캔 시작
    scanSubscription = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      // 스캔 결과 처리 로직
      print("디바이스 발견: $device");
      // 동일 디바이스가 다시 발견되면 리스트에 추가하지 않음
      if (!_remoteIdList.contains(device.id)) {
        setState(() {
          _remoteId = device.id;
          _advName =
              device.name ?? 'Unknown'; // device.name이 null일 수 있으므로 기본값 설정
          _remoteIdList.add(_remoteId);
          _advNameList.add(_advName);
        });
      }
    }, onError: (error) {
      // 에러 처리 로직
      print("스캔 중 에러 발생: $error");
    });

    // 7초 후에 스캔 자동 중지
    Future.delayed(const Duration(seconds: 7)).then((_) {
      if (scanSubscription != null) {
        scanSubscription!.cancel(); // 스캔 구독 취소
        scanSubscription = null;
        print("스캔 자동 중지됨");
      }
    });
  }

  // BLE 연결
  void BLEConnect(remoteId, advName) async {
    flutterReactiveBle
        .connectToDevice(
      id: remoteId,
      //servicesWithCharacteristicsToDiscover: {serviceId: [char1, char2]},
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) async {
      // Handle connection state updates
      print("connectionState : $connectionState");
      _showDialog("connected", "connected to $advName");

      // send data

      // 이미지 경로
      String imagePath = 'assets/images/image.png';
      // 특성 UUID와 특성 정의
      Uuid characteristicUuid = Uuid.parse(remoteId);
      QualifiedCharacteristic characteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse(remoteId),
          characteristicId: characteristicUuid,
          deviceId: advName);

      // 이미지 로딩
      Uint8List imageBytes = await loadImageBytesFromAssets(imagePath);

      // 이미지 전송
      sendImage(imageBytes, characteristicUuid, characteristic);
    }, onError: (Object error) {
      // Handle a possible error
      print("error : $error");
    });
  }

  // 이미지를 바이트 배열로 변환하는 함수
  // Future<Uint8List> loadImageBytes(String imagePath) async {
  //   File imageFile = File(imagePath);
  //   Uint8List imageBytes = await imageFile.readAsBytes();
  //   return imageBytes;
  // }

  Future<Uint8List> loadImageBytesFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return bytes;
  }

// 바이트 배열을 여러 패킷으로 나누어 전송하는 함수
  void sendImage(Uint8List imageBytes, Uuid characteristicUuid,
      QualifiedCharacteristic characteristic) async {
    const int maxPacketSize = 20; // 한 번에 전송할 수 있는 최대 바이트 수
    List<List<int>> packets = [];

    // 이미지 바이트 배열을 패킷으로 나누기
    for (int i = 0; i < imageBytes.length; i += maxPacketSize) {
      int end = (i + maxPacketSize < imageBytes.length)
          ? i + maxPacketSize
          : imageBytes.length;
      packets.add(imageBytes.sublist(i, end));
    }

    // 패킷 전송
    for (List<int> packet in packets) {
      try {
        await flutterReactiveBle
            .writeCharacteristicWithoutResponse(characteristic, value: packet);
      } on Exception catch (e) {
        // TODO
      }
      // 필요하다면 여기서 진행 상태를 업데이트
    }

    // 전송 완료 처리
    print("Image transmission completed");
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // FlutterBluePlus.stopScan();
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _remoteIdList.clear();
      //       _advNameList.clear();
      //     });
      //     DiscoverBLE();
      //   },
      //   child: const Icon(Icons.reset_tv),
      // ),
    );
  }
}
