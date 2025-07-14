
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const TimerBellApp());
}

class TimerBellApp extends StatelessWidget {
  const TimerBellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hourly Bell Timer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimerHomePage(),
    );
  }
}

class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> {
  bool isRunning = false;
  late Timer timer;
  int secondsPassed = 0;
  final AudioPlayer player = AudioPlayer();

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsPassed++;
      });
      final minutes = secondsPassed ~/ 60;
      if (secondsPassed % 3600 == 0) {
        // 每小時整點：播放對應次數鐘聲
        final hour = secondsPassed ~/ 3600;
        playHourBell(hour);
      } else if (secondsPassed % 1800 == 0) {
        // 每半小時
        playHalfHourBell();
      }
    });
  }

  void stopTimer() {
    timer.cancel();
    setState(() {
      isRunning = false;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('計時結束'),
        content: Text('總共經過了 ${formatTime(secondsPassed)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  void playHourBell(int count) async {
    for (int i = 0; i < count; i++) {
      await player.play(AssetSource('hour_bell.mp3'));
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }

  void playHalfHourBell() async {
    await player.play(AssetSource('half_hour_bell.mp3'));
  }

  String formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('鐘聲計時器')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('已過時間：${formatTime(secondsPassed)}',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!isRunning) {
                  setState(() {
                    isRunning = true;
                    secondsPassed = 0;
                  });
                  startTimer();
                } else {
                  stopTimer();
                }
              },
              child: Text(isRunning ? '停止' : '開始'),
            ),
          ],
        ),
      ),
    );
  }
}
