import 'package:flutter/material.dart';

class USBCheck extends StatefulWidget {
  const USBCheck({super.key});

  @override
  State<USBCheck> createState() => _USBCheckState();
}

class _USBCheckState extends State<USBCheck> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'USB Check',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
