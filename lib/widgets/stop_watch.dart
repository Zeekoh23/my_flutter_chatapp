import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopWatch extends StatelessWidget {
  StopWatch({Key? key, required this.stopWatchTimer, required this.isHours})
      : super(key: key);
  StopWatchTimer stopWatchTimer;
  bool isHours;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: stopWatchTimer.rawTime,
        initialData: stopWatchTimer.rawTime.value,
        builder: (ctx, snap) {
          final value = snap.data;
          final displayTime =
              StopWatchTimer.getDisplayTime(value!, hours: isHours);
          return Text(
            displayTime,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        });
  }
}
