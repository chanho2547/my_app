import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final player = AudioPlayer();
  void soundPlay() async {
    await player.play(
        UrlSource('https://www2.cs.uic.edu/~i101/SoundFiles/StarWars3.wav'));
  }

  void pressNext() {
    dispose();
    context.push('/display');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SOUND Page',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
              onPressed: pressNext,
              icon: const Icon(
                Icons.next_plan_sharp,
                size: 40,
                color: Colors.black,
              ))
        ],
      ),
      body: SafeArea(
        child: Center(
          // make sound button
          child: ElevatedButton(
            onPressed: () {
              print("sound button pressed");
              soundPlay();

              //wait 10 seconds
              Future.delayed(const Duration(seconds: 10), () {
                pressNext();
              });
            },
            child: const Text(
              'Sound',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
