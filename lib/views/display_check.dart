import 'dart:async'; // Timer를 사용하기 위해 필요합니다.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DisplayCheck extends StatefulWidget {
  const DisplayCheck({super.key});

  @override
  State<DisplayCheck> createState() => _DisplayCheckState();
}

class _DisplayCheckState extends State<DisplayCheck> {
  final List<Color> _backgroundColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.lightBlue,
    Colors.purple,
    Colors.yellow,
  ];
  int _currentIndex = 0; // 현재 배경색 인덱스
  late Timer _timer; // 타이머 객체

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // 2초마다 호출되는 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        // 다음 배경색으로 업데이트
        if (_currentIndex < _backgroundColors.length - 1) {
          _currentIndex = (_currentIndex + 1);
        } else {
          dispose();
          context.push('/usb');
        }
      });
    });
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 타이머 취소
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColors[_currentIndex],
      // appBar: AppBar(
      //   title: const Text(
      //     'Display Check',
      //     style: TextStyle(
      //       fontSize: 30,
      //       fontWeight: FontWeight.normal,
      //       color: Colors.black,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           context.push('/usb');
      //         },
      //         icon: const Icon(
      //           Icons.next_plan_sharp,
      //           size: 40,
      //           color: Colors.black,
      //         ))
      //   ],
      // ),
      // 배경색을 _currentIndex에 따라 업데이트
    );
  }
}
