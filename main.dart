import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(BellTimerApp());

class BellTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bell Timer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BellTimerPage(),
    );
  }
}

class BellTimerPage extends StatefulWidget {
  @override
  _BellTimerPageState createState() => _BellTimerPageState();
}

class _BellTimerPageState extends State<BellTimerPage> {
  Timer? _hourTimer;
  Timer? _halfHourTimer;
  DateTime? _startTime;
  bool _running = false;
  int _hoursElapsed = 0;
  final AudioPlayer _player = AudioPlayer();

  void _toggleTimer() {
    if (_running) {
      _hourTimer?.cancel();
      _halfHourTimer?.cancel();
      final duration = DateTime.now().difference(_startTime!);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('計時結束'),
          content: Text('共經過：${duration.inHours} 小時 ${duration.inMinutes % 60} 分鐘'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('確定'))],
        ),
      );
    } else {
      _startTime = DateTime.now();
      _hoursElapsed = 0;

      _hourTimer = Timer.periodic(Duration(hours: 1), (timer) {
        _hoursElapsed++;
        for (int i = 0; i < _hoursElapsed; i++) {
          Future.delayed(Duration(milliseconds: i * 800), () => _playHourBell());
        }
      });

      _halfHourTimer = Timer.periodic(Duration(minutes: 30), (timer) {
        if (DateTime.now().difference(_startTime!).inMinutes % 60 != 0) {
          _playHalfHourBell();
        }
      });
    }

    setState(() {
      _running = !_running;
    });
  }

  Future<void> _playHourBell() async {
    await _player.play(AssetSource('assets/hour_bell.mp3'));
  }

  Future<void> _playHalfHourBell() async {
    await _player.play(AssetSource('assets/half_hour_bell.mp3'));
  }

  @override
  void dispose() {
    _hourTimer?.cancel();
    _halfHourTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('鐘聲計時器')),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleTimer,
          child: Text(_running ? '停止計時' : '開始計時'),
        ),
      ),
    );
  }
}